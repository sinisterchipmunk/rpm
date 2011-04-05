require 'thor'
require 'thor/actions'

module RPM
	class CLI < Thor
		include Thor::Actions
		include RPM
		default_task :build
		
		desc 'install', "creates an 'rpm' directory and spec template"
		def install
			if rails?
				copy_file "rails.spec.erb", "rpm/application.spec.erb"
			else
				copy_file "gem.spec.erb", "rpm/application.spec.erb"
			end
		end

		desc 'build', "builds the RPM"
		def build
			RPM::Builder.new(File.expand_path("rpm/application.spec.erb", Dir.pwd)).build!
		end

		def self.source_root
			File.expand_path(File.join(File.dirname(__FILE__), "templates"))
		end
	end
end
