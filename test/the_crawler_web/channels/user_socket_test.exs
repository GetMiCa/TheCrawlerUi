defmodule TheCrawlerWeb.UserSocketTest do
  use TheCrawlerWeb.ChannelCase, async: true
  alias TheCrawlerWeb.UserSocket

  test "connect to socket" do
    assert {:ok, _} = UserSocket.connect(%{}, UserSocket, %{})
  end

  test "return nil as id" do
    assert nil == UserSocket.id(UserSocket)
  end
end
