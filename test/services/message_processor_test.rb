require "test_helper"

class MessageProcessorTest < ActiveSupport::TestCase
  test "replies with interest message when message contains 'información'" do
    result = MessageProcessor.process("Hola, quiero información")
    assert_equal "Gracias por tu interés. En breve te contactaremos.", result[:reply]
  end

  test "matches 'información' case-insensitively" do
    result = MessageProcessor.process("INFORMACIÓN sobre el servicio")
    assert_equal "Gracias por tu interés. En breve te contactaremos.", result[:reply]
  end

  test "replies with price message when message contains 'precio'" do
    result = MessageProcessor.process("¿Cuál es el precio?")
    assert_equal "Nuestros precios comienzan desde 29€ al mes.", result[:reply]
  end

  test "matches 'precio' case-insensitively" do
    result = MessageProcessor.process("PRECIO del plan")
    assert_equal "Nuestros precios comienzan desde 29€ al mes.", result[:reply]
  end

  test "replies with default message for unrecognized content" do
    result = MessageProcessor.process("Hola!")
    assert_equal "Gracias por escribirnos.", result[:reply]
  end

  test "returns a hash" do
    result = MessageProcessor.process("any message")
    assert_kind_of Hash, result
    assert result.key?(:reply)
  end
end
