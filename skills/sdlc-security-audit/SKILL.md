---
name: sdlc-security-audit
description: Use when performing a security audit, checking for CVEs/vulnerabilities, scanning for secret leaks, or verifying OWASP Top 10 compliance before deployment.
---

# Pre-Deployment Security & Vulnerability Audit Workflow

Execute this 4-phase audit to identify vulnerabilities, secret leaks, and security regressions before shipping code.

---

## Phase 1: Secrets & Credential Leak Scanning
1. **Repository & Git History Scan**:
   - Verify no `.env`, `.pem`, `.key`, or credentials files are tracked in Git.
   - Run a quick scan for exposed high-entropy strings or common token patterns (e.g., `ghp_`, `AKIA`, `Bearer`, `sk-`).
   - Check `.gitignore` to ensure secret and local artifact patterns are strictly ignored.

## Phase 2: Dependency & Supply Chain Vulnerability Check
Run the native ecosystem vulnerability scanner for the repository's package manager:
- **Node.js / TypeScript**: `npm audit` or `pnpm audit`
- **Python**: `pip-audit` or `safety check`
- **Rust**: `cargo audit`
- **Go**: `govulncheck ./...`
- **General / Containers**: `trivy fs .` (if installed)

Triage findings: Distinguish between exploitable runtime vulnerabilities and benign dev-dependency warnings.

## Phase 3: Code-Level Adversarial Audit (OWASP Top 10)
Inspect all changed code and public boundaries for:
1. **Injection Vectors**: SQL queries, raw shell command execution (`exec`, `system`, `subprocess`), unescaped template evaluations.
2. **Path Traversal & File Access**: Unvalidated file paths or un-sanitized user inputs in file-system operations.
3. **Authentication & Authorization**: Missing permission gates, IDOR (Insecure Direct Object Reference) risks, unauthenticated public endpoints.
4. **Data Exposure & Logging**: Sensitive fields (passwords, tokens, PII) logged in plaintext or exposed in error responses.
5. **Network Boundaries**: SSRF (Server-Side Request Forgery) in outbound fetch calls; permissive CORS configurations.

## Phase 4: Security Audit Artifact & Remediation
1. Generate an audit report summarizing:
   - **Vulnerability Matrix**: Severity (Critical, High, Medium, Low), file location, and description.
   - **Exploit Scenario**: How an attacker could abuse the vulnerability.
   - **Remediation Plan**: Surgical code changes to resolve each vulnerability.
2. Gate approval: Require resolution of all Critical and High vulnerabilities before allowing deployment or merge.
