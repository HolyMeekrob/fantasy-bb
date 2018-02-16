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

  scope "/account", FantasyBbWeb do
    pipe_through([:browser, :authenticated])

    get("/profile", AccountController, :profile)
  end

  scope "/ajax/account", FantasyBbWeb do
    pipe_through(:ajax)

    get("/user", AccountController, :user)
    put("/user", AccountController, :update_user)
  end

  scope "/seasons", FantasyBbWeb do
    pipe_through([:browser, :authenticated])

    get("/:id", SeasonController, :show)
  end

  scope "/ajax/season", FantasyBbWeb do
    pipe_through(:ajax)

    post("/", SeasonController, :create)
  end

  scope "/admin", FantasyBbWeb do
    pipe_through([:browser, :authenticated])

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
