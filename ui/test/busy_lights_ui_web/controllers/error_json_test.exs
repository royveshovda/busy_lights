defmodule BusyLightsUiWeb.ErrorJSONTest do
  use BusyLightsUiWeb.ConnCase, async: true

  test "renders 404" do
    assert BusyLightsUiWeb.ErrorJSON.render("404.json", %{}) == %{errors: %{detail: "Not Found"}}
  end

  test "renders 500" do
    assert BusyLightsUiWeb.ErrorJSON.render("500.json", %{}) ==
             %{errors: %{detail: "Internal Server Error"}}
  end
end
