defmodule Sulat.OwnerAsUserTest do
  use Sulat.ConnCase
  alias Sulat.Auth
  alias Sulat.OwnerIsUser, as: OIU

  setup %{conn: conn} do
    conn = 
      conn
      |> bypass_through(Sulat.Router, :browser)
      |> get("/")
    {:ok, %{conn: conn}}
  end

  test "call with no session yields to a nil :owner", %{conn: conn} do
    conn = OIU.call(conn)
    assert nil == conn.assigns.owner
  end
end
