require "test_helper"

class WebhooksControllerTest < ActionDispatch::IntegrationTest
  # ---------------------------------------------------------------------------
  # Happy path
  # ---------------------------------------------------------------------------

  test "returns reply for message containing 'información'" do
    post webhook_url, params: { phone: "123456789", message: "Hola, quiero información" }, as: :json
    assert_response :ok
    assert_equal "Gracias por tu interés. En breve te contactaremos.", response.parsed_body["reply"]
  end

  test "returns reply for message containing 'precio'" do
    post webhook_url, params: { phone: "123456789", message: "¿Cuál es el precio?" }, as: :json
    assert_response :ok
    assert_equal "Nuestros precios comienzan desde 29€ al mes.", response.parsed_body["reply"]
  end

  test "returns default reply for unrecognized message" do
    post webhook_url, params: { phone: "123456789", message: "Hola!" }, as: :json
    assert_response :ok
    assert_equal "Gracias por escribirnos.", response.parsed_body["reply"]
  end

  # ---------------------------------------------------------------------------
  # Validation errors
  # ---------------------------------------------------------------------------

  test "returns 400 when phone is missing" do
    post webhook_url, params: { message: "Hola" }, as: :json
    assert_response :bad_request
    assert_equal "Invalid request", response.parsed_body["error"]
  end

  test "returns 400 when message is missing" do
    post webhook_url, params: { phone: "123456789" }, as: :json
    assert_response :bad_request
    assert_equal "Invalid request", response.parsed_body["error"]
  end

  test "returns 400 when body is empty" do
    post webhook_url, params: {}, as: :json
    assert_response :bad_request
    assert_equal "Invalid request", response.parsed_body["error"]
  end

  # ---------------------------------------------------------------------------
  # Malformed JSON
  # ---------------------------------------------------------------------------

  test "returns 400 with error message for invalid JSON body" do
    post webhook_url,
         params: "{bad json}",
         headers: { "CONTENT_TYPE" => "application/json" }
    assert_response :bad_request
    assert_equal "Invalid JSON", response.parsed_body["error"]
  end
end
