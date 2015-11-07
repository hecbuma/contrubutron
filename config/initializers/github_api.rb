Github.configure do |config|
  config.stack do |builder|
    builder.use Faraday::HttpCache, store: Rails.cache, logger: Rails.logger
  end
end
