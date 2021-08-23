require 'IisCommand'

class IisConfigCollection < IisCommand
  name 'iis_config_collection'

  def initialize(options = {})
    super
    @section_path = options[:section_path]
    @element = options.fetch(:element, [])
    @collection_name = options.fetch(:collection_name, nil)
    @commit_path = coerce_commit_path(options.fetch(:commit_path, nil))
    return skip_resource('section_path must be passed in options hash') if @section_path.nil? || @section_path.empty?
  end

  def to_s
    "IIS Config Collection #{@commit_path} #{@section_path} #{@collection_name}"
  end

  # Check for the existence of an element with attributes matching provided keys and values
  def has_config_element?(attributes = {})
    # Convert hash keys from symbols to strings
    attributes = attributes.transform_keys(&:to_s)
    # Get-IISConfigCollection fetch_data will return an array of attributes hashes
    # Return true if one of the contained attributes exactly matches the asserted attributes on all key value pairs
    # e.g. check an attribute that includes attribute subset hash {verb: 'TRACE', allowed: false} exists
    fetch_data.any? { |element| element['RawAttributes'] >= attributes }
  end

  private

  def fetch_data
    command = "Get-IISConfigSection -SectionPath '#{@section_path}'"
    command << " -CommitPath '#{@commit_path}'" if @commit_path
    @element.each do |e|
      command << " | Get-IISConfigElement -ChildElementName '#{e}'"
    end
    command << " | Get-IISConfigCollection -CollectionName #{@collection_name}" unless @collection_name.nil?
    command << ' | Get-IISConfigCollection' if @collection_name.nil?

    json_for_iis_command(command)
  end
end
