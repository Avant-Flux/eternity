require 'rake/testtask'
require 'rake/clean'

require './GameWindow'

Dir.chdir File.dirname(__FILE__)

task :clean_levels_dir do
	# Delete all XML files from levels directory
	Dir["./Levels/*"].each do |level_folder|
		Dir.entries(level_folder).each do |file|
			File.delete "#{File.join level_folder, file}" if File.extname(file) == ".xml"
		end
	end
end

task :default => :clean_levels_dir do
	GameWindow.new.show
end
