defmodule Tsuchinokus.Release do
  @app :tsuchinokus

  def migrate do
    load_app()

    for repo <- repos() do
      {:ok, _, _} = Ecto.Migrator.with_repo(repo, &Ecto.Migrator.run(&1, :up, all: true))
    end
  end

  def rollback(repo, version) do
    load_app()
    {:ok, _, _} = Ecto.Migrator.with_repo(repo, &Ecto.Migrator.run(&1, :down, to: version))
  end

  def update_channels do
    start_app()
    Tsuchinokus.Channels.update_tracked_channels!()
  end

  def verify_artist_links do
    start_app()
    Tsuchinokus.ArtistLinks.automatic_verify!()
  end

  def update_stats do
    start_app()
    TsuchinokusWeb.StatsUpdater.update_stats!()
  end

  def clean_moderation_logs do
    start_app()
    Tsuchinokus.ModerationLogs.cleanup!()
  end

  def generate_autocomplete do
    start_app()
    Tsuchinokus.Autocomplete.generate_autocomplete!()
  end

  defp repos do
    Application.fetch_env!(@app, :ecto_repos)
  end

  defp load_app do
    Application.load(@app)
  end

  defp start_app do
    Application.ensure_all_started(@app)
  end
end
