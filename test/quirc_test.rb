# frozen_string_literal: true

require "test_helper"

class QuircTest < Minitest::Test
  def test_version
    assert_equal(Quirc::VERSION, "0.1.0")
  end

  def test_lib_version
    assert_equal(Quirc::LIB_VERSION, "1.0")
  end
end
