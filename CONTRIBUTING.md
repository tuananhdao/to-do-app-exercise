# Contributing to to-do-app-exercise

## Code of Conduct
All interactions in this repository are covered by our standard Code of Conduct.

## Reporting Bugs
- Before submitting a new bug report, please search for existing or similar reports.
- Use one of our issue templates for unique problems.
- Duplicate issues or issues not using a template may be closed without response.

## Pull Request Conventions
### Commits
We use Conventional Commits. Please ensure your pull request title or each commit uses one of the following prefixes:
- `feat:` For new features (triggers a new minor version)
- `fix:` For bug fixes (triggers a new patch version)
- `docs:` For documentation updates (patch version)
- `chore:` For changes not affecting the published module (no version change)

### Branch and Commit Naming
Branches and commits must follow the SCRUM ticket format:

- `{SCRUM-number}-{SCRUM-name}`
- Or get the branch/commit name from development on Jira.

Examples:
- `SCRUM-123-fix-login-bug`
- `SCRUM-456-add-todo-feature`

Ensure a clear link between source code and Jira tasks for easy tracking of progress and development history.

### Test Coverage
- All pull requests must pass all existing tests.
- New features or bug fixes must include corresponding test cases.
- PRs that reduce test coverage may be rejected.

### Linting
- Linting runs automatically after tests. Use `npm run lintfix` to fix most errors.
- Ensure linting passes before submitting a PR.

## What not to contribute?
### Dependencies
- Third-party dependency updates/PRs are not accepted and will be closed.

### Tools/Automation
- Tooling/automation files (e.g., `.github/*`, `.eslintrc.json`, `.licensee.json`) are maintained by the core team. Do not submit PRs altering these files.

---

## Branch Protection Rules for `main`
To maintain code quality and stability, the following branch protection rules are enforced on the `main` branch:

- **Require Pull Request:** All changes must be submitted via pull request.
- **Require 1 Approver:** At least one approval is required before merging.
- **Require Status Checks:** All status checks (Test/Lint) must pass before merging.
- **Squash and Merge:** Squash and Merge is enabled and set as the default merge method.

Please follow these rules to ensure a smooth and consistent contribution process.

---

## Thank You
Thank you for contributing to this project! Your help makes it better for everyone.
