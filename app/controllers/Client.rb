class Client
  # @Instance variable
  # @@Class variable
  @@clientCount = 0
  attr_accessor :name

  def initialize(sockt)
    @sockt = sockt
    @@clientCount += 1
  end

  def self.num
    if @@clientCount > 0
      return @@clientCount - 1
    else
      return nil
    end
  end

  def self.dead
    $clientsList.delete_at(Client.num)
    @@clientCount -= 1
  end

  def self.quantity
    return @@clientCount
  end

  def send(msg)
    @sockt.puts(msg)
  end
end
