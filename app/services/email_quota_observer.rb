class EmailQuotaObserver
  def self.delivered_email(message)
    return unless message.perform_deliveries

    EmailSendLog.create!(
      to_address: Array(message.to).join(", "),
      subject: message.subject
    )
  end
end
