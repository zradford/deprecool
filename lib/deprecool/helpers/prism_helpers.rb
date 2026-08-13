# frozen_string_literal: true

module PrismHelpers
  # `(1..10)` parses as a ParenthesesNode wrapping the real expression.
  def unwrap_parentheses(node)
    return node unless node.is_a?(Prism::ParenthesesNode)

    body = node.body&.body
    body&.length == 1 ? body.first : node
  end

  # Method arguments are represented as:
  # node.arguments returns a literal array of arguments
  # https://docs.ruby-lang.org/en/master/Prism/ArgumentsNode.html
  def unwrap_arguments(node)
    return node unless node.is_a?(Prism::ArgumentsNode)

    node.arguments
  end

  # https://docs.ruby-lang.org/en/master/Prism/ArrayNode.html
  def unwrap_array(node)
    return node unless node.is_a?(Prism::ArrayNode)

    node.elements
  end

  def unwrap_class(node)
    return node unless node.is_a?(Prism::ClassNode)

    node.body
  end

  def unwrap_children(node)
    return node unless node.respond_to?(:child_nodes)

    node.child_nodes
  end
end
