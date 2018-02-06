defmodule FantasyBb.Repo.Migrations.AddEvictionCeremony do
  use Ecto.Migration

  def change do
    create table(:eviction_ceremony, primary_key: false) do
      add(:id, :serial, primary_key: true)
      add(:week_id, references(:week, type: :serial), null: false)
      add(:order, :smallint, null: false)

      timestamps(updated_at: false)
    end

    create(unique_index(:eviction_ceremony, [:week_id, :order]))

    alter table(:event) do
      add(:eviction_ceremony_id, references(:eviction_ceremony, type: :serial), null: false)
    end
  end
end
