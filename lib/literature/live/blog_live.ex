defmodule Literature.BlogLive do
  use Literature.Web, :live_view

  import Literature.Helpers,
    only: [atomize_keys_to_string: 1, literature_image_url: 2]

  alias Literature.{Author, Post, Repo, Tag}

  @layout {Literature.LayoutView, "live.html"}

  @impl Phoenix.LiveView
  def mount(%{"slug" => slug}, session, socket) do
    [&Literature.get_post!/1, &Literature.get_tag!/1, &Literature.get_author!/1]
    |> Enum.map(fn fun -> fun.(slug: slug, publication_slug: session["publication_slug"]) end)
    |> Enum.find(&is_struct/1)
    |> case do
      %Post{} = post -> assign_to_socket(socket, :post, post)
      %Tag{} = tag -> assign_to_socket(socket, :tag, preload_tag(tag))
      %Author{} = author -> assign_to_socket(socket, :author, preload_author(author))
    end
    |> assign(%{
      publication_slug: session["publication_slug"],
      view_module: session["view_module"]
    })
    |> then(&{:ok, &1, layout: @layout})
  end

  @impl Phoenix.LiveView
  def mount(_params, session, socket) do
    socket
    |> assign(%{
      publication_slug: session["publication_slug"],
      view_module: session["view_module"]
    })
    |> then(&{:ok, &1, layout: @layout})
  end

  @impl Phoenix.LiveView
  def render(%{view_module: view_module, live_action: live_action} = assigns) do
    live_action
    |> case do
      :show ->
        [
          {assigns[:post], "post.html"},
          {assigns[:tag], "tag.html"},
          {assigns[:author], "author.html"}
        ]
        |> Enum.find(fn {assign, _} -> is_map(assign) end)
        |> elem(1)

      action ->
        "#{to_string(action)}.html"
    end
    |> then(&Phoenix.View.render(view_module, &1, assigns))
  end

  @impl Phoenix.LiveView
  def handle_params(_params, _url, socket) do
    {:noreply, apply_action(socket, socket.assigns.live_action, socket.assigns.publication_slug)}
  end

  defp apply_action(socket, :index, slug) do
    publication = Literature.get_publication!(slug: slug)

    socket
    |> assign_meta_tags(publication)
    |> assign(:publication, publication)
    |> assign(:posts, list_posts(socket))
  end

  defp apply_action(socket, :tags, _params) do
    assign(socket, :tags, list_tags(socket))
  end

  defp apply_action(socket, :authors, _params) do
    assign(socket, :authors, list_authors(socket))
  end

  defp apply_action(socket, _, _), do: socket

  defp list_posts(%{assigns: %{publication_slug: slug}}) do
    %{"publication_slug" => slug, "status" => "published"}
    |> Literature.list_posts()
  end

  defp list_tags(%{assigns: %{publication_slug: slug}}) do
    %{"publication_slug" => slug, "status" => "public"}
    |> Literature.list_tags()
    |> preload_tag()
  end

  defp list_authors(%{assigns: %{publication_slug: slug}}) do
    %{"publication_slug" => slug}
    |> Literature.list_authors()
    |> preload_author()
  end

  defp preload_tag(tag),
    do: Repo.preload(tag, ~w(published_posts)a)

  defp preload_author(tag),
    do: Repo.preload(tag, ~w(published_posts)a)

  defp assign_to_socket(socket, name, struct) do
    socket
    |> assign(name, Map.from_struct(struct))
    |> assign_meta_tags(struct)
  end

  defp assign_meta_tags(socket, struct) do
    struct
    |> Map.from_struct()
    |> convert_name_to_title()
    |> convert_image_to_url()
    |> atomize_keys_to_string()
    |> then(&assign(socket, :meta_tags, &1))
  end

  defp convert_name_to_title(author_or_tag),
    do: Map.put_new(author_or_tag, :title, author_or_tag[:name])

  defp convert_image_to_url(author_or_tag_or_post) do
    author_or_tag_or_post
    |> Map.put(:og_image, literature_image_url(author_or_tag_or_post, :og_image))
    |> Map.put(:twitter_image, literature_image_url(author_or_tag_or_post, :twitter_image))
  end
end