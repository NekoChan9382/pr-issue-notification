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

  def hello do
    :world
  end
end
