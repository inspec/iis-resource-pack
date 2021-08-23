require 'IisCommand'

class IisConfigAttribute < IisCommand
  name 'iis_config_attribute'

  def initialize(options = {})
    super
    @section_path = options[:section_path]
    @element = options.fetch(:element, [])
    @element = [@element] unless @element.is_a? Array
    @commit_path = coerce_commit_path(options.fetch(:commit_path, nil))
    @location = options.fetch(:location, nil)
    return skip_resource('section_path must be passed in options hash') if @section_path.nil? || @section_path.empty?
  end

  def to_s
    string = "IIS Config Attribute #{@section_path}"
    string << "/#{@element.join('/')}" unless @element.empty?
    string << " #{@commit_path}" unless @commit_path.nil?
    string << " #{@location}" unless @location.nil?
    string
  end

  def method_missing(attribute_name)
    # catch behavior of rspec its implementation
    # convert the value to an integer if we have numbers only
    # otherwise we return the string
    convert_to_i(fetch_data(attribute_name))
  end

  private

  def fetch_data(attribute_name)
    command = "Get-IISConfigSection -SectionPath '#{@section_path}'"
    command << " -CommitPath '#{@commit_path}'" if @commit_path
    command << " -Location '#{@location}'" if @location
    @element.each do |e|
      command << " | Get-IISConfigElement -ChildElementName '#{e}'"
    end
    command << " | Get-IISConfigAttributeValue -AttributeName #{attribute_name}"
    iis_command(command)
  end
end
