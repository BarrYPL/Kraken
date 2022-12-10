class NilClass
  def name
    return nil
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
  p $clientsDB.where(:ip => params[:ip]).first
end
