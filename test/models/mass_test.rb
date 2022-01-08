require "test_helper"

class MassTest < ActiveSupport::TestCase
  test "::for_day should return expected masses" do
    mass = masses(:mater_dominical)
    assert_equal Array.wrap(mass), Mass.for_day(:sunday)
    assert_equal [], Mass.for_day(:monday)
  end
end
