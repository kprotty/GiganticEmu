class Player
  attr_accessor :authenticated, :member_settings, :session_configuration
  attr_accessor :device_id, :exp, :inventory, :moid, :name, :rank

  def initialize(pg_response)
    @authenticated = false
    @member_settings
    @session_configuration

    @device_id = pg_response[:device_id]
    @name = pg_response[:name]
    @moid = pg_response[:moid]
    @exp = pg_response[:exp]
    @rank = pg_response[:rank]
    @inventory = nil
    getInventory
  end

  def setinfo()
    # Store settings in database
  end

  def savelocation()
  end

  def declinematchreconnection()
  end

  def progressioncard()
  end

  def getpenalty()
  end

  def getbalance()
  end

  def getdisabledcontent()
  end

  def message()
  end

  def getGameStatus(id)
    JSON.generate([[{"end_date":Time.now.strftime("%Y.%m.%d-%H:%M:%S"),"state":"stateStr","countdown":false}],id])
  end

  def requesttransferhandle()
  end

  def currencyadded()
  end

  def message()
  end

  def penalty()
  end

  private
  def getInventory()
    self.inventory = [
      {"quantity":1,"resource_id":"Adept","origins":["owned","flagged"]},
      {"quantity":1,"resource_id":"Alchemist","origins":["owned","flagged"]},
      {"quantity":1,"resource_id":"Angel","origins":["owned","flagged"]},
      {"quantity":1,"resource_id":"Assault","origins":["owned","flagged"]},
      {"quantity":1,"resource_id":"Aura","origins":["owned","flagged"]},
      {"quantity":1,"resource_id":"Blade","origins":["owned","flagged"]},
      {"quantity":1,"resource_id":"Bombard","origins":["owned","flagged"]},
      {"quantity":1,"resource_id":"Despair","origins":["owned","flagged"]},
      {"quantity":1,"resource_id":"Frosty","origins":["owned","flagged"]},
      {"quantity":1,"resource_id":"Judo","origins":["owned","flagged"]},
      {"quantity":1,"resource_id":"Machine","origins":["owned","flagged"]},
      {"quantity":1,"resource_id":"Minotaur","origins":["owned","flagged"]},
      {"quantity":1,"resource_id":"Planter","origins":["owned","flagged"]},
      {"quantity":1,"resource_id":"Quarrel","origins":["owned","flagged"]},
      {"quantity":1,"resource_id":"Rogue","origins":["owned","flagged"]},
      {"quantity":1,"resource_id":"Swift","origins":["owned","flagged"]},
      {"quantity":1,"resource_id":"Tank","origins":["owned","flagged"]},
      {"quantity":1,"resource_id":"Warden","origins":["owned","flagged"]},
      {"quantity":1,"resource_id":"Zap","origins":["owned","flagged"]}
    ]
  end
end
