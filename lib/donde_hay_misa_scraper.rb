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

  BASE_URL = "http://dondehaymisa.com".freeze
  TYPES = {
    "Carismática" => :charismatic,
    "Diaria" => :daily,
    "Precepto dominical" => :dominical,
    "Con niños" => :kid_friendly,
    "Juvenil" => :teenage,
    "En latín" => :in_latin
  }.freeze
  DAYS = {
    "Lunes" => :monday,
    "Martes" => :tuesday,
    "Miércoles" => :wednesday,
    "Jueves" => :thursday,
    "Viernes" => :friday,
    "Sábado" => :saturday,
    "Domingo" => :sunday
  }.freeze

  def scrape_total_pages
    data = Wombat.crawl do
      base_url BASE_URL
      path "/busqueda?&estado=19&municipio_id=970&formType=basic"
      pages({css: ".pagination>li"}, :list)
    end

    data["pages"][-2].to_i
  end

  def scrape_parish_urls
    Array.new(number_of_pages).flat_map.with_index do |_, i|
      data = Wombat.crawl do
        base_url BASE_URL
        path "/busqueda?&estado=19&municipio_id=970&formType=basic&page=#{i + 1}"
        parish_urls({css: "//div[class='col-xs-6 col-sm-6 col-md-6']/a/@href"}, :list)
      end

      data["parish_urls"]
    end
  end

  def scrape_parish_data(url:)
    data = Wombat.crawl do
      base_url url
      path "/"
      name({css: "//div[class='col-xs-12 col-md-offset-1 col-md-5 col-sm-12']/h2"})
      masses({css: "//div[id='collapseMisas']/div/table[class='table']/tbody/tr"}, :list)
    end

    masses = data["masses"].map do |mass|
      mass_data = mass.split("\n").map(&:strip)

      {
        type: TYPES[mass_data[0]],
        day: DAYS[mass_data[1]],
        time: mass_data[2]
      }
    end

    {
      name: data["name"],
      masses: masses
    }
  end
end
