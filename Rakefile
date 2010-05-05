require 'config/init.rb'

spec = Gem::Specification.new do |s|
  s.name = 'social_network_analyser'
  s.version = '0.1.2'
  s.has_rdoc = true
  s.extra_rdoc_files = ['README.markdown', 'LICENSE']
  s.summary = 'provides useful functions to analize social networks'
  s.description = s.summary
  s.author = 'Anna Leśniak'
  s.email = 'lesniakania@gmail.com'
  # s.executables = ['your_executable_here']
  s.files = %w(LICENSE README.markdown Rakefile) + Dir.glob("{bin,lib,spec}/**/*")
  s.require_path = "lib"
  s.bindir = "bin"
end

Rake::GemPackageTask.new(spec) do |p|
  p.gem_spec = spec
  p.need_tar = true
  p.need_zip = true
end

Rake::RDocTask.new do |rdoc|
  files =['README.markdown', 'LICENSE', 'lib/**/*.rb']
  rdoc.rdoc_files.add(files)
  rdoc.main = "README.markdown" # page to start on
  rdoc.title = "social_network_analyser Docs"
  rdoc.rdoc_dir = 'doc' # rdoc output folder
  rdoc.options << '--line-numbers'
end

Rake::TestTask.new do |t|
  t.test_files = FileList['test/**/*.rb']
end

Spec::Rake::SpecTask.new do |t|
  t.spec_files = FileList['spec/**/*.rb']
  t.libs << Dir["lib"]
end

desc "Task example"
task :example do
  puts "Hi, I'm Example."
end