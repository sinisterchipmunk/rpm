module RPM
  class Config
    include RPM

    attr_accessor :name_prefix, :base_path, :rpm_dependencies, :build_dir, :project_root

    def initialize
      @project_root = defined?(RAILS_ROOT) ? RAILS_ROOT : Dir.pwd
      @name_prefix = rails? ? "" : "rubygem-"
      @base_path = File.expand_path("rpm", @project_root)
      @rpm_dependencies = []
      @build_dir = "build"
    end
  end
end
