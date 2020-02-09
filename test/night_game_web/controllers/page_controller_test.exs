defmodule NightGameWeb.PageControllerTest do
  use NightGameWeb.ConnCase

  test "GET /", %{conn: conn} do
    conn = get(conn, "/")
    assert html_response(conn, 302) =~ "/game/"
  end

  test "GET /game", %{conn: conn} do
    conn = get(conn, "/game")
    assert html_response(conn, 302) =~ "/game/"
  end
end
