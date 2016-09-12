defmodule WeebusPrice.TransactionTest do
  use WeebusPrice.ModelCase

  alias WeebusPrice.Transaction

  @valid_attrs %{account: "some content", amount: "120.5", category: "some content", date: %{day: 17, month: 4, year: 2010}, description: "some content", labels: "some content", notes: "some content", original_description: "some content", type: "some content"}
  @invalid_attrs %{}

  test "changeset with valid attributes" do
    changeset = Transaction.changeset(%Transaction{}, @valid_attrs)
    assert changeset.valid?
  end

  test "changeset with invalid attributes" do
    changeset = Transaction.changeset(%Transaction{}, @invalid_attrs)
    refute changeset.valid?
  end
end
