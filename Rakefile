require 'rake/testtask'

begin
  require 'jeweler'
  Jeweler::Tasks.new do |s|
    s.name = "deja-vu"
    s.description = s.summary = "A rack based session record / playback middleware for problemsolving web applications"
    s.email = "kuccello@gmail.com"
    s.homepage = "http://github.com/kuccello/deja-vu"
    s.authors = ['Kristan "Krispy" Uccello']
    s.files = FileList["[A-Z]*", "{lib,test,example,example-playback}/**/*"]
    s.version = "0.3"
  end
  Jeweler::GemcutterTasks.new
rescue LoadError
  puts "Jeweler not available. Install it with: sudo gem install technicalpickles-jeweler -s http://gems.github.com"
end

Rake::TestTask.new do |t|
  t.libs << "test"
  t.test_files = FileList['test/*-test.rb']
  t.verbose = true
end

require 'rake/rdoctask'
desc "Generate documentation"
Rake::RDocTask.new do |rd|
  rd.main = "README.rdoc"
  rd.rdoc_files.include("README.rdoc", "lib/**/*.rb")
  rd.rdoc_dir = 'rdoc'
end
