defmodule DS.Application do
  use Application

  def start(_type, _args) do
    children = [
      DS.Database.Repo,
      DS.Http.Server.child_spec(),
      DS.Mice.Server.child_spec(),
    ]

    Supervisor.start_link(children, [
      name: DS.Supervisor,
      strategy: :one_for_one,
    ])
  end
end
