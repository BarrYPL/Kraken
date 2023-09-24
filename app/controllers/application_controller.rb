require 'socket'
require 'sinatra'
require 'threads'
require 'timeout'
require 'sequel'
require 'bcrypt'
require 'rotp'
require 'rqrcode'

DB = Sequel.sqlite 'db/database.db'

$usersDB = DB[:users]
$clientsDB = DB[:clients]

require_relative 'private_methods.rb'
require_relative 'Client.rb'
