require 'erb'
require 'rubygems'
require 'rbconfig'

module RPM
  class Spec
    autoload :Rails, File.join(File.dirname(__FILE__), "spec/rails")
    attr_accessor :config, :path, :gemspec, :version, :name, :licenses, :homepage,
                  :dependencies, :runtime_dependencies, :development_dependencies,
                  :summary, :description, :arch

    alias url homepage

    def tag(name_or_sym, value = :_unassigned)
      value = send(name_or_sym) if value == :_unassigned && name_or_sym.kind_of?(Symbol)
      name_or_sym = name_or_sym.to_s.gsub(/(^|_)(.)/) { |m| $~[2].upcase }
      if !value || (value.respond_to?(:empty?) && value.empty?)
        # see if it's required; if so, fill one in
        case name_or_sym
          when "License" then "License: None Specified"
          else ""
        end
      else
        "#{name_or_sym}: #{value}"
      end
    end

    def rpm_dependencies
      config.rpm_dependencies
    end

    def initialize(rpm_config, path)
      gemspec_file = File.expand_path(%x[ls -d *.gemspec].split(/\n/).first.strip, Dir.pwd)

      @config = rpm_config
      @path = path
      @gemspec = Gem::Specification.load(gemspec_file)
      @version = gemspec.version
      @name = [config.name_prefix, gemspec.name].join
      @summary = gemspec.summary
      @licenses = gemspec.licenses
      @homepage = gemspec.homepage
      @dependencies = dependency_list(gemspec.dependencies).join(", ")
      @runtime_dependencies = dependency_list(gemspec.runtime_dependencies).join(", ")
      @development_dependencies = dependency_list(gemspec.development_dependencies).join(", ")
      @description = gemspec.description
      @arch = ::Config::CONFIG['arch']
    end

    def generate
      ERB.new(File.read(path)).result(binding)
    end

    def project_files
      Dir.glob(File.join(config.project_root,"*"),File::FNM_DOTMATCH).reject do |d|
        [File.basename(config.base_path),'.','..'].include?(File.basename(d))
      end
    end

    private
    def dependency_list(deps)
      deps.collect do |dep|
        if dep.requirements_list.empty?
          "#{config.name_prefix}#{dep.name}"
        else
          "#{config.name_prefix}#{dep.name} #{reformat_requirements_list(dep.requirements_list).join(" ")}"
        end
      end
    end

    def reformat_requirements_list(reqs)
      reqs.collect do |req|
        req.gsub(/\~\>/, '=')
      end
    end
  end
end
