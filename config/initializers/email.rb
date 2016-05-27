ActionMailer::Base.logger = nil
ActionMailer::Base.delivery_method = :smtp
ActionMailer::Base.smtp_settings = {
  :enable_starttls_auto => ENV['SMTP_START_TLS'],
  :address              => ENV['SMTP_ADDRESS'],
  :domain               => ENV['SMTP_DOMAIN'],
  :port                 => ENV['SMTP_PORT'],
  :authentication       => :plain,
  :user_name            => ENV['SMTP_USERNAME'],
  :password             => ENV['SMTP_PASSWORD']
}
