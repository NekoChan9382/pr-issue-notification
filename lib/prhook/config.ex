defmodule PrIssueNotify.Config do
  alias PrIssueNotify.Queries
  @review_requested_name Queries.review_requested_name()
  @assigned_issues_name Queries.assigned_issues_name()

  @colors %{
    @review_requested_name => 0x8957E5,
    @assigned_issues_name => 0xBD561D
  }

  @type_labels %{
    @review_requested_name => "Review Requested PRs",
    @assigned_issues_name => "Assigned Issues"
  }

  def get_color(type) do
    Map.get(@colors, type, 0x000000)
  end

  def get_label(type) do
    Map.get(@type_labels, type, "Unknown")
  end
end
