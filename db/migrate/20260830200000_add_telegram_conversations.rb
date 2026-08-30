class AddTelegramConversations < ActiveRecord::Migration[8.0]
  def change
    create_table :telegram_conversations do |t|
      t.bigint :telegram_chat_id, null: false
      t.bigint :telegram_user_id, null: false
      t.string :openai_conversation_id
      t.datetime :last_message_at

      t.timestamps
    end

    add_index :telegram_conversations, [ :telegram_chat_id, :telegram_user_id ], unique: true
    add_reference :voice_commands, :telegram_conversation, foreign_key: true
    add_column :voice_commands, :input_type, :integer, null: false, default: 0
    add_column :voice_commands, :input_text, :text
  end
end
