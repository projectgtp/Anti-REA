# Anti-REA v1.0 — Traps (defensive only)

A trap is a fake thing that looks real. Its whole job is to waste an
attacker's time and, if it is ever USED, to flag the attempt
server-side. A trap NEVER bricks anything, deletes anything, or harms
any device or analyst.

## The traps in v1.0

| Trap | What it looks like | What happens if used | Layer |
|------|-------------------|----------------------|-------|
| Fake secrets | Plausible API keys / tokens in smali | Server logs a tripwire event (L62), flags the account for review (L63) | L04, L72 |
| Fake endpoints | Plausible admin / debug URLs | Same tripwire; the endpoint does not exist, so calls fail safely | L05, L71 |
| Fake keys | Plausible key material | Same tripwire | L73 |
| Decoy API | Fake methods returning fake data | Caller gets plausible-looking wrong data; use is logged if the app reports it | L74 |
| Dead-code maze | Branch chains that always resolve to 0 | Nothing. It only costs analysis time | L53, L75 |
| Delayed silent failure | A sensitive action works briefly, then refuses once integrity has failed | The action is refused (never a wrong result) | L50 |

## Rules for traps

1. Every honeypot value MUST be fake and MUST come from the config's
   `honeypots:` section. Never put a real secret in a trap — a trap
   is bait, and bait must be worthless.
2. A trap's response is always one of: return a fake value, record an
   event, refuse one sensitive action. Never more.
3. One tripwire event is never auto-punishment. The server flags for
   human review; repeated events may escalate (server policy, not
   this tool).
4. Traps chain: all honeypots share one tripwire format
   (`tripwire/v1`, see docs/SERVER.md), so the second trap
   an attacker touches is recognised as the same actor.
5. If a trap ever fires on a legitimate user, that is a bug — the fake
   values must never be reachable from normal app code paths. Only
   the attacker's tools (decompilers, scripts) can see them.

## What traps are NOT

- Not malware, not a virus, not a rootkit. No code runs on the
  analyst's machine.
- Not a way to "hack back". There is no counter-attack.
- Not a replacement for server checks. The server is the enforcement;
  traps are the alarm.
