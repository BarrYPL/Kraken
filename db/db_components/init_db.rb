require 'sequel'
require 'bcrypt'
require 'rqrcode'

DB = Sequel.sqlite "databaset.db"

DB.create_table :users do
  primary_key :id
  String :username
  String :name
  String :password_hash
  int :isAdmin
  int :isMod
  date :isBanned
  int :is2FA
  String :twofaKey
end

users = DB[:users]

  def hash_password(password)
    BCrypt::Password.create(password).to_s
  end

  User = Struct.new(:username, :name, :password_hash, :isAdmin, :isMod, :is2FA, :twofaKey)
  USERSS = [
    User.new('barry', 'bob', hash_password('tvR84VGE@Bnh8pViGUxz'), 1, 1, 1, nil)
  ]

USERSS.each do |user|
	  users.insert username: user.username,
		name: user.name,
		password_hash: user.password_hash,
		isAdmin: user.isAdmin,
		isMod: user.isMod,
		isBanned: Time.now - 1;
end
