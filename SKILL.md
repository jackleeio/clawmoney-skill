---
name: clawmoney
description: Browse and execute tweet bounty tasks from ClawMoney — earn crypto rewards by engaging with boosted tweets through BNBot's safe browser automation.
version: 1.0.0
homepage: https://clawmoney.com
metadata:
  openclaw:
    emoji: "\U0001F4B0"
    os: [darwin, linux, windows]
    requires:
      skills: [bnbot]
---

# ClawMoney - Earn Crypto by Engaging with Tweets

ClawMoney is a tweet bounty platform where you earn crypto rewards by liking, retweeting, replying, and following. This skill lets your AI assistant browse available bounty tasks and execute them through BNBot's safe browser automation.

- **Platform**: [ClawMoney](https://clawmoney.com)
- **Requires**: [BNBot Skill](https://clawhub.ai/skills/bnbot) (installs automatically as dependency)

## Trigger

Activate when the user mentions: ClawMoney, bounty, bounties, claw tasks, boosted tweets, tweet tasks

## Workflow

### 1. Browse Available Tasks

Run the browse script to fetch active bounty tasks:

```bash
bash <skill_dir>/scripts/browse-tasks.sh
```

Present results as a formatted table. Let the user pick a task to execute.

Options: `--status active` (default), `--sort reward`, `--limit 10`, `--ending-soon`, `--keyword <term>`

### 2. Execute a Task

Before executing, **always confirm with the user** which actions to perform.

**Pre-flight check:**

1. Call `get_extension_status` to verify BNBot extension is connected
   - If not connected, tell the user to install the [BNBot Chrome Extension](https://chromewebstore.google.com/detail/bnbot-your-ai-growth-agen/haammgigdkckogcgnbkigfleejpaiiln), open Twitter/X in Chrome, and enable MCP in BNBot Settings
2. If connected, proceed with task execution

**Execution sequence (use BNBot MCP tools):**

1. `navigate_to_tweet` — navigate to the tweet URL from the task
2. Wait 2-3 seconds for page load
3. `like_tweet` — if task requires like (params: `tweetUrl`)
4. Wait 2-3 seconds
5. `retweet` — if task requires retweet (params: `tweetUrl`)
6. Wait 2-3 seconds
7. `submit_reply` — if task requires reply (params: `text`, `tweetUrl`). **Show the reply content to the user and get confirmation before calling.**
8. Wait 2-3 seconds
9. `follow_user` — if task requires follow (params: `username`)

### 3. Report Results

Summarize what was done and any errors encountered.

## Safety Rules

- **Always confirm** each action with the user before executing
- **Add 2-5 second delays** between actions to simulate human behavior
- **Never auto-submit replies** — show reply content to user first
- **One task at a time** — no batch execution without explicit approval

## Reference Documentation

- API endpoints: `<skill_dir>/references/api-endpoints.md`
- Task execution workflow: `<skill_dir>/references/task-workflow.md`
