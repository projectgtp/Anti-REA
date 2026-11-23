# GameGuardian — what it does, and what we do about it

Date: 2026-11-23. Written in simple words, on purpose. No fix here
is perfect — the honest limits are at the bottom, not hidden.

## What GameGuardian does (in simple words)

GameGuardian is a memory editor for Android games. It does NOT open
your APK file and read your code. That is not how it works.

It works while your app is RUNNING. Think of it like this:

1. **Run** — your app is running on the phone, and your points
   (say, 100) are sitting in the phone's memory (RAM).
2. **Dump** — GameGuardian copies that memory and looks through it.
   It searches for the number 100.
3. **Write** — you spend 10 points, so now it is 90. GameGuardian
   searches again for 90. After a few rounds it knows exactly where
   your points live. Then it WRITES a new number there — 99999 —
   and your app now thinks you have 99999 points.

Dump, run, write. That is the whole trick. The user who asked about
this said it exactly right: "runtime memory dump, run, write".

It needs root to do this, because Android normally does not let one
app read another app's memory. GameGuardian uses a Linux call called
`ptrace` to attach to your app's process — its own author says
there is no other way, only ptrace. There is also a no-root mode
where your app runs inside GameGuardian's own virtual space — see
"what is still not fixed" below, because that mode is harder.

## Why a name blocklist can never catch it

GameGuardian changes its own name every time it is installed. On
purpose. Its own help page says so, in plain words: it reinstalls
itself with a random package name "to prevent detection by
anti-cheats by package name". Its starting name is
`catch_.me_.if_.you_.can_`, but the name on your phone is almost
never that — it is a random jumble of letters.

So checking "is an app called GameGuardian installed?" will never
work. That is why the first version of Anti-REA left it unverified.
It was not laziness. A name check against a random name is a check
that can never fire. We do not ship checks that can never fire and
pretend they protect you.

## What we do now (layers L102 + L103)

We catch GameGuardian by what it DOES, not by what it is called.

**L102 — GameGuardian / memory-editor defence:**

- **Tracer check.** When GameGuardian attaches to your app with
  ptrace, Android writes that down: in `/proc/self/status` the
  line `TracerPid` becomes the GameGuardian process id instead of
  0. We read that line before every sensitive action (login, buy,
  settle). If it is not 0, someone is attached — refuse the
  action. We also read `/proc/self/stat`: a traced process sits in
  state `t` (stopped). Two signals for the same fact.
- **Memory-map scan.** We read `/proc/self/maps` and look for
  named GameGuardian pieces: `gameguardian`, `libgg`,
  `bulldog-daemon`, and the starting data name. We do NOT look for
  the letters `gg` on their own — they appear in innocent words
  like "logged" and would block innocent users all day.
- **Known folders.** We check (read-only, never writing) whether
  GameGuardian's starting data folders exist. This is a weak signal
  on its own, because the random install renames them — but
  together with the tracer check it is one more piece of evidence.
- **Root + trace together.** GameGuardian needs root. Our root
  check already exists. When root AND a tracer signal fire
  together, that is the strong combination — we say so in the
  report, instead of treating root alone as proof (many honest
  phones are rooted).
- **Hidden numbers in memory.** This is the real fix for the
  "write" step. A points balance is no longer stored as the plain
  number 100 in memory. It is stored split into two random-looking
  pieces, plus a checksum. A memory scan for "100" finds nothing —
  there is no 100 in memory to find. If someone writes garbage
  into those pieces, the checksum does not match and the read
  refuses instead of returning a wrong number. See
  `runtime/ReaMemory.kt` (`ObfuscatedLong`, `ObfuscatedInt`).
  Example: `val points = ObfuscatedLong(100L)`, then
  `points.get() ?: refuse()`.

**L103 — renamed / repacked APK defence:**

A renamed APK is the same app with a new name. An attacker takes
your APK, changes the package name so no name list matches it,
re-signs it with THEIR key, and installs it. We catch it two ways:

- **Package name.** The app knows what its own package name must
  be. Before every sensitive action it compares the running name
  with the expected one. A renamed copy fails — refuse.
- **Signature.** Every APK is signed. Your release key has a
  fingerprint (SHA-256 of the signing certificate). A repacked APK
  is re-signed with the attacker's key, so the fingerprint WILL be
  different — the attacker cannot forge your key without it. We
  compare the running app's certificate fingerprint with the
  expected one. The expected fingerprint is stored as an encrypted
  blob, never as a plain string (make it with
  `tools/make_sig_blob.py` from your own release certificate).
  Mismatch — refuse.

The installer check (which store installed the app) is recorded as
a signal only. It never refuses on its own, because honest users
sideload apps too.

## What only the server can do (the most important part)

None of the above stops a determined root attacker completely. If
someone has root, time, and patience, and watches the exact
function that reads your hidden number, they can still get it. That
is true for every protection on every app. Please do not believe
anyone who tells you otherwise.

So the rule that actually protects money and points is this:

> **Never trust a number the phone reports. The server recomputes
> it from its own records.**

If the phone says "this user has 99999 points", the server must
check its own ledger and say "no — our records say 90". Bridge
already does this: balances come from the server's ledger, not from
whatever the app claims. That is the example to copy. Client checks
slow the attacker down and catch the easy cases; the server is what
makes the cheating useless.

## What is still not fixed (please read this)

- **Root + patience wins in the end.** A root memory editor that
  watches the read function can still win. Our layers make it
  slow, noisy, and likely to trip a check — they do not make it
  impossible. The server rule above is what makes the win useless.
- **Virtual-space GameGuardian (no-root mode).** GameGuardian can
  run your app inside its own virtual space, so our checks run
  inside ITS environment. The tracer and maps checks see the
  virtual world, not the real one. We do not claim to catch this
  mode. Only server-side validation catches it.
- **Renamed clones of the tools.** A memory editor renamed to a
  random name escapes every name check. That is exactly why L102
  checks behaviour (tracer, maps, files) instead of names.
- **No device test yet.** Everything here is compile-verified and
  JVM-tested only. No phone test has happened. The user's
  reverse-engineering contact is the planned real test.
- **False positives exist.** A tracer check can fire on a phone
  being debugged for honest reasons (a developer testing their own
  app). A rooted phone is not proof of cheating. That is why every
  check here returns a signal and the app refuses ONE sensitive
  action — it never deletes anything, never kills another app, and
  never blocks the app from opening.

## Files

- `runtime/ReaTrace.kt` — TracerPid / stat state / maps / files
  checks (L102 behaviour detection).
- `runtime/ReaMemory.kt` — `ObfuscatedLong`, `ObfuscatedInt`
  (hidden numbers in memory).
- `runtime/ReaRepack.kt` — package name, signing-certificate
  fingerprint, installer signal (L103).
- `runtime/ReaEnv.kt` — the new findings are part of `checkAll()`,
  so `ReaGuardProvider` reports them automatically.
- `tools/make_sig_blob.py` — make the encrypted expected-
  fingerprint blob from your release certificate SHA-256.
- `runtime/tests/GameGuardianFixTest.kt` — JVM tests for all of it.
- `GAMEGUARDIAN-FIX-REPORT.md` — the full evidence for this fix.
