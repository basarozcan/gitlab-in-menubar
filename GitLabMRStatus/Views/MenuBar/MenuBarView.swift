import SwiftUI

struct MenuBarView: View {
    @ObservedObject var viewModel: MRListViewModel

    var body: some View {
        VStack(spacing: 0) {
            header
            Divider()
            content
            Divider()
            footer
        }
        .frame(width: 420)
    }

    private var header: some View {
        HStack {
            Text("Merge Requests")
                .font(.headline)
            if !viewModel.enrichedMRs.isEmpty {
                Text("\(viewModel.enrichedMRs.count)")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .padding(.horizontal, 6)
                    .padding(.vertical, 2)
                    .background(.quaternary)
                    .cornerRadius(8)
            }
            Spacer()
            if viewModel.isLoading {
                ProgressView()
                    .scaleEffect(0.6)
                    .frame(width: 16, height: 16)
            }
            Button(action: { Task { await viewModel.refresh() } }) {
                Image(systemName: "arrow.clockwise")
            }
            .buttonStyle(.borderless)
            .disabled(viewModel.isLoading)
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
    }

    @ViewBuilder
    private var content: some View {
        if !viewModel.isConfigured {
            notConfiguredView
        } else if let error = viewModel.errorMessage {
            errorView(error)
        } else if viewModel.enrichedMRs.isEmpty && viewModel.lastRefresh != nil {
            emptyView
        } else if viewModel.enrichedMRs.isEmpty {
            loadingView
        } else {
            mrListView
        }
    }

    private var mrListView: some View {
        ScrollView {
            LazyVStack(spacing: 2) {
                ForEach(viewModel.enrichedMRs) { enriched in
                    MRRowView(enriched: enriched, showPipeline: viewModel.showPipelineInfo)
                    if enriched.id != viewModel.enrichedMRs.last?.id {
                        Divider().padding(.leading, 26)
                    }
                }
            }
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
        }
    }

    private var notConfiguredView: some View {
        VStack(spacing: 8) {
            Image(systemName: "gear")
                .font(.largeTitle)
                .foregroundStyle(.secondary)
            Text("Not Configured")
                .font(.subheadline)
            Text("Open Settings to add your GitLab URL, token, and projects.")
                .font(.caption)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
        }
        .padding(20)
    }

    private func errorView(_ message: String) -> some View {
        VStack(spacing: 8) {
            Image(systemName: "exclamationmark.triangle")
                .font(.title2)
                .foregroundStyle(.red)
            Text(message)
                .font(.caption)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
            Button("Retry") {
                Task { await viewModel.refresh() }
            }
            .buttonStyle(.bordered)
            .controlSize(.small)
        }
        .padding(20)
    }

    private var emptyView: some View {
        VStack(spacing: 8) {
            Image(systemName: "checkmark.circle")
                .font(.title2)
                .foregroundStyle(.green)
            Text("No open merge requests")
                .font(.subheadline)
        }
        .padding(20)
    }

    private var loadingView: some View {
        VStack(spacing: 8) {
            ProgressView()
            Text("Loading...")
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .padding(20)
    }

    private var footer: some View {
        HStack {
            if let lastRefresh = viewModel.lastRefresh {
                Text("Updated \(lastRefresh.formatted(.relative(presentation: .named)))")
                    .font(.caption2)
                    .foregroundStyle(.secondary)
            }
            Spacer()
            Button("Settings...") {
                openSettings()
            }
            .buttonStyle(.borderless)
            Button("Quit") {
                NSApplication.shared.terminate(nil)
            }
            .buttonStyle(.borderless)
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 6)
    }

    private func openSettings() {
        SettingsWindowController.shared.show()
    }
}
