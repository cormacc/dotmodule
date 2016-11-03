require 'thor'

module DotModule
  class CLI < Thor
    desc 'install', 'Install one or more modules'
    # option :modules, :type => :array
    def install(*modules)
      collection = DotModule::Collection.new(Dir.pwd)
      if modules.size.zero?
        modules = case ask("#{collection}\nNo module argument passed. Install (c)ore/(a)ll/(n)one? [n]:").downcase
                  when 'a'
                    collection.modules
                  when 'c'
                    collection.core_modules
                  else #none
                    []
                  end
      end
      collection.install_modules(modules)
    end

    desc 'info', 'List module collection details'
    def info
      collection = DotModule::Collection.new(Dir.pwd)
      puts collection
    end
  end
end
