defmodule Sulat.Router do
  use Sulat.Web, :router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_flash
    plug :protect_from_forgery
    plug :put_secure_browser_headers

    plug Sulat.Auth, repo: Sulat.Repo
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/", Sulat do
    pipe_through :browser # Use the default browser stack

    get "/", PageController, :index
    resources "/session", SessionController, only: [:new, :create, :delete]
    resources "/users", UserController, only: [:new, :create, :update, :show, :edit]
    resources "/posts", PostController
  end

  # Other scopes may use custom stacks.
  # scope "/api", Sulat do
  #   pipe_through :api
  # end
end
