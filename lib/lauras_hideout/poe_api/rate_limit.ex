defmodule LaurasHideout.PoeApi.RateLimit do
  defstruct [:rule, :policy, :max_hits, :period, :penality]
  alias LaurasHideout.PoeApi.RateLimit

  def to_bucket_name(%RateLimit{} = rate_limit, token \\ nil) do
    base =
      "#{rate_limit.policy}-#{rate_limit.rule}-#{rate_limit.max_hits}-#{rate_limit.period}-#{rate_limit.penality}"

    if rate_limit.rule == "account" do
      "#{base}-#{token}"
    else
      base
    end
  end

  @doc """
  Parses the headers of an PoeApi Response for the rate limits

  ## Examples

      iex> RateLimit.get_rate_limits_from_headers(%{
      ...> "x-rate-limit-account" => ["2:10:60,5:300:300"],
      ...> "x-rate-limit-account-state" => ["1:10:0,1:300:0"],
      ...> "x-rate-limit-policy" => ["character-list-request-limit"],
      ...> "x-rate-limit-rules" => ["Account"]
      ...> })
      [
        %RateLimit{rule: "account", policy: "character-list-request-limit", max_hits: 2, period: 10000, penality: 60000},
        %RateLimit{rule: "account", policy: "character-list-request-limit", max_hits: 5, period: 300000, penality: 300000}
      ]
  """
  def get_rate_limits_from_headers(headers) do
    with {:ok, [rules]} <- Map.fetch(headers, "x-rate-limit-rules"),
         {:ok, [policy]} <- Map.fetch(headers, "x-rate-limit-policy"),
         rules <- String.downcase(rules),
         rules_array <- String.split(rules, ",") do
      rate_limits =
        Enum.map(rules_array, fn rule -> get_rate_limits_for_rule(headers, rule, policy) end)

      List.flatten(rate_limits)
    else
      _ -> nil
    end
  end

  defp get_rate_limits_for_rule(headers, rule, policy) do
    with {:ok, [limits]} <- Map.fetch(headers, "x-rate-limit-#{rule}"),
         limits_array <- String.split(limits, ",") do
      Enum.map(limits_array, fn limit -> create_rate_limit(limit, rule, policy) end)
    end
  end

  defp create_rate_limit(limits, rule, policy) do
    [max_hits, period, penality] = String.split(limits, ":")

    %RateLimit{
      rule: rule,
      policy: policy,
      max_hits: String.to_integer(max_hits),
      period: String.to_integer(period) * 1000,
      penality: String.to_integer(penality) * 1000
    }
  end

  @doc """
  Parses the headers of an PoeApi Reponse to check if a rate limit
  was triggered.

  Logs the incident for future investigation.

  ## Examples

      iex> RateLimit.rate_limit_triggered?(%{
      ...> "retry-after" => ["60"]
      ...> })
      true
  """
  def rate_limit_triggered?(headers) do
    if Map.has_key?(headers, "retry-after") do
      # TODO: log incident, and actually use it in get_endpoint
      true
    else
      false
    end
  end
end
