defmodule NightGameWeb.Router do
  use NightGameWeb, :router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_flash
    plug Phoenix.LiveView.Flash
    plug :protect_from_forgery
    plug :put_secure_browser_headers
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/", NightGameWeb do
    pipe_through :browser

    get "/", PageController, :index
    get "/game", PageController, :index

    live "/game/:name", Game
  end

  # Other scopes may use custom stacks.
  # scope "/api", NightGameWeb do
  #   pipe_through :api
  # end
end
