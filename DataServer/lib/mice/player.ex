defmodule DS.Mice.Player do
  alias DS.Database.User
  alias __MODULE__, as: Self

  defstruct(
    name: "",
    moid: 0,
    exp: 0,
    rank: 1,
    device_id: ""
  )

  def new(%User{}=user) do
    %Self{
      moid: user.id,
      name: user.nickname,
      device_id: "noString"
    }
  end

  def auth_response(self), do: [".auth", %{
    name: self.name,
    game: "ggc", # ggl for release
    deviceid: self.device_id,
    exp: self.exp,
    moid: self.moid,
    version: "298288", # 326539 for release
    time: 1,
    xmpp: %{
      host: "127.0.0.1"
    }
  }]

end