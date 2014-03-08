Rails.application.config.after_initialize do
  ActiveRecord::Base.connection_pool.disconnect!

  ActiveSupport.on_load(:active_record) do
    threads_workers_size = Integer(ENV['MAX_THREADS'] || 1) * Integer(ENV['PUMA_WORKERS'] || 2)
    config = ActiveRecord::Base.configurations[Rails.env]
    config['pool'] = ENV['DB_POOL'] || threads_workers_size || 2
    ActiveRecord::Base.establish_connection(config)
  end
end
