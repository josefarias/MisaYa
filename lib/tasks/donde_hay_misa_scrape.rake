require "donde_hay_misa_scraper"

namespace :donde_hay_misa do
  desc "Scrapes dondehaymisa.com for mass dates"
  task scrape: :environment do
    scraper = DondeHayMisaScraper.new
    scraper.scrape!
    pp scraper.states
  end
end
