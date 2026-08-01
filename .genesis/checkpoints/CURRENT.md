# CURRENT
- active_loop: NONE
- target: M1
- iteration: 0
- last_gate: G2 PASS (context-graph: 37 nodes, 41 edges, 0 cycles, 6 invariants)
- last_action: genesis ritual G0-G6 complete; spine filled and verified; no code written yet
- next_action: run G0 existence pre-flight on M1, then L1 BUILD
- model: claude-sonnet-5
- tokens_used: 0
- tokens_budget: 50000
- skills_loaded: []

## Genesis summary (2026-07-31)
- Spec source: `~/ketan-data/code/antern/SessionNotesDeliverables/Week8/pr-review-agent.html`
- Approach chosen (G0.5): **C — grounded agentic fan-out**, sequenced as a thin vertical slice
- Milestones: M1-M8. M1-M5 need no external services; M6-M7 need local Docker; M8 is the credential wall
- explain_diff: **on** — after each L4 APPROVE, run explain-diff-html into `.genesis/explanations/`, then quiz-me

## Known environment facts (verified, not assumed)
- python 3.12.3 · node v22.22.1 · docker 27.3.1 with reachable daemon · git 2.43.0
- NOT provisioned: Tiger Cloud, LLM API key, GitHub App. M8 halts until these exist.
- `GENESIS_KIT_ROOT=/home/ketan/Desktop/genesis-kit` (exported in ~/.bashrc twice — line 150 wins)

## Traps found during genesis (do not rediscover)
- `graphizer.mjs --write` rebuilds context-graph.json from scratch and **destroys hand-written
  invariants** + resets freeze_boundary to `src/**`. Always use `bash scripts/regraph.sh` instead.
- `scaffold.sh` does an unconditional `shift 2`, so it needs BOTH positionals
  (`scaffold.sh <target> <project-name>`) before any flags, or it silently eats the first flag.
