class StorageUsageService
  LIMIT_BYTES = 5.gigabytes
  CACHE_KEY = "storage_usage_service:s3_usage"
  CACHE_TTL = 1.hour

  Result = Struct.new(:available, :bytes_used, :object_count, :error, keyword_init: true) do
    def limit_bytes
      LIMIT_BYTES
    end

    def percent_used
      return 0 unless available
      ((bytes_used.to_f / limit_bytes) * 100).clamp(0, 100)
    end
  end

  def self.call
    new.call
  end

  def call
    return Result.new(available: false) unless amazon_service?

    cached = Rails.cache.read(CACHE_KEY)
    return cached if cached

    result = fetch_from_s3
    Rails.cache.write(CACHE_KEY, result, expires_in: CACHE_TTL) if result.available
    result
  end

  private

  def amazon_service?
    ActiveStorage::Blob.service.name.to_s == "amazon"
  end

  def fetch_from_s3
    service = ActiveStorage::Blob.services.fetch(:amazon)

    bytes_used = 0
    object_count = 0

    service.bucket.objects.each do |object|
      bytes_used += object.size
      object_count += 1
    end

    Result.new(available: true, bytes_used: bytes_used, object_count: object_count)
  rescue Aws::Errors::ServiceError, Seahorse::Client::NetworkingError => e
    Rails.logger.error("StorageUsageService: #{e.class} #{e.message}")
    Result.new(available: false, error: e.message)
  end
end
