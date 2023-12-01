defmodule LaurasHideout.Schema do
  @moduledoc """
  Custom `use LaurasHideout.Schema` instead of `Ecto.Schema`
  with `:binary_id` as default type for keys and `:utc_datetime`
  for timestamps.

  See also `migration_primary_key` and `migration_timestamps` in the
  config to use them as defaults for migrations.
  """
  defmacro __using__(_opts) do
    quote do
      use Ecto.Schema
      @timestamps_opts [type: :utc_datetime]
      @foreign_key_type :binary_id
      @primary_key {:id, :binary_id, autogenerate: true}
    end
  end
end
