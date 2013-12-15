namespace :generate do
  desc 'Generate a migration'
  task :migration, :name do |_, args|
    MIGRATIONS_DIR = ENV['MIGRATIONS_DIR'] || 'db/migrate'

    name = args[:name].parameterize.underscore
    file_name = File.join(MIGRATIONS_DIR, "#{Time.now.strftime '%Y%m%d%H%M%S'}_#{name}.rb")

    File.open file_name, 'w' do |f|
      f.write <<-MIGRATION
class #{name.camelize} < ActiveRecord::Migration
  def change
    
  end
end
      MIGRATION
    end

    puts "Generated migration #{file_name}"
  end
end
