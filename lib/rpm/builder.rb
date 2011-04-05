require 'fileutils'
require 'tmpdir'

module RPM
	class Builder
		include FileUtils
		include RPM

		attr_reader :config

		def initialize(spec_path)
			if !File.exist?(spec_path)
				raise "Could not find spec template #{spec_path}! Did you `ruby-rpm install` first?"
			end

			@spec_path = spec_path
			@config = RPM::Config.new
		end

		def build!
			build_dir = File.expand_path(config.build_dir, config.base_path)
			rm_rf build_dir
			spec = new_spec
			spec_contents = spec.generate
			spec_file_name = File.expand_path("application.spec", config.base_path)
			File.open(spec_file_name, 'w') { |f| f.puts spec_contents }

			name, version = spec.name, spec.version
			archive_dir = File.join(build_dir, "#{name}-#{version}")
			mkdir_p archive_dir
			%w(BUILD RPMS SOURCES SPECS SRPMS).each do |d|
				mkdir_p File.join(build_dir, d)
			end
			mkdir_p File.join(archive_dir, spec.name)
			files = `ls`.split(/\n/)
			files.delete "rpm"

			Dir.mktmpdir do |path|
				# if svn, export so there're no .svn directories
				if File.exist?(File.expand_path(".svn", Dir.pwd))
					system "svn export #{File.expand_path(Dir.pwd)} #{path}/#{spec.name}"
				else
					system "cp -r #{File.expand_path(Dir.pwd)} #{path}/#{spec.name}"
				end
				# no .git should be in rpm build
				system "rm -rf #{path}/#{spec.name}/.git"

				system "cp -aR #{files.collect { |r| File.join(path, spec.name, r) }.join(" ")} #{archive_dir}/#{spec.name}"
			end

			tar_file = File.join(build_dir, "SOURCES", "#{name}-#{version}.tar.gz")
			system "tar -czvpf #{tar_file} -C #{build_dir} #{name}-#{version}"
			system "rpmbuild -ba --define '_topdir #{build_dir}' --clean #{spec_file_name}"

			mkdir_p File.join(config.base_path, "pkg")
			Dir.glob(File.join(build_dir, "RPMS/*/*.rpm")) { |f| cp f, File.join(config.base_path, "pkg", File.basename(f)) }
		end

		private

		def new_spec
			if rails?
				RPM::Spec::Rails.new(config, File.expand_path("application.spec.erb", config.base_path))
			else
				RPM::Spec.new(config, File.expand_path("application.spec.erb", config.base_path))
			end
		end
	end
end
