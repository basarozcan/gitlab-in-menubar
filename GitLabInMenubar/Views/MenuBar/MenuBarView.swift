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
        .frame(minWidth: 420, maxWidth: 420, minHeight: 400, maxHeight: 600)
    }

    private var header: some View {
        VStack(spacing: 0) {
            HStack {
                Text("Merge Requests")
                    .font(.headline)
                if !viewModel.activeEnrichedMRs.isEmpty {
                    Text("\(viewModel.activeFilteredMRs.count)")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .padding(.horizontal, 6)
                        .padding(.vertical, 2)
                        .background(.quaternary)
                        .cornerRadius(8)
                }
                Spacer()
                HStack(spacing: 4) {
                    Image(systemName: "magnifyingglass")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    TextField("Filter...", text: $viewModel.searchText)
                        .textFieldStyle(.plain)
                        .font(.caption)
                    if !viewModel.searchText.isEmpty {
                        Button(action: { viewModel.searchText = "" }) {
                            Image(systemName: "xmark.circle.fill")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                        .buttonStyle(.borderless)
                    }
                }
                .frame(width: 120)
                .padding(.horizontal, 6)
                .padding(.vertical, 3)
                .background(.quaternary)
                .cornerRadius(6)
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
            .padding(.top, 8)
            .padding(.bottom, 6)

            HStack(spacing: 0) {
                ForEach(MRTab.allCases, id: \.self) { tab in
                    Button(action: { viewModel.selectedTab = tab }) {
                        VStack(spacing: 4) {
                            HStack(spacing: 5) {
                                Text(tab.label)
                                    .font(.subheadline)
                                    .fontWeight(viewModel.selectedTab == tab ? .semibold : .regular)
                                    .foregroundStyle(viewModel.selectedTab == tab ? .primary : .secondary)
                                let count = viewModel.count(for: tab)
                                if count > 0 {
                                    Text("\(count)")
                                        .font(.caption2)
                                        .fontWeight(.medium)
                                        .foregroundStyle(viewModel.selectedTab == tab ? Color.accentColor : .secondary)
                                        .padding(.horizontal, 5)
                                        .padding(.vertical, 2)
                                        .background(
                                            (viewModel.selectedTab == tab ? Color.accentColor : Color.secondary)
                                                .opacity(0.12)
                                        )
                                        .cornerRadius(6)
                                }
                            }
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 6)
                            Rectangle()
                                .fill(viewModel.selectedTab == tab ? Color.accentColor : Color.clear)
                                .frame(height: 2)
                        }
                        .contentShape(Rectangle())
                    }
                    .buttonStyle(.plain)
                }
            }
        }
    }

    @ViewBuilder
    private var content: some View {
        Group {
            if !viewModel.isConfigured {
                notConfiguredView
            } else if let error = viewModel.errorMessage {
                errorView(error)
            } else if viewModel.selectedTab == .reviewing && viewModel.currentUserUsername.isEmpty {
                noUsernameView
            } else if viewModel.activeEnrichedMRs.isEmpty && viewModel.lastRefresh != nil {
                emptyView
            } else if viewModel.activeEnrichedMRs.isEmpty {
                loadingView
            } else if viewModel.activeFilteredMRs.isEmpty {
                noSearchResultsView
            } else {
                mrListView
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    private var mrListView: some View {
        ScrollView {
            LazyVStack(spacing: 2) {
                ForEach(viewModel.activeFilteredMRs) { enriched in
                    MRRowView(enriched: enriched, showPipeline: viewModel.showPipelineInfo)
                    if enriched.id != viewModel.activeFilteredMRs.last?.id {
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

    private var noUsernameView: some View {
        VStack(spacing: 8) {
            Image(systemName: "person.badge.plus")
                .font(.title2)
                .foregroundStyle(.secondary)
            Text("Username not found")
                .font(.subheadline)
            Text("Open Settings and use \"Test Connection\" to detect your GitLab username.")
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
            Text(viewModel.selectedTab == .reviewing
                 ? "No MRs awaiting your review"
                 : "No open merge requests")
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

    private var noSearchResultsView: some View {
        VStack(spacing: 8) {
            Image(systemName: "magnifyingglass")
                .font(.title2)
                .foregroundStyle(.secondary)
            Text("No results for \"\(viewModel.searchText)\"")
                .font(.subheadline)
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
