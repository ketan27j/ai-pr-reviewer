#!/usr/bin/env bash
# regraph.sh — safely re-derive .genesis/context-graph.json from real imports.
#
# WHY THIS EXISTS: genesis-kit's tools/graphizer.mjs builds its output object from
# scratch (graphizer.mjs:69-77) and writeFileSync's it (line 82). It never reads the
# existing file, so `graphizer.mjs . --write` DESTROYS hand-written invariants and
# resets freeze_boundary to ["src/**"]. Run this instead of graphizer directly.
#
# Usage: bash scripts/regraph.sh
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
GRAPH="$ROOT/.genesis/context-graph.json"
KIT="${GENESIS_KIT_ROOT:-$HOME/Desktop/genesis-kit}"

[[ -f "$GRAPH" ]] || { echo "no context-graph.json at $GRAPH"; exit 1; }
[[ -f "$KIT/tools/graphizer.mjs" ]] || { echo "graphizer not found under GENESIS_KIT_ROOT=$KIT"; exit 1; }

# 1. stash the hand-written parts (incl. the seeded nodes/edges, in case the
#    repo still has no importable code and graphizer would regress us to zero)
PRESERVED="$(mktemp)"
python3 - "$GRAPH" > "$PRESERVED" <<'PY'
import json, sys
g = json.load(open(sys.argv[1]))
json.dump({k: g[k] for k in ("invariants", "freeze_boundary", "$comment", "seeded_by",
                             "nodes", "edges") if k in g},
          sys.stdout, indent=2)
PY

# 2. regenerate nodes/edges from actual imports
node "$KIT/tools/graphizer.mjs" "$ROOT" --write >/dev/null

# 3. merge the hand-written parts back over the regenerated file
python3 - "$GRAPH" "$PRESERVED" <<'PY'
import json, sys
graph = json.load(open(sys.argv[1]))          # freshly derived from imports
kept  = json.load(open(sys.argv[2]))          # hand-written / seeded
derived_nodes, derived_edges = graph["nodes"], graph["edges"]

# Hand-written parts always win.
graph.update({k: v for k, v in kept.items() if k not in ("nodes", "edges")})

if derived_nodes:
    # Real code exists — imports are now the source of truth for the graph.
    graph["nodes"], graph["edges"] = derived_nodes, derived_edges
    graph.pop("seeded_by", None)
    origin = f"derived from imports ({len(derived_nodes)} nodes)"
else:
    # No importable code yet — keep the G2 architectural seed rather than regress to zero.
    graph["nodes"], graph["edges"] = kept.get("nodes", []), kept.get("edges", [])
    origin = f"no code yet — kept G2 seed ({len(graph['nodes'])} nodes)"

graph["project"] = "ai-pr-reviewer"
json.dump(graph, open(sys.argv[1], "w"), indent=2)
open(sys.argv[1], "a").write("\n")
print(f"re-graphed: {origin}, {len(graph['edges'])} edges, "
      f"{len(graph['invariants'])} invariants preserved")
PY
rm -f "$PRESERVED"

# 4. re-assert the G2 gate: no cycles, >=2 invariants
python3 - "$GRAPH" <<'PY'
import json, sys
g = json.load(open(sys.argv[1]))
adj = {}
for a, b in g["edges"]:
    adj.setdefault(a, []).append(b)
color, cycles = {}, []
def dfs(u, stack):
    color[u] = 1; stack.append(u)
    for v in adj.get(u, []):
        if color.get(v) == 1:
            cycles.append(" -> ".join(stack[stack.index(v):] + [v]))
        elif color.get(v, 0) == 0:
            dfs(v, stack)
    stack.pop(); color[u] = 2
for x in g["nodes"]:
    if color.get(x, 0) == 0:
        dfs(x, [])
if cycles:
    print("G2 GATE FAIL — dependency cycles:", *cycles, sep="\n  "); sys.exit(1)
if len(g["invariants"]) < 2:
    print("G2 GATE FAIL — fewer than 2 invariants"); sys.exit(1)
print("G2 GATE: PASS — no cycles, %d invariants" % len(g["invariants"]))
PY
