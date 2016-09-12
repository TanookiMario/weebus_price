defmodule WeebusPrice.Repo.Migrations.CreateTransaction do
  use Ecto.Migration

  def change do
    create table(:transactions) do
      add :date, :date
      add :description, :string
      add :original_description, :string
      add :amount, :decimal
      add :type, :string
      add :category, :string
      add :account, :string
      add :labels, :string
      add :notes, :string

      timestamps()
    end

  end
end
