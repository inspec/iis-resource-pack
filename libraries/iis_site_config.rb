require 'IisCommand'

class IisSiteConfig < IisCommand
  name 'iis_site_config'

  def initialize(options = {})
    @name = options[:name]
    return skip_resource('name must be passed in options hash') if @name.nil? || @name.empty?
  end

  def to_s
    "IIS Site #{@name} Config"
  end

  # Use method_missing to retrieve a parameter name via `#its`.
  # Similar to InSpec JSON resource
  def method_missing(*keys)
    # catch behavior of rspec its implementation
    keys.shift if keys.is_a?(Array) && keys[0] == :[]
    # convert the value to an integer if we have numbers only
    # otherwise we return the string
    convert_to_i(fetch_data(keys))
  end

  def all_sites
    json_for_iis_command('Get-IISSite | ForEach-Object { $_.Name }')
  end

  def physicalPath
    # Get-IISSite doesn't actually have a physicalPath attribute despite appearing in the output of `Get-IISSite`
    # Both `(Get-IISSite "Default Web Site").physicalPath` and `Get-IISSite "Default Web Site" | Select physicalPath` will return nothing
    #
    # physicalPath in the output of `Get-IISSite` in IISAdministration appears to be a WebAdministration backwards compat attribute
    # and the actual location of the physicalPath in IISAdministration is:
    # `(Get-IISSite "Default Web Site").Applications["/"].VirtualDirectories["/"].PhysicalPath`
    fetch_data(['Applications["/"]', 'VirtualDirectories["/"]', 'physicalPath'])
  end

  def bindings
    fetch_json_data(['bindings'])
  end

  def applications
    fetch_json_data(['applications'])
  end

  private

  def fetch_data(keys)
    iis_command(build_command(keys))
  end

  def fetch_json_data(keys)
    json_for_iis_command(build_command(keys))
  end

  def build_command(keys)
    command = "(Get-IISSite '#{@name}')"
    keys.each do |key|
      command << ".#{key}"
    end
    command
  end
end
