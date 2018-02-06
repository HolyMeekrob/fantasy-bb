defmodule FantasyBb.Schema.User do
  use Ecto.Schema

  import Ecto.Changeset,
    only: [
      cast: 3,
      validate_required: 2,
      validate_format: 3,
      unique_constraint: 2,
      foreign_key_constraint: 2
    ]

  schema "user" do
    field(:email, :string)
    field(:first_name, :string)
    field(:last_name, :string)
    field(:bio, :string)
    field(:avatar, :string)
    belongs_to(:favorite_player, FantasyBb.Schema.Player)

    timestamps()

    has_many(:commissioned_leagues, FantasyBb.Schema.League, foreign_key: :commissioner_id)
    has_many(:teams, FantasyBb.Schema.Team)
  end

  def changeset(user, params \\ %{}) do
    user
    |> cast(params, [:email, :first_name, :last_name, :bio, :favorite_player_id, :avatar])
    |> validate_required([:email])
    |> validate_format(:email, ~r/@/)
    |> unique_constraint(:email)
    |> foreign_key_constraint(:favorite_player_id)
  end
end
