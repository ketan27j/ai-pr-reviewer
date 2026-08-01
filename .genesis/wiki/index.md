# Wiki Index — ai-pr-reviewer

The project knowledge base. Same schema as the agentic-swe-kit wiki: concept pages in `concepts/`,
each with frontmatter and ≥2 `[[wikilinks]]`. The L3 RESEARCH loop writes here; G0 reads here first.

> **Read this file before any milestone (G0 step 1).** Pick candidate pages by name-matching the
> milestone's nouns, then drill in. The wiki is what prevents rebuilding work that already exists.

**Source spec:** `~/ketan-data/code/antern/SessionNotesDeliverables/Week8/pr-review-agent.html`
— the first-principles architecture study this project implements. Levels are cited as L0–L9,
decisions as ADR-001…004.

## Entities (the things this system has)
<!-- stubs listed now so milestones can name them; promote to concepts/ pages as they become real -->
- `Finding` — the object on every arrow: `agent_type, severity, category, summary, file_path, line_start/end, suggestion, confidence, rationale` (L2). Created M2.
- `Review` — one PR's aggregated verdict: merged findings + `overall_confidence` + routing decision (L7). Created M2.
- `AgentEvent` — one row per action on the time spine: span/llm.call/tool.call/decision + cost + latency (L6). Created M6.
- `CodeChunk` — one embedded slice of the repo: `repo, path, symbol, chunk_index, content, embedding(256), content_tsv` (L5). Created M7.

## Concepts (how it works)
- _(none yet — the first L3 RESEARCH loop fills this)_

## Sources (research distilled by L3)
- _(none yet)_

## Seeded from agentic-swe-kit
Relevant global concept pages for this project's phases (pointers only — read on demand).
Root: `$AGENTIC_SWE_WIKI_ROOT` = `~/.agentic-swe-kit/wiki`

### Phase 1 — System Architecture (ADR-002 modular monolith) → M1
- `clean-architecture/concepts/Dependency-Arrow-Rule-All-dependency-arrows-between-components-must-point-toward.md` — the rule the `dependency_direction_inward` invariant enforces
- `clean-architecture/concepts/Boundary-Lines.md` — where to cut the 23 modules
- `clean-architecture/concepts/Component-Coupling-Principles.md` — acyclic dependencies; why the G2 cycle check exists
- `clean-architecture/concepts/Defer-Decisions-Framework-Shape-the-system-so-that-the-choice-of-database-web-fr.md` — the ADR-001 LangGraph→Temporal seam, stated generally
- `clean-architecture/concepts/Database-as-Detail-The-database-is-a-low-level-mechanism-like-a-doorknob-that-do.md` — read before letting Tiger Cloud specifics leak inward
- `distributed-systems/concepts/System-Architecture-Styles.md` — monolith vs the alternatives

### Phase 3/4 — Backend, ingress, orchestration → M3, M4
- `llmops-ai-agents/concepts/Orchestrator-Worker-Architecture.md` — the topology this build uses
- `llmops-ai-agents/concepts/Parallel-and-Fan-Out-Agents.md` — **the** page for the LangGraph Send fan-out (L3)
- `llmops-ai-agents/concepts/Multi-Agent-Orchestration.md` — span-of-control, join semantics
- `llmops-ai-agents/concepts/Agentic-Design-Patterns.md` — pattern catalog to check the design against
- `distributed-systems/concepts/Communication-Models.md` — why ingress enqueues instead of calling inline
- `release-it/concepts/Integration-Points.md` — every hop out of the process is a failure source

### Phase 5/8 — LLM layer, the four specialists, aggregator → M4, M5
- `llmops-ai-agents/concepts/Agent-Fundamentals.md` — baseline vocabulary
- `llmops-ai-agents/concepts/LLMOps-Essentials.md` — prompt versioning, routing, structured output
- `llmops-ai-agents/concepts/Hierarchical-Agent-Systems.md` — the aggregator-over-specialists shape
- `llmops-ai-agents/concepts/Metacognitive-Agents.md` — where `confidence` actually comes from; read before trusting it to gate autonomy

### Phase 6 — Memory / RAG → M7
- `llmops-ai-agents/concepts/RAG-Architecture.md` — hybrid retrieval, chunking, citation grounding (L4)
- `designing-data-intensive-applications/concepts/Storage-Engines.md` — what DiskANN-on-SSD is trading away
- `designing-data-intensive-applications/concepts/Polyglot-Persistence.md` — **read against ADR-003**; the strongest counter-argument to one-store
- `designing-data-intensive-applications/concepts/Data-System-Architecture-Patterns.md` — memory/truth/time as shapes (L5)
- `designing-data-intensive-applications/concepts/Encoding-and-Schema-Evolution.md` — re-embedding when the chunk schema changes

### Phase 10/16 — Observability, events spine, cost → M6
- `llmops-ai-agents/concepts/Observability-and-Cost-Control.md` — per-span cost attribution, BudgetGuard (ADR-004)
- `release-it/concepts/Steady-State.md` — retention/compression on the hypertable before it eats the disk
- `designing-data-intensive-applications/concepts/Stream-Processing-Patterns.md` — continuous aggregates as incremental views

### Phase 11 — Security (trust boundary: the diff is hostile) → M3, M8
- `security-engineering/concepts/Threat-Modeling.md` — write the threat model here, adversary categories first
- `security-engineering/concepts/Protocol-Security.md` — HMAC-SHA256 webhook verification, replay windows
- `security-engineering/concepts/Access-Control.md` — RBAC on the HITL and dispute routes
- `security-engineering/concepts/Secure-Development-and-Assurance.md` — secrets handling; why `.env` never enters git

### Phase 12 — Reliability → M3, M4, M8
- `release-it/concepts/Circuit-Breaker.md` — the breaker in `reliability/circuit_breaker.py`
- `release-it/concepts/Stability-Patterns.md` and `release-it/concepts/Stability-Antipatterns.md` — the catalog behind `every_outbound_call_bounded`
- `release-it/concepts/Fail-Fast.md` — degrade to slower-but-correct, never fast-but-wrong
- `release-it/concepts/Bulkheads.md` — one hung specialist must not sink the other three
- `distributed-systems/concepts/Fault-Tolerance.md` — timeout/retry/idempotency semantics

### Phase 9 — Evaluation (deferred past the vertical slice, but read early)
- `llmops-ai-agents/concepts/Evaluation-Frameworks.md` — golden datasets, LLM-as-judge calibration
- `llmops-ai-agents/concepts/Production-Hardening.md` — what "ready" means before M8 posts to a real PR
