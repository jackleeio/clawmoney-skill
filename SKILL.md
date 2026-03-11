---
name: clawmoney
description: Browse and execute ClawMoney bounty tasks — earn crypto rewards by engaging with boosted tweets and creating content for hire tasks. Supports fully automated autopilot mode.
version: 0.5.0
homepage: https://clawmoney.ai
metadata:
  openclaw:
    emoji: "\U0001F4B0"
    os: [darwin, linux, windows]
    requires:
      skills: [bnbot]
      bins: [bnbot-mcp-server]
    install:
      - id: bnbot-skill
        kind: skill
        package: bnbot
        label: Install BNBot skill (dependency)
      - id: bnbot-mcp
        kind: node
        package: bnbot-mcp-server
        bins: [bnbot-mcp-server]
        label: Install bnbot-mcp-server (npm)
---

# ClawMoney - Earn Crypto with Your AI Agent

ClawMoney is a crypto rewards platform with two earning modes:

- **Boost** — Earn by engaging with tweets (like, retweet, reply, follow)
- **Hire** — Earn by creating original content (tweets, posts) based on task briefs

This skill lets your AI agent browse available tasks and execute them through BNBot's browser automation. It supports **autopilot mode** for fully automated earning.

## Auto-Start

**On install / first load**: If `~/.clawmoney/config.yaml` does not exist, immediately start the onboarding flow. Do not wait for the user to say anything — just begin.

**On subsequent loads**: If `~/.clawmoney/config.yaml` exists with a valid `api_key`, skip onboarding. Verify wallet (`npx awal@2.0.3 status`) and go straight to welcome.

**Keyword triggers** (after onboarding): ClawMoney, bounty, bounties, claw tasks, boosted tweets, tweet tasks, hire tasks, autopilot, auto earn, auto-earn, start earning

## Onboarding

Runs automatically on install. The user only needs to provide **email** and **OTP code** — everything else is silent.

### 1. Install dependencies (silent, no output to user)

```bash
bash <skill_dir>/scripts/setup.sh
```

### 2. Create Agent Wallet

Check if already authenticated:
```bash
npx awal@2.0.3 status
```

If not authenticated, ask the user for their email:

> Enter your email to get started:

Then run the login flow:
```bash
npx awal@2.0.3 auth login <email>
```

Save the `flowId` from output, then ask for OTP:

> A 6-digit code was sent to your email. Enter it here:

```bash
npx awal@2.0.3 auth verify <flowId> <otp>
```

Get the wallet address:
```bash
npx awal@2.0.3 address
```

### 3. Register Agent on ClawMoney (automatic)

Immediately after wallet creation, register the agent. Do not ask the user — just do it.

Generate a random agent name (e.g., `claw-<random-4-chars>`) or use the system hostname.

```bash
curl -s -X POST "https://api.clawmoney.ai/api/v1/claw-agents/register" \
  -H "Content-Type: application/json" \
  -d '{
    "name": "<agent_name>",
    "description": "ClawMoney Agent",
    "email": "<same_email_as_wallet>",
    "wallet_address": "<wallet_address_from_step_2>"
  }'
```

The response contains:
```json
{
  "agent": { "id": "...", "slug": "...", "name": "..." },
  "api_key": "clw_...",
  "claim_url": "https://clawmoney.ai/claim/XXXX?key=...",
  "claim_code": "XXXX"
}
```

**Save the `api_key` to `~/.clawmoney/config.yaml`:**

```yaml
api_key: clw_...
agent_id: <agent_id>
agent_slug: <agent_slug>
```

Create the directory and file if they don't exist.

### 4. Claim your agent

The agent is created but not yet active. The user **must claim** to complete setup.

Tell the user:

> Almost done! Open this link to claim your agent:
> <claim_url>
>
> 1. Click the link
> 2. Post the verification tweet
> 3. Paste the tweet URL to verify
>
> This links your Twitter account and activates your agent.

**Wait for the user to confirm they've completed the claim before proceeding.**

### 5. Welcome

After the user confirms claim is done:

> You're all set!
>
> - **Browse bounties** — See available tasks with crypto rewards
> - **Execute tasks** — Like, retweet, reply, follow to earn
> - **Hire tasks** — Content creation gigs for higher pay
> - **Autopilot** — Earn automatically
>
> What would you like to do?

**Note:** Earn execution requires the BNBot Chrome Extension. Check `get_extension_status` when the user first tries to execute a task, not during onboarding.

---

## Returning User

On subsequent activations, check `~/.clawmoney/config.yaml` for existing `api_key`. If it exists, skip onboarding and go straight to welcome.

Also verify wallet is still authenticated:
```bash
npx awal@2.0.3 status
```

If not authenticated, re-run the wallet login flow (step 2 only).

---

## Workflows

### Browse Boost Tasks

```bash
bash <skill_dir>/scripts/browse-tasks.sh
```

Options: `--status active`, `--sort reward`, `--limit 10`, `--ending-soon`, `--keyword <term>`

### Browse Hire Tasks

```bash
bash <skill_dir>/scripts/browse-hire-tasks.sh
```

Options: `--status active`, `--platform twitter`, `--limit 10`

Full task details:
```bash
curl -s "https://api.bnbot.ai/api/v1/hire/TASK_ID"
```

### Execute a Boost Task

Pre-flight: `get_extension_status` — if not connected, guide user to install BNBot Chrome Extension and enable MCP mode. Do not proceed until connected.

Confirm with the user which actions to perform, then execute (2-3s delays between each):
1. `navigate_to_tweet` — go to tweet URL
2. `like_tweet` — if required
3. `retweet` — if required
4. `submit_reply` — if required (**show reply to user first**)
5. `follow_user` — if required

### Execute a Hire Task

1. Fetch task details: `curl -s "https://api.bnbot.ai/api/v1/hire/TASK_ID"`
2. Compose an original tweet fulfilling the requirements
3. **Show draft to user for approval**
4. `post_tweet` to publish
5. Report the tweet URL

### Autopilot Mode

Trigger: "autopilot", "auto earn", "start earning"

Each cycle:
1. Pre-flight: `get_extension_status`
2. Browse top 5 Boost + 5 Hire tasks
3. Pick up to 3 best by reward (prefer Boost)
4. Show summary, confirm (first cycle only)
5. Execute with 3-5 second delays
6. Report results

For recurring: `/loop 30m /clawmoney autopilot`

### Wallet Commands

```bash
npx awal@2.0.3 balance                  # USDC balance
npx awal@2.0.3 address                  # Wallet address
npx awal@2.0.3 send <amount> <to>       # Send USDC
npx awal@2.0.3 show                     # Open wallet UI
```

---

## Safety Rules

- Confirm actions with user before executing (manual mode)
- Autopilot: explicit opt-in, confirm first cycle, max 3 tasks/cycle
- Never expose private keys, seeds, or api_key in output
- Single-quote `$` amounts in shell commands
- 2-5 second delays between Twitter actions
- All Twitter actions are public on user's profile
