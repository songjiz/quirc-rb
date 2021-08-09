# frozen_string_literal: true

require "bundler/gem_tasks"
require "rake/testtask"
require "fileutils"

Rake::TestTask.new(:test) do |t|
  t.libs << "test"
  t.libs << "lib"
  t.test_files = FileList["test/**/*_test.rb"]
end

require "rake/extensiontask"

task build: :compile

Rake::ExtensionTask.new("quirc") do |ext|
  ext.name    = "quirc"
  ext.lib_dir = "lib/quirc"
end

desc "git clone https://github.com/dlbeer/quirc.git"
task :clone do
  FileUtils.remove_dir("ext/src", true)
  FileUtils.remove_dir("tmp/quirc", true)
  FileUtils.mkdir("ext/src")
  system("git clone https://github.com/dlbeer/quirc.git tmp/quirc")
  FileUtils.copy_entry("tmp/quirc/lib", "ext/src/lib")
  FileUtils.copy_file("tmp/quirc/Makefile", "ext/src/Makefile")
end

task default: %i[clobber compile test]
