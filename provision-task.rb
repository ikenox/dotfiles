class TaskBuilder
  def self.root(&block)
    t = TaskBuilder.new(name: :root, do_if: Condition.new {false}, cmd: nil)
    t.instance_eval &block
    t
  end

  def initialize(name:, do_if:, cmd:)
    @_name = name
    @_do_if = do_if
    @_cmd = cmd
    @child_tasks = []
  end

  def task(*args, &block)
    if block
      args.push(TaskArgParser::Block.new(block))
    end
    result = TaskArgParser.parse args
    t = TaskBuilder.new(name: result[:name], do_if: result[:do_if], cmd: result[:cmd])

    if block
      t.instance_eval &block
    end

    @child_tasks.push(t)
  end

  def parse
    Task.new(
        name: @_name,
        do_if: @_do_if,
        childs: @child_tasks.map {|t| t.parse},
        cmd: @_cmd,
    )
  end
end

class TaskArgParser

  class Block
    def initialize(block)
      @block = block
    end

    def block
      @block
    end
  end

  def self.parse(args)
    dfa = {
        start: [Symbol, Condition, Block, String, Proc, TaskAlias],
        Symbol => [Condition, Block, String, Proc, TaskAlias],
        Condition => [Block, String, Proc],
        Block => [],
        String => [],
        Proc => [],
    }

    current = :start

    result = {
        name: nil,
        do_if: Condition.new {true},
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
      when Block then
        result[:block] = arg.block
      when String then
        result[:cmd] = -> {arg}
      when Proc then
        result[:cmd] = arg
      when TaskAlias then
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

def tasks(&block)
  builder = TaskBuilder.root &block
  TaskVisitor.new.visit builder.parse.get_child(:default)
end

class TaskVisitor
  def visit(task)
    todo = task.cond.todo?
    print "#{task.name || "(anonymous task)"} -> "
    puts todo ? 'EXEC' : 'SKIP'
    return unless todo

    c = task.cmd_or_children
    case c
    when Proc then
      cmd = c.call
      exec! cmd
    when Array then
      c.each {|t| visit(t)}
    else
      raise "unknown"
    end
  end
end

# ================================
# Task
# ================================

class Task
  def initialize(name:, do_if:, cmd:, childs:)
    @_name = name
    @_do_if = do_if
    @_cmd = cmd
    @_child_tasks = childs
  end

  def cond
    @_do_if
  end

  def name
    @_name
  end

  def get_child(name)
    arr = (@_child_tasks || []).select {|t| t.name == name}
    arr.length == 0 ? nil : arr[0]
  end

  def cmd_or_children
    @_cmd || @_child_tasks || raise("empty task")
  end
end

# ================================
# conditions
# ================================

#@return Condition
def if_err(command)
  Condition.new {!exec? command}
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

def exec?(cmd)
  puts "> #{cmd}"
  `#{cmd}`
  $? == 0
end

def exec!(cmd)
  puts "> #{cmd}"
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

def brew(package)
  TaskAlias.new if_err("which #{package} || /usr/local/Cellar/#{package}"), "brew install #{package}"
end

def brew_cask(package)
  TaskAlias.new if_not_exist("/usr/local/Caskroom/#{package}"), "brew cask install #{package}"
end

def mas(app_id)
  TaskAlias.new if_err("mas list | grep '^#{app_id} '"), "mas install #{app_id}"
end

def symlink(origin, link)
  # todo multicommand
  TaskAlias.new if_not_symlinked(origin, link), %(
                mkdir -p #{link.gsub(/[^\/]+\/?$/, '')}
                ln -si #{origin} #{link}
  )
end

class TaskAlias
  def initialize(*args)
    if args.length == 2
      @do_if = args[0]
      @cmd = args[1].class == Proc ? args[1] : -> {args[1]}
    elsif args.length == 1
      @cmd = args[0].class == Proc ? args[0] : -> {args[0]}
    else
      raise 'invalid arg'
    end
  end

  def do_if
    @do_if
  end

  def cmd
    @cmd
  end
end

