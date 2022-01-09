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
    random_thursday = Time.parse("13/01/2022").end_of_day

    Time.expects(:current).returns(random_thursday)
    random_thursday.expects(:in_time_zone).returns(random_thursday)

    assert mass.happened_today?
  end

  test "#happened_today? should return false when mass has not happened today" do
    mass = masses(:divina_providencia_daily)
    random_thursday = Time.parse("13/01/2022").beginning_of_day

    Time.expects(:current).returns(random_thursday)
    random_thursday.expects(:in_time_zone).returns(random_thursday)

    refute mass.happened_today?
  end

  test "#happened_today? should return false when mass will not happen today" do
    mass = masses(:divina_providencia_daily)
    random_monday = Time.parse("10/01/2022").end_of_day

    Time.expects(:current).returns(random_monday)
    random_monday.expects(:in_time_zone).returns(random_monday)

    refute mass.happened_today?
  end
end
