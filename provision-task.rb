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
        name: "",
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
  puts builder.parse.inspect
end

# ================================
# Task
# ================================

def task(*args, parent: nil)
  args.each do |arg|
    arg
  end
end

class Task
  def initialize(name:, do_if:, cmd:, childs:)
    @_name = name
    @_do_if = do_if
    @_cmd = cmd
    @_child_tasks = childs
  end

  def child_tasks()
  end
end

# ================================
# conditions
# ================================

#@return Condition
def if_err(command)
  Condition.new {system(command) === false}
end

#@return Condition
def if_not_exist(path)
  if_err "which #{path}"
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

class Condition
  def initialize(&block)
    @_checker = block
  end

  def check
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
  TaskAlias.new if_not_exist("which #{package}"), "brew install #{package}"
end

def brew_cask(package)
  TaskAlias.new if_not_exist("/usr/local/Caskroom/#{package}"), "brew cask install #{package}"
end

def mas(app_id)
  TaskAlias.new if_err("mas list | grep '^#{app_id} '"), "mas install #{app_id}"
end

def symlink(origin, link)
  TaskAlias.new if_not_symlinked(origin, link),
                "mkdir -p #{link.gsub(/[^\/]+\/?$/, '')}",
                "ln -si #{origin} #{link}"
end

class TaskAlias
  def initialize(*args)

  end

  def do_if

  end

  def cmd

  end
end

