defmodule BusyLightsUiWeb.LightsController do
  use BusyLightsUiWeb, :controller

  @possible_colors [:red, :yellow, :green, :blank, :blue, :white]

  def show(conn, _params) do
    # authenticated users only
    self = Node.self()
    nodes = Node.list() ++ [self]
    light = BusyLightsUi.LightKeeper.get_light()


    conn
    |> json(%{color: light, nodes: nodes, current_node: self, possible_colors: @possible_colors})
  end

  def change(conn, %{"color" => color}) do
    self = Node.self()
    nodes = Node.list() ++ [self]

    case legal_color(color) do
      false ->
        conn
        |> put_status(400)
        |> json(%{message: "Not a legal color", nodes: nodes, current_node: self, possible_colors: @possible_colors})
      true ->
        c = String.to_atom(color)
        BusyLightsUi.LightKeeper.publish(c)
        conn
        |> json(%{color: color, nodes: nodes, current_node: self, possible_colors: @possible_colors})
    end
  end

  defp legal_color(color) do
    legal = @possible_colors |> Enum.map(fn x -> to_string(x) end)
    color in legal
  end
end
