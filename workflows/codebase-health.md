# Workflow: Codebase Health

Not feature work — *upkeep*. Agents radically accelerate coding, which means they
also accelerate **software entropy**: codebases get more complex at an
unprecedented rate. Run this every few days to keep the code good for agents (and
humans) to operate in. Distilled from Pocock's `improve-codebase-architecture`
and `codebase-design`.

```
explore → report → pick → grill the fix → (feeds back into idea→ship)
```

---

## The design vocabulary (use these exact terms)

The point is a *shared language* — don't substitute "component", "service",
"API", or "boundary".

| Term | Meaning |
|---|---|
| **Module** | Anything with an interface + implementation (scale-agnostic: function → package → tier-spanning slice) |
| **Interface** | *Everything* a caller must know: signature **plus** invariants, ordering, error modes, config, perf — not just the type surface |
| **Implementation** | What's inside the module |
| **Depth** | Leverage at the interface: behaviour exercised per unit of interface learned |
| **Seam** (Feathers) | Where you can alter behaviour without editing in that place — *where the interface lives* |
| **Adapter** | A concrete thing satisfying an interface at a seam (a role, not a substance) |
| **Leverage** | What callers get from depth (capability per unit of interface) |
| **Locality** | What maintainers get from depth (change/bugs/knowledge concentrate in one place) |

**Deep module = small interface + lots of implementation.** Shallow = interface
nearly as complex as the implementation (avoid). When designing an interface ask:
fewer methods? simpler params? more complexity hidden inside?

### Principles

- **Depth is a property of the interface, not the implementation.** A deep module
  can be internally composed of small mockable parts — they just aren't *in* the
  interface.
- **The deletion test.** Imagine deleting the module. Complexity vanishes → it was
  a pass-through (shallow). Complexity reappears across N callers → it earned its keep.
- **The interface is the test surface.** If you want to test *past* the interface,
  the module is the wrong shape.
- **One adapter = a hypothetical seam; two adapters = a real one.** Don't add a
  seam unless something actually varies across it.

### Designing for testability

1. **Accept dependencies, don't create them** (`processOrder(order, gateway)` not `new StripeGateway()` inside).
2. **Return results, don't produce side effects** (`calculateDiscount(cart): Discount` not mutating `cart.total`).
3. **Small surface area** — fewer methods/params = fewer, simpler tests.

---

## The process

### 1. Explore
Read `CONTEXT.md` and relevant ADRs first. Then use a read-only **Explore
subagent** to walk the codebase *organically* (no rigid heuristics) and note
friction: bouncing between many small modules to understand one concept; shallow
modules; pure functions extracted for testability while the real bugs hide in how
they're called (no locality); modules leaking across seams; untested or
hard-to-test-through-their-interface code. Apply the deletion test to suspects.

### 2. Present candidates as a visual HTML report
Write a self-contained HTML file to the **OS temp dir** (nothing lands in the
repo), open it, tell the user the path. Each candidate card: Files · Problem ·
Solution (plain English) · Benefits (in terms of locality/leverage and how tests
improve) · **before/after diagram** · recommendation badge (Strong / Worth
exploring / Speculative). End with a "Top recommendation". Use `CONTEXT.md`
vocabulary for the domain and the design vocabulary for the architecture. Don't
propose interfaces yet — ask "which would you like to explore?"

### 3. Grill the chosen fix
Run the grilling loop on the picked candidate — constraints, the shape of the
deepened module, what sits behind the seam, what tests survive. Keep the domain
model current inline (new concept → add to `CONTEXT.md`; rejected with a
load-bearing reason → offer an ADR so future reviews don't re-suggest it).

This generates an *idea*, which re-enters [idea-to-ship.md](idea-to-ship.md) at
the align step.

---

## When to reach for this

- On a cadence ("once every few days").
- After a `diagnosing-bugs` post-mortem concludes the root cause was
  architectural (no good seam, tangled callers) — hand off here with specifics.
- Before starting a big feature in a part of the codebase that already feels like
  a ball of mud — deepen the seams first so the feature is easier to slice.
