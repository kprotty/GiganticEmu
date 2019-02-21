#!/usr/bin/ruby
require 'rubygems'
require 'eventmachine'
require 'base64'

#require './lib/matchmaking'
require './lib/miceServer'

class Server
  attr_accessor :clients, :parties, :matchmaking_parties, :salsa, :dev, :xmpp

  def initialize
    @clients = Array.new
    @parties = Array.new
    @matchmaking_parties = Array.new
    if ENV.has_key?('SALSA_CK') && ENV.has_key?('SALSA_SCK')
      @salsa = {:ck => ENV['SALSA_CK'], :sck => ENV['SALSA_SCK']}
    else
      @salsa = false
    end
    @dev = ENV['dev'] || false
    @xmpp = {:server => ENV['XMPP_SERVER'] || '127.0.0.1', :port => 443} # key needs to be set to something
  end

  def start
    EventMachine.start_server("0.0.0.0", 4000, MiceServer) do |con|
      con.server = self
    end

    # Print user and states debug
    EventMachine::PeriodicTimer.new(1) do
      puts `clear`
      @clients.each { | c |
        puts c.player.name + " " + c.player.moid.to_s + "\n"
      }
    end

    # Temporary matchmaking funciton, have a semi functional matchmaking lib with unreleased dependencies
    EventMachine::PeriodicTimer.new(1) do
      player_count = 0
      @matchmaking_parties.each { | p |
          party_count = p.members.count
          player_count += party_count
      }
      if player_count > 5
        @matchmaking_parties.each { | mp |
          mp.members.each { |m|
            ck2 = Base64.strict_encode64("imagoodcipherkey")
            ck = Base64.strict_encode64("amotigadeveloper")
            bcryptHmac = Base64.strict_encode64("totsagoodsuperlonghmacsecretkeys")
            payload = JSON.generate(["match.ready",
                       {
                          "matchinfo":{
                             "server":{
                                "connstr":"127.0.0.1:7777", # Lacking match server orchestration in this version
                                "map":"lv_canyon"
                             },
                             "instanceid":"12",
                             "token":ck + ck2 + bcryptHmac,
                             "meta":{
                                "moid":m.moid.to_i
                             }
                          }
                       }
                    ])
            @clients.each { |c|
              if c.player.moid = m.moid
                c.encode_data(payload)
                @matchmaking_parties.delete(mp)
                break
              end
            }
          }
        }
      end
    end


=begin
    Callbacks for matchmaking algo and to ping .echo each client to ensure still connected.
    EventMachine::PeriodicTimer.new(1) do
      @clients.each { | c |
       c.ping
      }
    end
=end
  end
end

EventMachine::run do
  Signal.trap("INT")  { EventMachine.stop }
  Signal.trap("TERM") { EventMachine.stop }

  s = Server.new
  s.start
end
