defmodule Prhook do
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
        headers: [{"Authrization", "Bearer " <> token}, {"content-type", "application/json"}],
        json: %{query: query}
      )
      |> Req.post()

    case res do
      {:ok, %Req.Response{status: 200, body: body}} -> {:ok, body}
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
          title: data.repository.name,
          url: data.repository.url,
          fields:
            Enum.map(data.issues, &webhook_json_fields(&1.number <> " " <> &1.title, &1.url))
        }
      ]
    }
  end

  def hello do
    :world
  end
end
