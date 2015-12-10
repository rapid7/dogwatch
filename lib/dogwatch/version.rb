# nodoc
module DogWatch
  VERSION = IO.read(File.expand_path('../../../VERSION', __FILE__)) rescue '0.0.1'
  SUMMARY = 'A DSL to create DataDog Monitors'
  DESCRIPTION = IO.read(File.expand_path('../../../README.md', __FILE__)) rescue ''
end
