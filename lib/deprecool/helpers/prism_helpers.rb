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

  def arguments_are_length(node, length)
    return false unless node.is_a?(Prism::ArgumentsNode)

    unwrap_arguments(node.arguments).length == length
  end

  def arguments_contain(node, value, position: -1, kwarg: nil)
    return false unless node.is_a?(Prism::ArgumentsNode)

    arguments = unwrap_arguments(node)

    return (value_from_argument(arguments[position]) == value) if position >= 0

    arguments.any? do |arg|
      value_from_argument(arg) == value
    end
  end

  def value_from_argument(node)
    case node
    when Prism::SymbolNode, Prism::StringNode then node.unescaped
    end
  end
end
