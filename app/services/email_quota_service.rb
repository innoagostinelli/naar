class EmailQuotaService
  DAILY_LIMIT   = 90
  MONTHLY_LIMIT = 2700

  Result = Struct.new(:daily_used, :monthly_used, keyword_init: true) do
    def daily_limit
      EmailQuotaService::DAILY_LIMIT
    end

    def monthly_limit
      EmailQuotaService::MONTHLY_LIMIT
    end

    def daily_percent
      ((daily_used.to_f / daily_limit) * 100).clamp(0, 100)
    end

    def monthly_percent
      ((monthly_used.to_f / monthly_limit) * 100).clamp(0, 100)
    end

    def can_send?
      daily_used < daily_limit && monthly_used < monthly_limit
    end
  end

  def self.call
    new.call
  end

  def call
    Result.new(
      daily_used: EmailSendLog.today.count,
      monthly_used: EmailSendLog.this_month.count
    )
  end
end
