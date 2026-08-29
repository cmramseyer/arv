class CreateVoiceCommands < ActiveRecord::Migration[8.0]
  def change
    create_table :voice_commands do |t|
      t.bigint :telegram_update_id, null: false
      t.bigint :telegram_chat_id, null: false
      t.bigint :telegram_user_id, null: false
      t.bigint :telegram_message_id, null: false
      t.string :telegram_file_id, null: false
      t.integer :status, default: 0, null: false
      t.text :error

      t.timestamps
    end

    add_index :voice_commands, :telegram_update_id, unique: true
  end
end
