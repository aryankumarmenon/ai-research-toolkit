---
name: consensus
description: Answer an open-ended question by spawning N independent agents with varied reasoning stances, then aggregate their solution lists by frequency — high-frequency = consensus (filters hallucinations), low-frequency = high-variance outliers worth keeping. For option generation, ranking, and strategy, not for executing a single task.
disable-model-invocation: true
allowed-tools: Task
---

# Stochastic Consensus

Spread an open-ended question across N independent agents, then synthesize their
answers by **how often each idea recurs**. Exploits LLM stochasticity: the same
prompt diverges run-to-run, so N runs cover far more of the solution space than
one — and recurrence across independent agents is a cheap confidence signal.

**Use it for:** problems with a **checkable answer** (numeric, factual, a discrete
choice) where agreement across samples filters errors — this is *self-consistency*
(Wang 2022), proven on reasoning benchmarks. For **open-ended** ideation
("all the ways to X") it still helps you scan a search space, but the aggregation
is a dedup, not a real vote — weight the "consensus" accordingly.
**Don't use it for:** executing one well-defined task (that's just the 7× wallet
hit with no upside). If there's one right action, don't poll for it.

## Process

### 1. Frame the question
One clear, open-ended prompt with a concrete output ask, e.g. "Brainstorm all the
ways to `<X>`; return at least `<10>` distinct options as a list." If the user's
question is a single-answer task, stop and say so — this isn't the right tool.

### 2. Fan out N agents in parallel (one message, N Agent calls)
- `<N>` agents (start at 5–10), each on a **cheap/fast model** (`<Sonnet/Haiku>`)
  — research and ideation are token-heavy, low-reasoning work.
- Give each the **same core prompt** but a **different stance** so they explore
  different regions: e.g. conservative/traditional, adventurous/boundary-pushing,
  first-principles, contrarian/challenges-assumptions, pragmatic/cost-driven.
- Each returns its own list. They run independently — no shared context.

### 3. Aggregate by frequency (synthesizer on a smart model)
On the **expensive model** (`<Opus>`) with a *short* prompt — it's combining,
not researching:
- Deduplicate across all lists; count how many agents produced each idea (the
  **mode**).
- Split the output into two buckets:
  - **Consensus** — high-frequency ideas multiple agents independently reached.
    Recurrence is what *filters hallucinations*; trust these most.
  - **High-variance outliers** — ideas only one agent surfaced. Don't discard —
    these are the creative/non-obvious options that make the exercise worth it.
- Report raw count, deduped count, then the two buckets.

## Why frequency, not a single pick
One smart agent could produce a list too — but you'd get one trajectory through a
stochastic space. N independent agents plus frequency-counting gives you both the
*statistically likely* answers (consensus) and the *genuine outliers*, and tells
them apart. That separation is the whole value; don't collapse it into one ranked
list.

<!-- Tune <N>, the model tiers, and the stance set per project. Keep the cheap
model for fan-out and the smart model for synthesis — that split is the economics. -->
