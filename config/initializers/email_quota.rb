Rails.application.config.to_prepare do
  ActionMailer::Base.register_interceptor(EmailQuotaInterceptor)
  ActionMailer::Base.register_observer(EmailQuotaObserver)
end
