def alias_task(name, old_name)
  t = Rake::Task[old_name]
  desc "alias for `rake #{old_name}`"
  task name, *t.arg_names do |_, args|
    # values_at is broken on Rake::TaskArguments
    args = t.arg_names.map { |a| args[a] }
    t.invoke(args)
  end
end


desc "Open an irb session preloaded with this project"
task :console do
  require 'irb'

  ARGV.clear
  IRB.start
end

alias_task :c, :console
