defmodule LaurasHideout.StashManagement do
  alias LaurasHideout.PoeApi
  alias LaurasHideout.StashManagement.AccountStash
  alias LaurasHideout.Repo
  alias LaurasHideout.Accounts.User

  def request_account_stashes(user, league) do
    with {:ok, reponse} <- PoeApi.get_account_stashes(user, league) do
      extract_account_stashes(reponse.body, user, league)
      |> insert_or_update_account_stashes()

      get_stashes(user.id)
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

    Repo.transaction(multi)
  end

  def get_stashes(user_id) do
    %User{id: user_id}
    |> Ecto.assoc(:account_stash)
    |> Repo.all()
  end
end
