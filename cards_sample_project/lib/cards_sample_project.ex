defmodule CardsSampleProject do
  @moduledoc """
    Cards dealing game functions
  """

  @doc """
    Creates the ordered list of cardnames of a single deck
  """
  def create_deck do
    values = ["A", "2", "3", "4", "5", "6", "7", "8", "9", "10", "J", "Q", "K"]
    suits = ["♠", "♣", "♥", "♦"]

    for suit <- suits, value <- values do
      "#{value} #{suit}"
    end
  end

  @doc """
    Shuffles the deck (randomizes the list)
  """
  def shuffle(deck) do
    Enum.shuffle(deck)
  end

  @doc """
    Returns the tuple of the one hand cards list and the list of the rest of the cards
    from the deck. `hand_size` is used to tell the amount of cards in a hand

  ## Examples

      iex> deck = CardsSampleProject.create_deck
      iex> { hand, deck } = CardsSampleProject.deal(deck, 2)
      iex> hand
      ["A ♠", "2 ♠"]
  """
  def deal(deck, hand_size) do
    Enum.split(deck, hand_size)
  end

  @doc """
    Checks if the provided card name exists in the provided deck

  ## Examples

      iex> deck = CardsSampleProject.create_deck
      iex> card = "10 ♠"
      iex> CardsSampleProject.contains?(deck, card)
      true
  """
  def contains?(deck, card) do
    card in deck
  end

  def save(deck, file_name) do
    binary = :erlang.term_to_binary(deck)
    File.write(file_name, binary)
  end

  def load(file_name) do
    case File.read(file_name) do
      {:ok, data} -> :erlang.binary_to_term(data)
      {:error, _data} -> "File does not exist"
    end
  end

  def make_hand(hand_size) do
    {hand, _restOfDeck} =
      CardsSampleProject.create_deck()
      |> CardsSampleProject.shuffle()
      |> CardsSampleProject.deal(hand_size)

    hand
  end
end
