import Mogrify

defmodule Identicon do
  @moduledoc """
    Identicon generation functions
  """

  @doc """
    Handles all the process from generating to saving
  """
  def create(input_text) do
    input_text
    |> compute_hash
    |> pick_color
    |> build_grid
    |> filter_empty_squares
    |> build_pixel_map
    |> draw_image
    |> save_image(input_text)
  end

  @doc """
    Generates Image struct with hex of MD5 hash of the input string

  ## Examples
      iex> Identicon.compute_hash("Specific text")
      %Identicon.Image{hex: [33, 73, 61, 0, 254, 78, 58, 48, 40, 134, 8, 92, 80, 36, 20, 38]}
  """
  def compute_hash(input_text) do
    %Identicon.Image{hex: :crypto.hash(:md5, input_text) |> :binary.bin_to_list()}
  end

  @doc """
    Picks the color from image struct hex and returns new struct with it

  ## Examples
      iex> image = %Identicon.Image{hex: [16, 16, 16]}
      iex> Identicon.pick_color(image)
      %Identicon.Image{hex: [16, 16, 16], color: "#101010"}
  """
  def pick_color(%Identicon.Image{hex: [r, g, b | _not_used]} = image) do
    %Identicon.Image{
      image
      | color: "\##{Base.encode16(<<r>>)}#{Base.encode16(<<g>>)}#{Base.encode16(<<b>>)}"
    }
  end

  @doc """
    Builds grid out of the Image struct's hex and returns new struct with it

  ## Examples
      iex> image = %Identicon.Image{hex: [1, 2, 3, 3, 2, 1]}
      iex> Identicon.build_grid(image)
      %Identicon.Image{hex: [1, 2, 3, 3, 2, 1], grid: [{1, 0}, {2, 1}, {3, 2}, {2, 3}, {1, 4}, {3, 5}, {2, 6}, {1, 7}, {2, 8}, {3, 9}]}
  """
  def build_grid(%Identicon.Image{hex: hex} = image) do
    grid =
      hex
      |> Enum.chunk_every(3, 3, :discard)
      |> Enum.map(&_mirror_row/1)
      |> List.flatten()
      |> Enum.with_index()

    %Identicon.Image{image | grid: grid}
  end

  @doc """
    Filters out the small elements from Item's grid (odd or even)

  ## Examples
      iex> image = %Identicon.Image{grid: [{200, 0}, {100, 1}, {80, 2}, {30, 3}, {128, 4}, {251, 5}]}
      iex> Identicon.filter_empty_squares(image)
      %Identicon.Image{color: nil, grid: [{251, 5}]}
  """
  def filter_empty_squares(%Identicon.Image{grid: grid} = image) do
    filtered_grid = Enum.filter(grid, fn {item, _index} -> rem(item, 2) !== 0 end)
    %Identicon.Image{image | grid: filtered_grid}
  end

  @doc """
    Builds the pixel map based on the grid provided

  ## Examples
      iex> image = %Identicon.Image{color: nil, grid: [{200, 0}, {128, 4}, {251, 5}], hex: nil}
      iex> Identicon.build_pixel_map(image)
      %Identicon.Image{grid: [{200, 0}, {128, 4}, {251, 5}], pixel_map: [{{0, 0}, {50, 50}}, {{200, 0}, {250, 50}}, {{0, 50}, {50, 100}}]}
  """
  def build_pixel_map(%Identicon.Image{grid: grid} = image) do
    pixel_map =
      for {_val, index} <- grid do
        h = rem(index, 5) * 50
        v = div(index, 5) * 50
        {{h, v}, {h + 50, v + 50}}
      end

    %Identicon.Image{image | pixel_map: pixel_map}
  end

  @doc """
    Draws the image based on pixel map to the RAM
  """
  def draw_image(%Identicon.Image{color: color, pixel_map: pixel_map}) do
    image =
      %Mogrify.Image{ext: "png"}
      |> custom(:size, "250x250")
      |> canvas("white")
      |> custom(:fill, color)

    Enum.reduce(pixel_map, image, fn {{x, y}, {x1, y1}}, acc ->
      Mogrify.Draw.rectangle(acc, x, y, x1, y1)
    end)
  end

  @doc """
    Saves the image data to the file name provided
  """
  def save_image(mogrify_image_data, file_name) do
    %Mogrify.Image{mogrify_image_data | path: "#{file_name}.png"} |> create(path: ".")
    :ok
  end

  ######
  def _mirror_row(row) do
    row ++ (List.delete_at(row, 2) |> Enum.reverse())
  end
end
