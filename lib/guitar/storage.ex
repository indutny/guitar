defmodule Guitar.Storage do
  @spec start(String.t()) :: nil
  def start(filename) do
    map =
      File.read!(filename)
      |> Jason.decode!()
      |> Enum.map(&Guitar.Log.Entry.from_json/1)
      |> Enum.map(&{&1.date, &1})
      |> Map.new()

    loop(filename, map)
  end

  def loop(filename, map) do
    receive do
      {:list, pid} ->
        send(pid, {:list, Map.values(map) |> Enum.sort(Guitar.Log.Entry)})
        loop(filename, map)

      {:append, date, exercise} ->
        updated_map =
          Map.update(
            map,
            date,
            %Guitar.Log.Entry{
              date: date,
              exercises: [exercise]
            },
            fn existing ->
              %Guitar.Log.Entry{
                existing
                | exercises: existing.exercises ++ [exercise]
              }
            end
          )

        save(filename, updated_map)
        loop(filename, updated_map)

      {:close, pid} ->
        send(pid, :closed)
    end
  end

  def save(filename, map) do
    list =
      map
      |> Map.values()
      |> Enum.sort(Guitar.Log.Entry)
      |> Enum.map(&Guitar.Log.Entry.to_json/1)

    json = Jason.encode!(list, pretty: true)

    backup = filename <> ".bkp"
    File.rename!(filename, backup)

    try do
      File.write!(filename, json)
    rescue
      e in FileError ->
        # Do best attempt at recovery
        File.rename(backup, filename)
        raise e
    end

    File.rm!(backup)
  end
end
