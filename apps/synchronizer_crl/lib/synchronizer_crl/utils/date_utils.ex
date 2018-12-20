defmodule SynchronizerCrl.DateUtils do
  @moduledoc "format datetime chars from crl file to DateTime"

  def convert_date(date) do
    case Regex.named_captures(
           ~r/(?<year>\d{2})(?<month>\d{2})(?<day>\d{2})(?<hour>\d{2})(?<minute>\d{2})(?<second>\d{2})Z/,
           to_string(date)
         ) do
      %{
        "day" => day,
        "hour" => hour,
        "minute" => minute,
        "month" => month,
        "second" => second,
        "year" => year
      } ->
        with {:ok, ecto_datetime} <-
               Ecto.DateTime.cast(
                 # XXI century, works only for 2001-2099
                 {{"20" <> year, month, day}, {hour, minute, second}}
               ) do
          dt =
            ecto_datetime
            |> Ecto.DateTime.to_erl()
            |> NaiveDateTime.from_erl!()
            |> DateTime.from_naive!("Etc/UTC")

          {:ok, dt}
        else
          _ -> :error
        end

      nil ->
        :error
    end
  end

  def next_update_time(next_update, check \\ false) do
    case DateTime.diff(next_update, DateTime.utc_now(), :millisecond) do
      n when n >= 0 ->
        {:ok, n}

      _n when check ->
        {:ok, 0}

      n when n > -1000 * 60 * 60 * 12 ->
        # crl file shoul be updated less then 12 hours ago, but
        # providers offen has little bit outdated crl files
        # let's check this url in 30 minutes
        {:ok, 30 * 60 * 60 * 1000}

      _ ->
        # Suspicious crl file, probaply this url never be updated, skip it
        {:error, :outdated}
    end
  end
end
