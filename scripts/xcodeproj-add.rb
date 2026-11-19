#!/usr/bin/env ruby
# frozen_string_literal: true

# Adds files to MusicPlayer.xcodeproj without Xcode (e.g. on Linux or in CI).
#
# Usage: scripts/xcodeproj-add.rb <target> <file>...
#   e.g. scripts/xcodeproj-add.rb MusicPlayerTests MusicPlayerTests/Foo.swift
#
# Each file is placed in the group that mirrors its folder (groups are created
# as needed). .swift files go to the target's Sources phase; everything else
# goes to its Resources phase. Running it twice for the same file is a no-op.
#
# Requires the xcodeproj gem: gem install xcodeproj

require 'pathname'
require 'xcodeproj'

PBXGroup = Xcodeproj::Project::Object::PBXGroup

target_name, *files = ARGV
abort 'Usage: scripts/xcodeproj-add.rb <target> <file>...' if target_name.nil? || files.empty?

root = Pathname(__dir__).parent
project = Xcodeproj::Project.open(root.join('MusicPlayer.xcodeproj'))
target = project.targets.find { |t| t.name == target_name } ||
         abort("No target named #{target_name}. Targets: #{project.targets.map(&:name).join(', ')}")

# The deepest existing group whose folder contains `dir`.
def closest_group(project, dir)
  groups = project.objects.select { |o| o.instance_of?(PBXGroup) && o.path }
  groups.select { |g| dir == g.real_path || dir.to_s.start_with?("#{g.real_path}/") }
        .max_by { |g| g.real_path.to_s.length } || project.main_group
end

files.each do |file|
  path = Pathname(file).expand_path(root)
  abort "No such file: #{file}" unless path.file?

  group = closest_group(project, path.dirname)
  path.dirname.relative_path_from(group.real_path).each_filename do |component|
    next if component == '.'

    group = group.children.find { |c| c.instance_of?(PBXGroup) && c.path == component } ||
            group.new_group(component, component)
  end

  ref = group.files.find { |f| f.real_path == path } || group.new_reference(path.to_s)
  phase = path.extname == '.swift' ? target.source_build_phase : target.resources_build_phase
  phase.add_file_reference(ref, true)
  puts "#{target_name}: #{path.relative_path_from(root)}"
end

project.save
