defmodule Sulat.OwnerIsUser do
  import Plug.Conn

  alias Sulat.Router.Helpers

  def call(conn) do
    cond do
      _ = conn.assigns[:owner] -> conn
      true -> assign(conn, :owner, nil)
    end
  end

end
