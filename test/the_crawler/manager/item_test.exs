defmodule TheCrawler.Manager.ItemTest do
  use TheCrawler.DataCase, async: true
  alias TheCrawler.Manager.Item

  test "Item must have job_id" do
    changeset = Item.changeset(%Item{}, %{data: %{"field" => "value"}})

    assert %{job_id: ["can't be blank"]} = errors_on(changeset)
  end

  test "Item must have data" do
    changeset = Item.changeset(%Item{}, %{job_id: 1})

    assert %{data: ["can't be blank"]} = errors_on(changeset)
  end
end
