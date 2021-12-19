# frozen_string_literal: true

require "net/http"

class DondeHayMisaScraper
  attr_reader :states, :loaded

  def initialize
    @loaded = false
  end

  def scrape!
    @states = scrape_states
    @loaded = true
  end

  private

  BASE_URL = "http://dondehaymisa.com"
  DAYS = {
    "Lunes" => :monday,
    "Martes" => :tuesday,
    "Miércoles" => :wednesday,
    "Jueves" => :thursday,
    "Viernes" => :friday,
    "Sábado" => :saturday,
    "Domingo" => :sunday
  }.freeze
  PAGINATION_ELEMENTS_CSS = ".pagination>li"
  PARISH_ADDRESS_XPATH = "//p[@class='search-results']/strong[contains(., 'Dirección')]/following-sibling::em"
  PARISH_NAME_XPATH = "//div[@class='col-xs-12 col-md-offset-1 col-md-5 col-sm-12']/h2"
  PARISH_MASSES_XPATH = "//div[@id='collapseMisas']/div/table[@class='table']/tbody/tr"
  PARISH_URLS_XPATH = "//div[@class='col-xs-6 col-sm-6 col-md-6']/a/@href"
  STATE_ELEMENTS_CSS = "select#estado>option"
  TYPES = {
    "Carismática" => :charismatic,
    "Diaria" => :daily,
    "Precepto dominical" => :dominical,
    "Con niños" => :kid_friendly,
    "Juvenil" => :teenage,
    "En latín" => :in_latin
  }.freeze

  def municipality_url(state_id:, municipality_id:, page: nil)
    url = "#{BASE_URL}/busqueda?formType=basic"
    url += "&estado=#{state_id}"
    url += "&municipio_id=#{municipality_id}"
    url += "&page=#{page}" if page
    url
  end

  def municipalities_url(state_id:)
    "#{BASE_URL}/listaMunicipiosSearch/#{state_id}"
  end

  def scrape_parish_data(url:)
    uri = URI(url)
    response = Net::HTTP.get(uri)
    doc = Nokogiri::HTML(response)
    name_element = doc.xpath(PARISH_NAME_XPATH).first
    address_element = doc.xpath(PARISH_ADDRESS_XPATH).first
    mass_elements = doc.xpath(PARISH_MASSES_XPATH)
    name = name_element.content.strip
    address = address_element.content.strip
    masses = mass_elements.map(&:content).map do |mass|
      mass_data = mass.strip.split("\n").map(&:strip)

      {
        type: TYPES[mass_data[0]],
        day: DAYS[mass_data[1]],
        time: mass_data[2]
      }
    end

    {name: name, address: address, masses: masses}
  end

  def scrape_parish_urls(number_of_pages:)
    Array.new(number_of_pages).flat_map.with_index do |_, i|
      url = municipality_url(state_id: 19, municipality_id: 970, page: i + 1)
      uri = URI(url)
      response = Net::HTTP.get(uri)
      doc = Nokogiri::HTML(response)
      elements = doc.xpath(PARISH_URLS_XPATH)
      elements.map { _1.content.strip }
    end
  end

  def scrape_states
    uri = URI(BASE_URL)
    response = Net::HTTP.get(uri)
    doc = Nokogiri::HTML(response)
    elements = doc.css(STATE_ELEMENTS_CSS)
    elements.map do |element|
      id = element.attributes["value"].value.strip
      next unless id.present?

      {
        id: id,
        name: element.content.strip,
        municipalities: scrape_municipalities(state_id: id)
      }
    end.compact
  end

  def scrape_municipalities(state_id:)
    url = municipalities_url(state_id: state_id)
    uri = URI(url)
    response = Net::HTTP.get(uri)
    municipalities = JSON.parse(response)["municipios"]
    municipalities.map do |municipality|
      id = municipality["id"].strip
      total_pages = scrape_total_pages(state_id: state_id, municipality_id: id)
      parish_urls = scrape_parish_urls(number_of_pages: total_pages)

      {
        id: id,
        name: municipality["nombre"].strip,
        parishes: parish_urls.map { |url| scrape_parish_data(url: url) }
      }
    end
  end

  def scrape_total_pages(state_id:, municipality_id:)
    url = municipality_url(state_id: state_id, municipality_id: municipality_id)
    uri = URI(url)
    response = Net::HTTP.get(uri)
    doc = Nokogiri::HTML(response)
    elements = doc.css(PAGINATION_ELEMENTS_CSS)
    elements.map(&:content)[-2].strip.to_i
  end
end
