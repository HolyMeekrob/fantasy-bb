defmodule FantasyBb.Repo.Migrations.AddRule do
  use Ecto.Migration

  def change do
    create table(:rule) do
      add(:league_id, references(:league), null: false)
      add(:scorable_id, references(:scorable, type: :serial), null: false)
      add(:point_value, :integer, null: false)

      timestamps()
    end

    create(unique_index(:rule, [:league_id, :scorable_id]))
  end
end
