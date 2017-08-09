defmodule LoggerNsqTest do
  use ExUnit.Case, async: false

  require Logger

  test "the truth" do
    assert 1 + 1 == 2
  end

  test "log process exit" do
    Logger.metadata user_id: :bar
    Logger.log :error, "foo"

    bar = {:bar, :baz}
    Logger.error inspect(bar)
  end
end
