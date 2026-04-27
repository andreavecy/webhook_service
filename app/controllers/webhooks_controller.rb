class WebhooksController < ApplicationController
  wrap_parameters false

  MESSAGE_LOGGER = ActiveSupport::Logger.new(Rails.root.join("log/messages.log"))

  def create
    phone   = webhook_params[:phone]
    message = webhook_params[:message]

    return render json: { error: "Invalid request" }, status: :bad_request if phone.blank? || message.blank?

    log_message(phone, message)
    render json: MessageProcessor.process(message), status: :ok
  rescue ActionDispatch::Http::Parameters::ParseError
    render json: { error: "Invalid JSON" }, status: :bad_request
  end

  private

  def webhook_params
    params.permit(:phone, :message)
  end

  def log_message(phone, message)
    MESSAGE_LOGGER.info("[#{Time.current.iso8601}] #{phone}: #{message}")
  end
end
