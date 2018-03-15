defmodule FantasyBbWeb.Router do
  use FantasyBbWeb, :router

  pipeline :browser do
    plug(:accepts, ["html"])
    plug(:fetch_session)
    plug(:fetch_flash)
    plug(:protect_from_forgery)
    plug(:put_secure_browser_headers)
    plug(:assign_current_user)
  end

  pipeline :authenticated do
    plug(:authenticate)
  end

  pipeline :ajax do
    plug(:accepts, ["json"])
    plug(:fetch_session)
    plug(:protect_from_forgery)
    plug(:put_secure_browser_headers)
    plug(:assign_current_user)
    plug(:ajax_authenticate)
  end

  scope "/", FantasyBbWeb do
    pipe_through(:browser)

    get("/", HomeController, :index)
  end

  scope "/login", FantasyBbWeb do
    pipe_through(:browser)

    get("/", LoginController, :index)
  end

  scope "/auth", FantasyBbWeb do
    pipe_through(:browser)

    get("/:provider", AuthController, :index)
    get("/:provider/callback", AuthController, :callback)
    delete("/logout", AuthController, :delete)
  end

  scope "/ajax", FantasyBbWeb, as: :ajax do
    pipe_through(:ajax)

    get("/account/user", AccountController, :user)
    put("/account/user", AccountController, :update_user)

    get("/leagues/", LeagueController, :for_current_user)
    post("/leagues/", LeagueController, :create)

    get("/players/", PlayerController, :index)
    post("/players/", PlayerController, :create)
    get("/players/:id", PlayerController, :get)
    put("/players/:id", PlayerController, :update)

    post("/seasons/", SeasonController, :create)
    get("/seasons/upcoming", SeasonController, :get_upcoming)
    get("/seasons/:id", SeasonController, :get)
    put("/seasons/:id", SeasonController, :update)
  end

  scope "/account", FantasyBbWeb do
    pipe_through([:browser, :authenticated])

    get("/profile", AccountController, :profile)
  end

  scope "/leagues", FantasyBbWeb do
    pipe_through([:browser, :authenticated])

    get("/", LeagueController, :index)
    get("/create", LeagueController, :create_view)
  end

  scope "/players", FantasyBbWeb do
    pipe_through([:browser, :authenticated])

    get("/:id", PlayerController, :show)
  end

  scope "/seasons", FantasyBbWeb do
    pipe_through([:browser, :authenticated])

    get("/:id", SeasonController, :show)
  end

  scope "/admin", FantasyBbWeb, as: :admin do
    pipe_through([:browser, :authenticated])

    get("/player/create", PlayerController, :create_view)
    get("/season/create", SeasonController, :create_view)
  end

  # Fetch the current user from the session and add it to `conn.assigns`.
  defp assign_current_user(conn, _) do
    assign(conn, :current_user, get_session(conn, :current_user))
  end

  # Check if the user is authenticated.
  # If not, redirect them to the login page.
  defp authenticate(conn, _params) do
    case Map.get(conn.assigns, :current_user) do
      nil ->
        conn
        |> put_flash(:error, "You must be logged in to access that page.")
        |> redirect(to: "/login")
        |> halt()

      _ ->
        conn
    end
  end

  # Check if the user is authenticated.
  # If not, return a 401.
  defp ajax_authenticate(conn, _params) do
    case Map.get(conn.assigns, :current_user) do
      nil ->
        conn
        |> send_resp(401, "Unauthorized")
        |> halt()

      _ ->
        conn
    end
  end
end
