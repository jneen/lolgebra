require 'rake'

ROOT = File.expand_path(File.dirname(__FILE__))

begin
  require 'spec/rake/spectask'
  Spec::Rake::SpecTask.new('spec') do |t|
    t.spec_files = FileList['spec/**/*_spec.rb']
    t.ruby_opts = ['-r init -r spec/helper']
  end
rescue LoadError
  #rspec is not required to use this lib
end

task :server do
  rackup = File.join(ROOT, 'config', 'rackup.ru')
  `thin -R #{rackup} start`
end
