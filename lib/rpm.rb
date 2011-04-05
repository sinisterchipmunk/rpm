module RPM
	autoload :Builder, File.join(File.dirname(__FILE__), "rpm/builder")
	autoload :Config, File.join(File.dirname(__FILE__), "rpm/config")
	autoload :Spec, File.join(File.dirname(__FILE__), "rpm/spec")

	def rails?
		@__rails ||= defined?(Rails) ||
				File.exist?(File.expand_path("Gemfile", Dir.pwd)) && File.read(File.expand_path("Gemfile", Dir.pwd)) =~ /['"]rails['"]/
	end

	def rails_project_name
		if File.file?(file = File.expand_path("config/application.rb", Dir.pwd)) # rails3
			if File.read(file) =~ /^module ([a-zA-Z0-9]*)$/
				return $~[1]
			end
		end
		# rails2, or if we couldn't get project name from application.rb
		File.basename(File.expand_path(Dir.pwd))
	end
end
