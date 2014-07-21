# Load the rails application
require File.expand_path('../application', __FILE__)

# Actionmailer configuration
require 'mail'

from_mail_address = Mail::Address.new "ongakuryoho.mailer@gmail.com"
from_mail_address.display_name = "Ongaku Ryoho"

ActionMailer::Base.delivery_method = :smtp
ActionMailer::Base.smtp_settings = {
  enable_starttls_auto:     true,
  address:                  'smtp.gmail.com',
  port:                     587,
  domain:                   'gmail.com',
  authentication:           :plain,
  user_name:                from_mail_address.address,
  password:                 'bVbxMNfsmBGin9JUohRoszpXVhQrLzbkEiLs8MLVUzDZsfdk'
}

ActionMailer::Base.default(
  from: from_mail_address.format
)

# Initialize the rails application
OngakuRyoho::Application.initialize!
