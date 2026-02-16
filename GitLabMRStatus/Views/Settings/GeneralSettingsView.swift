import SwiftUI

struct GeneralSettingsView: View {
    @ObservedObject var viewModel: SettingsViewModel

    var body: some View {
        Form {
            Section("Refresh") {
                VStack(alignment: .leading) {
                    HStack {
                        Text("Refresh interval:")
                        Text("\(Int(viewModel.refreshInterval))s")
                            .foregroundStyle(.secondary)
                            .monospacedDigit()
                    }
                    Slider(
                        value: $viewModel.refreshInterval,
                        in: AppConstants.minimumRefreshInterval...AppConstants.maximumRefreshInterval,
                        step: 15
                    )
                    HStack {
                        Text("\(Int(AppConstants.minimumRefreshInterval))s")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                        Spacer()
                        Text("\(Int(AppConstants.maximumRefreshInterval))s")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }
            }

            Section("Display") {
                Toggle("Show pipeline status", isOn: $viewModel.showPipelineInfo)
            }

            Section("Notifications") {
                Toggle("Enable notifications", isOn: $viewModel.notificationsEnabled)
                Text("Get notified when pipeline statuses change or MRs receive approvals.")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
        .padding()
    }
}
