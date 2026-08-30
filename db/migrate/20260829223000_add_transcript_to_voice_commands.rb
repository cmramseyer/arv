class AddTranscriptToVoiceCommands < ActiveRecord::Migration[8.0]
  def change
    add_column :voice_commands, :transcript, :text
  end
end
