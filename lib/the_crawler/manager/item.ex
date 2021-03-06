defmodule TheCrawler.Manager.Item do
  use Ecto.Schema
  import Ecto.Changeset

  schema "items" do
    field :data, :map
    field :job_id, :id

    timestamps()
  end

  @doc false
  def changeset(item, attrs) do
    item
    |> cast(attrs, [:data, :job_id])
    |> validate_required([:data, :job_id])
  end
end
