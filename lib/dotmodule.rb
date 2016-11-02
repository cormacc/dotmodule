require "dotmodule/version"
require "dotmodule/cli"

require 'fileutils'
require 'pathname'

module DotModule
  PROFILE_PATH = Pathname.new("~/.profile.d")
  BIN_PATH = Pathname.new("~/bin")
  ZGEN_AUTOLOADS = Pathname.new("~/.zgen.d")
  ZSH_AUTOLOADS = Pathname.new("~/.zshrc.d")
  DOT_PATHS = [PROFILE_PATH, BIN_PATH, ZGEN_AUTOLOADS, ZSH_AUTOLOADS]
  def self.create_paths
    DOT_PATHS.each do |path|
      abs_path = path.expand_path
      if !abs_path.directory?
        puts "Directory '#{abs_path}' not found, creating..."
        FileUtils.mkdir_p(abs_path)
      end
    end
  end

  def self.install(name)
    self.create_paths

    raise ArgumentError, "Module '#{name}' not found" unless File.directory?(name)

    puts "... installing #{name} ..."
    system "stow #{name}"

    #TODO: Source any additions to .profile.d for the current session
    #TODO: Touch .zsh...whatever to ensure zgen regenerates init cache
  end

  def self.install_all
    modules = Dir.glob('*').select { |f| File.directory? f}
    puts "Installing #{modules.size} modules from current directory..."
    modules.each { |m| install m}
  end

end
