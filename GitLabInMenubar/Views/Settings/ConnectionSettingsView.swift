import SwiftUI

struct ConnectionSettingsView: View {
    @ObservedObject var viewModel: SettingsViewModel

    var body: some View {
        Form {
            Section("GitLab Instance") {
                TextField("GitLab URL", text: $viewModel.gitlabURL, prompt: Text("https://gitlab.com"))
                    .textFieldStyle(.roundedBorder)
            }

            Section("Authentication") {
                SecureField("Personal Access Token", text: $viewModel.accessToken)
                    .textFieldStyle(.roundedBorder)
                Text("Requires 'read_api' scope. Token is stored in macOS Keychain.")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            Section {
                HStack {
                    Button("Test Connection") {
                        Task { await viewModel.testConnection() }
                    }
                    .disabled(viewModel.gitlabURL.isEmpty || viewModel.accessToken.isEmpty)

                    connectionStatusView

                    Spacer()
                }
            }
        }
        .padding()
    }

    @ViewBuilder
    private var connectionStatusView: some View {
        switch viewModel.connectionStatus {
        case .untested:
            EmptyView()
        case .testing:
            ProgressView()
                .scaleEffect(0.6)
                .frame(width: 16, height: 16)
        case .success(let username):
            Label("Connected as \(username)", systemImage: "checkmark.circle.fill")
                .foregroundStyle(.green)
                .font(.caption)
        case .failed(let msg):
            Label(msg, systemImage: "xmark.circle.fill")
                .foregroundStyle(.red)
                .font(.caption)
                .lineLimit(2)
        }
    }
}
