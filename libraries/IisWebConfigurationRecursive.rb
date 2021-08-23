require 'IisCommand'

class IisWebConfigurationRecursive < IisCommand
  name 'iis_web_configuration_recursive'

  def initialize(options = {})
    super
    @filter = options[:filter]
    return skip_resource('filter must be passed in options hash') if @filter.nil? || @filter.empty?
  end

  def to_s
    "IIS Web Configuration Recursive Paths for #{@filter}"
  end

  def paths
    # For a given filter, find all paths that contain that configuration section
    fetch_data.collect { |k| k['PSPath'] }
  end

  def locations
    # For a given filter, find all locations that contain that configuration section
    # Location can be empty, so replace blank string with nil
    fetch_data.collect { |k| k['Location'].empty? ? nil : k['Location'] }
  end

  private

  def fetch_data
    json_for_iis_command("Get-WebConfiguration '#{@filter}' -Recurse")
  end
end
