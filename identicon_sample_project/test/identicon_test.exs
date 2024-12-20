defmodule IdenticonTest do
  use ExUnit.Case
  doctest Identicon

  test ".compute_hash always generates hex with list of 16 integers" do
    assert length(Identicon.compute_hash("long long test string").hex) == 16
  end
end
