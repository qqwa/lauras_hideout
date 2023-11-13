defmodule LaurasHideout.StashManagement do
  alias LaurasHideout.PoeApi
  alias LaurasHideout.StashManagement.AccountStash
  alias LaurasHideout.Repo

  def request_account_stashes(user, league) do
    with {:ok, reponse} <- PoeApi.get_account_stashes(user, league) do
      extract_account_stashes(reponse.body, user, league)
      |> insert_or_update_account_stashes()
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

    IO.inspect(Ecto.Multi.to_list(multi))
    Repo.transaction(multi)
    stashes
  end
end
