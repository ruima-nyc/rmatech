class CreateUsers < ActiveRecord::Migration
  def self.up
    create_table :users do |t|
      t.string :email
      t.string :login
      t.string :passwd
      t.string :salt
      t.string :remember_token
      t.datetime :remember_token_expires_at
      t.column :admin,                     :boolean, :default => false

      t.timestamps
    end
  end

  def self.down
    drop_table :users
  end
end
