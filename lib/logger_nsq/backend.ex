defmodule LoggerNsq.Backend do
  use GenEvent

  alias LoggerNsq.Nsq

  def init(_) do
    if user = Process.whereis(:user) do
      Process.group_leader(self(), user)

      {:ok, configure([])}
    else
      {:error, :ignore}
    end
  end

  def handle_call({:configure, options}, _state) do
    {:ok, :ok, configure(options)}
  end

  def handle_event({_level, gl, {Logger, _, _, _}}, state) when node(gl) != node() do
    {:ok, state}
  end
  def handle_event({level, _gl, {Logger, msg, ts, md}}, %{level: min_level} = state) do
    if is_nil(min_level) or Logger.compare_levels(level, min_level) != :lt do
      log_event(level, msg, ts, md, state)
    end
    {:ok, state}
  end

  defp configure(options) do
    merged = Keyword.merge(Application.get_env(:logger, __MODULE__, []), options)
    Application.put_env(:logger, __MODULE__, merged)

    format = merged
      |> Keyword.get(:format)
      |> Logger.Formatter.compile

    level    = Keyword.get(merged, :level)
    metadata = Keyword.get(merged, :metadata, [])
    %{format: format, metadata: metadata, level: level}
  end

  defp log_event(level, msg, ts, md, %{format: format, metadata: metadata}) do
    Logger.Formatter.format(format, level, msg, ts, Keyword.take(md, metadata))
    |> to_string()
    |> Nsq.log
  end
end
