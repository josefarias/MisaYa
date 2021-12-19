# frozen_string_literal: true

require "test_helper"
require "donde_hay_misa_scraper"

# NOTE: Some of these tests are for private methods. We usually wouldn't test
#   private methods. But, in this case, we think they're useful in case the
#   website changes.

class DondeHayMisaScraperTest < ActiveSupport::TestCase
  test "should set loaded to false by default" do
    refute DondeHayMisaScraper.new.loaded
  end

  test "#scrape! should set loaded to true" do
    scraper = DondeHayMisaScraper.new

    refute scraper.loaded

    scraper.stubs(:scrape_states)
    scraper.scrape!

    assert scraper.loaded
  end

  test "#scrape_states should scrape states and their ids from webpage" do
    uri = URI("http://dondehaymisa.com")
    html = file_fixture("donde_hay_misa/homepage.txt").read
    scraper = DondeHayMisaScraper.new

    Net::HTTP.expects(:get).with(uri).returns(html)
    scraper.stubs(:scrape_municipalities).returns([])

    assert_equal STATES, scraper.send(:scrape_states)
  end

  test "#scrape_total_pages should scrape number of pages from webpage" do
    uri = URI("http://dondehaymisa.com/busqueda?formType=basic&estado=#{TEST_STATE_ID}&municipio_id=#{TEST_MUNICIPALITY_ID}")
    html = file_fixture("donde_hay_misa/municipality_parishes_page_1.txt").read
    scraper = DondeHayMisaScraper.new

    Net::HTTP.expects(:get).with(uri).returns(html)

    assert_equal 5, scraper.send(:scrape_total_pages, state_id: TEST_STATE_ID, municipality_id: TEST_MUNICIPALITY_ID)
  end

  test "#scrape_parish_urls should scrape all parish urls from webpage" do
    number_of_municipality_page_fixtures = 2
    scraper = DondeHayMisaScraper.new
    uri_page_1 = URI("http://dondehaymisa.com/busqueda?formType=basic&estado=#{TEST_STATE_ID}&municipio_id=#{TEST_MUNICIPALITY_ID}&page=1")
    uri_page_2 = URI("http://dondehaymisa.com/busqueda?formType=basic&estado=#{TEST_STATE_ID}&municipio_id=#{TEST_MUNICIPALITY_ID}&page=2")
    html_page_1 = file_fixture("donde_hay_misa/municipality_parishes_page_1.txt").read
    html_page_2 = file_fixture("donde_hay_misa/municipality_parishes_page_2.txt").read

    Net::HTTP.expects(:get).with(uri_page_1).returns(html_page_1)
    Net::HTTP.expects(:get).with(uri_page_2).returns(html_page_2)

    assert_equal PARISH_URLS.sort, scraper.send(:scrape_parish_urls, number_of_pages: number_of_municipality_page_fixtures).sort
  end

  test "#scrape_parish_data should scrape parish data for provided parish url" do
    scraper = DondeHayMisaScraper.new
    url = "http://dondehaymisa.com/parroquia/42"
    uri = URI(url)
    html = file_fixture("donde_hay_misa/parish_42.txt").read
    name = "Parroquia Mater Admirabilis"
    address = "Av. Vasconcelos No. 264 Pte., Col. Del Valle, C.P. 66220, San Pedro Garza García, Nuevo León, México"

    Net::HTTP.expects(:get).with(uri).returns(html)
    parish_data = scraper.send(:scrape_parish_data, url: url)

    assert_equal name, parish_data[:name]
    assert_equal address, parish_data[:address]
    assert_equal MASSES, parish_data[:masses]
  end

  private

  MASSES = [
    {kind: :dominical, day: :sunday, time: "09:00 AM"},
    {kind: :kid_friendly, day: :sunday, time: "10:30 AM"},
    {kind: :dominical, day: :sunday, time: "10:30 AM"},
    {kind: :dominical, day: :sunday, time: "11:30 AM"},
    {kind: :dominical, day: :sunday, time: "01:00 PM"},
    {kind: :dominical, day: :sunday, time: "06:00 PM"},
    {kind: :dominical, day: :sunday, time: "07:00 PM"},
    {kind: :dominical, day: :sunday, time: "08:00 PM"},
    {kind: :daily, day: :monday, time: "11:00 AM"},
    {kind: :daily, day: :monday, time: "07:00 PM"},
    {kind: :daily, day: :tuesday, time: "11:00 AM"},
    {kind: :daily, day: :tuesday, time: "07:00 PM"},
    {kind: :daily, day: :wednesday, time: "11:00 AM"},
    {kind: :daily, day: :wednesday, time: "07:00 PM"},
    {kind: :daily, day: :thursday, time: "11:00 AM"},
    {kind: :daily, day: :thursday, time: "07:00 PM"},
    {kind: :daily, day: :friday, time: "11:00 AM"},
    {kind: :daily, day: :friday, time: "07:00 PM"},
    {kind: :daily, day: :saturday, time: "11:00 AM"},
    {kind: :dominical, day: :saturday, time: "05:00 PM"},
    {kind: :dominical, day: :saturday, time: "06:00 PM"},
    {kind: :dominical, day: :saturday, time: "07:00 PM"}
  ].freeze
  PARISH_URLS = [
    "http://dondehaymisa.com/parroquia/31",
    "http://dondehaymisa.com/parroquia/42",
    "http://dondehaymisa.com/parroquia/47",
    "http://dondehaymisa.com/parroquia/50",
    "http://dondehaymisa.com/parroquia/83",
    "http://dondehaymisa.com/parroquia/93",
    "http://dondehaymisa.com/parroquia/113",
    "http://dondehaymisa.com/parroquia/158",
    "http://dondehaymisa.com/parroquia/161",
    "http://dondehaymisa.com/parroquia/191"
  ].freeze
  STATES = [
    {id: "1", name: "Aguascalientes", municipalities: []},
    {id: "42", name: "Asturias", municipalities: []},
    {id: "2", name: "Baja California", municipalities: []},
    {id: "3", name: "Baja California Sur", municipalities: []},
    {id: "4", name: "Campeche", municipalities: []},
    {id: "9", name: "CDMX", municipalities: []},
    {id: "7", name: "Chiapas", municipalities: []},
    {id: "8", name: "Chihuahua", municipalities: []},
    {id: "5", name: "Coahuila", municipalities: []},
    {id: "6", name: "Colima", municipalities: []},
    {id: "10", name: "Durango", municipalities: []},
    {id: "11", name: "Guanajuato", municipalities: []},
    {id: "12", name: "Guerrero", municipalities: []},
    {id: "13", name: "Hidalgo", municipalities: []},
    {id: "14", name: "Jalisco", municipalities: []},
    {id: "15", name: "México", municipalities: []},
    {id: "16", name: "Michoacán", municipalities: []},
    {id: "17", name: "Morelos", municipalities: []},
    {id: "18", name: "Nayarit", municipalities: []},
    {id: "19", name: "Nuevo León", municipalities: []},
    {id: "20", name: "Oaxaca", municipalities: []},
    {id: "21", name: "Puebla", municipalities: []},
    {id: "22", name: "Querétaro", municipalities: []},
    {id: "23", name: "Quintana Roo", municipalities: []},
    {id: "24", name: "San Luis Potosí", municipalities: []},
    {id: "25", name: "Sinaloa", municipalities: []},
    {id: "26", name: "Sonora", municipalities: []},
    {id: "27", name: "Tabasco", municipalities: []},
    {id: "28", name: "Tamaulipas", municipalities: []},
    {id: "29", name: "Tlaxcala", municipalities: []},
    {id: "30", name: "Veracruz", municipalities: []},
    {id: "31", name: "Yucatán", municipalities: []},
    {id: "32", name: "Zacatecas", municipalities: []}
  ].freeze
  TEST_MUNICIPALITY_ID = "970"
  TEST_STATE_ID = "19"
end
