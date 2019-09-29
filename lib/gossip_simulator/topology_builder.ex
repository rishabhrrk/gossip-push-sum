defmodule GossipSimulator.TopologyBuilder do
  def build(node_ids, topology) do
    case topology do
      "full" -> build_full(node_ids)
      "line" -> build_line(node_ids)
      "rand2D" -> build_random2d(node_ids)
      "honeycomb" -> build_honeycomb(node_ids)
      "3Dtorus" -> torus_3d(node_ids)
      "randhoneycomb" -> build_random2d(node_ids)
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

  defp calc_distance(a, b) do
     c = a - b
     if c<0 do
       c = c * (-1)
     end
     c
  end

  defp build_random2d(mode_ids) do
    cordinates = node_ids
      |> Enum.map(fn {node_id} ->
        {node_id, :rand.uniform(), :rand.uniform()}
      end)

    for {nodei,xi, yi} <- cordinates do
      neighbours = for {nodej,xj, yj} <- cordinates, nodei != nodej,
          calc_distance(xi, xj) < 0.1, calc_distance < 0.1 do
                          {nodej}
                    end
      {nodei, neighbours}
    end
  end

  defp build_honeycomb(node_ids) do
    node_count = Enum.count(node_ids)
    row_length = :math.sqrt(node_count)
    node_ids
    |> Enum.with_index()
    |> Enum.map(fn {node_id, index} ->
      neighbours = cond do
        # 1 odd row, odd index
         rem(div(index, row_length) + 1,2) != 0
         && rem(rem(index,row_length),2) != 0
         -> [Enum.at(node_ids, index - 1),
              Enum.at(node_ids, index + row_length),
              Enum.at(node_ids, index - row_length)]
        # 2 odd row, even index, not last index
          rem(div(index, row_length) + 1,2) != 0
          && rem(rem(index,row_length),2) == 0
          && (row_length - rem(index,row_length)) != 1
          -> [Enum.at(node_ids, index + 1),
               Enum.at(node_ids, index + row_length),
               Enum.at(node_ids, index - row_length)]
        # 3 even row , odd index
          rem(div(index, row_length) + 1,2) == 0
          && rem(rem(index,row_length),2) != 0
          -> [Enum.at(node_ids, index + 1),
                Enum.at(node_ids, index + row_length),
                Enum.at(node_ids, index - row_length)]
        # 4 even row, even index, not  first index
          rem(div(index, row_length) + 1,2) == 0
          && rem(rem(index,row_length),2) == 0
          && rem(index,row_length) != 0
          -> [Enum.at(node_ids, index - 1),
                Enum.at(node_ids, index + row_length),
                Enum.at(node_ids, index - row_length)]
        # 5 even row, even index, first index
        rem(div(index, row_length) + 1,2) == 0
        && rem(rem(index,row_length),2) == 0
        && rem(index,row_length) == 0
        -> [  Enum.at(node_ids, index + row_length),
              Enum.at(node_ids, index - row_length)]
        # 6 odd row, odd index, last member
        rem(div(index, row_length) + 1,2) != 0
        && rem(rem(index,row_length),2) != 0
        && (row_length - rem(index,row_length)) != 1
        -> [ Enum.at(node_ids, index + row_length),
             Enum.at(node_ids, index - row_length)]
      end
      {node_id, Enum.filter(neighbours, &(&1))}
    end)
  end

  defp torus_3d(node_ids) do
    node_count = Enum.count(node_ids)
    row_length = :math.sqrt(node_count)
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
    for x <- 1..row_length do
      for y <- 1..row_length do
        for z <- 1..row_length do

        end
      end
    end
  end

  defp randhoneycomb(node_ids) do
    
  end

end
