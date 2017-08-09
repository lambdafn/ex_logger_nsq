defmodule LoggerNsq.Nsq do
  use GenServer

  def start_link(opts \\ [])  do
    GenServer.start_link(__MODULE__, opts, name: __MODULE__)
  end

  def init(_) do
    config = Application.get_env(:logger, LoggerNsq.Backend)

    case Keyword.get(config, :nsqds) do
      nsqds when is_list(nsqds) ->
        {:ok, _producer} = NSQ.Producer.Supervisor.start_link("chrome_worker_errors", %NSQ.Config{
          nsqds: nsqds
        })
      _ ->
        {:stop, "No NSQD configuration found.  Please configure `:logger, LoggerNsq.Backend`"}
    end
  end

  def handle_cast({:log, message}, producer) do
    NSQ.Producer.pub(producer, message)
    {:noreply, producer}
  end

  def log(message) do
    GenServer.cast(__MODULE__, {:log, message})
  end
end
