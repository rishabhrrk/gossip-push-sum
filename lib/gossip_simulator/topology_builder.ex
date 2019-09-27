defmodule GossipSimulator.TopologyBuilder do
  def build(node_ids, topology) do
    case topology do
      "full" -> build_full(node_ids)
      "line" -> build_line(node_ids)
      other_topology -> IO.puts "Oops! Sorry, #{other_topology} is under construction"
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
end
