class ClientApi::AuthController < ApplicationController
  skip_before_action :verify_authenticity_token

  def index

  end

  def create
    if params.has_key?(:arc_token)
      user = User.where("token = ?", params[:arc_token]).first
      user_response = {
        'result':'ok',
        'username': user[:email],
        'name': user.nickname,
        'min_version': 16897, # Game doesn't even check.
        'token': user.token,
        'auth': user.token,  # Using token for mice auth so it's used twice.
        'host': "192.168.50.1",
        'port': 4000,
        'accounts': 'accmple', # unknown string
        'current_version': 16897,  # Game doesn't even check.
        'ck': Base64.encode64("\x00\x00" + ENV.fetch("SALSA_CK")),
        'sck': Base64.encode64("\x00\x00" + ENV.fetch("SALSA_SCK")),
        'xbox_preview': false, # Used for achievements
        'founders_pack': true, # Display founderpack advert
        'buddy_key': false,
        'flags': '', ## unknown string
        'mostash_verbosity_level': 0,
        'voice_chat': {'baseurl':'http://127.0.0.1/voice.html','username':"sip:.username.@voice.sipServ.com",'token':'sipToken'}, # This key may not be needed.
        'announcements': {'message':'serverMessage','status':'serverStatus'},
        'catalog': {'cdn_url':'http://192.168.50.1/cdn.html', 'sha256_digest':'04cd2302958566b0219c78a6066049933f5da07ec23634f986194ba6e7c9094e'}
      }
      render json: user_response
    else
      render json: {}, status: 401
    end
  end
end
