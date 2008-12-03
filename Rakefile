require "spec/rake/spectask"

task :default => :spec

desc "Run all specs"
Spec::Rake::SpecTask.new("spec") do |task|
  task.spec_opts = ["--format", "specdoc", "--colour"]
  task.spec_files = ["spec/**/*_spec.rb"]
end
