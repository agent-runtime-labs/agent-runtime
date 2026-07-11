# Agent Instructions

## Current State
- This repo currently contains only `README.md`, `opencode.json`, and this file; do not assume a Python, Node, CDK, SAM, or Terraform scaffold exists until manifests are added.
- No build, test, lint, typecheck, deploy, or local dev commands are defined in the repo yet.

## Product Context
- Intended service: AWS Bedrock AgentCore Runtime based Agentic AI service built with Strands.
- Expected responsibilities: run asynchronous agent workflows, orchestrate MCP tools, persist execution state in DynamoDB, and expose REST APIs for job submission and result retrieval.

## OpenCode Config
- `opencode.json` loads `AGENTS.md` via `instructions`; keep this file compact and update it when repo conventions become executable.
- The configured MCP server is GitHub Copilot MCP and requires `GITHUB_PAT` in the environment.

## Working Guidance
- When adding the first app scaffold, also add explicit commands for install, run, test, lint/typecheck, and deploy in `README.md` or a manifest, then mirror only non-obvious agent guidance here.
- Prefer executable source of truth over prose once manifests, CI, or task runners are introduced.
