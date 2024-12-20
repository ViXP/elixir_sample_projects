defmodule CardsSampleProjectTest do
  use ExUnit.Case
  doctest CardsSampleProject

  test "create_deck makes 52 cards deck" do
    deck = CardsSampleProject.create_deck
    assert length(deck) == 52
  end

  test "shuffle the deck randomizes it" do
    deck = CardsSampleProject.create_deck
    assert deck != CardsSampleProject.shuffle(deck) # a little dangerous
  end

  test "deal returns correct number of cards in hand and rest of the deck" do
    { hand, rest } = CardsSampleProject.create_deck |> CardsSampleProject.deal(12)
    assert { length(hand), length(rest) } == { 12, 40 }
  end
end
