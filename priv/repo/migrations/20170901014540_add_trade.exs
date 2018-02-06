defmodule FantasyBb.Repo.Migrations.AddTrade do
  use Ecto.Migration

  def change do
    create table(:trade) do
      add(:initiated_by_team_id, references(:team), null: false)
      add(:parent_id, references(:trade))
      add(:message, :text)
      add(:is_approved, :boolean)

      timestamps()
    end

    create(unique_index(:trade, [:parent_id]))
  end
end
