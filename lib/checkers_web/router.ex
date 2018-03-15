defmodule CheckersWeb.Router do
  use CheckersWeb, :router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_flash
    plug :protect_from_forgery
    plug :put_secure_browser_headers
  end

  pipeline :cookie_auth do
    plug CheckersWeb.Authentication
  end

  scope "/game", CheckersWeb do
    pipe_through :browser
    get "/", PageController, :index
    get "/*path", RedirectController, :index
  end

  scope "/auth", CheckersWeb do
    pipe_through :browser

    get "/:provider", AuthController, :request
    get "/:provider/callback", AuthController, :new
    get "/*path", RedirectController, :index
  end

  scope "/", CheckersWeb do
    pipe_through :browser
    get "/", PageController, :index
    get "/*path", RedirectController, :index
  end

end
