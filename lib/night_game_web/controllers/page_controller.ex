defmodule NightGameWeb.PageController do
  use NightGameWeb, :controller

  alias NightGame.HeroNameGenerator

  @impl true
  def index(conn, _params) do
    redirect(conn, to: "/game/#{HeroNameGenerator.random()}")
  end
end
