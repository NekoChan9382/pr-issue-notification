defmodule PrIssueNotify do
  def query do
    """
    query {
      search(query: "is:pr is:open review-requested:@me", type: ISSUE, first: 100) {
        issueCount
        nodes {
          ... on PullRequest {
            number
            title
            url
            repository { nameWithOwner url }
          }
        }
      }
    }
    """
  end

  def webhook_json_fields(issue_name, issue_url) do
    %{
      name: issue_name,
      value: issue_url
    }
  end

  def get_api_data(query, token \\ System.get_env("GITHUB_TOKEN")) do
    res =
      Req.new(
        url: "https://api.github.com/graphql",
        headers: [{"Authorization", "Bearer " <> token}, {"content-type", "application/json"}],
        json: %{query: query}
      )
      |> Req.post()

    case res do
      {:ok, %Req.Response{status: 200, body: body}} -> {:ok, body}
      {:ok, %Req.Response{status: status, body: body}} -> {:error, status, body}
      {:error, reason} -> {:error, reason}
    end
  end

  def parse_body(body) do
    nodes = get_in(body, ["data", "search", "nodes"]) || []

    nodes
    |> Enum.group_by(&get_in(&1, ["repository", "nameWithOwner"]))
    |> Enum.map(fn {repo_name, issues} ->
      first_issue = List.first(issues)
      repo_url = get_in(first_issue, ["repository", "url"])

      %{
        repository: %{
          name: repo_name,
          url: repo_url
        },
        issues:
          Enum.map(issues, fn issue ->
            %{
              number: issue["number"],
              title: issue["title"],
              url: issue["url"]
            }
          end)
      }
    end)
  end

  def make_discord_msg(data) do
    %{
      embeds: [
        %{
          title: "Pull Request on " <> get_in(data, [:repository, :name]),
          url: get_in(data, [:repository, :url]),
          fields:
            Enum.map(
              get_in(data, [:issues]),
              fn issue ->
                webhook_json_fields(
                  # issue[:number] <> " " <> issue[:title],"
                  "#" <> to_string(issue[:number]) <> " " <> issue[:title],
                  issue[:url]
                )
              end
            ),
          color: 0x8957E5
        }
      ]
    }
  end

  def send_webhook(msg, url \\ System.get_env("DISCORD_WEBHOOK_URL")) do
    res =
      Req.new(
        url: url,
        headers: [{"content-type", "application/json"}],
        json: msg
      )
      |> Req.post()

    case res do
      {:ok, %Req.Response{status: 204}} -> :ok
      {:ok, %Req.Response{status: status, body: body}} -> {:error, status, body}
      {:error, reason} -> {:error, reason}
    end
  end

  def main do
    case get_api_data(query()) do
      {:ok, body} ->
        parse_body(body) |> Enum.map(fn data -> make_discord_msg(data) |> send_webhook() end)

      {:error, status, body} ->
        {:error, status, body}

      {:error, reason} ->
        {:error, reason}
    end
  end
end
