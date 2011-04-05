require 'bundler/setup'

class RPM::Spec::Rails < RPM::Spec
	include RPM

	def initialize(rpm_config, path)
		self.config = rpm_config
		self.path = path

		self.gemspec = nil
		self.version = '1.0'
		self.name = [config.name_prefix, rails_project_name].join
		self.summary = "Rails application"
		self.licenses = []
		self.homepage = nil
		self.dependencies = []
		self.development_dependencies = []
		self.runtime_dependencies = []
		self.description = "Rails application"
		self.arch = ::Config::CONFIG['arch']
	end

	private
	def dependency_list(deps)
		deps.collect do |dep|
			if dep.requirements.blank?
				"#{config.name_prefix}#{dep.name}"
			else
				"#{config.name_prefix}#{dep.name} #{reformat_requirement(dep.requirements)}"
			end
		end
	end

	def reformat_requirement(req)
		req.gsub(/\~\>/, '=')
	end
end
