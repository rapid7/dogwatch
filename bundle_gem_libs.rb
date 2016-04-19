# This script is to work round the problem of broken RubyMine dependencies for bundle files.
# It uses an undocumented feature for RubyMine (but available in Intellij Idea) to create a
# gems library xml file and update the iml file.
#
# See Rubymine issues:
# https://youtrack.jetbrains.com/issue/RUBY-16428
# https://youtrack.jetbrains.com/issue/RUBY-15026
# https://youtrack.jetbrains.com/issue/RUBY-14542
#
# Usage:
#  1) If you are installing gems into .bundle, remove .bundle from ignored files (Settings > Editor > Filetypes)
#  2) Add your gems location to excluded files (Settings > Project: Your Project > Project Structure)
#  3) From your project root run bundle exec ruby bundle_gem_libs.rb
#
# This script does 2 things:
# 1) Creates a file at .idea/libraries/gems.xml with entries for each currently loaded bundle gem
# 2) Adds a library line to your project iml file .idea/your_project.iml:
#    <orderEntry type="library" name="gems" level="project" />
#
# Timestamped backups of modified files are kept for each run
#
# Tested on RubyMine 7.1.1

require 'fileutils'
require 'pathname'

timestamp = Time.now.strftime('%m-%d_%H-%M-%S')

project_dir = Pathname.new(Dir.pwd)
idea_conf_dir = project_dir + '.idea'

raise "Unable to find #{idea_conf_dir}" unless Dir.exist?(idea_conf_dir)

libraries_dir = idea_conf_dir + 'libraries'
puts "Creating libraries directory: #{libraries_dir}"
FileUtils.mkdir_p libraries_dir

paths = Bundler.load.specs.to_a.map(&:full_gem_path).map do |full_gem_path|
  Pathname.new(full_gem_path).relative_path_from(project_dir)
end

# Do not add gem files outside of
paths = paths.reject do |path|
  exclude = (path.to_s == '.' || path.to_s.start_with?('..'))
  puts "Excluding gem #{path}" if exclude
  exclude
end

paths = paths.map do |path|
  %{<root url="file://$PROJECT_DIR$/#{path}" />}
end

gems_lib_file = libraries_dir + 'gems.xml'
puts "Creating #{gems_lib_file} with #{paths.size} gems:"

library_file_xml = <<-eos
<component name="libraryTable">
  <library name="gems">
    <CLASSES />
    <JAVADOC />
    <SOURCES>
#{paths.join("\n")}
    </SOURCES>
  </library>
</component>
eos

puts library_file_xml

if File.exists?(gems_lib_file)
  FileUtils.copy(gems_lib_file, "#{gems_lib_file}.#{timestamp}")
end

File.open(gems_lib_file, 'w') { |file| file.write(library_file_xml) }

iml_files = Dir.glob(idea_conf_dir + '*.iml')

raise "Expected singe iml file, found #{iml_files}" if iml_files.size != 1

iml_file = idea_conf_dir + iml_files.first

file = File.readlines(iml_file)
existing_line = file.find { |line| line =~ /\s+<orderEntry\s+type="library"\s+name="gems"/ }
if existing_line.nil?
  puts "Adding gems lib to #{iml_file}"

  FileUtils.copy(iml_file, "#{iml_file}.#{timestamp}")

  index = file.index { |line| line =~ /\s+<orderEntry\s+type="library"/ }

  raise 'Unable to find library order entry for gems lib insertion' if index.nil? || index.zero?

  file.insert(index-1, %{<orderEntry type="library" name="gems" level="project" />\n})
  File.write(iml_file, file.join)
else
  puts "Skipping adding gems lib to #{iml_file}, line already added #{existing_line}"
end
