#!/usr/bin/env ruby

require 'test_helper'

class ObjectSpaceId2refTest < Deprecool::FinderTest
  finder Deprecool::Finders::Ruby::V4_0_0::ObjectSpaceId2ref

  def test_original_object_space_id2ref_method_call
    assert_offense 'ObjectSpace._id2ref(my_object.object_id)', confidence: :high
  end

  def test__id2ref_defined_on_other_class
    assert_no_offense 'MyClass._id2ref(123)'
  end
end

