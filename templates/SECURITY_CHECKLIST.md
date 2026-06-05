# SECURITY_CHECKLIST.md — DevSecOps Baseline (drop into any project)

> **Purpose:** one reusable checklist so every project gets the same security review, whether it's a weekend PoC or production. Grounded in OWASP Top 10:2025, OWASP ASVS 5.0, the OWASP Cheat Sheet Series, NIST SSDF (SP 800-218), SLSA, and the OWASP LLM/Agentic Top 10 lists.
>
> **The rule: no box is ever left blank.** Every item ends in exactly one state:
> - `[x]` — done, with evidence (link to code/config/commit)
> - `[~]` — partial; note what's missing and the follow-up
> - `[N/A]` — does not apply, **with a one-line reason** ("static site, no auth")
>
> An unexamined item is a finding. "N/A because we thought about it" is success; silence is not.
>
> **When to run:** at project start (threat model + secrets sections minimum), before first deploy/share (full pass), and on a recurring cadence for anything that stays alive.

---

## 1. Scope & Threat Model

- [ ] One paragraph written: what this system does, who uses it, what the crown jewels are (data, money, credentials, reputation).
- [ ] Trust boundaries drawn: every place data crosses from untrusted → trusted (user input, third-party APIs, webhooks, files, model outputs).
- [ ] Data classified: public / internal / personal (PII) / secret. Each class has a named storage location.
- [ ] Abuse cases listed, not just use cases ("what would I do to attack this?") — STRIDE per boundary if the system is non-trivial.
- [ ] Exposure decided explicitly: localhost-only / VPN-or-tailnet / public internet. Public exposure is a decision, never a default.
- [ ] Single-copy risk check: is any critical data or doc stored in exactly one place? (Backups: §19.)

## 2. Secrets & Credentials

- [ ] No secrets in code, config files committed to git, chat logs, prompts, tickets, or docs. Ever.
- [ ] Secrets live in env vars or a secret manager; `.env` is gitignored from the **first** commit.
- [ ] `.env.example` documents every key by name with placeholder values only.
- [ ] Secret scanning runs on the repo (gitleaks / trufflehog / GitHub secret scanning) — including full history, not just HEAD.
- [ ] Each credential is least-privilege (API keys scoped to needed permissions only) and per-environment (dev keys ≠ prod keys).
- [ ] Rotation is possible without code changes; a compromised-key runbook exists (revoke → rotate → audit usage).
- [ ] No long-lived credentials in CI — use OIDC/workload identity where the platform supports it.
- [ ] Secrets never appear in logs, error messages, crash dumps, or analytics.

## 3. Authentication (if the system has users)

- [ ] Passwords hashed with a modern memory-hard KDF (argon2id preferred; bcrypt/scrypt acceptable) — never MD5/SHA-x, never reversible.
- [ ] Password policy follows NIST 800-63B: length over composition rules; check against breached-password lists; no forced periodic rotation.
- [ ] MFA available (TOTP/WebAuthn); passkeys preferred where feasible. Admin accounts: MFA mandatory.
- [ ] Login, signup, and reset endpoints are rate-limited and timing-consistent (no user-enumeration via error text or response time).
- [ ] Account recovery is as strong as login (recovery is the attacker's favorite door).
- [ ] OAuth/OIDC: `state` + PKCE used; redirect URIs exact-matched; tokens validated (issuer, audience, expiry, signature).
- [ ] Default/demo credentials removed; first-run forces credential setup.
- [ ] Service-to-service auth exists (API keys/mTLS/signed tokens) — internal ≠ trusted.

## 4. Session Management & Cookies

- [ ] Session tokens: long random values from a CSPRNG; never sequential, never derived from user data.
- [ ] Session cookies set with `Secure`, `HttpOnly`, and `SameSite=Lax` or `Strict` (explicitly, not by browser default).
- [ ] `__Host-` cookie name prefix used for session cookies (locks Secure + no Domain + Path=/).
- [ ] Session ID rotated on login and privilege change (fixation defense); sessions invalidated server-side on logout.
- [ ] Idle and absolute session timeouts set appropriate to data sensitivity.
- [ ] CSRF defense on every state-changing request: SameSite + anti-CSRF token (or signed double-submit); confirm framework protection is actually ON.
- [ ] Cross-site cookies (if truly needed) are `Partitioned` (CHIPS) and justified in writing.
- [ ] JWTs (if used): short expiry, `alg` allowlist (reject `none`), signature verified, revocation strategy exists, nothing sensitive in the payload.
- [ ] Tokens never in URLs (they leak via logs, referrers, history).

## 5. Authorization & Access Control  *(OWASP A01:2025 — #1 risk)*

- [ ] Deny by default: every route/endpoint/tool requires explicit permission; new endpoints are private until opened.
- [ ] Object-level checks on every request: user A cannot read/modify user B's records by changing an ID (IDOR/BOLA — test it manually).
- [ ] Function-level checks: admin endpoints verify role server-side; UI hiding is not access control.
- [ ] Authorization enforced server-side only — never trust client-sent roles, prices, flags, or hidden fields (mass assignment: bind allowlisted fields only).
- [ ] SSRF treated as access control (per OWASP 2025): any server-side fetch of user-supplied URLs uses an allowlist, blocks private IP ranges + cloud metadata endpoints (169.254.169.254), and ignores redirects to them.
- [ ] CORS: explicit origin allowlist; never `*` with credentials; preflight behavior verified.
- [ ] Path traversal blocked: user input never concatenated into filesystem paths; canonicalize then verify prefix.
- [ ] Multi-tenancy (if any): tenant isolation enforced in every query (tenant_id in WHERE, or row-level security), verified by test.

## 6. Input Handling & Injection

- [ ] SQL/DB: parameterized queries or ORM bindings everywhere; zero string-built queries (grep for f-strings/concat near execute).
- [ ] OS commands: avoid shelling out; if unavoidable, use argument arrays (never `shell=True` with user input).
- [ ] All external input validated server-side against type/length/format/range allowlists — "external" includes APIs, webhooks, files, and LLM output, not just forms.
- [ ] Deserialization of untrusted data avoided (no pickle/unsafe YAML on external input); use JSON + schema validation.
- [ ] XML parsing: external entities (XXE) disabled.
- [ ] Template injection: user input never evaluated as a template; no `eval`/`exec`/`Function()` on anything user-influenced.
- [ ] Regex on user input checked for catastrophic backtracking (ReDoS); timeouts on regex-heavy paths.
- [ ] Request size limits: max body, max JSON depth/keys, max array lengths, max multipart parts.

## 7. Output Handling, XSS & Security Headers

- [ ] Context-aware output encoding on everything user-influenced (HTML body, attributes, JS, URLs); framework auto-escaping ON and not bypassed (`dangerouslySetInnerHTML`/`|safe` audited).
- [ ] Content-Security-Policy set; no `unsafe-inline` scripts (use nonces/hashes); `frame-ancestors` directive replaces X-Frame-Options.
- [ ] `Strict-Transport-Security` (HSTS) with sensible max-age once HTTPS is stable.
- [ ] `X-Content-Type-Options: nosniff`, `Referrer-Policy: strict-origin-when-cross-origin` (or stricter), `Permissions-Policy` minimal.
- [ ] Rich-text/markdown from users sanitized server-side with an allowlist sanitizer (DOMPurify-class), not regex.
- [ ] Error pages and API errors expose no stack traces, paths, versions, or queries to clients (detail goes to logs, §18).
- [ ] Headers verified with an external scan (securityheaders.com / Mozilla Observatory) before launch.

## 8. Cryptography & Data Protection  *(OWASP A04:2025)*

- [ ] TLS everywhere external (1.2 minimum, 1.3 preferred); internal cleartext hops are a written, justified decision.
- [ ] Certificates auto-renew (Let's Encrypt/ACME or platform-managed); expiry is monitored.
- [ ] No homemade crypto: vetted libraries only; AES-GCM/ChaCha20-Poly1305 for symmetric; no ECB, no static IVs.
- [ ] Sensitive data at rest encrypted (full-disk minimum; field-level for high-value secrets/PII); keys stored separately from data.
- [ ] Random values that matter (tokens, IDs, salts) come from a CSPRNG, not `random`/`Math.random`.
- [ ] No sensitive data in URLs, browser localStorage (XSS-readable), or client-side code.
- [ ] Key inventory exists: what keys, where, who/what can read them, rotation plan.

## 9. Privacy & Data Lifecycle

- [ ] Data minimization: collect only what the feature needs; every stored personal field is justifiable in one sentence.
- [ ] PII inventory: what personal data exists, where it lives, who can access it, how long it's kept.
- [ ] Retention + deletion: data has an expiry; deletion actually deletes (including backups policy, logs, analytics, model/API providers).
- [ ] Third-party data flows mapped: every external service receiving user data is listed (analytics, error tracking, LLM APIs, CDNs); each is necessary.
- [ ] Logs and telemetry contain no PII or secrets by design (scrub at the logger, not by discipline).
- [ ] If EU users / GDPR-relevant: lawful basis identified, privacy notice exists, data-subject requests (export/delete) are feasible, processors have DPAs.
- [ ] Cookie/tracking consent implemented where legally required; strictly-necessary cookies separated from tracking; no dark patterns.
- [ ] AI-specific: user content sent to model APIs is disclosed; privacy-sensitive content routes to local/approved processing per project policy.

## 10. Files & Uploads (if applicable)

- [ ] Uploads validated by content (magic bytes), not extension; allowlist of types; size caps.
- [ ] Stored outside the web root with generated names; original filenames treated as untrusted display data.
- [ ] Served with correct Content-Type + `nosniff`; user HTML/SVG never served from the app origin (SVG can carry scripts).
- [ ] Image/file processing libraries sandboxed or updated aggressively (ImageMagick-class CVEs); archives extracted with path + size guards (zip-slip, zip bombs).
- [ ] Antivirus/malware scanning if files are shared between users.

## 11. APIs

- [ ] Every endpoint authenticated and authorized (§3, §5) — including "internal", debug, and health endpoints that reveal more than "ok".
- [ ] Rate limiting per identity/IP on all endpoints; stricter on auth, search, and anything expensive.
- [ ] Schema validation on request and response (pydantic/zod/JSON Schema); unknown fields rejected on write models.
- [ ] Pagination caps on list endpoints (no `?limit=1000000`).
- [ ] API versioning strategy exists; deprecated versions have a sunset plan.
- [ ] No GraphQL introspection / debug endpoints / API docs exposed in prod unless intentionally public.
- [ ] Webhooks received: signatures verified, replay protection (timestamp + nonce), processed idempotently.

## 12. Supply Chain & Dependencies  *(OWASP A03:2025 — new category)*

- [ ] Lockfiles committed (uv.lock/package-lock/poetry.lock); builds are reproducible from lockfile.
- [ ] Automated dependency scanning ON (Dependabot/Renovate + `pip-audit`/`npm audit`/OSV-Scanner) with a triage habit, not just alerts.
- [ ] New dependencies vetted before adding: maintenance health, downloads, repo provenance; name typo-squatting checked character-by-character.
- [ ] Install scripts distrusted: `--ignore-scripts` where viable; review postinstall hooks of new packages.
- [ ] No `curl | bash` installs of unpinned scripts; vendor binaries verified by checksum/signature.
- [ ] CDN-loaded scripts pinned with Subresource Integrity (SRI) or self-hosted.
- [ ] SBOM can be produced for anything serious (syft/cyclonedx); base images pinned by digest, minimal, rebuilt regularly.
- [ ] The xz-utils lesson applied: critical-path dependencies preferred boring, popular, and few; dependency count is a cost.

## 13. Backdoor Resistance & Code Integrity

- [ ] All code reaches main via reviewed PRs or (solo) a deliberate diff review habit; no unreviewed direct pushes to prod branches by automation.
- [ ] Branch protection on main; force-push disabled; signed commits/tags where the platform makes it cheap.
- [ ] AI/agent-generated code is diff-reviewed before merge — especially anything touching auth, crypto, network calls, or process execution.
- [ ] Grep-audit for backdoor patterns before release: hardcoded credentials, hidden admin routes, `eval` on remote content, obfuscated blobs, unexpected outbound hosts.
- [ ] Outbound network egress from prod is known and minimal; unexpected destinations are alertable (§18).
- [ ] Build provenance: artifacts traceable to a commit + pipeline run (SLSA direction); nobody builds prod artifacts on laptops.
- [ ] Maintainer/account security: repo owner accounts have MFA + recovery codes stored safely.

## 14. CI/CD & Build Pipeline

- [ ] CI runners least-privilege; secrets exposed only to the jobs that need them; fork PRs cannot read secrets.
- [ ] Third-party CI actions/plugins pinned to commit SHAs, not floating tags.
- [ ] Pipeline runs the security gates: tests, SAST/linters (bandit/semgrep/eslint-security), dependency audit, secret scan — and failures block merge.
- [ ] Deploy credentials scoped per environment; staging cannot touch prod.
- [ ] Rollback is one command and has been exercised.
- [ ] Infrastructure-as-code scanned (tfsec/checkov-class) if IaC exists.

## 15. Infrastructure, Hosting & Network

- [ ] Host firewall default-deny inbound; only required ports open; admin interfaces (SSH/DB/dashboards) never on the public internet — VPN/tailnet/allowlist only.
- [ ] SSH: keys only, password auth off, root login off; fail2ban or equivalent on anything exposed.
- [ ] OS + runtime patched on a cadence; unattended security updates where safe.
- [ ] Databases/caches/queues bound to localhost or private networks with auth ON (no "open Redis/Mongo" defaults).
- [ ] Containers: non-root user, minimal base, no privileged mode, read-only FS where possible, resource limits set.
- [ ] Separate environments (dev/prod) with separate data and credentials; prod data never copied into dev unsanitized.
- [ ] Cloud IAM least-privilege; no wildcard `*:*` policies; billing alerts ON (cost is a security signal).
- [ ] DNS: registrar account MFA'd; dangling DNS records cleaned (subdomain takeover).

## 16. Availability, DoS & DDoS Resilience

- [ ] Anything public sits behind a CDN/reverse proxy with DDoS absorption (Cloudflare-class); origin IP not directly reachable.
- [ ] Application rate limiting (per IP + per identity) on all endpoints; aggressive on auth, search, exports, and anything that fans out work.
- [ ] Timeouts everywhere: inbound requests, outbound calls, DB queries; no unbounded waits.
- [ ] Body/payload limits enforced before processing (§6); expensive endpoints cached, queued, or job-ified.
- [ ] Resource-exhaustion review: ReDoS (§6), zip bombs (§10), unbounded loops/recursion on user input, memory-unbounded reads.
- [ ] Graceful degradation decided: what happens at overload — shed load, queue, or fail closed? Health checks don't lie.
- [ ] For LLM apps: per-user token/cost budgets and concurrency caps (unbounded consumption is the DoS *and* the bill).

## 17. Error & Exception Handling  *(OWASP A10:2025 — new category)*

- [ ] Fail closed: errors in auth/authz/validation deny by default, never skip the check.
- [ ] Every external call handles failure explicitly (timeout, retry-with-backoff where idempotent, circuit-break where chronic).
- [ ] No bare `except: pass`; unexpected exceptions are logged with context and surfaced.
- [ ] Partial-failure states defined: batch jobs are resumable/idempotent; money/data-mutating operations are transactional or compensated.
- [ ] Resource cleanup guaranteed (context managers/finally): connections, files, locks released on error paths.
- [ ] Error paths tested, not just happy paths (kill the dependency, feed garbage, fill the disk — see what happens).

## 18. Logging, Monitoring & Alerting  *(OWASP A09:2025)*

- [ ] Security-relevant events logged: logins (success/fail), permission denials, admin actions, config changes, money/data mutations.
- [ ] Logs structured, timestamped (synced clocks/UTC), centralized off-host, with retention defined.
- [ ] No secrets/PII/session tokens in logs (§2, §9) — verified by sampling, not assumed.
- [ ] Alerts exist for: repeated auth failures, error-rate spikes, cost/spend anomalies, unexpected egress, certificate expiry, disk full.
- [ ] Logs are tamper-resistant (append-only or shipped off-host) — an attacker's first stop is the logs.
- [ ] Someone (or something) actually reads alerts; alert fatigue triaged.

## 19. Backups & Recovery

- [ ] Backups automated for anything you can't recreate (DBs, user data, canonical docs); 3-2-1 spirit: multiple copies, separate media/account, one offline/offsite.
- [ ] **Restore tested.** An untested backup is a hope, not a backup.
- [ ] Backups encrypted; backup credentials can't be reached from the prod box they back up (ransomware path).
- [ ] Single-copy risk from §1 resolved: no canonical artifact exists in exactly one place.

## 20. Incident Response & Disclosure

- [ ] A one-page runbook exists: how to take the system offline, rotate all secrets, preserve logs, and who decides.
- [ ] Key-compromise drill thought through per credential class (API key vs DB vs cloud root).
- [ ] `security.txt` / contact route published for anything public, so reporters can reach you.
- [ ] Post-incident habit: blameless write-up, root cause to the checklist (this file gains an item).

## 21. AI / LLM / Agentic Systems (if applicable)  *(OWASP LLM Top 10 2025 + Agentic ASI Top 10)*

- [ ] Prompt injection assumed unsolved: any untrusted content entering a prompt (user text, web pages, files, emails, tool results) is treated as potentially adversarial instructions.
- [ ] Agent tool access is least-privilege and scoped per task; destructive tools (delete, send, pay, execute) require human confirmation or are absent.
- [ ] Model output is untrusted input: validated/encoded before rendering (XSS), parameterized before queries, never `eval`'d or executed unsandboxed.
- [ ] Agent-generated code/commands run in a sandbox with no secrets and constrained egress until reviewed.
- [ ] System prompts contain no secrets and nothing that's catastrophic to leak (assume leakable).
- [ ] Cost/token/iteration budgets per request and per user; runaway loops detected and halted.
- [ ] Read-only vs write boundaries explicit for agents touching repos/filesystems; protected paths enforced by mechanism, not instruction.
- [ ] Model/data supply chain: models pulled from verified sources (checksums, official registries); RAG/embedding stores access-controlled (they contain your data).
- [ ] Agent actions logged with rationale; high-impact flows keep a human approval gate until trust is earned.
- [ ] Excessive agency reviewed: every permission an agent has is one a prompt injection can use.

## 22. Pre-Launch Quick Gate (the 10-minute version)

Before anything is exposed beyond localhost, these must all be `[x]`:

- [ ] No secrets in repo or history (§2) — scanner run.
- [ ] Auth on every non-public endpoint; IDOR spot-checked (§5).
- [ ] Parameterized queries verified; no eval of external input (§6).
- [ ] TLS + HSTS + cookie flags + CSP set (§4, §7, §8).
- [ ] Rate limits + body limits + timeouts on (§16).
- [ ] Errors leak nothing; logging on with no PII (§17, §18).
- [ ] Backup + restore tested if there's data worth keeping (§19).
- [ ] Exposure decision written down (§1) — who is this reachable by, and why.

---

## References

1. OWASP Top 10:2025 — https://owasp.org/Top10/
2. OWASP ASVS 5.0 (≈350 requirements, 17 chapters; the deep version of this file) — https://owasp.org/www-project-application-security-verification-standard/
3. OWASP Cheat Sheet Series (per-topic implementation guidance) — https://cheatsheetseries.owasp.org/
4. OWASP Top 10 for LLM Applications (2025) & OWASP Top 10 for Agentic Applications — https://genai.owasp.org/
5. NIST SSDF, SP 800-218 (secure development framework) — https://csrc.nist.gov/projects/ssdf
6. NIST SP 800-63B (authentication & passwords)
7. SLSA — supply-chain levels for software artifacts — https://slsa.dev/
8. CIS Benchmarks (OS/container/cloud hardening) — https://www.cisecurity.org/cis-benchmarks
9. Mozilla Observatory / securityheaders.com (header scans)
10. Books: Ross Anderson, *Security Engineering* (3rd ed.); *The DevOps Handbook* (security-as-everyone's-job); Google SRE books (reliability ↔ availability overlap).

*Maintained as a living document: every incident, audit finding, or postmortem adds or sharpens an item.*
