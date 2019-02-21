class Party
  attr_accessor :host, :members, :configuration, :session_settings
  def initialize(player)
    @host = player
    @members = Array.new()
    @configuration
    @session_settings

    self.members.push(player)
  end

  def create(payload,id,document_version)
    updatePartyVariables(payload)
    hash = generateResponse(document_version)

    response = JSON.generate([[hash],id])

    return response
  end

  alias_method :partyUpdate, :create
  
  def partykickplayer()
  end

  def partyleave()
  end

  def partyjoin()
  end

  def partyget()
  end

  def partypreview()
  end

  def partycreatereservations()
  end

  def partysendmessage()
  end

  def partypromotehost()
  end

  def partyreserveandpreview()
  end

  def partymemberpenalty()
  end

  def partystateupdated()
  end

  def partymemberdisconnected()
  end

  def partymemberjoined()
  end

  def partymessagerecieved()
  end

  def partypromotedtohost()
  end

  def partyforcedsync()
  end

  private
  def updatePartyVariables(payload)
    if payload.key?("session_settings")
        self.session_settings = payload["session_settings"]
    end

    if payload.key?("member_settings")
        self.host.member_settings = payload["member_settings"]
    end

    if payload.key?("configuration")
        self.configuration = payload["configuration"]
    end
  end

  def generateResponse(document_version)
    hash =
        {
           "session_id":"12", #not using atm
           "session":{
              "host":self.host.moid.to_s,
              "document_version":document_version,
              "join_state":"open",
              "session_settings":self.session_settings,
              "configuration":self.configuration,
              "members":{}
              }
        }

   self.members.each { | m |
     hash[:session][:members][m.moid] = {"username":m.name,"member_settings":m.member_settings}
   }

   return hash
  end
end
