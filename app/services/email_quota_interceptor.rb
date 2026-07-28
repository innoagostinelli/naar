class EmailQuotaInterceptor
  def self.delivering_email(message)
    quota = EmailQuotaService.call
    return if quota.can_send?

    Rails.logger.warn(
      "EmailQuotaInterceptor: envío bloqueado, cuota alcanzada " \
      "(daily=#{quota.daily_used}/#{quota.daily_limit}, monthly=#{quota.monthly_used}/#{quota.monthly_limit})"
    )
    message.perform_deliveries = false
  end
end
