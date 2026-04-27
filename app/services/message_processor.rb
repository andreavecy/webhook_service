class MessageProcessor
  RESPONSES = {
    /información/i => "Gracias por tu interés. En breve te contactaremos.",
    /precio/i      => "Nuestros precios comienzan desde 29€ al mes."
  }.freeze

  DEFAULT_REPLY = "Gracias por escribirnos."

  def self.process(message)
    reply = RESPONSES.find { |pattern, _| message.match?(pattern) }&.last || DEFAULT_REPLY
    { reply: reply }
  end
end
