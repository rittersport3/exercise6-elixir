defmodule WeatherFeed.CLI do
@moduledoc """
Module that manages the CLI form, that expect a city and returns the weather
forecast
"""

  def main(argv) do
    argv
      |> parse_args
      |> process
  end


  def parse_args(argv) do
    parse = OptionParser.parse(argv, switches: [ help: :boolean],
                                     aliases:  [ h:    :help   ])
    case  parse  do

    { [ help: true ], _,           _ } -> :help
    { _, [city], _ } -> {city}
    _                                  -> :help
    end
  end

  def process(:help) do
    IO.puts """
    usage:  weather <City Name>
    """
    System.halt(0)
  end

  def process(city) do
    { :ok, city_code} = WeatherFeed.Fetcher.fetch_city_code(city)
    { :ok, weather} = WeatherFeed.Fetcher.fetch_weather(city_code)
    IO.inspect weather
    stringified = Enum.map(weather, &(stringify(&1)))
    IO.inspect stringified
    WeatherFeed.TableFormatter.print_table_for_columns(stringified, ["dia", "maxima", "minima"])
  end

  def stringify(map) do
    for {k, v} <- map, into: %{}, do: {to_string(k), v}
  end


end
