class CreateEmailSendLogs < ActiveRecord::Migration[8.1]
  def change
    create_table :email_send_logs do |t|
      t.string :mailer_name
      t.string :to_address
      t.string :subject

      t.timestamps
    end

    add_index :email_send_logs, :created_at
  end
end
