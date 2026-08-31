class RemoveJwtAndRefreshTokens < ActiveRecord::Migration[8.0]
  def up
    drop_table :jwt_denylists

    remove_index :users, :refresh_token_digest
    remove_index :users, :refresh_token_jti
    remove_column :users, :refresh_token_digest
    remove_column :users, :refresh_token_expires_at
    remove_column :users, :refresh_token_jti
  end

  def down
    add_column :users, :refresh_token_digest, :string
    add_column :users, :refresh_token_expires_at, :datetime
    add_column :users, :refresh_token_jti, :string
    add_index :users, :refresh_token_digest
    add_index :users, :refresh_token_jti

    create_table :jwt_denylists do |t|
      t.string :jti
      t.datetime :exp

      t.timestamps
    end
    add_index :jwt_denylists, :jti
  end
end
