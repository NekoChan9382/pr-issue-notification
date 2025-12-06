defmodule PrIssueNotify do
  alias PrIssueNotify.Queries
  alias PrIssueNotify.Config

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
    {type, nodes} = body

    nodes["nodes"]
    |> Enum.group_by(&get_in(&1, ["repository", "nameWithOwner"]))
    |> Enum.map(fn {repo_name, issues} ->
      first_issue = List.first(issues)
      repo_url = get_in(first_issue, ["repository", "url"])

      %{
        type: type,
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

  def make_summary_msg(body_data) do
    uid = System.get_env("DISCORD_UID")

    summary =
      if uid && uid != "" do
        "<@#{uid}>\n"
      else
        ""
      end

    summary =
      summary <>
        (body_data
         |> Enum.map(fn {type, data} ->
           count = data["issueCount"] || 0
           label = Config.get_label(type)
           "#{label}: **#{count}**"
         end)
         |> Enum.join("\n"))

    %{
      embeds: [
        %{
          title: "PR Issue Summary",
          description: summary,
          color: 0x5865F2
        }
      ]
    }
  end

  def make_discord_msg(data) do
    %{
      embeds: [
        %{
          title: Config.get_label(data.type) <> " on " <> get_in(data, [:repository, :name]),
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
          color: Config.get_color(data.type)
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
    case get_api_data(Queries.query()) do
      {:ok, body} ->
        data = body["data"]
        make_summary_msg(data) |> send_webhook()

        data
        |> Enum.map(fn item ->
          parse_body(item)
          |> Enum.map(fn data -> make_discord_msg(data) |> send_webhook() end)
        end)

      {:error, status, body} ->
        {:error, status, body}

      {:error, reason} ->
        {:error, reason}
    end
  end
end
