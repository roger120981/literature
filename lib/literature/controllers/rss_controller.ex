defmodule Literature.RSSController do
  use Literature.Web, :controller

  alias Atomex.{Feed, Entry}
  alias Literature.Config

  @default_path "/posts/rss.xml"

  def index(conn, _params) do
    base_path = String.replace(current_path(conn), @default_path, "")
    base_url = Config.feed_url() <> base_path
    publication_slug = String.split(base_path, "/") |> List.last()

    conn
    |> put_resp_content_type("text/xml")
    |> send_resp(200, render_feed(base_url, publication_slug))
  end

  defp render_feed(base_url, publication_slug) do
    %{
      "status" => "published",
      "preload" => ~w(primary_author)a,
      "publication_slug" => publication_slug
    }
    |> Literature.list_posts()
    |> build_feed(base_url)
  end

  def build_feed(posts, base_url) do
    Feed.new(base_url, DateTime.utc_now(), "Literature RSS")
    |> Feed.author(Config.feed_author(), email: Config.feed_email())
    |> Feed.link(base_url <> @default_path, rel: "self")
    |> Feed.entries(Enum.map(posts, &get_entry(base_url, &1)))
    |> Feed.build()
    |> Atomex.generate_document()
  end

  defp get_entry(base_url, %{
         title: title,
         slug: slug,
         custom_excerpt: custom_excerpt,
         published_at: published_at,
         primary_author: primary_author
       }) do
    post_path = "#{base_url}/#{slug}"
    name = Map.get(primary_author, :name)

    Entry.new(post_path, DateTime.from_naive!(published_at, "Etc/UTC"), title)
    |> Entry.link(post_path)
    |> Entry.author(name)
    |> Entry.content(custom_excerpt)
    |> Entry.build()
  end
end
