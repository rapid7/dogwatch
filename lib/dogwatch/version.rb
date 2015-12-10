# nodoc
module DogWatch
  VERSION = IO.read(File.expand_path('../../../VERSION', __FILE__)) rescue '0.0.1'
  SUMMARY = 'A DSL to create DataDog Monitors'
  DESCRIPTION = 'DogWatch provides a simple method for creating DataDog monitors in Ruby.'
end
