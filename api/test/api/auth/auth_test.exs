defmodule Api.AuthTest do
  use Api.DataCase

  alias Api.Auth

  describe "users" do
    alias Api.Auth.User

    @valid_attrs %{email: "some email", username: "some username"}
    @update_attrs %{email: "some updated email", username: "some updated username"}
    @invalid_attrs %{email: nil, username: nil}

    def user_fixture(attrs \\ %{}) do
      {:ok, user} =
        attrs
        |> Enum.into(@valid_attrs)
        |> Auth.create_user()

      user
    end

    test "list_users/0 returns all users" do
      user = user_fixture()
      assert Auth.list_users() == [user]
    end

    test "get_user!/1 returns the user with given id" do
      user = user_fixture()
      assert Auth.get_user!(user.id) == user
    end

    test "create_user/1 with valid data creates a user" do
      assert {:ok, %User{} = user} = Auth.create_user(@valid_attrs)
      assert user.email == "some email"
      assert user.username == "some username"
    end

    test "create_user/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Auth.create_user(@invalid_attrs)
    end

    test "update_user/2 with valid data updates the user" do
      user = user_fixture()
      assert {:ok, user} = Auth.update_user(user, @update_attrs)
      assert %User{} = user
      assert user.email == "some updated email"
      assert user.username == "some updated username"
    end

    test "update_user/2 with invalid data returns error changeset" do
      user = user_fixture()
      assert {:error, %Ecto.Changeset{}} = Auth.update_user(user, @invalid_attrs)
      assert user == Auth.get_user!(user.id)
    end

    test "delete_user/1 deletes the user" do
      user = user_fixture()
      assert {:ok, %User{}} = Auth.delete_user(user)
      assert_raise Ecto.NoResultsError, fn -> Auth.get_user!(user.id) end
    end

    test "change_user/1 returns a user changeset" do
      user = user_fixture()
      assert %Ecto.Changeset{} = Auth.change_user(user)
    end
  end

  describe "clocks" do
    alias Api.Auth.Clocking

    @valid_attrs %{status: true, time: ~N[2010-04-17 14:00:00.000000]}
    @update_attrs %{status: false, time: ~N[2011-05-18 15:01:01.000000]}
    @invalid_attrs %{status: nil, time: nil}

    def clocking_fixture(attrs \\ %{}) do
      {:ok, clocking} =
        attrs
        |> Enum.into(@valid_attrs)
        |> Auth.create_clocking()

      clocking
    end

    test "list_clocks/0 returns all clocks" do
      clocking = clocking_fixture()
      assert Auth.list_clocks() == [clocking]
    end

    test "get_clocking!/1 returns the clocking with given id" do
      clocking = clocking_fixture()
      assert Auth.get_clocking!(clocking.id) == clocking
    end

    test "create_clocking/1 with valid data creates a clocking" do
      assert {:ok, %Clocking{} = clocking} = Auth.create_clocking(@valid_attrs)
      assert clocking.status == true
      assert clocking.time == ~N[2010-04-17 14:00:00.000000]
    end

    test "create_clocking/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Auth.create_clocking(@invalid_attrs)
    end

    test "update_clocking/2 with valid data updates the clocking" do
      clocking = clocking_fixture()
      assert {:ok, clocking} = Auth.update_clocking(clocking, @update_attrs)
      assert %Clocking{} = clocking
      assert clocking.status == false
      assert clocking.time == ~N[2011-05-18 15:01:01.000000]
    end

    test "update_clocking/2 with invalid data returns error changeset" do
      clocking = clocking_fixture()
      assert {:error, %Ecto.Changeset{}} = Auth.update_clocking(clocking, @invalid_attrs)
      assert clocking == Auth.get_clocking!(clocking.id)
    end

    test "delete_clocking/1 deletes the clocking" do
      clocking = clocking_fixture()
      assert {:ok, %Clocking{}} = Auth.delete_clocking(clocking)
      assert_raise Ecto.NoResultsError, fn -> Auth.get_clocking!(clocking.id) end
    end

    test "change_clocking/1 returns a clocking changeset" do
      clocking = clocking_fixture()
      assert %Ecto.Changeset{} = Auth.change_clocking(clocking)
    end
  end

  describe "workingtimes" do
    alias Api.Auth.WorkingTime

    @valid_attrs %{end: ~N[2010-04-17 14:00:00.000000], start: ~N[2010-04-17 14:00:00.000000]}
    @update_attrs %{end: ~N[2011-05-18 15:01:01.000000], start: ~N[2011-05-18 15:01:01.000000]}
    @invalid_attrs %{end: nil, start: nil}

    def working_time_fixture(attrs \\ %{}) do
      {:ok, working_time} =
        attrs
        |> Enum.into(@valid_attrs)
        |> Auth.create_working_time()

      working_time
    end

    test "list_workingtimes/0 returns all workingtimes" do
      working_time = working_time_fixture()
      assert Auth.list_workingtimes() == [working_time]
    end

    test "get_working_time!/1 returns the working_time with given id" do
      working_time = working_time_fixture()
      assert Auth.get_working_time!(working_time.id) == working_time
    end

    test "create_working_time/1 with valid data creates a working_time" do
      assert {:ok, %WorkingTime{} = working_time} = Auth.create_working_time(@valid_attrs)
      assert working_time.end == ~N[2010-04-17 14:00:00.000000]
      assert working_time.start == ~N[2010-04-17 14:00:00.000000]
    end

    test "create_working_time/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Auth.create_working_time(@invalid_attrs)
    end

    test "update_working_time/2 with valid data updates the working_time" do
      working_time = working_time_fixture()
      assert {:ok, working_time} = Auth.update_working_time(working_time, @update_attrs)
      assert %WorkingTime{} = working_time
      assert working_time.end == ~N[2011-05-18 15:01:01.000000]
      assert working_time.start == ~N[2011-05-18 15:01:01.000000]
    end

    test "update_working_time/2 with invalid data returns error changeset" do
      working_time = working_time_fixture()
      assert {:error, %Ecto.Changeset{}} = Auth.update_working_time(working_time, @invalid_attrs)
      assert working_time == Auth.get_working_time!(working_time.id)
    end

    test "delete_working_time/1 deletes the working_time" do
      working_time = working_time_fixture()
      assert {:ok, %WorkingTime{}} = Auth.delete_working_time(working_time)
      assert_raise Ecto.NoResultsError, fn -> Auth.get_working_time!(working_time.id) end
    end

    test "change_working_time/1 returns a working_time changeset" do
      working_time = working_time_fixture()
      assert %Ecto.Changeset{} = Auth.change_working_time(working_time)
    end
  end
end
