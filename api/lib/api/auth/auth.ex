defmodule Api.Auth do
  @moduledoc """
  The Auth context.
  """

  import Ecto.Query, warn: false
  alias Api.Repo

  alias Api.Auth.User

  @doc """
  Returns the list of users.

  ## Examples

      iex> list_users()
      [%User{}, ...]

  """
  def list_users do
    Repo.all(User)
  end

  @doc """
  Gets a single user.

  Raises `Ecto.NoResultsError` if the User does not exist.

  ## Examples

      iex> get_user!(123)
      %User{}

      iex> get_user!(456)
      ** (Ecto.NoResultsError)

  """
  def get_user!(id), do: Repo.get!(User, id)

  @doc """
  Creates a user.

  ## Examples

      iex> create_user(%{field: value})
      {:ok, %User{}}

      iex> create_user(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_user(attrs \\ %{}) do
    %User{}
    |> User.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a user.

  ## Examples

      iex> update_user(user, %{field: new_value})
      {:ok, %User{}}

      iex> update_user(user, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_user(%User{} = user, attrs) do
    user
    |> User.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a User.

  ## Examples

      iex> delete_user(user)
      {:ok, %User{}}

      iex> delete_user(user)
      {:error, %Ecto.Changeset{}}

  """
  def delete_user(%User{} = user) do
    Repo.delete(user)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking user changes.

  ## Examples

      iex> change_user(user)
      %Ecto.Changeset{source: %User{}}

  """
  def change_user(%User{} = user) do
    User.changeset(user, %{})
  end

  alias Api.Auth.Clocking

  @doc """
  Returns the list of clocks.

  ## Examples

      iex> list_clocks()
      [%Clocking{}, ...]

  """
  def list_clocks do
    Repo.all(Clocking)
  end

  @doc """
  Gets a single clocking.

  Raises `Ecto.NoResultsError` if the Clocking does not exist.

  ## Examples

      iex> get_clocking!(123)
      %Clocking{}

      iex> get_clocking!(456)
      ** (Ecto.NoResultsError)

  """
  def get_clocking!(id), do: Repo.get!(Clocking, id)

  @doc """
  Creates a clocking.

  ## Examples

      iex> create_clocking(%{field: value})
      {:ok, %Clocking{}}

      iex> create_clocking(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_clocking(attrs \\ %{}) do
    %Clocking{}
    |> Clocking.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a clocking.

  ## Examples

      iex> update_clocking(clocking, %{field: new_value})
      {:ok, %Clocking{}}

      iex> update_clocking(clocking, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_clocking(%Clocking{} = clocking, attrs) do
    clocking
    |> Clocking.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a Clocking.

  ## Examples

      iex> delete_clocking(clocking)
      {:ok, %Clocking{}}

      iex> delete_clocking(clocking)
      {:error, %Ecto.Changeset{}}

  """
  def delete_clocking(%Clocking{} = clocking) do
    Repo.delete(clocking)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking clocking changes.

  ## Examples

      iex> change_clocking(clocking)
      %Ecto.Changeset{source: %Clocking{}}

  """
  def change_clocking(%Clocking{} = clocking) do
    Clocking.changeset(clocking, %{})
  end

  alias Api.Auth.WorkingTime

  @doc """
  Returns the list of workingtimes.

  ## Examples

      iex> list_workingtimes()
      [%WorkingTime{}, ...]

  """
  def list_workingtimes do
    Repo.all(WorkingTime)
  end

  @doc """
  Gets a single working_time.

  Raises `Ecto.NoResultsError` if the Working time does not exist.

  ## Examples

      iex> get_working_time!(123)
      %WorkingTime{}

      iex> get_working_time!(456)
      ** (Ecto.NoResultsError)

  """
  def get_working_time!(id), do: Repo.get!(WorkingTime, id)

  @doc """
  Creates a working_time.

  ## Examples

      iex> create_working_time(%{field: value})
      {:ok, %WorkingTime{}}

      iex> create_working_time(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_working_time(attrs \\ %{}) do
    %WorkingTime{}
    |> WorkingTime.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a working_time.

  ## Examples

      iex> update_working_time(working_time, %{field: new_value})
      {:ok, %WorkingTime{}}

      iex> update_working_time(working_time, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_working_time(%WorkingTime{} = working_time, attrs) do
    working_time
    |> WorkingTime.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a WorkingTime.

  ## Examples

      iex> delete_working_time(working_time)
      {:ok, %WorkingTime{}}

      iex> delete_working_time(working_time)
      {:error, %Ecto.Changeset{}}

  """
  def delete_working_time(%WorkingTime{} = working_time) do
    Repo.delete(working_time)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking working_time changes.

  ## Examples

      iex> change_working_time(working_time)
      %Ecto.Changeset{source: %WorkingTime{}}

  """
  def change_working_time(%WorkingTime{} = working_time) do
    WorkingTime.changeset(working_time, %{})
  end
end
