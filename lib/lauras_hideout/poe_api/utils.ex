defmodule LaurasHideout.PoeApi.Utils do
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

  def get_endpoint(endpoint, token, request) do
    rate_limits = RateLimitsList.get_rate_limits(endpoint)

    # if rate_limits exists, we check the rate limits and return {:error, _}
    # when at least one would be hit
    if rate_limits do
      if Enum.all?(rate_limits, fn rate_limit -> check_rate_limit(rate_limit, token) end) do
        with {:ok, response} <- request.() do
          new_rate_limits = RateLimit.get_rate_limits_from_headers(response.headers)
          RateLimitsList.maybe_update_rate_limits(endpoint, new_rate_limits)
          {:ok, response}
        end
      else
        {:error, "Would hit rate limit"}
      end

      # if no rate_limits exists, we assume it is save to call the endpoint, and will
      # call check_rate_limit after the fact, to account for the request we just did
    else
      with {:ok, response} <- request.() do
        new_rate_limits = RateLimit.get_rate_limits_from_headers(response.headers)
        RateLimitsList.maybe_update_rate_limits(endpoint, new_rate_limits)
        Enum.each(new_rate_limits, fn rate_limit -> check_rate_limit(rate_limit, token) end)
        {:ok, response}
      end
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

  def service_token(), do: Application.get_env(:lauras_hideout, :service_token)
end
