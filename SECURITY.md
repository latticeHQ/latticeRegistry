# Security Policy

## Reporting Security Vulnerabilities

**Do not report security vulnerabilities through public GitHub issues.**

Instead, please report them privately to:

**Email:** security@latticeruntime.com

Include the following information:

- Description of the vulnerability
- Steps to reproduce
- Potential impact
- Suggested fix (if any)

We will respond within 48 hours and work with you to understand and address the issue.

## Scope

This security policy covers the **Lattice Registry**, including:

- Terraform modules that configure identity, authorization, and policy
- Templates that provision agent deployment environments
- Build and validation tooling

## What Qualifies as a Security Issue?

Issues that could compromise:

- **Module integrity** — malicious code or supply chain attacks in Registry modules
- **Authorization bypass** — modules that misconfigure Runtime enforcement
- **Credential exposure** — modules that leak secrets or API keys
- **Template vulnerabilities** — insecure default configurations in deployment templates

## What Is Not a Security Issue?

- **Feature requests** — use GitHub Discussions
- **Configuration errors** — see module documentation
- **Runtime vulnerabilities** — report to the [Runtime security policy](https://github.com/latticeHQ/latticeRuntime/blob/develop/SECURITY.md)

## Disclosure Policy

We follow **coordinated disclosure**:

1. **Report received** — we acknowledge within 48 hours
2. **Investigation** — we validate and assess severity
3. **Fix developed** — we create and test a patch
4. **Coordinated release** — we work with you on timing
5. **Public disclosure** — after fix is deployed

We aim to resolve critical issues within 30 days.

## Recognition

We recognize security researchers who responsibly disclose vulnerabilities:

- **Public acknowledgment** (with permission)
- **Credit in release notes** and security advisory

## Contact

- **Security issues:** security@latticeruntime.com
- **General questions:** [GitHub Discussions](https://github.com/latticeHQ/latticeRuntime/discussions)
