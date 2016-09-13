defmodule WeebusPrice.Transaction do
  use WeebusPrice.Web, :model
  import Ecto.Query, only: [from: 2]

  schema "transactions" do
    field :date, Timex.Ecto.Date
    field :description, :string
    field :original_description, :string
    field :amount, :decimal
    field :type, :string
    field :category, :string
    field :account, :string
    field :labels, :string
    field :notes, :string

    timestamps()
  end

  @doc """
  Builds a changeset based on the `struct` and `params`.
  """
  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, [:date, :description, :original_description, :amount, :type, :category, :account, :labels, :notes])
    |> validate_required([:date, :description, :original_description, :amount, :type, :category, :account])
  end

  def in_date_range(first = %Date{}, last = %Date{}) do
    from t in WeebusPrice.Transaction,
      where: t.date >= ^first and t.date <= ^last
  end
end
