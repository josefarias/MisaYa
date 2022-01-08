require "test_helper"

class MassTest < ActiveSupport::TestCase
  test "::for_day should return expected masses" do
    mass = masses(:mater_dominical)
    assert_equal Array.wrap(mass), Mass.for_day(:sunday)
    assert_equal [], Mass.for_day(:monday)
  end

  test "#parsed_time should split out the components of the time string into a hash in 24 hour format" do
    mass = masses(:divina_providencia_daily)
    time = {hour: 20, minute: 30}
    assert_equal time, mass.parsed_time
  end

  test "#happened_today? should return true when mass has already happened today" do
    mass = masses(:divina_providencia_daily)
    now = Time.current.end_of_day

    Time.expects(:current).returns(now)
    now.expects(:in_time_zone).returns(now)

    assert mass.happened_today?
  end

  test "#happened_today? should return false when mass has not happened today" do
    mass = masses(:divina_providencia_daily)
    now = Time.current.beginning_of_day

    Time.expects(:current).returns(now)
    now.expects(:in_time_zone).returns(now)

    refute mass.happened_today?
  end
end
