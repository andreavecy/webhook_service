# Webhook Service

A small Rails API that receives messages via webhook, processes them, and returns automatic replies.

---

## Requirements

- Ruby 3.3.4
- Bundler

---

## Setup

```bash
git clone <repository-url>
cd webhook_service
bundle install
```

---

## Run the server

```bash
bin/rails server
# Server starts at http://localhost:3000
```

---

## Run with Docker

```bash
# Build the image
docker build -t webhook_service .

# Run the container (replace with your actual master key)
docker run -d -p 3000:80 \
  -e RAILS_MASTER_KEY=$(cat config/master.key) \
  --name webhook_service \
  webhook_service
```

---

## Endpoint

### `POST /webhook`

**Request body:**
```json
{
  "phone": "123456789",
  "message": "Hola, quiero información"
}
```

**Responses:**

| Condition | Response | HTTP Status |
|---|---|---|
| Message contains "información" | `{"reply": "Gracias por tu interés. En breve te contactaremos."}` | 200 |
| Message contains "precio" | `{"reply": "Nuestros precios comienzan desde 29€ al mes."}` | 200 |
| Any other message | `{"reply": "Gracias por escribirnos."}` | 200 |
| Missing `phone` or `message` | `{"error": "Invalid request"}` | 400 |
| Malformed JSON | `{"error": "Invalid JSON"}` | 400 |

---

## Example curl requests

```bash
# Keyword: información
curl -X POST http://localhost:3000/webhook \
  -H "Content-Type: application/json" \
  -d '{"phone":"123456789","message":"Hola, quiero información"}'

# Keyword: precio
curl -X POST http://localhost:3000/webhook \
  -H "Content-Type: application/json" \
  -d '{"phone":"123456789","message":"¿Cuál es el precio?"}'

# Default reply
curl -X POST http://localhost:3000/webhook \
  -H "Content-Type: application/json" \
  -d '{"phone":"123456789","message":"Hola!"}'

# Missing field → 400
curl -X POST http://localhost:3000/webhook \
  -H "Content-Type: application/json" \
  -d '{"phone":"123456789"}'

# Malformed JSON → 400
curl -X POST http://localhost:3000/webhook \
  -H "Content-Type: application/json" \
  -d '{bad json}'
```

---

## Run tests

```bash
bin/rails test
```

---

## Logging

Incoming messages are saved to `log/messages.log` in the format:

```
[2026-04-27T10:00:00+00:00] 123456789: Hola, quiero información
```

---

## Technical decisions

- **Rails API mode** (`ActionController::API`): lighter stack, no view layer or cookie middleware — appropriate for a pure JSON API.
- **Service object (`MessageProcessor`)**: business logic is isolated from the controller. The controller only handles HTTP concerns (parsing, validation, response). This makes the logic independently testable and easy to extend.
- **Pattern matching with a hash of regexes**: adding new keyword rules requires a single line change in `MessageProcessor::RESPONSES` — no conditionals to chain.
- **`ActiveSupport::Logger`** for message logging: integrates naturally with Rails and writes to a dedicated file (`log/messages.log`) without polluting the main application log.
- **Strong parameters**: `params.permit(:phone, :message)` prevents mass-assignment and documents the expected shape of the input.
- **`ActionDispatch::Http::Parameters::ParseError`** rescue: Rails wraps `JSON::ParserError` in this exception before it reaches the controller action, so this is the correct place to catch malformed JSON in a Rails API.
