desc 'Alias for strings:generate'
task :doc => ['strings:generate']

desc 'Generate REFERENCE.md'
task :reference do
  sh 'puppet strings generate --format markdown'
end
