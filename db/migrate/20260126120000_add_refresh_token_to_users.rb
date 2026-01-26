class AddRefreshTokenToUsers < ActiveRecord::Migration[8.0]
  def change
    add_column :users, :refresh_token_digest, :string
    add_column :users, :refresh_token_expires_at, :datetime
    add_column :users, :refresh_token_jti, :string

    add_index :users, :refresh_token_digest
    add_index :users, :refresh_token_jti
  end
end
