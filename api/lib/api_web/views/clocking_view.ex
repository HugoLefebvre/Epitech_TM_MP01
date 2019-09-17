defmodule ApiWeb.ClockingView do
  use ApiWeb, :view
  alias ApiWeb.ClockingView

  def render("index.json", %{clocks: clocks}) do
    %{data: render_many(clocks, ClockingView, "clocking.json")}
  end

  def render("show.json", %{clocking: clocking}) do
    %{data: render_one(clocking, ClockingView, "clocking.json")}
  end

  def render("clocking.json", %{clocking: clocking}) do
    %{id: clocking.id,
      time: clocking.time,
      status: clocking.status,
      user: clocking.user_a}
  end
end
