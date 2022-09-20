defmodule Literature.Author do
  use Literature.Web, :model

  schema "literature_authors" do
    field(:slug, :string)
    field(:name, :string)
    field(:profile_image, Uploader.Type)
    field(:cover_image, Uploader.Type)
    field(:bio, :string)
    field(:website, :string)
    field(:location, :string)
    field(:facebook, :string)
    field(:twitter, :string)
    field(:meta_title, :string)
    field(:meta_description, :string)

    belongs_to(:publication, Publication)

    has_many(:posts, Post, foreign_key: :primary_author_id)

    timestamps()
  end

  @required_params ~w(
    publication_id
    slug
    name
  )a

  @optional_params ~w(
    bio
    website
    location
    facebook
    twitter
    meta_title
    meta_description
  )a

  @attachments ~w(
    profile_image
    cover_image
  )a

  @doc false
  def changeset(author, params) do
    author
    |> cast(params, @required_params ++ @optional_params)
    |> cast_attachments(params, @attachments)
    |> maybe_generate_slug(author)
    |> validate_required(@required_params, message: "This field is required")
    |> unique_constraint(:slug)
  end

  defp maybe_generate_slug(changeset, %{name: name, slug: slug}) when name != slug,
    do: changeset

  defp maybe_generate_slug(changeset, %{slug: nil}),
    do: slugify(changeset, :name)

  defp maybe_generate_slug(changeset, _), do: changeset
end
