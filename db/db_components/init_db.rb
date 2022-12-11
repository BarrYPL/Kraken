require 'sequel'
require 'bcrypt'
require 'rqrcode'
require 'rotp'

DB = Sequel.sqlite "databaset.db"

DB.create_table :users do
  primary_key :id
  String :username
  String :password_hash
  int :isAdmin
  int :isMod
  date :isBanned
  int :is2FA
  String :twofaKey
end

DB.create_table :clients do
	primary_key :id
	String :ip
	String :name
	String :image
end

users = DB[:users]

  def hash_password(password)
    BCrypt::Password.create(password).to_s
  end

  User = Struct.new(:username, :password_hash, :isAdmin, :isMod, :is2FA, :twofaKey)
  USERSS = [
    User.new('barry', hash_password('tvR84VGE@Bnh8pViGUxz'), 1, 1, 0, ROTP::Base32.random),
	User.new('jakub', hash_password('tvR84VGE@Bnh8pViGUxz'), 0, 0, 0, ROTP::Base32.random),
	User.new('michal', hash_password('tvR84VGE@Bnh8pViGUxz'), 0, 0, 0, ROTP::Base32.random),
	User.new('terrorist', hash_password('tvR84VGE@Bnh8pViGUxz'), 0, 0, 0, ROTP::Base32.random),
	User.new('piotr', hash_password('tvR84VGE@Bnh8pViGUxz'), 0, 0, 0, ROTP::Base32.random),
	User.new('kamil', hash_password('tvR84VGE@Bnh8pViGUxz'), 0, 0, 0, ROTP::Base32.random),
	User.new('krzysztof', hash_password('tvR84VGE@Bnh8pViGUxz'), 0, 0, 0, ROTP::Base32.random),
	User.new('kacper', hash_password('tvR84VGE@Bnh8pViGUxz'), 0, 0, 0, ROTP::Base32.random)
  ]

USERSS.each do |user|
	  users.insert username: user.username,
		password_hash: user.password_hash,
		isAdmin: user.isAdmin,
		isMod: user.isMod,
		isBanned: Time.now - 1,
		is2FA: user.is2FA,
		twofaKey: ROTP::Base32.random;
end
