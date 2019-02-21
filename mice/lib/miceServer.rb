#!/usr/bin/ruby
require 'json'
require "pg" #TODO: move to non blocking postgres client / api

require './lib/adminFunctions'
require './lib/miceFunctions'
require './lib/party'
require './lib/player'
require './lib/salsa'

class MiceServer < EventMachine::Connection
  attr_accessor :server
  include MiceFunctions
  include AdminFunctions

  attr_accessor :initialized, :document_version, :party, :player, :message_buffer, :timeout_count, :salsa_in, :salsa_out

  def post_init
    @initialized = false
    @document_version = 1
    @party = nil
    @player = nil
    @message_buffer = String.new()
    @timeout_count = 0
    @salsa_in = nil
    @salsa_out = nil
  end

  def unbind
    @server.clients.delete(self)
  end

  def clients
    @server.clients
  end

  def parties
    @server.parties
  end

  # Receive data, decode it, handle command and encode response
  def receive_data(serialized_in)
    # Add player to clients list
    if !self.initialized
      self.salsa_in = Salsa.new(@server.salsa[:sck],16)
      self.salsa_out = Salsa.new(@server.salsa[:sck],16)
      authenticate(serialized_in)
      @server.clients.push(self)
      self.initialized = true
      return
    end

    mice_commands = decode_data(serialized_in)

    if mice_commands
      mice_commands.each do | command |
          mice_response = self.command(command)
          if mice_response
            encode_data(mice_response)
          end

      end
    end

  end

  # Deserialize, decrypt data and return array of commands.
  def decode_data(serialized_in)

    # if any unprocessed data from previous packets, prepend them to the current packet.
    if self.message_buffer.length > 0
      serialized_in = self.message_buffer + serialized_in
      self.message_buffer.clear
    end

    data_length = serialized_in.length
    data_read = 0
    commands = Array.new

    # Payload can be multiple commands, length prepended
    begin
      while data_read < data_length do
        first_byte = serialized_in[data_read].ord
        if first_byte == 0xff
          command_length = serialized_in[data_read..data_read+2].unpack('w')[0]
          data_read += 3
          length_bytes = 3
        elsif first_byte >= 0x80
          command_length = serialized_in[data_read..data_read+1].unpack('w')[0]
          data_read += 2
          length_bytes = 2
        else
          command_length = first_byte
          data_read += 1
          length_bytes = 1
        end

        # payload can be larger than buffer size, if so store in buffer.
        if command_length > data_length
          self.message_buffer = self.message_buffer + serialized_in[data_read - length_bytes .. command_length + length_bytes]
          return
        end

        mice_command = serialized_in[data_read .. data_read + command_length - 1]

        # Salsa20 encryption
        if @server.salsa
          mice_command = self.salsa_in.encrypt(mice_command)
        end

        json = JSON.parse(mice_command)
        commands << json
        data_read += command_length
      end

      return commands

    rescue => error
      puts "Rescued #{error.message}"
    end

  end

  # Serialize and encrypt data before sending.
  def encode_data(mice_command)
    # Salsa20 encryption
    if @server.salsa
      mice_command = self.salsa_out.encrypt(mice_command)
    end

    len = [mice_command.length].pack("w")
    serialized_out = len + mice_command
    send_data serialized_out
  end

  # First packet uses different key, decrypt check token and return auth packet.
  def authenticate(token_payload)
    token_payload = token_payload[1..-1]
    if @server.salsa
      s = Salsa.new(@server.salsa[:ck],12)
      token_payload = s.decrypt(token_payload)
    end

    begin
      json = JSON.parse(token_payload)
      token = json[0]

      con = PG.connect :host => ENV['DB_HOST'], :dbname => 'gigantic_dev', :user => ENV['DB_USER'], :password => ENV['DB_PASS']
      res = con.exec_params(%q{SELECT * FROM users WHERE token = $1},[token])
      con.close if con

      if res
        pg_response = {
          :device_id => "noString",
          :name => res[0]['nickname'],
          :moid => res[0]['id'].to_i,
          :exp => 0,
          :rank => 1}
        self.player = Player.new(pg_response)

        response = JSON.generate([".auth",
          {
          "name": self.player.name,
          "deviceid": self.player.device_id,
          "gameid": "ggl", #ggc for core builds
          "exp": self.player.exp,
          "moid": self.player.moid,
          "version": "326539", #298288 core
          "time": 1,
          "xmpp": { "host": @server.xmpp[:server] }
          }
        ])

        if @server.salsa
          response = self.salsa_out.encrypt(response)
        end
        len = [response.length].pack("w")
        serialized_out = len + response
        send_data serialized_out
        return
      else
        self.unbind
      end
    rescue => e
      puts e
    end
  end

  def command(mice_command)
    admin_command = mice_command[0]
    payload = mice_command[1]
    id = mice_command[2]

    case admin_command
    when "inv.get.balances"
       return false
    when "inv.get.balance"
       return false
    when "inv.get.items"
       return false
    when "inventory.requestsync"
       return false
    when "lobby.cancelinvite"
       return false
    when "lobby.invite"
       return false
    when "lobby.join"
       return false
    when "lobby.leave"
       return false
    when "lobby.respondtoinvite"
       return false
    when "lobby.view"
       return false
    when "party.kickplayer"
       return false
    when "player.getinfo"
       self.playerGetInfo(payload,id)
    when "player.setinfo"
       return false
    when "player.savelocation"
       return false
    when "player.declinematchreconnection"
       return false
    when "player.progressionget"
       self.progressionGet(payload, id)
    when "player.progressioncard"
       return false
    when "player.getpenalty"
       return false
    when "player.getbalance"
       return false
    when "player.getdisabledcontent"
       return false
    when "player.message"
       return false
    when "player.getgamestatus"
       self.player.getGameStatus(id)
    when "player.requesttransferhandle"
       return false
    when "player.getservertime"
       self.getServerTime(id)
    when "rx.list.servers"
       return false
    when "store.get.products"
       return false
    when ".chat"
       return false
    when ".debug"
       return false
    when ".close"
      self.close()
    when "match.me"
      #should check if leader
      @server.matchmaking_parties.push(self.party)
      JSON.generate([[{}],id])
    when "match.live"
       return false
    when "stop.matching"
      @server.matchmaking_parties.delete(self.party)
      JSON.generate([[{}],id])
    when "match.confirm.response"
       return false
    when "friend.pending"
       return false
    when "friend.invite"
       return false
    when "friend.accept"
       return false
    when "friend.reject"
       return false
    when "friend.remove"
       return false
    when "friend.view"
       return false
    when "strategy.get"
       return false
    when "strategy.update"
       return false
    when "cart.process"
       return false
    when "orders.get"
       return false
    when "balance.resync"
       return false
    when "windowsstore.gettoken"
       return false
    when "track.event"
       return false
    when "party.create"
       self.partyCreate(payload,id)
    when "party.leave"
       return false
    when "party.join"
       return false
    when "party.get"
       return false
    when "party.preview"
       return false
    when "party.update"
       response = self.party.partyUpdate(payload,id,self.document_version)
       self.document_version += 1
       response
    when "party.createreservations"
       return false
    when "party.sendmessage"
       return false
    when "party.promotehost"
       return false
    when "party.reserveandpreview"
       return false
    when "voice.getlogintoken"
       return false
    when "voice.getjointoken"
       return false
    when "lobby.invitecanceled"
       return false
    when "lobby.invited"
       return false
    when "lobby.notifyjoin"
       return false
    when "lobby.notifypart"
       return false
    when "lobby.friendnotifyjoin"
       return false
    when "lobby.friendnotifypart"
       return false
    when "party.kickme"
       return false
    when "match.mefail"
       return false
    when "match.fail"
       return false
    when "match.ready"
       return false
    when "match.inviter.action"
       return false
    when "match.progress"
       return false
    when "match.confirm"
       return false
    when "match.removedfromqueue"
       return false
    when "match.returntoqueue"
       return false
    when "friend.presencenotify"
       return false
    when "catalog.info"
       return false
    when ".echo"
       self.echo(payload,id)
    when ".kick"
       return false
    when "order.processed"
       return false
    when "service.contextserverexiting"
       return false
    when "player.currencyadded"
       return false
    when "player.message"
       return false
    when "endofmatch.processed"
       return false
    when "player.penalty"
       return false
    when "party.memberpenalty"
       return false
    when "balance.updated"
       return false
    when "party.stateupdated"
       return false
    when "party.memberdisconnected"
       return false
    when "party.memberjoined"
       return false
    when "party.messagerecieved"
       return false
    when "party.promotedtohost"
       return false
    when "party.forcedsync"
       return false
    when "sub.message"
       return false
    when "sub.status"
       return false
    when "inventory.updateddef"
       return false
    else
      puts "Unknown: " + admin_command
      return false
    end

  end

end
