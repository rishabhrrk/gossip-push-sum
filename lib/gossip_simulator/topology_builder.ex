require Logger

defmodule GossipSimulator.TopologyBuilder do

  def build(node_ids, topology) do
    case topology do
      "full" -> build_full(node_ids)
      "line" -> build_line(node_ids)
      "rand2D" -> build_random2d(node_ids)
      "honeycomb" -> build_honeycomb(node_ids)
      "3Dtorus" -> torus_3d(node_ids)
      "randhoneycomb" -> build_randhoneycomb(node_ids)
      other_topology -> IO.puts "Oops! Sorry, #{other_topology}
         is under construction"
    end
  end

  defp build_full(node_ids) do
    Enum.map(node_ids, fn node_id ->
      {node_id, Enum.reject(node_ids, fn i -> i == node_id end)}
    end)
  end

  defp build_line(node_ids) do
    node_ids
    |> Enum.with_index()
    |> Enum.map(fn {node_id, index} ->

      neighbours = case index do
        0 -> [Enum.at(node_ids, index + 1)]
        _ -> [Enum.at(node_ids, index - 1), Enum.at(node_ids, index + 1)]
      end

      # Remove nil from neighbours
      # Enum.at(a, B) is nil for B >= length(a)
      {node_id, Enum.filter(neighbours, &(&1))}

    end)
  end

  defp calc_distance(x1, y1, x2, y2) do
    x = :math.pow x1 - x2, 2
    y = :math.pow y1 - y2, 2
    :math.sqrt(x + y)
  end

  defp build_random2d(node_ids) do
    cordinates = Enum.map(node_ids, fn node_id ->
      {node_id, :rand.uniform(), :rand.uniform()}
    end)

    for {node1, x1, y1} <- cordinates do
      neighbours = for {node2, x2, y2} <- cordinates, node1 != node2, calc_distance(x1, y1, x2, y2) < 0.1 do
        node2
      end

      {node1, neighbours}
    end
  end

  defp build_honeycomb(node_ids) do
    node_count = Enum.count(node_ids)
    row_length = round(:math.sqrt(node_count))

    node_ids
    |> Enum.with_index()
    |> Enum.map(fn {node_id, index} ->
      neighbours = cond do
        # 1 first row, odd index
        index <= (row_length - 1)
        && rem(rem(index,row_length), 2) != 0
        -> [
          Enum.at(node_ids, index - 1),
          Enum.at(node_ids, index + row_length)
        ]

        # 2 first row, even index, not last element
        index <= (row_length - 1)
        && rem(rem(index,row_length), 2) == 0
        && (row_length - rem(index,row_length)) != 1
        -> [
          Enum.at(node_ids, index + 1),
          Enum.at(node_ids, index + row_length)
        ]

        # 3 first row, even index, last element
        index <= (row_length - 1)
        && rem(rem(index,row_length), 2) == 0
        && (row_length - rem(index,row_length)) == 1
        -> [
          Enum.at(node_ids, index + row_length)
        ]

        # 4 odd row, odd index
        rem(div(index, row_length) + 1, 2) != 0
        && rem(rem(index,row_length), 2) != 0
        -> [
          Enum.at(node_ids, index - 1),
          Enum.at(node_ids, index + row_length),
          Enum.at(node_ids, index - row_length)
        ]

        # 5 odd row, even index, not last index
        rem(div(index, row_length) + 1, 2) != 0
        && rem(rem(index,row_length), 2) == 0
        && (row_length - rem(index,row_length)) != 1
        -> [
          Enum.at(node_ids, index + 1),
          Enum.at(node_ids, index + row_length),
          Enum.at(node_ids, index - row_length)
        ]

        # 6 even row , odd index, not first index
        rem(div(index, row_length) + 1, 2) == 0
        && rem(rem(index,row_length), 2) != 0
        && rem(index,row_length) != 0
        -> [
          Enum.at(node_ids, index + 1),
          Enum.at(node_ids, index + row_length),
          Enum.at(node_ids, index - row_length)
        ]

        # 7 even row, even index, not first index
        rem(div(index, row_length) + 1, 2) == 0
        && rem(rem(index,row_length), 2) == 0
        && rem(index,row_length) != 0
        -> [
          Enum.at(node_ids, index - 1),
          Enum.at(node_ids, index + row_length),
          Enum.at(node_ids, index - row_length)
        ]

        # 8 even row, even index, first index
        rem(div(index, row_length) + 1, 2) == 0
        && rem(rem(index,row_length), 2) == 0
        && rem(index,row_length) == 0
        -> [
          Enum.at(node_ids, index + row_length),
          Enum.at(node_ids, index - row_length)
        ]

        # 9 even row, odd index, first index
        rem(div(index, row_length) + 1, 2) == 0
        && rem(rem(index,row_length), 2) != 0
        && rem(index,row_length) == 0
        -> [
          Enum.at(node_ids, index + row_length),
          Enum.at(node_ids, index - row_length)
        ]

        # 10 odd row, odd index, last member
        rem(div(index, row_length) + 1, 2) != 0
        && rem(rem(index,row_length), 2) != 0
        && (row_length - rem(index,row_length)) == 1
        -> [
          Enum.at(node_ids, index + row_length),
          Enum.at(node_ids, index - row_length)
        ]

        # 11 odd row, even index, last member
        rem(div(index, row_length) + 1, 2) != 0
        && rem(rem(index,row_length), 2) == 0
        && (row_length - rem(index,row_length)) == 1
        -> [
          Enum.at(node_ids, index + row_length),
          Enum.at(node_ids, index - row_length)
        ]

        true -> Logger.error "Generating Honeycomb Topology
        No match for index: #{index} and row length: #{row_length}"
      end

      {node_id, Enum.filter(neighbours, &(&1))}
    end)
  end

  defp torus_3d(_node_ids) do
    # node_count = Enum.count(node_ids)
    # row_length = :math.sqrt(node_count)
    # y_increment = row_length
    # z_increment = row_length * row_length
    #
    # node_ids
    # |> Enum.with_index()
    # |> Enum.map(fn {node_id, index} ->
    #   neighbours = case index do
    #     0 -> [Enum.at(node_ids, index + 1)]
    #     _ -> [Enum.at(node_ids, index - 1),
    #           Enum.at(node_ids, index + 1),
    #           Enum.at(node_ids, index - y_increment),
    #           Enum.at(node_ids, index + y_increment),
    #           Enum.at(node_ids, index - z_increment),
    #           Enum.at(node_ids, index + z_increment)]
    #   end
    #
    #   # Remove nil from neighbours
    #   # Enum.at(a, B) is nil for B >= length(a)
    #    {node_id, Enum.filter(neighbours, &(&1))}
    # end)

    # llist = for x <- 1..row_length do
    #   for y <- 1..row_length do
    #     for z <- 1..row_length do
    #       [x, y, z]
    #     end
    #   end
    # end

    # llist = List.flatten(llist) |> Enum.chunk(3)

    # map_xyz = Enum.zip(llist, a) |> Enum.into(%{})

    # nodes_with_xyz = node_ids
    # |> Enum.with_index()
    # |> Enum.map(fn {node_id, index} ->
    #     {node_id, List.flatten(Enum.at(List.flatten(llist)
    #       |> Enum.chunk_every(3),index))}
    # end)

    # nodes_with_xyz
    # |> Enum.map(fn {node, [x, y, z]} ->
    #     neighbours = cond do
    #       x != 1 && y != 1 && z != 1
    #       -> [ ]
    #     end

    # end)

  end

  defp build_randhoneycomb(node_ids) do
    build_honeycomb(node_ids)
    |> Enum.map(fn {node, neighbours} ->
      possible_random_neighbours = node_ids
        |> Enum.reject(&(&1 in neighbours))
        |> Enum.reject(&(&1 == node))

      {node, [Enum.random(possible_random_neighbours)] ++ neighbours}
    end)
  end
end
