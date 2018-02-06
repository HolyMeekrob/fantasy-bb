defmodule FantasyBb.Repo.Migrations.AddRule do
  use Ecto.Migration

  def change do
    create table(:rule) do
      add(:league_id, references(:league), null: false)
      add(:event_type_id, references(:event_type, type: :serial), null: false)
      add(:point_value, :integer, null: false)

      timestamps()
    end

    create(unique_index(:rule, [:league_id, :event_type_id]))
  end
end
