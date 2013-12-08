OngakuRyoho::Application.config.secret_token = ENV["SESSION_KEY"] || "9fc57e164ebe2a22339d4f1955ca14bce680089dae1e8b981f675300ebbd59df3c0e67fc858bd5cab5a6c1c13c3119c76de86f3802e810fb174fdfe671363f75"
OngakuRyoho::Application.config.cookie_secret = OngakuRyoho::Application.config.secret_token
