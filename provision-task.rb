class TaskParser
  def self.root(&block)
    t = TaskParser.new
    t.instance_eval &block
    t
  end

  def initialize(name: "")
    @_name = name
    @_do_if
    @_cmd
    @child_tasks = []
  end

  def task(*args, &block)
    t = TaskParser.new name: args[0]

    if block
      t.instance_eval &block
    end

    case args[0]
    when Symbol then
      @_name = args[0]
    when Condition then
      @_do_if = args[0]
    when TaskAlias then
      @_do_if = args[0].do_if
      @_cmd = Command.new args[0].cmd
    when String then
      @_cmd = Command.new ->{args[0]}
    when Proc then
      @_cmd = Command.new args[0]
    else
      raise "unexpected #{args[0]}"
    end
    # puts "#{t.inspect} is child of #{ self.inspect }"
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

def tasks(&block)
  builder = TaskParser.root &block
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

