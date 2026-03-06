# ClawMoney API Endpoints

Base URL: `https://api.bnbot.ai/api/v1`

## GET /boost/search

Search for bounty tasks (boosts).

### Query Parameters

| Parameter     | Type    | Default      | Description                          |
|---------------|---------|--------------|--------------------------------------|
| status        | string  | "active"     | Filter by status: active, completed, expired |
| sort          | string  | "created_at" | Sort field: created_at, reward, deadline |
| limit         | number  | 10           | Max results to return                |
| offset        | number  | 0            | Pagination offset                    |
| keyword       | string  |              | Search in tweet content              |
| ending_soon   | boolean | false        | Filter tasks ending within 24h       |
| token         | string  |              | Filter by reward token (ETH, USDT, etc.) |

### Response

```json
{
  "data": [Boost],
  "total": 42,
  "offset": 0,
  "limit": 10
}
```

## GET /boost/{id}

Get a single boost by ID.

### Response

Returns a single Boost object.

## Boost Object Schema

```json
{
  "id": "string",
  "tweetUrl": "string",
  "tweetId": "string",
  "creatorAddress": "string",
  "rewardAmount": "string (wei)",
  "rewardToken": "string",
  "requirements": {
    "like": true,
    "retweet": true,
    "reply": false,
    "follow": false
  },
  "replyGuidelines": "string | null",
  "maxParticipants": 100,
  "currentParticipants": 42,
  "status": "active | completed | expired",
  "endTime": "ISO 8601 datetime",
  "createdAt": "ISO 8601 datetime"
}
```

## Token Precision Table

| Token  | Decimals | Example: 1 token in wei         |
|--------|----------|---------------------------------|
| ETH    | 18       | 1000000000000000000             |
| WETH   | 18       | 1000000000000000000             |
| USDT   | 6        | 1000000                         |
| USDC   | 6        | 1000000                         |
| DAI    | 18       | 1000000000000000000             |
| SOL    | 9        | 1000000000                      |
| MATIC  | 18       | 1000000000000000000             |
| BNB    | 18       | 1000000000000000000             |

To convert from wei: `amount = wei_value / (10 ^ decimals)`
