require 'inspec/utils/object_traversal'
require 'inspec/utils/convert'

class IisCommand < Inspec.resource(1)
  name '_iis_command'

  include ObjectTraverser
  include Converter

  def initialize(options = {})
  end

  def to_s
    'Base resource for running IIS PowerShell commands'
  end

  # Use method_missing to retrieve a parameter name via `#its`.
  #
  # Similar to InSpec JSON resource
  def method_missing(*keys)
    # catch behavior of rspec its implementation
    keys.shift if keys.is_a?(Array) && keys[0] == :[]
    value(keys)
  end

  def value(key)
    # uses ObjectTraverser.extract_value to walk the hash looking for the key,
    # which may be an Array of keys for a nested Hash.

    # fetch_data should be defined in the class implementing IisCommand
    extract_value(key, fetch_data)
  end

  private

  # IIS Command method used when JSON parsing is not needed
  def iis_command(script)
    cmd = inspec.powershell(script)
    potential_stderr = cmd.stderr
    raise(Inspec::Exceptions::ResourceFailed, "stderr not empty when querying IIS: #{potential_stderr}") unless potential_stderr == ''
    # Return stdout stripped of whitespace \r\n
    cmd.strip
  end

  # JSON for IIS Command used when JSON parsing is needed
  def json_for_iis_command(script)
    script = "#{script} | ConvertTo-Json"
    begin
      result = iis_command(script)
      result = '[]' if result.empty?
      result = JSON.parse(result)
      result = [result] unless result.is_a? Array
      result
    rescue JSON::ParserError => e
      raise(Inspec::Exceptions::ResourceFailed, "Failed to parse IIS result to JSON: #{e}")
    end
  end

  def coerce_commit_path(commit_path)
    return commit_path if commit_path.nil?
    # Drop MACHINE/WEBROOT/APPHOST prefix if it exists, commit_path option doesn't take it
    commit_path = commit_path.gsub('MACHINE/WEBROOT/APPHOST', '')
    # If empty string, set to / for consistency
    commit_path = '/' if commit_path.empty?
    commit_path
  end
end
