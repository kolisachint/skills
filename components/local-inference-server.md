# LM Studio / Ollama

## Role

Local API inference server.

## Why It Exists

Use local inference to reduce cost for bounded, low-risk tasks such as summaries,
mechanical edits, simple test drafts, and documentation.

## Skillkit Mapping

- Skill: `local-inference`
- Typical local endpoints:
  - `http://localhost:1234/v1`
  - `http://localhost:11434/v1`

## Notes

Do not hide model routing inside prompts. Keep local model use explicit in the
agent or project config.

