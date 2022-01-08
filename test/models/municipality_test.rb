require "test_helper"

class MunicipalityTest < ActiveSupport::TestCase
  test "#timezone should return the municipality's state's timezone" do
    municipality = municipalities(:san_pedro)
    assert "America/Monterrey", municipality.timezone
  end

  test "#timezone should return the municipality's timezone for municipalities with special timezones" do
    municipality = municipalities(:anahuac)
    assert "America/Matamoros", municipality.timezone
  end
end
