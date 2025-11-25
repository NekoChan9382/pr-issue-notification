defmodule PrIssueNotify.Queries do
  @review_requested_name "reviewRequestedPr"
  @assigned_issues_name "assignedIssues"

  @review_requested_query "is:pr is:open review-requested:@me"
  @assigned_issues_query "is:issue is:open assignee:@me"

  @query_template """
  query {
      {pr_name}: search(query: "{pr_query}", type: ISSUE, first: 100) {
        issueCount
        nodes {
          ... on PullRequest {
            number
            title
            url
            repository {
              nameWithOwner
              url
            }
          }
        }
      }

      {issue_name}: search(query: "{issue_query}", type: ISSUE, first: 100) {
        issueCount
        nodes {
          ... on Issue {
            number
            title
            url
            repository {
              nameWithOwner
              url
            }
          }
        }
      }
    }
  """
  def query do
    @query_template
    |> String.replace("{pr_name}", @review_requested_name)
    |> String.replace("{issue_name}", @assigned_issues_name)
    |> String.replace("{pr_query}", @review_requested_query)
    |> String.replace("{issue_query}", @assigned_issues_query)
  end

  def review_requested_name, do: @review_requested_name
  def assigned_issues_name, do: @assigned_issues_name
end
