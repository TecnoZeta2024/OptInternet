# Responsibility Matrix

This matrix clarifies ownership across human contributors and BMAD agents for OptiGemini v3.0. It resolves the gaps recorded in PO checklist Section 5.

## Roles

- **End User:** Final consumer running the desktop app.
- **Project Owner (PO):** Carlos Zamora.
- **Product Manager (PM) Agent:** Requirements curation.
- **Scrum Master (SM) Agent:** Story drafting and backlog flow.
- **Developer (Dev) Agent:** Story implementation within IDE.
- **QA (Test Architect) Agent:** Quality gates and risk management.
- **DevOps (Human/Agent):** Build, packaging, and release automation.
- **Support/Marketing:** Communication with users and community.

## RACI Table (Key Activities)

| Activity                             | User | PO  | PM Agent | SM Agent | Dev Agent | QA Agent | DevOps | Support |
| ------------------------------------ | ---- | --- | -------- | -------- | --------- | -------- | ------ | ------- |
| Install MSI & accept admin prompts   | R    | I   | I        | I        | I         | I        | A      | C       |
| Provide hotspot/ISP credentials      | R    | C   | I        | I        | I         | I        | I      | I       |
| Configure Limited Mode fallback      | R    | A   | C        | I        | I         | I        | C      | C       |
| PRD updates / scope changes          | I    | A   | R        | C        | C         | C        | I      | I       |
| Architecture modifications           | I    | A   | C        | C        | C         | R        | C      | I       |
| Story drafting and approval          | I    | C   | A        | R        | I         | C        | I      | I       |
| Code implementation                  | I    | C   | C        | C        | A/R       | C        | I      | I       |
| Unit/integration test creation       | I    | C   | C        | C        | A/R       | C        | I      | I       |
| Risk assessment & test strategy      | I    | C   | C        | C        | C         | A/R      | I      | I       |
| QA review & gate decision            | I    | I   | C        | C        | C         | A/R      | I      | I       |
| CI/CD pipeline maintenance           | I    | C   | I        | I        | C         | C        | A/R    | I       |
| Secrets & credential storage         | I    | A   | I        | I        | I         | I        | R      | C       |
| Git mirror & backup rotation         | I    | C   | I        | C        | R         | C        | A/R    | I       |
| Release publication                  | I    | A   | C        | I        | C         | C        | R      | C       |
| User documentation & admin messaging | R    | A   | C        | I        | C         | C        | I      | R       |
| Support ticket triage                | R    | C   | I        | I        | I         | C        | I      | A       |

Legend: **R** = Responsible (executes), **A** = Accountable (approves), **C** = Consulted, **I** = Informed.

## Operational Notes

- The **End User** is only responsible for providing secrets (SSID/password) and consenting to admin operations; all code/config duties remain with delivery team.
- The **PO** retains accountability for production changes, release approvals, and security-sensitive actions.
- The **Dev Agent** must not request admin credentials; it implements code and automation only.
- The **QA Agent** has authority to block releases via gate decisions and documents any waivers in `docs/qa/gates/`.
- The **DevOps** function manages GitHub Actions secrets, MSI packaging, WinGet submissions, and rollback execution.

## Escalation Path

1. **Critical Incident (P0):** QA Agent → PO → DevOps. Execute rollback playbook (`Docs/Rollback-and-Feature-Flag-Plan.md`).
2. **Security Concern:** Dev Agent or QA Agent → PO immediately; halt release until resolved.
3. **Documentation Gaps:** Any agent identifies issue → PM Agent updates PRD/Backlog → PO validates.

Review this matrix quarterly or after significant team changes.