require "test_helper"

class ParishHelperTest < ActionView::TestCase
  test "#mass_has_happened? returns true when mass has already happened today" do
    municipality = municipalities(:zapopan)
    now = Time.current.end_of_day

    Time.expects(:current).returns(now)
    now.expects(:in_time_zone).returns(now)

    assert mass_has_happened?(municipality, "09:00 AM")
  end

  test "#mass_has_happened? returns false when mass has not happened today" do
    municipality = municipalities(:zapopan)
    now = Time.current.beginning_of_day

    Time.expects(:current).returns(now)
    now.expects(:in_time_zone).returns(now)

    refute mass_has_happened?(municipality, "09:00 AM")
  end
end
