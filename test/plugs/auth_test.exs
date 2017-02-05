defmodule Sulat.AuthTest do
  use Sulat.ConnCase

  setup %{conn: conn} do
    conn = conn
           |> bypass_through(Sulat.Router, :browser)
           |> get("/")
    {:ok, %{conn: conn}}
  end
  
  test "authentication halts when :user does not exist", %{conn: conn} do
    # authenticate_user expects key :current_user to exist
    conn = conn |> assign(:current_user, nil) |> Sulat.Auth.authenticate_user([])
    assert conn.halted
  end
end
