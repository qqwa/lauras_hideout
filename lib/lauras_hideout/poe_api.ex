defmodule LaurasHideout.PoeApi do
  import LaurasHideout.PoeApi.Utils

  @doc """
  https://www.pathofexile.com/developer/docs/reference#leagues-list
  """
  def get_leagues() do
    endpoint = "/league"

    request = fn ->
      client_with_token(service_token())
      |> Req.get(url: endpoint)
    end

    get_endpoint(endpoint, service_token(), request)
  end

  @doc """
  https://www.pathofexile.com/developer/docs/reference#publicstashes-list
  """
  def get_public_stash_tabs(id \\ "") do
    endpoint = "/public-stash-tabs/id"

    request = fn ->
      client_with_token(service_token())
      |> Req.get(url: "#{endpoint}?id=#{id}")
    end

    get_endpoint(endpoint, service_token(), request)
  end

  @doc """
  https://www.pathofexile.com/developer/docs/reference#profile-get
  """
  def get_account_profile(token) do
    endpoint = "/profile"

    request = fn ->
      client_with_token(token)
      |> Req.get(url: endpoint)
    end

    get_endpoint(endpoint, token, request)
  end

  @doc """
  https://www.pathofexile.com/developer/docs/reference#accountleagues-list
  """
  def get_account_leagues(token) do
    endpoint = "/account/leagues"

    request = fn ->
      client_with_token(token)
      |> Req.get(url: endpoint)
    end

    get_endpoint(endpoint, token, request)
  end

  @doc """
  https://www.pathofexile.com/developer/docs/reference#characters-list
  """
  def get_characters(token) do
    endpoint = "/character"

    request = fn ->
      client_with_token(token)
      |> Req.get(url: endpoint)
    end

    get_endpoint(endpoint, token, request)
  end

  @doc """
  https://www.pathofexile.com/developer/docs/reference#characters-get
  """
  def get_character(token, character) do
    endpoint = "/character/"

    request = fn ->
      client_with_token(token)
      |> Req.get(url: "#{endpoint}#{character}")
    end

    get_endpoint(endpoint, token, request)
  end

  @doc """
  https://www.pathofexile.com/developer/docs/reference#stashes-list
  """
  def get_account_stashes(token, league) do
    endpoint = "/stash"

    request = fn ->
      client_with_token(token)
      |> Req.get(url: "#{endpoint}/#{league}")
    end

    get_endpoint(endpoint, token, request)
  end

  @doc """
  https://www.pathofexile.com/developer/docs/reference#stashes-get
  """
  def get_account_stash(token, league, stash_id) do
    endpoint = "/stash/"

    request = fn ->
      client_with_token(token)
      |> Req.get(url: "#{endpoint}#{league}/#{stash_id}")
    end

    get_endpoint(endpoint, token, request)
  end

  def get_account_stash(token, league, stash_id, substash_id) do
    # TODO: has this a different x-rate-limit-policy as without substash?
    endpoint = "/stash/"

    request = fn ->
      client_with_token(token)
      |> Req.get(url: "#{endpoint}#{league}/#{stash_id}/#{substash_id}")
    end

    get_endpoint(endpoint, token, request)
  end

  @doc """
  https://www.pathofexile.com/developer/docs/reference#leagueaccounts-get
  """
  def get_league_account(token, league) do
    endpoint = "/league-account"

    request = fn ->
      client_with_token(token)
      |> Req.get(url: "#{endpoint}/#{league}")
    end

    get_endpoint(endpoint, token, request)
  end

  @doc """
  https://www.pathofexile.com/developer/docs/reference#itemfilters-list
  """
  def get_item_filters(token) do
    endpoint = "/item-filter"

    request = fn ->
      client_with_token(token)
      |> Req.get(url: "#{endpoint}")
    end

    get_endpoint(endpoint, token, request)
  end

  @doc """
  https://www.pathofexile.com/developer/docs/reference#itemfilters-get
  """
  def get_item_filter(token, filter_id) do
    endpoint = "/item-filter/"

    request = fn ->
      client_with_token(token)
      |> Req.get(url: "#{endpoint}#{filter_id}")
    end

    get_endpoint(endpoint, token, request)
  end
end
