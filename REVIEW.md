# Review — `lib/sms_console.dart` (starter)

Reviewed against `API-CONTRACT.md`. Line numbers refer to the starter file as
committed at `4b13563`.

---

### 1. Hardcoded API credential and tenant ID committed to source

**Severity:** Critical — leaked credential.
**Location:** lines 8–10.

```dart
const String kApiKey = 'fw_live_8c21e0b47ad94f13ba77e0c9d51a3b62';
const String kTenantId = '9f1c2d3e-4a5b-6c7d-8e9f-0a1b2c3d4e5f';
```

A live-looking API key and a tenant UUID are compiled into the app binary and
committed to git history. Anyone who decompiles the APK/web bundle, or anyone
with repo read access (including in a public GitHub submission), gets a
working credential for whatever it's scoped to. Rotating it after the fact
doesn't remove it from history. There is also no per-user session — every
install of the app shares one tenant, so multi-tenancy is architecturally
impossible with this code.

**Fix:** never bake secrets into source. Read the API base URL from
`--dart-define`/build config; obtain access/refresh tokens through an auth
flow and hold them in `flutter_secure_storage`, never in a `const`. Tenant ID
becomes part of a session object selected at runtime, not a compile-time
constant.

---

### 2. No `mounted` check after `await` — throws if the user navigates away mid-request

**Severity:** High — crash on a normal usage pattern (slow network + back button).
**Location:** lines 45, 57, 77, 83 (`setState` and `ScaffoldMessenger.of(context)` after every `await`).

```dart
Future<void> loadCosts() async {
  setState(() => loading = true);
  final res = await http.get(...);           // widget may be disposed here
  ...
  setState(() => loading = false);           // throws if disposed
}
```

`initState` calls `loadCosts()` without awaiting it, and every method
resumes after an `await` and immediately calls `setState` (or
`ScaffoldMessenger.of(context)`, which also needs a live `context`) with no
check that the widget is still in the tree. On a slow connection, the very
common case of the user backing out of the screen before the request
completes throws `setState() called after dispose()`.

**Fix:** guard every post-`await` state mutation with `if (!mounted) return;`,
or move the async logic into a state-management layer (Riverpod
`AsyncNotifier`, this rebuild) whose lifecycle is decoupled from the widget's.

---

### 3. `loadCosts()` has no error handling at all — no error state is possible

**Severity:** High — violates the explicit requirement to handle 429/502/timeout, produces either an unhandled exception or a stuck spinner.
**Location:** lines 44–58.

Unlike `sendSms` (which at least swallows exceptions into
`AppState.lastError`, itself never read anywhere), `loadCosts()` has no
`try`/`catch`. Any non-200 response, a `429` with `Retry-After`, a `502` from
the upstream provider, or a timeout on a slow connection is an unhandled
`Exception` that propagates out of an `async` callback — the screen is left
showing `loading = true` forever, i.e. the exact infinite spinner the
assignment calls out.

**Fix:** every repository call must produce a typed result (`Either<Failure,
T>` in this rebuild) covering the specific failure modes in the contract, and
the UI must render a distinct widget per failure with a retry action —
never rely on an uncaught exception to "handle" an error state.

---

### 4. `FutureBuilder` re-issues a fresh `http.get` inline in `build()`

**Severity:** Medium — duplicate network calls, flicker, and inconsistent state, but not itself an incident.
**Location:** lines 109–110.

```dart
future: http.get(Uri.parse('$kApiBase/api/v1/sms/cost/breakdown'), ...),
```

A new `Future` (and therefore a new HTTP request) is created on every
`build()`, which happens on every `setState()` anywhere in the widget
(including the `loading` toggle from `sendSms`). This duplicates
`loadCosts()`, which already fetches and caches the same data into
`AppState.history` two lines above — the two code paths can race and briefly
show different data for the same screen depending on which response lands
first.

**Fix:** fetch once through the state layer and let the widget only read the
cached state; never construct a `Future` inside `build()`.

---

### 5. `totalCost` cast from a decimal string as `double` — crashes against the real API, and loses precision even if it didn't

**Severity:** Critical — crash / wrong money.
**Location:** line 52.

```dart
total = total + (costRows[i]['totalCost'] as double);
```

The contract is explicit: `"totalCost": "12.4500"` is a **decimal string**,
never a float, specifically because `double` can't represent values like
`0.0079` exactly. Against a real backend response this line throws a
cast error the first time it runs — the cost screen never renders. Even if
it were parsed with `double.parse` instead of cast, summing many `double`
amounts accumulates binary floating-point error (`0.1 + 0.2 != 0.3`), which
on an invoice across hundreds of thousands of messages is real money —
exactly the scenario the contract calls out.

**Fix:** parse the string with an exact decimal type (`Decimal.parse`, this
rebuild) and never touch `double` for money anywhere in the pipeline.

---

### 6. Global mutable static state — no tenant scoping, no isolation

**Severity:** Critical — cross-tenant data leak (the exact failure mode the assignment calls out under tenant isolation).
**Location:** lines 12–16.

```dart
class AppState {
  static double totalCost = 0.0;
  static List<dynamic> history = [];
  static String? lastError;
}
```

There's a single hardcoded `kTenantId` (#1) and a single static `AppState`
shared process-wide. Nothing in this file is capable of showing more than
one tenant, but the shape of the bug is important: if a tenant switcher were
bolted onto this code as-is, `AppState.totalCost`/`history` would keep
showing the previous tenant's numbers until the next successful fetch
overwrites them — i.e. exactly "one tenant's data under another's header"
during the window between switching tenants and the new fetch resolving.

**Fix:** state must be scoped by tenant (a `.family`-keyed provider or
equivalent), and switching tenants must synchronously clear/invalidate the
previous tenant's cached state rather than leaving it visible until
overwritten.

---

### 7. A failed send can still be charged

**Severity:** Critical — bills for messages that were never sent.
**Location:** lines 68–75.

```dart
final res = await http.post(...);
final result = jsonDecode(res.body);
final provider = result['provider'];              // null on 400/429/502 bodies
final cost = rateFor(provider) * segments;         // rateFor(null) -> 0.07 default
AppState.totalCost = AppState.totalCost + cost;    // charged anyway
```

There is no status-code check on the send response at all. A `400`
(`INVALID_PHONE_NUMBER`), `429`, or `502` body doesn't have a `provider` key,
so `result['provider']` is `null`; `rateFor(null)` falls through every `if`
and returns the `0.07` default rate. The code then unconditionally adds that
default cost to `AppState.totalCost` and shows the user a "Sent via null —
€0.0700" snackbar, regardless of whether the message actually sent. The user
is billed for and told they sent a message that failed outright.

**Fix:** check `res.statusCode` before treating the body as a success
payload; map non-2xx responses to a typed failure and never touch the cost
total unless the send actually succeeded (`202 Accepted`).

---

### 8. Message body and phone number logged in plaintext

**Severity:** Critical — personal data exposure.
**Location:** line 66.

```dart
print('Sending SMS to $phone: $body');
```

The destination phone number and full message body (which the contract's own
example shows can contain a one-time passcode) are written to device/console
logs. On Android this lands in `logcat`, which is readable by other apps with
`READ_LOGS` on older OS versions and is routinely captured by crash/log
aggregators in production builds. The contract is explicit that recipient
data is sensitive enough to be masked server-side (`+4915*****78`); logging it
client-side in full defeats that.

**Fix:** delete the log line. If diagnostic logging is needed, log the
`messageId`/`referenceId` only, never `to` or `body`.

---

### 9. Cost is computed from a local rate table instead of the API's authoritative response

**Severity:** Critical — bills the wrong amount.
**Location:** lines 18–23, 71–73.

```dart
double rateFor(String provider) {
  if (provider == 'TWILIO') return 0.075;
  ...
}
...
final cost = rateFor(provider) * segments; // segments is hardcoded to 1
```

The send response already returns the authoritative `cost` ("0.1500") and
`segmentCount` for that specific message — the contract states an SMS may
span multiple segments. The client ignores both and recomputes its own
number from a guessed, hardcoded per-provider rate, with `segments`
hardcoded to `1` regardless of the real segment count. Every multi-segment
message is undercharged in the UI; the guessed rates don't match whatever
the provider actually billed. The number shown to the user (and accumulated
into `AppState.totalCost`) has no relationship to the real invoice.

**Fix:** use `result['cost']` and `result['segmentCount']` straight from the
send response (as a `Decimal`, see #5), never recompute it client-side.

---

### 10. Cost breakdown row displays a recipient phone number the endpoint never returns

**Severity:** Critical — fabricated data / crash, and a direct contract violation flagged as sensitive.
**Location:** line 119.

```dart
subtitle: Text(rows[i]['recipient']),
```

`API-CONTRACT.md` states explicitly: *"Note what is not here: recipient phone
numbers. The cost endpoint never returns them. If your UI shows a phone
number on this screen, it invented it."* This line reads a `recipient` key
from the cost breakdown response, which per contract doesn't exist — at
best `rows[i]['recipient']` is `null` and `Text(null)` throws; at worst, a
future backend field that happens to share that name gets rendered as if it
were a real recipient on the wrong screen (cost rows are aggregated by
provider, not per-message, so there is no single recipient to show here in
the first place).

**Fix:** the cost-row model must not have a `recipient` field at all —
typed models make this class of bug impossible rather than merely unlikely.

---

### 11. No client-side validation, and API validation errors are never surfaced

**Severity:** Medium.
**Location:** whole `sendSms` flow; no validation before line 63.

The phone field accepts anything; the contract requires E.164 and returns a
structured `400 INVALID_PHONE_NUMBER` with a message when it isn't. This
code has no client-side check and, per #7, can't even surface that error
once the server returns it — the user gets no feedback about what to fix.

**Fix:** validate E.164 shape before submitting (fail fast, cheaper than a
round trip), and render the server's `errorCode`/`message` on `400`.

---

### 12. One shared `loading` flag for two independent concurrent operations

**Severity:** Low/Medium — race condition, confusing UX rather than data loss.
**Location:** line 35, used by both `sendSms` and `loadCosts`.

`sendSms` calls `loadCosts()` at its end (line 79), so a send in progress and
a cost reload can both be touching the same `loading` bool. Whichever
`setState(() => loading = false)` runs first flips the whole screen back to
its content view — including hiding the spinner that was supposed to be
covering the other, still in-flight operation — and the input fields
disappear entirely while `loading` is true (the `Padding`/`Column` is
swapped out wholesale), so the user can't even see what they typed while a
request is in flight.

**Fix:** separate, independently-scoped loading/error state per operation
(send vs. history vs. cost), and never replace the whole form with a
spinner — show inline/local loading indicators instead.

---

## Summary

| # | Severity | One-line |
|---|---|---|
| 1 | Critical | Hardcoded API key + tenant ID in source |
| 2 | High | No `mounted` check after `await` — crashes on navigate-away |
| 3 | High | No error handling in `loadCosts` — infinite spinner or unhandled exception |
| 4 | Medium | `FutureBuilder` re-fetches inline in `build()` |
| 5 | Critical | `totalCost` cast as `double` from a decimal string — crashes/imprecise |
| 6 | Critical | Global static state — no tenant isolation possible |
| 7 | Critical | Failed sends are still charged and reported as sent |
| 8 | Critical | Phone/message body logged in plaintext |
| 9 | Critical | Cost computed from guessed local rates, ignores authoritative API cost |
| 10 | Critical | Renders a `recipient` field the cost endpoint never sends |
| 11 | Medium | No input validation, server validation errors never shown |
| 12 | Low/Medium | Shared `loading` flag races across two concurrent operations |
