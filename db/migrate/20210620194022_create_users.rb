class CreateUsers < ActiveRecord::Migration[6.1]
  def change
    create_table :users do |t|
      t.string :email
      t.string :username
      t.integer :status, default: 0
      t.integer :role, default: 2
      t.string :validation_code
      t.string :password_digest

      # Reset
      t.string :reset_password_token
      t.datetime :reset_password_within, limit: 6

      t.timestamps
    end
  end
end
