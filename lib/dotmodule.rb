require 'dotmodule/version'
require 'dotmodule/cli'

require 'fileutils'
require 'pathname'
require 'yaml'

##
# Ruby wrapper for GNU stow, designed for modular dotfile maintenance
#
# It doesn't really do a huge amount.
# In addition to creating symlinks using stow, it allows a set of DOT_PATHS
# to be defined. These may exist in multiple modules and are created prior to
# installing any module if not already present.
#
# GNU Stow is already clever enough to manage this well, for the most part,
# however this gets around a corner case with paths also used by the system
# e.g. ~/.config...
# Given a module a containing a subdirectory .config/A
# On a clean system (with no existing ~/.config dir), installing just the i3
# module will create a symlink ~/.config -> ~/dotfiles/A/.config
# Installing another module B which contains .config/B will happily replace
# that symlink with a directory ~/.config containg two symlinks,
# ~/.config/A -> ~/dotfiles/A/.config/A
# ~/.config/B -> ~/dotfiles/B/.config/B
# If another application has created a directory in .config in the meantime,
# however, this directory will now.
#
# Short version -- it is only necessary to define paths as DOT_PATHs if they
# are likely to be written to by applications/scripts outside the dotmodule
# framework 
module DotModule

  ##
  # A collection of modules, with an optional YAML configuration file
  class Collection

    CONFIG_FILE_NAME = 'dotmodule.collection'.freeze
    attr_reader :root

    def initialize(root_path = Dir.pwd)
      @root = Pathname.new(root_path).expand_path
      raise ArgumentError, "Directory '#{@root}' not found" unless @root.directory?
      load_config
    end

    ##
    # Load the optional YAML configuration file
    # Currently, this supports a single array entry listing any folders shared with other applications / the system
    def load_config
      file = root+CONFIG_FILE_NAME
      @config = file.file? ? YAML.load_file(file) : { :shared_directories => nil, :core_modules => nil }
    end
    
    def modules
      @root.children.select(&:directory?).map(&:basename).map(&:to_s).reject {|d| d.start_with?('.')}
    end

    def shared_directories
      @config[:shared_directories]
    end

    def core_modules
      @config[:core_modules]
    end

    def default_target
      @root.parent
    end

    def create_shared_directories(target_root)
      shared_directories.each do |dir|
        abs_path = Pathname.new(target_root + dir).expand_path
        unless abs_path.directory?
          puts "Directory '#{abs_path}' not found, creating..."
          FileUtils.mkdir_p(abs_path)
        end
      end
    end

    def install_module(name, target=default_target)
      create_shared_directories(target)
      puts "... installing #{name} ..."
      raise ArgumentError, "Module '#{name}' not found" unless (@root+name).directory?

      system "stow -d #{@root} -t #{target} #{name}"
    end

    def install_modules(module_names, target=default_target)
      puts "Installing #{module_names.size} modules ..." unless modules.size.zero?
      module_names.each do |m|
        begin
          install_module(m)
        rescue ArgumentError
          puts "WARNING: Module '#{m}' not found"
          break unless ask('... (a)bort or (c)ontinue [a]: ') == 'c'
        end
      end
    end

    def install_all(target=default_target)
      install_modules(modules)
    end

    def to_s
      <<~HEREDOC

      Collection root:    #{@root}
      Default target:     #{default_target}

      Shared target subdirectories:
        #{shared_directories.join(', ')}

      Modules:
        #{modules.join(', ')}

      Core modules:
        #{core_modules.join(', ')}

      HEREDOC
    end
  end

end
