defmodule LaurasHideout.StashManagement do
  alias LaurasHideout.PoeApi
  alias LaurasHideout.StashManagement.{AccountStashInfo, AccountStashSnapshot}
  alias LaurasHideout.Repo
  import Ecto.Query

  def refresh_account_stashes(user, league) do
    with {:ok, response} <- PoeApi.get_account_stashes(user, league),
         stashes <- extract_account_stashes(response.body),
         {:ok, _} <- insert_or_update_account_stashes(stashes, user, league) do
      {:ok, stashes}
    end
  end

  def refresh_account_stash(user, league, id) do
    with {:ok, response} <- PoeApi.get_account_stash(user, league, id),
         items <- extract_items(response.body),
         {:ok, _} <- insert_or_update_account_stash(user, league, id, items) do
      {:ok, items}
    end
  end

  def extract_items(response_body) do
    response_body["stash"]["items"]
  end

  def insert_or_update_account_stash(user, league, id, items) do
    %AccountStashSnapshot{}
    |> AccountStashSnapshot.changeset(%{
      user_id: user.id,
      league: league,
      stash_id: id,
      items: items
    })
    |> Repo.insert()
  end

  @doc """
  Flattens any folder with its children and removes folders
  """
  def extract_account_stashes(response_body) do
    response_body["stashes"]
    |> flatten_children()
    |> filter_folders()
  end

  defp flatten_children(stashes) do
    stashes
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
  end

  defp filter_folders(stashes) do
    Enum.filter(stashes, fn stash ->
      stash["type"] != "Folder"
    end)
  end

  def convert_account_stashes(stashes) do
    Enum.map(stashes, fn stash ->
      changeset =
        %AccountStashInfo{}
        |> AccountStashInfo.changeset(stash)

      changeset.changes
    end)
  end

  def insert_or_update_account_stashes(stashes, user, league) do
    %AccountStashInfo{}
    |> AccountStashInfo.changeset(%{
      user_id: user.id,
      league: league,
      stashes: stashes
    })
    |> Repo.insert(
      on_conflict: [set: [stashes: stashes, updated_at: DateTime.utc_now()]],
      conflict_target: [:user_id, :league]
    )
  end

  def get_stash_infos(user_id, league) do
    query =
      from a in AccountStashInfo,
        where: a.user_id == ^user_id,
        where: a.league == ^league

    case Repo.one(query) do
      nil -> []
      stash_infos -> stash_infos.stashes
    end
  end

  def get_stash_snapshot(stash_id) do
    case Repo.one(
           from s in AccountStashSnapshot,
             where: s.stash_id == ^stash_id
         ) do
      nil -> nil
      changeset -> %{items: changeset.items, last_refresh: changeset.updated_at}
    end
  end
end
