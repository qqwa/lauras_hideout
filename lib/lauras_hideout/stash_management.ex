defmodule LaurasHideout.StashManagement do
  alias LaurasHideout.PoeApi
  alias LaurasHideout.StashManagement.AccountStash
  alias LaurasHideout.Repo
  alias LaurasHideout.Accounts.User
  import Ecto.Query

  def request_account_stashes(user, league) do
    with {:ok, reponse} <- PoeApi.get_account_stashes(user, league),
         stashes <- extract_account_stashes(reponse.body, user, league),
         {:ok, _} <- insert_or_update_account_stashes(stashes) do
      {:ok, convert_account_stashes(stashes)}
    end
  end

  @doc """
  Flattens any folder with its children
  """
  def extract_account_stashes(response_body, user, league) do
    response_body["stashes"]
    |> Enum.map(fn stash ->
      if stash["type"] == "Folder" do
        children =
          stash["children"]
          |> Enum.map(fn child -> [child] end)
          |> List.flatten()

        stash = Map.delete(stash, "children")
        [stash | children]
      else
        stash
      end
    end)
    |> List.flatten()
    |> Enum.map(fn stash ->
      stash
      |> Map.put("user_id", user.id)
      |> Map.put("league", league)
    end)
  end

  def convert_account_stashes(stashes) do
    Enum.map(stashes, fn stash ->
      changeset =
        %AccountStash{}
        |> AccountStash.changeset(stash)

      changeset.changes
    end)
  end

  def insert_or_update_account_stashes(stashes) do
    multi = Ecto.Multi.new()

    multi =
      Enum.reduce(stashes, multi, fn stash, multi ->
        changeset =
          case Repo.get(AccountStash, stash["id"]) do
            nil -> %AccountStash{}
            account_stash -> account_stash
          end
          |> AccountStash.changeset(stash)

        Ecto.Multi.insert_or_update(multi, stash["id"], changeset)
      end)

    Repo.transaction(multi)
  end

  def get_stashes(user_id, league) do
    query =
      from a in AccountStash,
        where: a.user_id == ^user_id,
        where: a.league == ^league,
        order_by: a.index

    Repo.all(query)
  end
end
