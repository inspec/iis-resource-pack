require 'IisCommand'

class IisConfigUsers < IisCommand
  name 'iis_config_users'

  def initialize(options = {})
    super
    @commit_path = coerce_commit_path(options.fetch(:commit_path, nil))
  end

  def to_s
    string = 'IIS users in site configuration'
    string << " for IIS site #{@commit_path}" unless @commit_path.nil?
    string << ' for the default IIS configuration' if @commit_path.nil?
    string
  end

  def exist?
    fetch_data.any?
  end

  private

  def fetch_data
    command = "Get-IISConfigSection -SectionPath 'system.web/authentication'"
    command << " -CommitPath '#{@commit_path}'" if @commit_path
    command << " | Get-IISConfigElement -ChildElementName 'forms'"
    command << "  | Get-IISConfigElement -ChildElementName 'credentials'"
    command << ' | Get-IISConfigCollection'

    json_for_iis_command(command)
  end
end
