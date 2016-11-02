require 'thor'

module DotModule
  class CLI < Thor
    desc "install", "Install one or more modules"
    # option :modules, :type => :array
    def install(*modules)
      # DotModule::install_all
      if modules.size == 0
        puts ""
        DotModule::install_all if ask("No module argument passed. Install (a)ll/(n)one? [n]:") == 'a'
      else
        puts "Installing #{modules.size} modules..."
        modules.each do |m|
          begin
            DotModule::install(m)
          rescue ArgumentError
            puts "WARNING: Module '#{m}' not found"
            break unless ask("... (a)bort or (c)ontinue [a]: ") == 'c'
          end
        end
      end
    end
  end

end
