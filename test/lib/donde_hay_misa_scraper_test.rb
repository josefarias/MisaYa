require 'test_helper'
require 'donde_hay_misa_scraper'
require 'net/http'

class DondeHayMisaScraperTest < ActiveSupport::TestCase
  test "should set loaded to false by default" do
    refute DondeHayMisaScraper.new.loaded
  end

  test "#scrape! should set loaded to true" do
    scraper = DondeHayMisaScraper.new

    refute scraper.loaded

    scraper.stubs(:scrape_total_pages)
    scraper.stubs(:scrape_parish_urls).returns([])
    scraper.scrape!

    assert scraper.loaded
  end

  # TODO: Change to provide states and municipalities when they're implemented
  # NOTE: These tests are testing private methods. Remove if they're being a nuissance.
  test "#scrape_total_pages should scrape number of pages from webpage" do
    uri = URI("http://dondehaymisa.com/busqueda?formType=basic&estado=19&municipio_id=970")
    html = file_fixture("donde_hay_misa/municipality_parishes_page_1.txt").read
    scraper = DondeHayMisaScraper.new

    Net::HTTP.expects(:get).with(uri).returns(html)

    assert_equal 5, scraper.send(:scrape_total_pages)
  end

  test "#scrape_parish_urls should scrape all parish urls from webpage" do
    number_of_municipality_page_fixtures = 2
    scraper = DondeHayMisaScraper.new
    uri_page_1 = URI("http://dondehaymisa.com/busqueda?formType=basic&estado=19&municipio_id=970&page=1")
    uri_page_2 = URI("http://dondehaymisa.com/busqueda?formType=basic&estado=19&municipio_id=970&page=2")
    html_page_1 = file_fixture("donde_hay_misa/municipality_parishes_page_1.txt").read
    html_page_2 = file_fixture("donde_hay_misa/municipality_parishes_page_2.txt").read
    parishes = [
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
    ]

    Net::HTTP.expects(:get).with(uri_page_1).returns(html_page_1)
    Net::HTTP.expects(:get).with(uri_page_2).returns(html_page_2)
    scraper.expects(:number_of_pages).returns(number_of_municipality_page_fixtures)

    assert_equal parishes.sort, scraper.send(:scrape_parish_urls).sort
  end

  test "#scrape_parish_data should scrape parish data for provided parish url" do
    scraper = DondeHayMisaScraper.new
    url = "http://dondehaymisa.com/parroquia/42"
    uri = URI(url)
    html = file_fixture("donde_hay_misa/parish_42.txt").read
    name = "Parroquia Mater Admirabilis"
    masses = [
      {:type=>:dominical, :day=>:sunday, :time=>"09:00 AM"},
      {:type=>:kid_friendly, :day=>:sunday, :time=>"10:30 AM"},
      {:type=>:dominical, :day=>:sunday, :time=>"10:30 AM"},
      {:type=>:dominical, :day=>:sunday, :time=>"11:30 AM"},
      {:type=>:dominical, :day=>:sunday, :time=>"01:00 PM"},
      {:type=>:dominical, :day=>:sunday, :time=>"06:00 PM"},
      {:type=>:dominical, :day=>:sunday, :time=>"07:00 PM"},
      {:type=>:dominical, :day=>:sunday, :time=>"08:00 PM"},
      {:type=>:daily, :day=>:monday, :time=>"11:00 AM"},
      {:type=>:daily, :day=>:monday, :time=>"07:00 PM"},
      {:type=>:daily, :day=>:tuesday, :time=>"11:00 AM"},
      {:type=>:daily, :day=>:tuesday, :time=>"07:00 PM"},
      {:type=>:daily, :day=>:wednesday, :time=>"11:00 AM"},
      {:type=>:daily, :day=>:wednesday, :time=>"07:00 PM"},
      {:type=>:daily, :day=>:thursday, :time=>"11:00 AM"},
      {:type=>:daily, :day=>:thursday, :time=>"07:00 PM"},
      {:type=>:daily, :day=>:friday, :time=>"11:00 AM"},
      {:type=>:daily, :day=>:friday, :time=>"07:00 PM"},
      {:type=>:daily, :day=>:saturday, :time=>"11:00 AM"},
      {:type=>:dominical, :day=>:saturday, :time=>"05:00 PM"},
      {:type=>:dominical, :day=>:saturday, :time=>"06:00 PM"},
      {:type=>:dominical, :day=>:saturday, :time=>"07:00 PM"}
    ]

    Net::HTTP.expects(:get).with(uri).returns(html)
    parish_data = scraper.send(:scrape_parish_data, url: url)

    assert_equal name, parish_data[:name]
    assert_equal masses, parish_data[:masses]
  end
end
