class AllowTextCommands < ActiveRecord::Migration[8.0]
  def change
    change_column_null :voice_commands, :telegram_file_id, true
  end
end
