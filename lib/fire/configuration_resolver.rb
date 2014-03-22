require 'yaml'

module Fire
  DOT_FILE = '.fire'

  class ConfigurationNotFound < StandardError; end

  class ConfigurationResolver
    def initialize(options = {})
      @stop_at = options[:stop_at] || '/'
    end

    def active_processes

    end

    def processes(path = DOT_FILE)
      raise ConfigurationNotFound if stop?(path)
      return processes("../#{path}") unless File.exist?(path)

      contents = File.read(path)
      YAML.load(contents).values
    end

    private

    def stop?(path)
      File.dirname(File.absolute_path path) == @stop_at
    end
  end
end
