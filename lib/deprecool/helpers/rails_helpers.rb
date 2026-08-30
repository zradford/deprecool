# frozen_string_literal: true

module RailsHelpers
  def active_record_query_method_names
    # this is as of 8.1.3.1
    # https://api.rubyonrails.org/classes/ActiveRecord/QueryMethods.html
    %i[
      and annotate create_with distinct
      eager_load excluding extending extract_associated
      from group having in_order_of includes invert_where
      joins left_joins left_outer_joins limit lock
      none offset optimizer_hints or order preload
      readonly references regroup reorder reselect reverse_order rewhere
      select strict_loading structurally_compatible?
      uniq! unscope
      where with with_recursive without
      ]
  end
end
