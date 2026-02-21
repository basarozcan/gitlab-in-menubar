# GitLab in Menubar

A native macOS menubar app that shows GitLab merge request statuses at a glance.

Built with Swift and SwiftUI. No third-party dependencies.

## Features

- **Menubar icon** with color-coded status indicator based on pipeline health
- **MR list** showing all open merge requests across configured projects
- **Pipeline status badges** with colored background and icon (Passed, Running, Failed, Pending, etc.)
- **Click pipeline badge** to open the pipeline page in GitLab
- **Click MR row** to open the merge request in GitLab
- **Approval tracking** showing received/required approval counts per MR
- **Thread tracking** showing resolved/total resolvable discussion threads
- **Draft detection** with visible DRAFT badge
- **Merge status** labels (Conflict, Not Approved, CI Running, Blocked, etc.)
- **Auto-refresh** in the background at a configurable interval (15s - 600s)
- **Notifications** on pipeline status changes and new approvals
- **Filters** by state (opened/merged/closed/all), scope (all/assigned to me/created by me), author username, and draft visibility
- **Secure token storage** in macOS Keychain
- **Menubar-only** - no dock icon

## Requirements

- macOS 13.0 (Ventura) or later
- Xcode 15+ (for building)
- [XcodeGen](https://github.com/yonaskolb/XcodeGen) (for generating the Xcode project)
- A GitLab personal access token with `read_api` scope

## Install Application
To install the application, follow these steps:

1. Download the latest ZIP release from the [GitHub releases page](https://github.com/basarozcan/gitlab-in-menubar/releases).
2. Extract the ZIP file.
3. Double-click the downloaded `.dmg` file to mount it.
4. Drag the `GitLab MR Status` application to your Applications folder.
5. Run following command in terminal to allow this 3rd party app
   ```bash
   xattr -cr /Applications/GitLabMRStatus.app
   ```
6. Launch the application from your Applications folder.

## Setup for Development

### Install XcodeGen

```bash
brew install xcodegen
```

### Build and Run

```bash
# Clone the repo
git clone https://github.com/basarozcan/gitlab-mr-status.git
cd gitlab-mr-status

# Generate the Xcode project
xcodegen generate

# Build
xcodebuild -project GitLabMRStatus.xcodeproj -scheme GitLabMRStatus -configuration Debug build

# Run
open "$(find ~/Library/Developer/Xcode/DerivedData/GitLabMRStatus-*/Build/Products/Debug/GitLabMRStatus.app -maxdepth 0)"
```

Or open `GitLabMRStatus.xcodeproj` in Xcode and run from there.

### Configure

1. Click the menubar icon
2. Click **Settings...**
3. **Connection tab** - Enter your GitLab URL and personal access token
4. **Projects tab** - Add project IDs and names (find the project ID in GitLab under Settings > General)
5. **Filters tab** - Configure which MRs to show
6. **General tab** - Set refresh interval, toggle pipeline display and notifications
7. Click **Save**

### Create a GitLab Personal Access Token

1. Go to GitLab > User Settings > Access Tokens
2. Create a token with the `read_api` scope
3. Copy the token and paste it in the app settings

## GitLab API Endpoints Used

- `GET /api/v4/projects/:id/merge_requests` - List merge requests
- `GET /api/v4/projects/:id/merge_requests/:iid/approval_state` - Approval status
- `GET /api/v4/projects/:id/merge_requests/:iid/discussions` - Discussion threads
- `GET /api/v4/projects/:id/merge_requests/:iid/pipelines` - Pipeline status
- `GET /api/v4/user` - Connection test

## Running Tests

```bash
xcodegen generate
xcodebuild -project GitLabMRStatus.xcodeproj -scheme GitLabMRStatus -configuration Debug test
```

## License

MIT
