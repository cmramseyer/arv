# ARV API

ARV manages the full lifecycle of agricultural work orders. Orders are created in an active state, then completed by recording the operator who performed the work and the date it was carried out. Completed orders can be linked to an invoice number, and invoices can later be marked as paid to close the operational and billing cycle.

The API also provides operational reports and PDF generation for active work orders. Generated PDFs are intended to be printed through a cloud-printer integration, which is planned but not implemented yet.

## Stack

- Ruby 3.4.3
- Rails 8 API-only
- SQLite
- Devise cookie-session authentication with CSRF protection
- Active Storage for attachments
- Prawn for PDF generation
- OpenAPI 3.0.3
- RSpec, RuboCop, and Brakeman

## Quick Start

### Prerequisites

- Ruby 3.4.3
- Bundler
- SQLite 3

### Setup

```bash
bundle install
bin/rails db:prepare
```

Create your local environment file:

```bash
cp .env.example .env
```

Start the development server:

```bash
bin/dev
```

The API is available at `http://localhost:3000`.

## Configuration

The following environment variables are available for integrations:

| Variable | Purpose |
| --- | --- |
| `TELEGRAM_ALLOWED_USER_IDS` | Comma-separated Telegram user IDs allowed to use the bot |
| `OPENAI_API_KEY` | API key for the OpenAI integration |
| `TELEGRAM_BOT_TOKEN` | Telegram bot token |
| `TELEGRAM_WEBHOOK_SECRET` | Secret used to validate Telegram webhooks |
| `ALLOW_CREATION` | Enables record creation through the MCP integration |
| `MCP_ACCESS_TOKEN` | Access token for the MCP endpoint |
| `MCP_CREATOR_ID` | User ID associated with MCP-created records |
| `APP_URL` | Public application URL used by the MCP client |

Never commit `.env` or production secrets.

## Authentication

Browser clients authenticate with an HttpOnly session cookie. The browser sends it automatically; clients must not store or send an access token themselves.

Get a CSRF token and save the session cookie before logging in:

```bash
CSRF_TOKEN=$(curl -s -c cookies.txt http://localhost:3000/session | jq -r .csrf_token)
```

Log in with that token:

```bash
curl -b cookies.txt -c cookies.txt -X POST http://localhost:3000/login \
  -H "Content-Type: application/json" \
  -H "X-CSRF-Token: ${CSRF_TOKEN}" \
  -d '{
    "user": {
      "email": "user@example.com",
      "password": "password"
    }
  }'
```

The response contains session information, never a credential. Fetch a fresh CSRF token after login because Devise resets it during authentication:

```bash
CSRF_TOKEN=$(curl -s -b cookies.txt -c cookies.txt http://localhost:3000/session | jq -r .csrf_token)

curl -b cookies.txt http://localhost:3000/estancias

curl -b cookies.txt -X POST http://localhost:3000/productos \
  -H "Content-Type: application/json" \
  -H "X-CSRF-Token: ${CSRF_TOKEN}" \
  -d '{ "producto": { "nombre": "Example", "tipo_producto": "herbicida", "unidad_medida": "litros" } }'
```

Available authentication endpoints:

| Method | Endpoint | Description |
| --- | --- | --- |
| `GET` | `/session` | Returns the current session state and a CSRF token |
| `POST` | `/login` | Creates a user session; requires `X-CSRF-Token` |
| `DELETE` | `/logout` | Ends the current session; requires `X-CSRF-Token` |

Send `X-CSRF-Token` on every `POST`, `PUT`, `PATCH`, or `DELETE` request. The token is returned by `GET /session`. The MCP endpoint is separate and uses `MCP_ACCESS_TOKEN` as a Bearer token.

## Main Resources

| Resource | Purpose |
| --- | --- |
| `estancias` | Farms or properties |
| `lotes` | Fields belonging to farms |
| `cultivos` | Crops |
| `productos` | Agricultural products and units of measure |
| `maquinistas` | Machinery operators |
| `ordenes_fumigacion` | Work orders, their fields, doses, attachments, and lifecycle |
| `dosis` | Product doses assigned to work-order fields |
| `facturas` | Invoices for completed work orders |
| `facturas_pago` | Invoices pending payment |
| `estadisticas` | Aggregated hectares by farm, operator, and crop |

Work orders also support:

- `PATCH /ordenes_fumigacion/:id/terminar` to complete an order
- `GET /ordenes_fumigacion/:id/pdf` to generate its PDF
- `GET /ordenes_fumigacion/pendiente_factura` to retrieve uninvoiced orders
- `GET /informe_orden?mes=MM&anio=YYYY` to generate a monthly PDF report of completed orders

## Telegram and MCP Assistant

ARV includes an MCP server used by the Telegram bot to process authorized private text and voice messages. Voice messages are transcribed, and the assistant uses MCP tools to retrieve operational data or execute supported order workflows.

The MCP server provides these basic tools:

| Tool | Capability |
| --- | --- |
| `list_estancias` / `search_estancias` | List or search farms |
| `search_lotes` | Search fields |
| `list_cultivos` / `search_cultivos` | List or search crops |
| `list_productos` / `search_productos` | List or search agricultural products |
| `list_ordenes_activas` | Retrieve active work orders |
| `resolve_order` | Resolve an order from user-provided details |
| `create_order` | Create a work order when creation is enabled |
| `terminar_orden` | Complete an order with its operator and work date when creation is enabled |

The Telegram integration only accepts authorized users, private chats, and valid webhook requests.

> Note: The MCP server registers all lookup tools. However, when order creation is enabled, the current OpenAI integration only permits `create_order`, `terminar_orden`, and `list_ordenes_activas`. The lookup tools are therefore not available to the assistant in that mode until the allowlist is adjusted.

## API Reference

The complete request and response contract is available in [openapi/v1/openapi.yaml](openapi/v1/openapi.yaml). It documents authentication, schemas, validation errors, filters, multipart uploads, and every public endpoint.
