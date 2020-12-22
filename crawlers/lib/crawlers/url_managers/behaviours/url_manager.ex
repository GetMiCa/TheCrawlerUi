defmodule Crawlers.UrlsManagers.Behaviours.UrlManager do
  @callback generate_urls() :: [String.t()]
end
