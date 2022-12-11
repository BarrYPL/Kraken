require 'socket'
require 'sinatra'
require 'threads'
require 'timeout'
require 'sequel'
require 'bcrypt'
require 'rotp'
require 'ImageResize'

DB = Sequel.sqlite 'db/database.db'

$usersDB = DB[:users]
$clientsDB = DB[:clients]

require_relative 'private_methods.rb'
require_relative 'Client.rb'
