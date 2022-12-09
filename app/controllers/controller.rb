require 'socket'
require 'sinatra'
require 'threads'
require 'timeout'
require 'sequel'
require 'bcrypt'

DB = Sequel.sqlite 'db/database.db'

$usersDB = DB[:users]

require_relative 'private_methods.rb'
require_relative 'Client.rb'
