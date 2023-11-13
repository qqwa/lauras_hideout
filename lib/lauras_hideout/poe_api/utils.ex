defmodule LaurasHideout.PoeApi.Utils do
  require Logger
  alias LaurasHideout.Repo
  alias LaurasHideout.PoeApi.Log
  alias LaurasHideout.PoeApi.RateLimit
  alias LaurasHideout.PoeApi.RateLimitsList

  @base_url_api "https://api.pathofexile.com"

  def user_agent() do
    client_id = to_string(Application.get_env(:lauras_hideout, :client_id))
    version = LaurasHideout.Application.version()
    "OAuth #{client_id}/#{version} (contact: benjamin.baeumler@qqwa.de)"
  end

  def client() do
    Req.new(base_url: @base_url_api, user_agent: user_agent())
  end

  def client_with_token(token) do
    client()
    |> Req.Request.merge_options(auth: {:bearer, token})
  end

  def get_endpoint(endpoint, user, request) do
    with {:ok, update_rate_limits} <- check_rate_limits(endpoint, user.token),
         {:ok, response} <- request.() do
      # post request tasks
      update_rate_limits.(response.headers)
      log_response(endpoint, user, response)
      {:ok, response}
    end
  end

  def log_response(endpoint, user, response) do
    metadata = %{username: user.username, endpoint: endpoint, status: response.status}

    case response.status do
      status when status in [200, 202] ->
        %Log{}
        |> Log.changeset(metadata)
        |> Repo.insert()

      _ ->
        metadata = Map.put(metadata, :message, "#{response}")

        %Log{}
        |> Log.changeset(metadata)
        |> Repo.insert()
    end
  end

  # returns a function that will take the headers of the response to eventually
  # update the rate limits
  defp check_rate_limits(endpoint, token) do
    rate_limits = RateLimitsList.get_rate_limits(endpoint)

    if rate_limits do
      if Enum.all?(rate_limits, fn rate_limit -> check_rate_limit(rate_limit, token) end) do
        {:ok,
         fn headers ->
           new_rate_limits = RateLimit.get_rate_limits_from_headers(headers)
           RateLimitsList.maybe_update_rate_limits(endpoint, new_rate_limits)
         end}
      else
        {:error, "Rate limited would be hit"}
      end
    else
      {:ok,
       fn headers ->
         new_rate_limits = RateLimit.get_rate_limits_from_headers(headers)
         RateLimitsList.maybe_update_rate_limits(endpoint, new_rate_limits)
         Enum.each(new_rate_limits, fn rate_limit -> check_rate_limit(rate_limit, token) end)
       end}
    end
  end

  def check_rate_limit(%RateLimit{} = rate_limit, token) do
    case ExRated.check_rate(
           RateLimit.to_bucket_name(rate_limit, token),
           rate_limit.period,
           rate_limit.max_hits
         ) do
      {:ok, _} -> true
      _ -> false
    end
  end

  def inspect_rate_limits(endpoint, token) do
    rate_limits = RateLimitsList.get_rate_limits(endpoint)

    if rate_limits do
      Enum.map(rate_limits, fn rate_limit ->
        ExRated.inspect_bucket(
          RateLimit.to_bucket_name(rate_limit, token),
          rate_limit.period,
          rate_limit.max_hits
        )
      end)
    else
      nil
    end
  end

  def service_token(),
    do: %{
      username: "__service_token__",
      token: Application.get_env(:lauras_hideout, :service_token)
    }
end
