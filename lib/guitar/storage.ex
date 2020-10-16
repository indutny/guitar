defmodule Guitar.Storage do
  use GenServer

  @type t :: GenServer.server()

  # Client

  @spec start_link(String.t()) :: GenServer.on_start()
  def start_link(filename) do
    GenServer.start_link(__MODULE__, filename)
  end

  @spec stop(t()) :: :ok
  def stop(pid) do
    GenServer.stop(pid)
  end

  @spec list(t()) :: [Guitar.Log.Entry]
  def list(pid) do
    GenServer.call(pid, :list)
  end

  @spec append(t(), Calendar.date(), Guitar.Log.Exercise) :: :ok
  def append(pid, date, exercise) do
    GenServer.cast(pid, {:append, date, exercise})
  end

  # Server

  @impl GenServer
  def init(filename) do
    map =
      File.read!(filename)
      |> Jason.decode!()
      |> Enum.map(&Guitar.Log.Entry.from_json/1)
      |> Enum.map(&{&1.date, &1})
      |> Map.new()

    {:ok, {filename, map}}
  end

  @impl GenServer
  def handle_call(:list, _, {_filename, map} = state) do
    {:reply, Map.values(map) |> Enum.sort(Guitar.Log.Entry), state}
  end

  @impl GenServer
  def handle_cast({:append, date, exercise}, {filename, map}) do
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
    {:noreply, {filename, updated_map}}
  end

  # Internal

  defp save(filename, map) do
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
