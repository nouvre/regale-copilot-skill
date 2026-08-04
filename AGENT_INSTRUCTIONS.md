# Agent Instructions — moved

This file used to carry a full copy of the definition-mode rules and the build
sequence. It went stale: it kept describing a screen-recording build and an inverted
talk-track mapping long after the runtime files had moved on, while still reading like
authoritative instructions.

It has been reduced to a pointer so that cannot happen again.

## If you are an agent

Read these instead:

- **Build pipeline** — [`.github/skills/demo/BUILD_PIPELINE.md`](.github/skills/demo/BUILD_PIPELINE.md).
  This is the single source of truth. Do not build from any other copy.
- **Definition mode** — whichever runtime file loaded you:
  [`.github/skills/demo/SKILL.md`](.github/skills/demo/SKILL.md),
  [`.github/agents/regale-demo.agent.md`](.github/agents/regale-demo.agent.md),
  [`.github/copilot-instructions.md`](.github/copilot-instructions.md), or
  [`AGENTS.md`](AGENTS.md).

## If you are a person

[`skill.md`](skill.md) is the overview: what this does, the scope of v1, and how a demo
definition maps onto Regale's project model.

## If you are editing behaviour

Change [`BUILD_PIPELINE.md`](.github/skills/demo/BUILD_PIPELINE.md) and nothing else.
The definition-mode rules are duplicated across four runtime files because Copilot's
skill and agent formats each load their own file — if you change those rules,
change all four. The build pipeline is deliberately not duplicated.
