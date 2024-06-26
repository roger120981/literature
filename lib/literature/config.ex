defmodule Literature.Config do
  @moduledoc false

  @default_30_days 60 * 60 * 24 * 30
  @default_cloudflare_api_host "https://api.cloudflare.com/client/v4"
  @default_locales ~w(en)

  def logo,
    do: Application.get_env(:literature, :image_path)

  def title,
    do: Application.get_env(:literature, :page_title)

  def repo,
    do: Application.get_env(:literature, :repo)

  def env,
    do: Application.get_env(:literature, :env)

  def ttl,
    do: Application.get_env(:literature, :ttl, @default_30_days)

  # Cloudflare Config

  def cloudflare_api_host, do: cloudflare_config()[:api_host] || @default_cloudflare_api_host
  def cloudflare_identifier, do: cloudflare_config()[:identifier]
  def cloudflare_token, do: cloudflare_config()[:token]
  def cloudflare_locales, do: cloudflare_config()[:locales] || @default_locales

  def cloudflare_config,
    do: Application.get_env(:literature, :cloudflare)

  # Waffle Config

  def waffle_asset_host,
    do: Application.get_env(:literature, :asset_host)

  def waffle_bucket,
    do: Application.get_env(:literature, :bucket)

  def waffle_storage,
    do: Application.get_env(:literature, :storage)

  def waffle_width_step,
    do: Application.get_env(:literature, :width_step, 100)

  # Sitemap Config

  def sitemap_changefreq, do: sitemap_config()[:changefreq]
  def sitemap_path, do: sitemap_config()[:path]
  def sitemap_router, do: sitemap_config()[:router]
  def sitemap_url, do: sitemap_config()[:url]

  defp sitemap_config,
    do: Application.get_env(:literature, :sitemap)
end
