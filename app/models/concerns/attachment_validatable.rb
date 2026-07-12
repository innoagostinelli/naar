module AttachmentValidatable
  extend ActiveSupport::Concern

  class_methods do
    def validates_attachment(name, content_types:, max_size:)
      validate do
        attachment = public_send(name)
        next unless attachment.attached?

        blob = attachment.blob

        unless blob.content_type.in?(content_types)
          errors.add(name, "debe ser un archivo de tipo: #{content_types.join(', ')}")
        end

        if blob.byte_size > max_size
          errors.add(name, "no puede superar #{max_size / 1.megabyte} MB")
        end
      end
    end
  end
end
