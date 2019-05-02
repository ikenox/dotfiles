require 'optparse'

class TaskBuilder
  def self.create_root(&block)
    t = TaskBuilder.new(name: :root, do_if: Condition.new {nil}, cmd: nil)
    t.instance_eval &block
    t
  end

  def initialize(name:, do_if:, cmd:)
    @name = name
    @do_if = do_if
    @cmd = cmd
    @child_tasks = []
  end

  def task(*args, &block)
    taskargs = args.dup

    if block
      taskargs.push(TaskArgParser::Wrapper.new(block))
    end
    result = TaskArgParser.parse taskargs
    t = TaskBuilder.new(name: result[:name], do_if: result[:do_if], cmd: result[:cmd])

    if block
      t.instance_eval &block
    end

    @child_tasks.push(t)
  end

  def parse
    Task.new(
        name: @name,
        do_if: @do_if,
        childs: @child_tasks.map {|t| t.parse},
        cmd: @cmd,
    )
  end
end

class TaskArgParser

  class Wrapper
    attr_accessor :block

    def initialize(block)
      @block = block
    end
  end

  def self.parse(args)
    dfa = {
        start: [Symbol, Condition, Wrapper, String, Proc, TaskAlias],
        Symbol => [Condition, Wrapper, String, Proc, TaskAlias],
        Condition => [Wrapper, String, Proc],
        Wrapper => [],
        String => [],
        Proc => [],
    }

    current = :start

    result = {
        name: nil,
        do_if: Condition.new {nil},
        cmd: nil,
        block: nil,
    }

    args.each do |arg|
      raise "syntax err" unless dfa[current].include? arg.class

      case arg
      when Symbol then
        result[:name] = arg
      when Condition then
        result[:do_if] = arg
      when Wrapper then
        result[:block] = arg.block
      when String then
        result[:cmd] = -> {arg}
      when Proc then
        result[:cmd] = arg
      when TaskAlias then
        result[:name] = arg.default_name unless result[:name]
        result[:cmd] = arg.cmd
        result[:do_if] = arg.do_if
      else
        raise "error"
      end

      current = arg.class
    end

    result
  end
end

class TaskExecutor
  def initialize(task, dry: false, level:0)
    @task = task
    @level = level
    @dry = dry
  end

  def execute()
    todo = @task.do_if.todo?
    print "    " * @level
    print "\e[48;5m[TASK]#{@task.name || "anonymous_task"}"

    case todo
    when nil then
      puts " -> \e[1mEXECUTE\e[0m"
    when false then
      puts " -> \e[1;34mSKIP\e[0m"
    when true then
      puts " -> \e[1;31mEXECUTE\e[0m"
    end
    return if todo == false

    c = @task.cmd_or_children
    case c
    when Proc then
      unless @dry
        cmd = c.call
        exec!(cmd)
      end
    when Array then
      c.each {|t| TaskExecutor.new(t, dry: @dry, level:@level+1).execute}
    else
      raise "unknown"
    end
  end
end

# ================================
# Task
# ================================

class Task
  attr_accessor :name, :do_if, :cmd, :child_tasks

  def initialize(name:, do_if:, cmd:, childs:)
    @name = name
    @do_if = do_if
    @cmd = cmd
    @child_tasks = childs
  end

  def get_child(names)
    arr = (@child_tasks || []).select {|t| t.name.to_s == names[0].to_s}
    if arr.length == 0
      return nil
    end
    child = arr[0]
    names.length == 1 ? child : child.get_child(names[1..-1])
  end

  def cmd_or_children
    @cmd || @child_tasks || raise("empty task")
  end
end

# ================================
# conditions
# ================================

#@return Condition
def if_err(command)
  Condition.new {!exec? command, silent: true}
end

#@return Condition
def if_not_exist(path)
  if_err "ls #{path}"
end

#@return Condition
def if_not_symlinked(origin, link)
  Condition.new do
    current_link = `readlink #{link}`.chomp
    (origin.start_with? "~", "/") ?
        File.expand_path(origin) != current_link # absolute symlink
        : origin != current_link # relative symlink
  end
end

def exec?(cmd, silent: false)
  puts "> #{cmd}" unless silent
  `#{cmd}`
  $? == 0
end

def exec!(cmd, silent: false)
  puts "> #{cmd}" unless silent
  res = `#{cmd}`
  if $? != 0
    raise 'execution error'
  end
  res
end

class Condition
  def initialize(&block)
    @_checker = block
  end

  def todo?
    @_checker.call
  end
end

class Command
  def initialize(block)
    @cmd = block
  end
end

# ================================
# task aliases
# ================================

class TaskAlias
  attr_accessor :default_name, :do_if, :cmd

  def initialize(*args)
    result = TaskArgParser.parse args
    @default_name = result[:name]
    @do_if = result[:do_if]
    @cmd = result[:cmd]
  end
end

def task_alias(*args)
  TaskAlias.new *args
end

# ================================
# entry point
# ================================

def main
  params = ARGV.getopts(nil, 'dry', "task:")
  # builder = TaskBuilder.create_root &method(:equil)

  builder = TaskBuilder.new(name: :root, do_if: Condition.new {nil}, cmd: nil)
  builder.instance_eval do
    method(:equil).call
  end

  executed_task = params["task"] ? params["task"].split('.').each {|t| t.to_sym} : [:default]

  executor = TaskExecutor.new(builder.parse.get_child(executed_task), dry: params["dry"])
  executor.execute

  puts ""
  puts "\e[2m[FINISHED]\e[0m"
end

main
