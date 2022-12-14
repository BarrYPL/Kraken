class NilClass
  def name
    return nil
  end
end

class Hash
  def isAdmin?
    if self[:isAdmin] == 1
      return true
    else
      return false
    end
  end
end

def hash_password(password)
  BCrypt::Password.create(password).to_s
end

def test_password(password, hash)
  BCrypt::Password.new(hash) == password
end

def add_client(ipAddr, name)
  $clientsDB.insert(ip: ipAddr, name: name)
end

def edit_name(params)
  $clientsDB.where(:ip => params[:ip]).update(:name => params[:new_name])
end

def update_photo(params)
  if params[:avatar] == "default"
    $clientsDB.where(:ip => params[:ip]).update(:image => nil)
  else
    $clientsDB.where(:ip => params[:ip]).update(:image => params[:avatar])
  end
  #p $clientsDB.where(:ip => params[:ip]).first
end

def generate_qr(params)
  path_to_file = "public/images/qr/#{params[:user]}.png"
  File.delete(path_to_file) if File.exist?(path_to_file)
  hotp = ROTP::HOTP.new(params[:key], issuer: params[:user])
  hotpKey = hotp.at(params[:num].to_i)
  loginLink = "http://192.168.0.59/user_login?username=#{params[:user]}&hotp=#{hotpKey}"
  qrcode = RQRCode::QRCode.new(loginLink)
  png = qrcode.as_png(
    bit_depth: 1,
    border_modules: 4,
    color_mode: ChunkyPNG::COLOR_GRAYSCALE,
    color: 'black',
    file: nil,
    fill: 'white',
    module_px_size: 6,
    resize_exactly_to: true,
    resize_gte_to: true,
    size: 200
  )
  IO.binwrite(path_to_file, png.to_s)
end
