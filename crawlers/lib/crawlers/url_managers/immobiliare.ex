defmodule Crawlers.UrlsManagers.Immobiliare do
  @behaviour Crawlers.UrlsManagers.Behaviours.UrlManager

  def generate_urls() do
    for bathroom <- immobiliare_settings(:bathroom_range) |> Enum.to_list(),
        floor <- immobiliare_settings(:floor_range),
        rooms <- immobiliare_settings(:room_range) |> Enum.to_list(),
        elevator <- immobiliare_settings(:elevator),
        basement <- immobiliare_settings(:basement),
        balcony <- immobiliare_settings(:balcony),
        terrace <- immobiliare_settings(:terrace),
        state <- immobiliare_settings(:state),
        zone <- immobiliare_settings(:zone_range) do
      url =
        base_url()
        |> add_zone(zone)
        |> add_basic_parameters()
        |> add_bathroom(bathroom)
        |> add_balcony(balcony)
        |> add_basement(basement)
        |> add_elevator(elevator)
        |> add_floor(floor)
        |> add_rooms(rooms)
        |> add_state(state)
        |> add_terrace(terrace)

      url
    end
  end

  defp add_basic_parameters(url), do: url <> immobiliare_settings(:additional_parameters)

  defp add_bathroom(url, number) when is_number(number) and 0 < number and number < 4,
    do: url <> "&bagni=#{number}"
  defp add_bathroom(url, _number), do: url

  defp add_floor(url, 1), do: url <> "&fasciaPiano[]=10"
  defp add_floor(url, 3), do: url <> "&fasciaPiano[]=30"
  defp add_floor(url, _floor), do: url <> "&fasciaPiano[]=20"

  defp add_rooms(url, room) when is_number(room),
    do: url <> "&localiMinimo=#{room}&localiMassimo=#{room}"

  defp add_state(url, "Nuovo"), do: url <> "&stato=6"
  defp add_state(url, "Ristrutturato"), do: url <> "&stato=1"
  defp add_state(url, "Buono"), do: url <> "&stato=2"
  defp add_state(url, "Da ristrutturare"), do: url <> "&stato=5"

  defp add_elevator(url, true), do: url <> "&ascensore=1"
  defp add_elevator(url, false), do: url

  defp add_basement(url, true), do: url <> "&cantina=1"
  defp add_basement(url, false), do: url

  defp add_balcony(url, true), do: url <> "&balcone=1"
  defp add_balcony(url, false), do: url

  defp add_terrace(url, true), do: url <> "&terrazzo=1"
  defp add_terrace(url, false), do: url

  defp add_zone(url, "Centro"), do: url <> "/centro/"
  defp add_zone(url, "Arco"), do: url <> "/arco-della-pace-arena-pagano/"
  defp add_zone(url, "Genova"), do: url <> "/genova-ticinese/"
  defp add_zone(url, "Quadronno"), do: url <> "/quadronno-palestro-guastalla/"
  defp add_zone(url, "Garibaldi"), do: url <> "/garibaldi-moscova-porta-nuova/"
  defp add_zone(url, "Fiera"), do: url <> "/fiera-sempione-city-life-portello/"
  defp add_zone(url, "Navigli"), do: url <> "/zona-navigli/"
  defp add_zone(url, "Romana"), do: url <> "/porta-romana-cadore-montenero/"
  defp add_zone(url, "Venezia"), do: url <> "/porta-venezia-indipendenza/"
  defp add_zone(url, "Centrale"), do: url <> "/centrale-repubblica/"
  defp add_zone(url, "Cenisio"), do: url <> "/cenisio-sarpi-isola/"
  defp add_zone(url, "Certosa"), do: url <> "/viale-certosa-cascina-merlata/"
  defp add_zone(url, "Inganni"), do: url <> "/bande-nere-inganni/"
  defp add_zone(url, "Famagosta"), do: url <> "/famagosta-barona/"
  defp add_zone(url, "Abbiategrasso"), do: url <> "/abbiategrasso-chiesa-rossa/"
  defp add_zone(url, "Vittoria"), do: url <> "/porta-vittoria-lodi/"
  defp add_zone(url, "Cimiano"), do: url <> "/cimiano-crescenzago-adriano/"
  defp add_zone(url, "Bicocca"), do: url <> "/bicocca-niguarda/"
  defp add_zone(url, "Solari"), do: url <> "/solari-washington/"
  defp add_zone(url, "Affori"), do: url <> "/affori-bovisa/"
  defp add_zone(url, "Sansiro"), do: url <> "/san-siro-trenno/"
  defp add_zone(url, "Bisceglie"), do: url <> "/bisceglie-baggio-olmi/"
  defp add_zone(url, "Ripamonti"), do: url <> "/ripamonti-vigentino/"
  defp add_zone(url, "Forlanini"), do: url <> "/forlanini/"
  defp add_zone(url, "Studi"), do: url <> "/citta-studi-susa/"
  defp add_zone(url, "Maggiolina"), do: url <> "/maggiolina-istria/"
  defp add_zone(url, "Precotto"), do: url <> "/precotto-turro/"
  defp add_zone(url, "Udine"), do: url <> "/udine-lambrate/"
  defp add_zone(url, "Pasteur"), do: url <> "/pasteur-rovereto/"
  defp add_zone(url, "Lambro"), do: url <> "/ponte-lambro-santa-giulia/"
  defp add_zone(url, "Covervetto"), do: url <> "/corvetto-rogoredo/"
  defp add_zone(url, "Napoli"), do: url <> "/napoli-soderini/"

  defp base_url(), do: Application.get_env(:crawlers, :immobiliare)[:base_url]
  defp immobiliare_settings(key), do: Application.get_env(:crawlers, :immobiliare)[key]
end
