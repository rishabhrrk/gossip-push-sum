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
end