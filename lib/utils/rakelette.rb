module Raclette
  # class Rakelette is a wrapper around Rake
  # its only purpose is to generate Rake tasks in a readable way
  class Rakelette

    def self.register_scraper(klass, args, job)
      Rake.application.in_namespace "scrape" do
        Rake.application.in_namespace klass.to_s.downcase do
          task = Rake::Task.define_task({"with_#{args.first}" => :init_scraper_flags}, *args) do |t,args|
            scraper = klass.new
            args = Rakelette.hashify args
            args[:offset_counter] = 0
            args[:page_counter] = 0
            Scheduler.plan(&job.curry[scraper.agent, args])
          end
          task.add_description "Scrape #{klass} with #{args}"
        end
      end
    end

    def self.hashify(hashish)
      res = {}
      hashish.each {|k,v| res[k] = v}
      res
    end

    def Rakelette.load_general_tasks
      Rake::Task.define_task :init_scraper_flags do
        BaseOptions.load_global_options
      end
    end

    load_general_tasks
  end
end
