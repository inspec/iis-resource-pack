require 'IisCommand'

class IisAppPoolConfig < IisCommand
  name 'iis_app_pool_config'

  def initialize(options = {})
    @name = options[:name]
    return skip_resource('name must be passed in options hash') if @name.nil? || @name.empty?
  end

  def to_s
    "IIS App Pool #{@name} Config"
  end

  # Use method_missing to retrieve a parameter name via `#its`.
  # Similar to InSpec JSON resource
  def method_missing(*keys)
    # catch behavior of rspec its implementation
    keys.shift if keys.is_a?(Array) && keys[0] == :[]
    fetch_data(keys)
  end

  def all_app_pools
    json_for_iis_command('Get-IISAppPool | ForEach-Object { $_.Name }')
  end

  def application_count
    iis_command("(Get-IISSite | ForEach-Object { $_.Applications } | Where-Object { $_.ApplicationPoolName -eq '#{@name}' }).Count").to_i
  end

  private

  def fetch_data(keys)
    command = "(Get-IISAppPool '#{@name}')"
    keys.each do |key|
      command << ".#{key}"
    end
    iis_command(command)
  end
end
