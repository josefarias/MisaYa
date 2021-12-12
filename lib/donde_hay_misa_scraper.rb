# frozen_string_literal: true

class DondeHayMisaScraper
  attr_reader :parishes, :loaded

  def initialize
    @loaded = false
  end

  def scrape!
    @number_of_pages = scrape_total_pages
    @parish_urls = scrape_parish_urls
    @parishes = parish_urls.map { |url| scrape_parish_data(url: url) }
    @loaded = true
  end

  private

  attr_reader :number_of_pages, :parish_urls

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
  PARISH_NAME_XPATH = "//div[@class='col-xs-12 col-md-offset-1 col-md-5 col-sm-12']/h2"
  PARISH_MASSES_XPATH = "//div[@id='collapseMisas']/div/table[@class='table']/tbody/tr"
  PARISH_URLS_XPATH = "//div[@class='col-xs-6 col-sm-6 col-md-6']/a/@href"
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

  def scrape_parish_data(url:)
    uri = URI(url)
    response = Net::HTTP.get(uri)
    doc = Nokogiri::HTML(response)
    name_element = doc.xpath(PARISH_NAME_XPATH).first
    mass_elements = doc.xpath(PARISH_MASSES_XPATH)
    name = name_element.content
    masses = mass_elements.map(&:content).map do |mass|
      mass_data = mass.strip.split("\n").map(&:strip)

      {type: TYPES[mass_data[0]],
       day: DAYS[mass_data[1]],
       time: mass_data[2]}
    end

    {name: name, masses: masses}
  end

  def scrape_parish_urls
    Array.new(number_of_pages).flat_map.with_index do |_, i|
      url = municipality_url(state_id: 19, municipality_id: 970, page: i + 1)
      uri = URI(url)
      response = Net::HTTP.get(uri)
      doc = Nokogiri::HTML(response)
      elements = doc.xpath(PARISH_URLS_XPATH)
      elements.map(&:content)
    end
  end

  def scrape_total_pages
    url = municipality_url(state_id: 19, municipality_id: 970)
    uri = URI(url)
    response = Net::HTTP.get(uri)
    doc = Nokogiri::HTML(response)
    elements = doc.css(PAGINATION_ELEMENTS_CSS)
    elements.map(&:content)[-2].to_i
  end
end
