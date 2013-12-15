require 'rake'

namespace :db do
  def default_connection config
    ActiveRecord::Base.establish_connection config.merge('database' => nil)
  end

  def create_database config
    options = {:charset => 'utf8'}

    create_db = lambda do |config|
      default_connection config
      ActiveRecord::Base.connection.create_database config['database'], options
      ActiveRecord::Base.establish_connection config
    end

    begin
      create_db.call config
    rescue => sqlerr
      STDERR.puts sqlerr
      STDERR.puts "Couldn't create database for #{config.inspect}, charset: utf8"
      STDERR.puts "(if you set the charset manually, make sure you have a matching collation)" if config['charset']
    end
  end

  def dump_schema
    Rake::Task["db:schema:dump"].invoke if ActiveRecord::Base.schema_format == :ruby
  end

  task :environment do
    MIGRATIONS_DIR = ActiveRecord::Migrator.migrations_paths.first
  end

  task :configuration => :environment do
    @config = YAML.load(ERB.new(File.read('config/database.yml')).result)
  end

  task :configure_connection => :configuration do
    ActiveRecord::Base.establish_connection @config
  end

  desc 'Drops the database'
  task :drop => :configuration do
    default_connection @config
    ActiveRecord::Base.connection.drop_database @config['database']
  end

  desc 'Create the database from config/database.yml'
  task :create => :configure_connection do
    create_database @config
  end

  desc 'Migrate the database (options: VERSION=x, VERBOSE=false).'
  task :migrate => :configure_connection do
    ActiveRecord::Migration.verbose = true
    step = ENV['VERSION'] ? ENV['VERSION'].to_i : nil
    ActiveRecord::Migrator.migrate MIGRATIONS_DIR, step
    dump_schema
  end

  desc 'Rolls the schema back to the previous version (specify steps w/ STEP=n).'
  task :rollback => :configure_connection do
    step = ENV['STEP'] ? ENV['STEP'].to_i : 1
    ActiveRecord::Migrator.rollback MIGRATIONS_DIR, step
    dump_schema
  end

  desc "Retrieves the current schema version number"
  task :version => :configure_connection do
    puts "Current version: #{ActiveRecord::Migrator.current_version}"
  end

  desc "Retrieves the full list of foreign_keys that aren't indexed"
  task :fk_without_index => :configure_connection do
    c = ActiveRecord::Base.connection
    c.tables.collect do |t|
      columns = c.columns(t).collect(&:name).select {|x| x.ends_with?("_id" || x.ends_with("_type"))}
      indexed_columns = c.indexes(t).collect(&:columns).flatten.uniq
      unindexed = columns - indexed_columns
      unless unindexed.empty?
        puts "#{t}: #{unindexed.join(", ")}"
      end
    end
  end

  namespace :schema do
    task :environment do
      DUMP_FILE = ENV['DUMP_FILE'] || 'db/schema.rb'
    end

    desc "Dumps the database"
    task :dump => :environment do
      ActiveRecord::Migration.suppress_messages do
        out = File.new(DUMP_FILE, 'w')

        ActiveRecord::SchemaDumper.dump(ActiveRecord::Base.connection, out)

        out.close
      end
    end

    desc "Loads the database"
    task :load => :environment do
      load DUMP_FILE
    end
  end
end
