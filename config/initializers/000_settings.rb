# This file must be named 000_settings.yml so it's the first initializer
# according to the lexicographical order and thus it's loaded first.

ConfigFilePath = "#{::Rails.root.to_s}/config/settings.yml"
raise Exception, "#{ConfigFilePath} configuration file is missing" unless FileTest.exists?(ConfigFilePath)

YAML.load_file(ConfigFilePath)[::Rails.env].each do |k,v|
  EVoucher::Application.config.send("#{k}=", v)
end

