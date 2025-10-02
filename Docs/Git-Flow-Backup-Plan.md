# Git Flow Backup Plan

This plan extends the existing Git Flow guidance in `.github/copilot-instructions.md` with concrete backup procedures so every agent protects the codebase against accidental data loss.

## 1. Remotes & Branch Protection

- Maintain two remotes on every workstation:
  - `origin` → Primary GitHub repository (TecnoZeta2024/OptInternet)
  - `backup` → Secondary remote (GitHub mirror, Azure DevOps, or local NAS bare repo)
- Enable branch protection on `main` and `develop`:
  - Require pull request reviews and status checks (CI workflow)
  - Disallow force pushes except by DevOps during disaster recovery
- DevOps keeps a read-only deploy key for the `backup` remote to support automated syncs.

## 2. Branch Strategy (Git Flow Recap)

| Branch      | Purpose                          | Backup Frequency                                     |
| ----------- | -------------------------------- | ---------------------------------------------------- |
| `main`      | Production-ready releases        | Mirror after each release tag                        |
| `develop`   | Integration of completed stories | Mirror nightly (scheduled action)                    |
| `feature/*` | Story implementation branches    | Mirror on story completion or before risky refactors |
| `hotfix/*`  | Urgent production fixes          | Mirror immediately after creation and completion     |
| `release/*` | Release preparation              | Mirror alongside `develop` during release freeze     |

## 3. Backup Triggers

1. **Before merges into `develop` or `main`:** SM/Dev agent runs `git push backup <branch>`.
2. **After story completion approvals:** QA agent confirms `feature/*` branch mirrored before closing the story.
3. **Nightly automation:** DevOps schedules GitHub Action to fetch all branches and `git push backup --mirror`.
4. **Pre-refactor snapshot:** Dev agent creates lightweight tag (`safety/<story>-<date>`) pushed to both remotes.
5. **Weekly bundles:** DevOps generates `backups/week-<iso>.bundle` stored in offsite storage (S3/OneDrive).

## 4. Disaster Recovery Workflow

1. Identify last known-good tag (e.g., `release/v3.0.0`).
2. Fetch mirror: `git fetch backup --prune`.
3. Restore branch: `git checkout -b recovery/<date> backup/main`.
4. Cherry-pick or merge required commits back into `origin` once verified.
5. Document incident in `Docs/QA/gates/` and update runbook with root cause.

## 5. Agent-Specific Directives

- **PO:** Approves backup cadence changes; ensures rollback plan references mirror availability.
- **PM Agent:** Notes backup checkpoints in release plans and PRD updates.
- **SM Agent:** Includes “Mirror feature branch to backup remote” as final checkbox in story task lists.
- **Dev Agent:** Executes `git push backup` before high-risk changes and logs tag IDs in story Dev Notes.
- **QA Agent:** Verifies backup tag present before marking story gate as PASS.
- **DevOps:** Maintains backup remote credentials, scheduled mirror job, and bundle archive integrity checks (monthly `git fsck`).
- **Support/Marketing:** Communicates to users when rollbacks involve mirrored builds.

## 6. Tooling & Automation

- Extend `.github/workflows/ci.yml` with a scheduled job (see backlog BL-008) that mirrors `develop` nightly once secrets configured.
- Provide helper script `scripts/push-backup.ps1` (TBD) to standardize mirror pushes and tagging.
- Document mirror remote URL in `Docs/Developer-Setup.md` (Section 3) so new contributors configure it immediately.

## 7. Verification Checklist

| Item                                     | Owner                | Frequency |
| ---------------------------------------- | -------------------- | --------- |
| `backup` remote reachable from CI runner | DevOps               | Nightly   |
| Weekly bundle stored offsite             | DevOps               | Weekly    |
| Feature branch mirrored before merge     | Dev Agent / SM Agent | Per story |
| Disaster recovery drill executed         | PO + DevOps + QA     | Quarterly |

Keeping these safeguards active ensures OptiGemini can recover quickly from tooling failures, accidental branch deletions, or compromised workstations.