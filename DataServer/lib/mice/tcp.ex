defmodule DS.Mice.TcpServer do
  defmacro __using__(_opts) do
    quote do
      use GenServer
      require Logger
      alias __MODULE__, as: Self

      def child_spec, do:
        __MODULE__.child_spec([])
      
      def start_link(options), do:
        GenServer.start_link(__MODULE__, options, name: __MODULE__)

      def init(_options) do
        port = Application.get_env(:ds, :mice_port)
        Logger.debug "[DS.Mice] Starting server on :#{port}"

        {:ok, _} = :ranch.start_listener(__MODULE__, 
          :ranch_tcp, [port: port],
          DS.Mice.Client, [])
        {:ok, new()}
      end
    end
  end
end

defmodule DS.Mice.TcpClient do
  defmacro __using__(_opts) do
    quote do
      use GenServer
      alias __MODULE__, as: Self

      @tcp_options [active: true, nodelay: true]

      def start_link(ref, socket, transport, _options), do:
        {:ok, :proc_lib.spawn_link(__MODULE__, :init, [{ref, socket, transport}])}

      def init({ref, socket, transport}) do
        :ok = :ranch.accept_ack(ref)
        :ok = transport.setopts(socket, @tcp_options)
        :gen_server.enter_loop(__MODULE__, [], new({socket, transport}))
      end

      def handle_info({:tcp, _, data}, self), do:
        {:noreply, receive_data(self, data)}
      def handle_info({:tcp_closed, _}, self), do:
        {:stop, :normal, close(self, nil)}
      def handle_info({:tcp_error, _, reason}, self), do:
        {:stop, :normal, close(self, reason)}

      defp send_data(self, data) do
        {socket, transport} = self.socket
        transport.send(socket, data)
      end

      defp close(self, reason) do
        on_close(self, reason)
        {socket, transport} = self.socket
        transport.close(socket)
        %{self | socket: nil}
      end

    end
  end
end