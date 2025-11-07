# 🛡️ Security Policy and Reporting for [Your Repository Name]

We take security seriously, especially when providing system-level scripts. We recognize that Windows Batch Files (.bat, .cmd) run commands directly, which necessitates extreme caution and vigilance from the community.

If you believe you have found a security vulnerability in any of our scripts, we urge you to report it immediately.

---

## 1. 📧 Reporting a Vulnerability

**DO NOT** file a public GitHub issue for security concerns.

To ensure your finding is handled promptly and privately, please use one of the following methods:

### Preferred Method: GitHub Private Vulnerability Reporting
We strongly encourage using GitHub's built-in private reporting feature:

1.  Navigate to the **Security** tab of this repository.
2.  Click **Advise maintainers about a security vulnerability**.
3.  Fill out the form with the required details (see Section 2).

### Alternative Method: Direct Email
If you are unable to use the GitHub feature, please send a detailed, encrypted email (if possible) to:

* **Email:** `[YOUR DEDICATED SECURITY EMAIL ADDRESS HERE]` (e.g., `security@yourdomain.com`)

We aim to acknowledge receipt of your report within **[2]** business days.

---

## 2. 📝 What to Include in a Report

A complete report allows us to triage and fix the issue faster. Please include:

* **File Path:** The exact location and name of the file(s) affected (e.g., `system/Cleanup_Tool.bat`).
* **Vulnerability Summary:** A brief title (e.g., "Command Injection via unvalidated input in script X").
* **Reproduction Steps:** A clear, numbered list of steps to reproduce the vulnerability. This is critical for batch files.
* **Input Data:** The exact input string or parameters used to trigger the issue.
* **Potential Impact:** What could an attacker achieve? (e.g., Remote code execution, Data exposure, System instability).

---

## 3. ⚠️ Security-Specific Considerations for Batch Files

Please note the inherent limitations of Windows Batch scripting:

* **Avoid Sensitive Data:** Due to the nature of the shell, these scripts are *not* designed to securely handle passwords or API keys. If a script in this repository appears to be logging or handling sensitive data insecurely, please report it.
* **Input Validation:** Our goal is to ensure all user-supplied input is validated against command injection characters (`&`, `|`, `<`, `>`, etc.). Any failure in this validation should be reported as a High-Severity vulnerability.
* **PowerShell Recommendation:** For tasks requiring true credential security, network interaction, or advanced logging, we strongly recommend using PowerShell and will favor migrating such scripts away from pure Batch.

---

## 4. ⏳ Our Response Timeline

We commit to a clear and responsible disclosure process:

* **Initial Acknowledgment:** Within **[2]** business days.
* **Triage and Plan:** We will confirm the vulnerability, assign a severity, and provide an update on a fix timeline within **[7]** days.
* **Public Disclosure:** We will coordinate with the reporter to ensure the patch is released and users are informed *before* any public disclosure of the vulnerability details.

We sincerely appreciate the efforts of security researchers to help keep our scripts safe and reliable.

---
