defmodule Prhook do
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

  def hello do
    :world
  end
end
