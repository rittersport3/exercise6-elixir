defmodule WeatherFeed.Fetcher do

require Logger
import SweetXml

@cities_url Application.get_env(:weatherFeed, :cities_url)
@weather_url Application.get_env(:weatherFeed, :weather_url)

def fetch_weather(code) do
  %{body: body} = HTTPoison.get! "#{@weather_url}#{code}/previsao.xml"
  converted = Codepagex.to_string!(body, :iso_8859_1)
  xmled = SweetXml.xpath(converted,
    ~x"//cidade/previsao"l,
    dia: ~x"./dia/text()",
    maxima: ~x"./maxima/text()",
    minima: ~x"./minima/text()",
  )
  {:ok,  xmled}

end



def fetch_city_code({city}) do
  safe_city = String.replace(city, " ", "%20")
  Logger.info "fetching city"
  Logger.info "#{@cities_url}#{safe_city}"

  resp = HTTPoison.get "#{@cities_url}#{safe_city}"
  resp
    |> handle_city_response
end

def handle_city_response({:ok, %{status_code: 200, body: body}}) do
  Logger.info "Successful response"
  # Logger.debug fn -> IO.puts body end

  converted = Codepagex.to_string!(body, :iso_8859_1)
  xmled = SweetXml.xpath(converted,
    ~x"//cidades/cidade",
    nome: ~x"./nome/text()",
    uf: ~x"./uf/text()",
    id: ~x"./id/text()",
  )
  {:ok,  xmled.id}
end

def handle_response({_, %{status_code: status, body: body}}) do
  Logger.error "Error #{status} returned"
end



end
