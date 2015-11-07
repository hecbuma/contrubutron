require 'sidekiq'

if Rails.env.production?
  Sidekiq.configure_client do |config|
    config.redis = { :url => ENV['REDISTOGO_URL'], :size => 1 }
  end

  Sidekiq.configure_server do |config|
    config.redis = { :url => ENV['REDISTOGO_URL'],:size => 9 }
  end
end
