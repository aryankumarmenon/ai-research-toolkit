# 2026-08-02 — NGO project validation kit

Outreach + interview materials for validating four candidate side-project ideas
before committing 120 weekend hours to one. Produced from a four-agent research
fan-out (job market · NGO tech gaps · portfolio signal · feasibility) run
2026-08-02.

**Standing rule for this kit:** ask about *past behaviour*, never future
intentions. "Would you use X?" is free to answer yes to and predicts nothing.
"Walk me through what you did last March" is evidence.

---

## Candidates under validation

| # | Project | One-line problem |
|---|---|---|
| 1 | Form 10BD donation reconciliation | Every 80G NGO must file a statement of every donation (donor PAN, amount, mode); small orgs assemble it by hand from bank PDFs, UPI screenshots and spreadsheets |
| 2 | FCRA dual-ledger | Foreign contributions must stay strictly segregated from domestic funds, with utilisation reporting; commonly handled via Tally workarounds |
| 4 | CSR-1 extraction + matching | NGOs seeking corporate CSR money must assemble PAN, 12A/80G, Darpan ID and a track record from heterogeneous PDFs |
| 10 | Spreadsheet-sprawl sync | 90% of nonprofits run 3+ systems, 79% run 5+; integration failure is the best-evidenced pain in the whole research set |

---

## Pre-committed decision gates

Written **before** any data arrives, so the results can't be rationalised after
the fact. Target sample: **5–8 conversations**. That's enough to see a pattern at
this stage; it is not a survey and shouldn't be presented as one.

| # | Promote if | Kill if |
|---|---|---|
| 1 | ≥3 of 5 finance interviewees describe **≥8 hours** of manual work per filing **and** name a concrete failure (rejection, correction, donor complaint about a missing deduction) | Most say their existing CRM/accounting software already handles it end to end |
| 2 | ≥2 describe an actual segregation error, near-miss, or audit query on FCRA funds | Everyone reports it as routine and fully handled by Tally |
| 4 | ≥3 describe CSR documentation as a **recurring** multi-day burden | It turns out to be a once-and-done registration, not a repeating cost |
| 10 | ≥3 describe re-entering the same data in two systems **weekly or more**, plus a concrete case where divergence produced a wrong number in a report | They only really use one or two systems and copying is rare |

If two candidates both clear their gate, prefer the one where interviewees
described a *specific incident* rather than a general grumble.

---

## Audience map

The person who feels the pain is often not the NGO's leadership.

| Candidate | Interview whom | Why them |
|---|---|---|
| 1, 2, 4 | **CA / accountant / finance volunteer** | They do the filing and feel the hours. One CA serves many NGOs, so a single conversation covers a dozen orgs |
| 10 | **Programme / M&E staff** | They maintain the spreadsheets and do the double entry |

---

## Script A — finance & compliance (#1, #2, #4)

Cap at 20 minutes. Let them talk; the goal is a story, not a checklist.

**Warm-up**
- What's your role, and roughly how many nonprofit clients do you handle (or is this for your own organisation)?

**Form 10BD (#1)**
1. Walk me through what happened for the last 10BD filing — start from wherever the donation data was sitting.
2. Where did that data come from? How many separate sources did you have to pull together?
3. Roughly how long did it take, and who actually did the work?
4. What went wrong last time? Did anything get rejected or need a correction filing?
5. How do you handle donations where the PAN is missing, wrong, or the donor never gave one?
6. What do you currently pay for any part of this — software, a professional fee, someone's time?

**FCRA (#2)**
7. How do you keep foreign and domestic funds separated in the books today — what's the actual mechanism?
8. Has that separation ever gone wrong, or come close? What happened?
9. Last time you produced a utilisation report, what did that involve?

**CSR (#4)**
10. When a corporate asks for your CSR documentation, what do they ask for, and what's painful to assemble?
11. How often does that come up — per corporate, per year, per proposal?

**Closing (always ask both)**
- If this whole task disappeared tomorrow, what would you do with the time?
- Who else should I be talking to?
- Can I come back in about six weeks and show you something?

**Never ask:** "would you use a tool that…", "does this sound useful?", "how much
would you pay for…". If they volunteer an opinion on a solution, write it down
but weight it near zero.

---

## Script B — programme / M&E staff (#10)

1. List every place your programme data currently lives — every system, sheet and app.
2. Walk me through the last time the same information had to be entered in more than one of them.
3. When two systems disagree, how do you find out? What do you do about it?
4. Who does the copying, and how often?
5. Tell me about a time data got lost or overwritten between systems.
6. What's the last report that forced you to pull from multiple systems? How long did assembling it take?
7. Have you tried to connect any of these before — exports, Zapier, a script, a volunteer? What happened to that?

---

## Outreach templates

Keep them short. No pitch, no feature list, no promised delivery date.

### A. Warm intro via an intermediary

> Subject: Intro request — research on nonprofit compliance tooling
>
> Hi [name],
>
> I'm a software engineer building a free, open-source tool for Indian nonprofits,
> and I'm at the stage of trying to understand the problem properly before writing
> any code.
>
> I'm looking to speak to 5–8 people who handle 10BD/FCRA filings or programme
> data for NGOs — 20 minutes, just about how the work actually gets done today.
> I'm not selling anything and there's nothing to buy.
>
> Would you be able to point me toward anyone, or tell me if this is the wrong
> question to be asking?
>
> Thanks,
> [name]

### B. Cold — CA / accountant

> Subject: 20 minutes on how NGO 10BD filings actually get done?
>
> Hi [name],
>
> I'm a software engineer, and I'm building a free open-source tool to reduce the
> manual work in nonprofit compliance filings. Before I build anything I want to
> understand how the process really works today — including the parts that are
> messier than the guides suggest.
>
> Would you have 20 minutes to walk me through how your last 10BD or FCRA
> utilisation filing went? I'm not selling anything, and I'll send you whatever I
> learn from the other conversations.
>
> Thanks,
> [name]

### C. Cold — NGO programme staff (#10)

> Subject: 20 minutes on how your programme data moves between systems?
>
> Hi [name],
>
> I'm a software engineer building a free open-source tool for nonprofits. I'm
> trying to understand a specific problem first: how data ends up spread across
> several spreadsheets and systems, and what that costs people day to day.
>
> Could I borrow 20 minutes to hear how it works at [org]? Nothing to buy — I'll
> share back what I learn.
>
> Thanks,
> [name]

---

## Channels

Warm intros massively outperform cold email — someone vouching for you is the
difference between a reply and the spam folder.

**Intermediaries (highest value)**
- Project Tech4Dev — the Glific / Avni / Dalgo ecosystem; active and India-focused
- Dasra
- NASSCOM Foundation
- TechSoup India

**Compliance professionals (best route for #1, #2, #4)**
- ICAI NPO/NGO-sector committees and study circles
- CAclubindia forums
- LinkedIn — CAs who publicly post about 12A/80G/FCRA work
- Any CA in your own network, or your family's — start here, it's the cheapest first call

**Nonprofit tech communities**
- CiviCRM India community
- Glific / Avni user groups
- Code for India, IndiaFOSS, university social-impact cells

---

## Rules for running this

- **Cap the initial batch at ~15 contacts.** Small NGOs are under-resourced; a
  mass mail asking for unpaid product research is a real imposition.
- **Never request real data.** No donor lists, no PANs, no beneficiary records —
  not even "just a sample". Build with synthetic data.
- **20 minutes means 20 minutes.**
- **Send a summary back** to everyone who talked to you. It's the payment.
- **Don't promise a delivery date** or imply they're getting a product.
- Expect a low response rate and multi-week latency. This runs *in parallel* with
  building — it must not gate the start.

---

## Response log

| Date | Who | Role | Candidate(s) touched | Hours they described | Concrete failure named? | Gate movement |
|---|---|---|---|---|---|---|
| | | | | | | |

---

## Provenance

Synthesised from four parallel Sonnet research agents (2026-08-02). Evidence
quality varies sharply: the nonprofit tech-sprawl statistics and the Indian
compliance procedural facts are well-sourced; the portfolio-signal "dead
categories" advice came largely from low-authority SEO blogs and is directional
only. The gates above deliberately depend on what interviewees *describe*, not on
any of the secondary statistics.
