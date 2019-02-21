require 'time'

module MiceFunctions

  def partyCreate(payload,id)
    self.parties.push(Party.new(self.player))

    parties = self.parties
    party = parties.detect { |p|
      p.host = self.player
    }
    self.party = party

    response = party.create(payload,id,self.document_version)
    self.document_version += 1
    return response
  end

  def invgetbalances()
  end

  def invgetbalance()
  end

  def invgetitems()
  end

  def inventoryrequestsync()
  end

  def lobbycancelinvite()
  end

  def lobbyinvite()
  end

  def lobbyjoin()
  end

  def lobbyleave()
  end

  def lobbyrespondtoinvite()
  end

  def lobbyview()
  end

  def playerGetInfo(payload,id)
    clients = self.clients
    client = clients.detect { |c|
      c.player.name = payload["username"]
    }
    if client
      JSON.generate([[{"player":{"savedLoadouts":[],"instanceid":"instanceStr","penalty_history":{},"moid":client.player.moid,"inventory":client.player.inventory},"preview_matches_left":{"keyStr":"valueStr"}}],id])
    end
  end

  def progressionGet(payload,id)
    clients = self.clients
    client = clients.detect { |c|
      c.player.moid = payload["moid"]
    }
    if client
      JSON.generate([[{"progression":{"account_rank":{"list":[{"current_value":"valueStr","rank":client.player.rank,"metric":"metricStr","teir":"teirStr","name":"nameStr","date":"dateStr","current_rank":{},"target":[{"keyStr":"valueStr"}],"rewards":"rewardStr","next_rank":{"keyStr":"valueStr"}}]},"badge":{"list":[{"rank":"rankStr","badge":"badgeStr"}],"medal":{"keyStr":"valueStr"}}},"signInDesc":{"keyStr":"valueStr"}}],id])
    end
  end

  def getServerTime(id)
    JSON.generate([[{"datetime":Time.now.strftime("%Y.%m.%d-%H:%M:%S")}],id])
  end

  def rxlistservers()
  end

  def storegetproducts()
  end

  def chat()
  end

  def debug()
  end

  def echo(payload,id)
    JSON.generate([[payload["data"]],id])
  end

  def close()
    # TODO remove from parties and matchmaking
    # send confirmation back
    self.unbind()
  end

  def matchme()
  end

  def matchlive()
  end

  def stopmatching()
  end

  def matchconfirmresponse()
  end

  def friendpending()
  end

  def friendinvite()
  end

  def friendaccept()
  end

  def friendreject()
  end

  def friendremove()
  end

  def friendview()
  end

  def strategyget()
  end

  def strategyupdate()
  end

  def cartprocess()
  end

  def ordersget()
  end

  def balanceresync()
  end

  def windowsstoregettoken()
  end

  def trackevent()
  end

  def voicegetlogintoken()
  end

  def voicegetjointoken()
  end

  def lobbyinvitecanceled()
  end

  def lobbyinvited()
  end

  def lobbynotifyjoin()
  end

  def lobbynotifypart()
  end

  def lobbyfriendnotifyjoin()
  end

  def lobbyfriendnotifypart()
  end

  def matchmefail()
  end

  def matchfail()
  end

  def matchready()
  end

  def matchinviteraction()
  end

  def matchprogress()
  end

  def matchconfirm()
  end

  def matchremovedfromqueue()
  end

  def matchreturntoqueue()
  end

  def friendpresencenotify()
  end

  def cataloginfo()
  end

  def kick()
  end

  def orderprocessed()
  end

  def servicecontextserverexiting()
  end

  def endofmatchprocessed()
  end

  def balanceupdated()
  end

  def submessage()
  end

  def substatus()
  end

  def inventoryupdated()
  end

end
