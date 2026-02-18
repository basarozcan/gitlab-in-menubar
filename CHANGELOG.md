# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Added
- Real-time search filter input in the main menu bar view

## [1.0.0] - 2026-02-16

### Added
- Menubar icon with color-coded status indicator based on pipeline health
- MR list showing all open merge requests across configured projects
- Pipeline status badges with colored background and icon (Passed, Running, Failed, Pending, etc.)
- Click pipeline badge to open the pipeline page in GitLab
- Click MR row to open the merge request in GitLab
- Approval tracking showing received/required approval counts per MR
- Thread tracking showing resolved/total resolvable discussion threads
- Draft detection with visible DRAFT badge
- Merge status labels (Conflict, Not Approved, CI Running, Blocked, etc.)
- Auto-refresh in the background at a configurable interval (15s–600s)
- Notifications on pipeline status changes and new approvals
- Filters by state (opened/merged/closed/all), scope (all/assigned to me/created by me), author username, and draft visibility
- Secure token storage in macOS Keychain
- Menubar-only mode — no dock icon
- Settings window with Connection, Projects, Filters, and General tabs
- Close button in settings window bottom bar

[Unreleased]: https://github.com/basarozcan/gitlab-mr-status/compare/v1.0.0...HEAD
[1.0.0]: https://github.com/basarozcan/gitlab-mr-status/releases/tag/v1.0.0
