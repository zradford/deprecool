# frozen_string_literal: true

require 'test_helper'

class YourDeprecationNameTest < Deprecool::FinderTest
  finder Deprecool::Finders::GEM_NAME::V_E_R_S_I_O_N::YourDeprecationName

  # see test_helper, but these are available:
  # assert_offense 'code with offense', confidence: :level
  # assert_no_offense 'code without offense'
end
