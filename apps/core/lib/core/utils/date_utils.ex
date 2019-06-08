defmodule Core.DateUtils do
  @moduledoc "format datetime chars from crl file to DateTime"

  def convert_date(date) do
    case Regex.named_captures(
           ~r/(?<year>\d{2})(?<month>\d{2})(?<day>\d{2})(?<hour>\d{2})(?<minute>\d{2})(?<second>\d{2})Z/,
           to_string(date)
         ) do
      %{
        "day" => _day,
        "hour" => _hour,
        "minute" => _minute,
        "month" => _month,
        "second" => _second,
        "year" => _year
      } = fields ->
        fields =
          Enum.into(fields, %{}, fn
            # XXI century, works only for 2001-2099
            {"year", v} -> {"year", String.to_integer("20" <> v)}
            {k, v} -> {k, String.to_integer(v)}
          end)

        with {:ok, naive_datetime} <-
               NaiveDateTime.from_erl(
                 {{fields["year"], fields["month"], fields["day"]},
                  {fields["hour"], fields["minute"], fields["second"]}}
               ) do
          {:ok, DateTime.from_naive!(naive_datetime, "Etc/UTC")}
        else
          _ -> :error
        end

      nil ->
        :error
    end
  end

  def convert_date!(date) do
    {:ok, date_time} = convert_date(date)
    date_time
  end

  def next_update_time(next_update, force_synchronization \\ false) do
    case DateTime.diff(next_update, DateTime.utc_now(), :millisecond) do
      n when n >= 0 ->
        # rechech 60 seconds after next update
        {:ok, n + 60 * 1000}

      _n when force_synchronization ->
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
