defmodule FantasyBb.Repo.Migrations.AddEvent do
  use Ecto.Migration

  def change do
    create table(:event) do
      add(:event_type_id, references(:event_type, type: :serial), null: false)
      add(:houseguest_id, references(:houseguest, type: :serial))
      add(:additional_info, :text)

      timestamps(updated_at: false)
    end
  end
end
