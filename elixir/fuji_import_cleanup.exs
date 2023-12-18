# from dir of folders imported off of SD card

def get_folders() do
  with {:ok, folders} <- File.ls(),
       folders <- Enum.filter(folders, &String.ends_with?(&1, "FUJI")) do
    folders
  else
    _ -> []
  end
end

def get_files(folders) do
  folders
  |> Enum.reduce([], fn folder, acc ->
    with :ok <- File.cd!(folder),
         {:ok, files} <- File.ls(),
         full_filenames <- Enum.map(files, &"#{folder}/#{&1}"),
         :ok <- File.cd!("../") do
      List.flatten([acc, full_filenames])
    else
      _ -> []
    end
  end)
end

defp mkdir_if_needed(dir) do
  unless File.exists?(dir) do
    File.mkdir(dir)
  end

  :ok
end

def sort_files(files) do
  files
  |> Enum.each(fn path ->
    with [_, name, ext] <- String.split(path, ["/", "."]),
         :ok <- mkdir_if_needed("../#{ext}"),
         :ok <- File.rename!(path, "#{ext}/#{name}.#{ext}") do
      :ok
    else
      e -> {:error, e}
    end
  end)
end

def run() do
  get_folders()
  |> get_files()
  |> sort_files()
end

run()
