require_relative 'logger'

module Raclette
  # class Rakelette is a wrapper around Rake
  # its only purpose is to generate Rake tasks in a readable way
  class Rakelette

    def self.register_scraper(klass, args, job)
      Logger.debug self, "Register scraper #{name_without_namespace(klass)} with args #{args}"

      Rake.application.in_namespace "scrape" do
        Rake.application.in_namespace name_without_namespace(klass) do
          task = Rake::Task.define_task("with_#{args.first}", {args => [:init_scraper_flags]}) do |t,args|
            Logger.debug self, "Running taks #{t} with args #{args}"
            scraper = klass.new
            args = Rakelette.hashify args
            args[:offset_counter] = 0
            args[:page_counter] = 0
            Scheduler.plan(&job.curry[scraper, args])
          end
          task.add_description "Scrape #{klass} with #{args}"
        end
      end

      Rake::Task["scrape:#{name_without_namespace(klass)}:with_#{args.first}"].enhance do
        Logger.debug klass, 'END TASK, WAIT FOR SHUTDOWN...'
        Rake::Task[:shutdown_raclette].invoke
      end
    end

    def self.hashify(hashish)
      res = {}
      hashish.each {|k,v| res[k] = v}
      res
    end

    def Rakelette.load_general_tasks
      Logger.debug self,'Loading general tasks'

      Rake::Task.define_task :init_scraper_flags do
        Logger.debug self, 'Run flag detection'
        BaseOptions.load_global_options
      end

      Rake::Task.define_task :shutdown_raclette do
        Logger.debug self, 'Run shutdown...'
        sleep 1
        Scheduler.shutdown
        Logger.debug self, 'END Shutdown'
      end
    end

    load_general_tasks

    def self.name_without_namespace(klass)
      klass.to_s.downcase.sub(/^.+:/, '') # as + is eager, it will remove all namespaces
    end
  end
end
