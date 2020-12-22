defmodule TheCrawlerWeb.ScheduleLive do
  use Phoenix.LiveView

  alias TheCrawler.SpiderManager
  alias TheCrawler.Manager

  def render(%{template: template} = assigns) do
    TheCrawlerWeb.JobView.render(template, assigns)
  end

  def mount(%{"node" => node}, _session, socket) do
    if connected?(socket), do: Process.send_after(self(), :pick_spider, 10000)

    generic_spiders =
      Enum.map(
        Manager.list_spiders(page_size: 100),
        fn spider -> spider.name end
      )

    spiders = SpiderManager.list_spiders(node)

    {:ok,
     assign(socket,
       generic_spiders: generic_spiders,
       template: "pick_spider.html",
       node: node,
       spiders: spiders,
       error: nil
     )}
  end

  def mount(_param, _session, socket) do
    nodes = Node.list()

    generic_spiders =
      Enum.map(
        Manager.list_spiders(page_size: 100),
        fn spider -> spider.name end
      )

    if connected?(socket), do: Process.send_after(self(), :pick_node, 10000)

    {:ok,
     assign(socket, generic_spiders: generic_spiders, template: "pick_node.html", nodes: nodes)}
  end

  def handle_info(:pick_node, socket) do
    nodes = Node.list()
    if connected?(socket), do: Process.send_after(self(), :pick_node, 10000)
    {:noreply, assign(socket, nodes: nodes)}
  end

  def handle_info(:pick_spider, socket) do
    if connected?(socket), do: Process.send_after(self(), :pick_spider, 10000)

    node = socket.assigns.node
    spiders = SpiderManager.list_spiders(node)

    {:noreply, assign(socket, spiders: spiders)}
  end

  def handle_event("spider_picked", %{"node" => node}, socket) do
    {:noreply,
     redirect(socket,
       to: TheCrawlerWeb.Router.Helpers.schedule_path(socket, :pick_spider, node: node)
     )}
  end

  def handle_event("schedule_spider", %{"spider" => spider}, socket) do
    node = socket.assigns.node

    case spider in socket.assigns.generic_spiders do
      true ->
        TheCrawler.create_spider(node, spider)

      false ->
        :ok
    end

    case SpiderManager.start_spider(node, spider) do
      {:ok, :started} ->
        {:noreply,
         socket
         |> put_flash(
           :info,
           "Spider scheduled successfully. It might take a bit of time before items will appear here..."
         )
         |> redirect(to: TheCrawlerWeb.Router.Helpers.job_path(socket, :index))}

      error ->
        {:noreply,
         socket
         |> put_flash(:error, "#{inspect(error)}")
         |> redirect(to: TheCrawlerWeb.Router.Helpers.schedule_path(socket, :pick_node))}
    end
  end
end
