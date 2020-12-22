defmodule TheCrawlerWeb.ItemController do
  use TheCrawlerWeb, :controller

  import Ecto.Query, warn: false
  alias TheCrawler.Repo

  alias TheCrawler.Manager.Item

  def export(conn, %{"job_id" => job_id} = _params) do
    query = from i in Item, where: i.job_id == ^job_id, select: i.data

    conn =
      conn
      |> put_resp_header("content-disposition", "attachment; filename=job_#{job_id}")
      |> put_resp_content_type("application/json")
      |> send_chunked(200)

    stream = Repo.stream(query)

    {:ok, conn} =
      Repo.transaction(fn ->
        Enum.reduce_while(
          stream,
          conn,
          fn data, conn ->
            data = Jason.encode!(data)

            case chunk(conn, data) do
              {:ok, conn} ->
                {:cont, conn}

              {:error, :closed} ->
                {:halt, conn}
            end
          end
        )
      end)

    conn
  end
end
