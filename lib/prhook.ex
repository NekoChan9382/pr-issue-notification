defmodule Prhook do
  @moduledoc """
  Documentation for `Prhook`.
  """

  @doc """
  Hello world.

  ## Examples

      iex> Prhook.hello()
      :world

  """
  def hello do
    _js = "{\"query\":\"{ search(query: \"is:pr review-requested:@me\", type: ISSUE, first: 100) { issueCount nodes { ... on PullRequest { number title url repository { nameWithOwner url } } } } }\"}"
    :world
  end
end
