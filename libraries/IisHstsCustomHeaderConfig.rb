require 'IisCommand'

class IisHstsCustomHeaderConfig < IisCommand
  name 'iis_hsts_custom_header_config'

  def initialize(options = {})
    super
    @commit_path = coerce_commit_path(options.fetch(:commit_path, nil))
    return skip_resource('commit_path must be passed in options hash') if @commit_path.nil? || @commit_path.empty?
  end

  def to_s
    "IIS HSTS Custom Header Config #{@commit_path}"
  end

  def enabled
    # To line up with the native HSTS config enabled attribute, return true if the Strict-Transport-Security header exists
    !fetch_data.empty?
  end

  def maxage
    return false unless enabled
    # Return value from the max-age array element as an integer
    convert_to_i(fetch_data.find { |element| element.match(/max-age/) }.match(/max-age=(?<value>\d*)/)[:value])
  end

  def preload
    return false unless enabled
    # Return true if preload is in the array
    fetch_data.include?('preload')
  end

  def includeSubDomains
    return false unless enabled
    # Return true if preload is in the array
    fetch_data.include?('includeSubDomains')
  end

  private

  def fetch_data
    result = json_for_iis_command("Get-IISConfigSection -SectionPath 'system.webServer/httpProtocol' -CommitPath '#{@commit_path}' | Get-IISConfigCollection -CollectionName 'customHeaders'")
    result = result.find { |element| element['RawAttributes']['name'] == 'Strict-Transport-Security' }
    return [] if result.nil?
    # Split "max-age=480; includeSubDomains; preload" into array of elements, minus whitespace.
    result['RawAttributes']['value'].split(';').collect(&:strip)
  end
end
