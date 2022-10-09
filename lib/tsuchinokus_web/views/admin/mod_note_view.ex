defmodule TsuchinokusWeb.Admin.ModNoteView do
  use TsuchinokusWeb, :view

  alias Tsuchinokus.Users.User
  alias Tsuchinokus.Reports.Report
  alias Tsuchinokus.DnpEntries.DnpEntry

  def link_to_noted_thing(conn, %DnpEntry{requesting_user: user} = dnp_entry),
    do: link("#{user.name}'s DNP entry", to: Routes.dnp_entry_path(conn, :show, dnp_entry))

  def link_to_noted_thing(conn, %Report{user: nil} = report),
    do: link("Report #{report.id}", to: Routes.admin_report_path(conn, :show, report))

  def link_to_noted_thing(conn, %Report{user: user} = report),
    do:
      link("Report #{report.id} by #{user.name}",
        to: Routes.admin_report_path(conn, :show, report)
      )

  def link_to_noted_thing(conn, %User{} = user),
    do: link("User #{user.name}", to: Routes.profile_path(conn, :show, user))

  def link_to_noted_thing(_conn, _notable), do: "Item permanently deleted"
end
