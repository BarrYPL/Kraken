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
