defmodule TheCrawlerWeb.JobLiveTest do
  import TheCrawler.DataCase

  use TheCrawlerWeb.ConnCase
  import Phoenix.LiveViewTest

  import Mock

  test "mount job view when there is no job", %{conn: conn} do
    {:ok, view, html} = live(conn, "/")
    assert TheCrawlerWeb.JobLive = view.module
    assert html =~ "No jobs are currently running"
  end

  test "mount job view when there is no running job", %{conn: conn} do
    insert_job(%{state: "abandoned"})

    {:ok, view, html} = live(conn, "/")
    assert TheCrawlerWeb.JobLive = view.module
    assert html =~ "No jobs are currently running"
  end

  test "mount job view when there are running jobs", %{conn: conn} do
    insert_job(%{state: "running"})
    {:ok, _view, html} = live(conn, "/")
    assert html =~ "Jobs"
  end

  test "redirect to a spider's jobs", %{conn: conn} do
    {:ok, view, _html} = live(conn, "/")
    render_click(view, :show_spider, %{"spider" => "TestSpider"})
    assert_redirect(view, "/spider?spider=TestSpider")
  end

  test "update index view after 100ms when jobs is updated to running", %{conn: conn} do
    job = insert_job(%{inserted_at: inserted_at(6 * 60), state: "new"})

    {:ok, view, _html} = live(conn, "/")

    assert render(view) =~ "No jobs are currently running"

    Process.sleep(50)

    insert_item(job.id, inserted_at(50))
    insert_item(job.id, inserted_at(10))

    TheCrawler.Manager.update_job(job, %{state: "running"})

    assert render(view) =~ "No jobs are currently running"

    Process.sleep(70)

    # render after every 100ms

    assert render(view) =~
             "<td>running</td><td>#{job.inserted_at}</td><td>2 items/min</td><td>5 min</td>"

    insert_item(job.id)

    Process.sleep(100)

    assert render(view) =~
             "<td>running</td><td>#{job.inserted_at}</td><td>3 items/min</td><td>6 min</td>"
  end

  test "update all jobs view after 100ms when jobs is updated to running", %{conn: conn} do
    job = insert_job(%{inserted_at: inserted_at(6 * 60), state: "new"})

    {:ok, view, _html} = live(conn, "/all")

    assert render(view) =~
             "<td>new</td><td>#{job.inserted_at}</td><td>0 items/min</td><td>0 min</td>"

    Process.sleep(20)

    insert_item(job.id, inserted_at(50))
    insert_item(job.id, inserted_at(10))

    TheCrawler.Manager.update_job(job, %{state: "running"})

    assert render(view) =~
             "<td>new</td><td>#{job.inserted_at}</td><td>0 items/min</td><td>0 min</td>"

    Process.sleep(100)

    # render after every 100ms

    assert render(view) =~
             "<td>running</td><td>#{job.inserted_at}</td><td>2 items/min</td><td>5 min</td>"

    insert_item(job.id)

    Process.sleep(100)

    assert render(view) =~
             "<td>running</td><td>#{job.inserted_at}</td><td>3 items/min</td><td>6 min</td>"
  end

  test "view not update if no job is running", %{conn: conn} do
    job = insert_job(%{state: "abandoned"})

    {:ok, view, _html} = live(conn, "/all")

    assert render(view) =~
             "<td>abandoned</td><td>#{job.inserted_at}</td><td>0 items/min</td><td>0 min</td>"

    Process.sleep(100)

    assert render(view) =~
             "<td>abandoned</td><td>#{job.inserted_at}</td><td>0 items/min</td><td>0 min</td>"
  end

  test "go to page", %{conn: conn} do
    # page 2
    job_1 = insert_job(%{inserted_at: inserted_at(6 * 60)})
    # page 1
    Enum.each(1..9, &insert_job(%{inserted_at: inserted_at(&1)}))
    job_2 = insert_job()

    {:ok, view, _html} = live(conn, "/all")

    assert render(view) =~ "<td>#{job_2.inserted_at}</td>"
    refute render(view) =~ "<td>#{job_1.inserted_at}</td>"

    {:ok, new_view, _html} =
      view
      |> render_click(:goto_page, %{"page" => "2"})
      |> follow_redirect(conn, "/all?page=2")

    assert render(new_view) =~ "<td>#{job_1.inserted_at}</td>"
    refute render(new_view) =~ "<td>#{job_2.inserted_at}</td>"
  end

  test "go to page for index view", %{conn: conn} do
    {:ok, view, _html} = live(conn, "/")

    assert view
           |> render_click(:goto_page, %{"page" => "2"})
           |> follow_redirect(conn, "/?page=2")
  end

  test "cancel running job", %{conn: conn} do
    job_1 = insert_job(%{state: "running"})

    with_mock TheCrawler.SpiderManager, [],
      close_job_spider: fn
        ^job_1 -> {:ok, :stopped}
      end do
      {:ok, view, _html} = live(conn, "/")

      assert render(view) =~
               "phx-click=\"cancel\" phx-value-job=\"#{job_1.id}\">Cancel"

      render_click(view, :cancel, %{"job" => Integer.to_string(job_1.id)})

      assert render(view) =~ "No jobs are currently running"

      {:ok, view, _html} = live(conn, "/all")

      assert render(view) =~
               "<td>cancelled</td><td>#{job_1.inserted_at}</td><td>0 items/min</td><td>0 min</td><td>"
    end
  end

  test "delete job", %{conn: conn} do
    job_1 = insert_job(%{state: "stopped"})
    job_2 = insert_job(%{state: "abandonned"})

    insert_item(job_2.id, inserted_at(50))
    insert_item(job_2.id, inserted_at(10))

    {:ok, view, _html} = live(conn, "/all")

    assert render(view) =~
             "phx-click=\"delete\" phx-value-job=\"#{job_1.id}\">Delete"

    assert render(view) =~
             "phx-click=\"delete\" phx-value-job=\"#{job_2.id}\">Delete"

    render_click(view, :delete, %{"job" => Integer.to_string(job_1.id)})
    render_click(view, :delete, %{"job" => Integer.to_string(job_2.id)})

    assert [] == TheCrawler.Repo.all(TheCrawler.Manager.Job)
    assert [] == TheCrawler.Repo.all(TheCrawler.Manager.Item, job_id: job_2.id)

    refute render(view) =~
             "phx-click=\"delete\" phx-value-job=\"#{job_1.id}\">Delete"

    refute render(view) =~
             "phx-click=\"delete\" phx-value-job=\"#{job_2.id}\">Delete"
  end
end
