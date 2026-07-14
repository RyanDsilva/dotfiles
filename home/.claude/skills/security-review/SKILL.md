---
name: security-review
description: Security audit of a diff or codebase for vulnerabilities. Use when asked for a security review or to check for vulnerabilities.
allowed-tools: Read, Grep, Glob, Bash(git diff:*)
---
Audit for security issues (read-only - never edit). Focus on the changed code first, then its blast radius.

Check for: injection (SQL/command/template), secrets or keys committed, unsafe deserialization, path traversal, SSRF, missing authn/authz, insecure crypto or randomness, unvalidated input crossing a trust boundary, dependency risks, and sensitive data in logs/errors.

For each finding: `file:line - vulnerability class - concrete exploit scenario - remediation`. Rank by exploitability. Distinguish confirmed issues from theoretical ones. Read the actual code paths before claiming a vulnerability. If the diff is clean, say so.
