workers Integer(ENV['PUMA_WORKERS'] || 1)
threads Integer(ENV['MIN_THREADS'] || 1), Integer(ENV['MAX_THREADS'] || 1)

preload_app!

rackup      DefaultRackup
port        ENV['PORT']     || 3000
environment ENV['RACK_ENV'] || 'production'

on_worker_boot do
  redis_url = "redis://172.17.0.4:49159"

  Sidekiq.configure_client do |config|
    config.redis = { :url => redis_url, :namespace => "ongakuryoho_sidekiq", :size => 2 }
  end

  Sidekiq.configure_server do |config|
    database_url = ENV['DATABASE_URL']

    if database_url
      ENV['DATABASE_URL'] = "#{database_url}?pool=15"
      ActiveRecord::Base.establish_connection
    end

    config.redis = { :url => redis_url, :namespace => "ongakuryoho_sidekiq" }
  end

  @sidekiq_pid ||= spawn("bundle exec sidekiq -c 2")
end
