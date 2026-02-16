import SwiftUI

struct SettingsView: View {
    @StateObject private var viewModel = SettingsViewModel()

    var body: some View {
        VStack(spacing: 0) {
            TabView {
                ConnectionSettingsView(viewModel: viewModel)
                    .tabItem {
                        Label("Connection", systemImage: "network")
                    }
                ProjectSettingsView(viewModel: viewModel)
                    .tabItem {
                        Label("Projects", systemImage: "folder")
                    }
                FilterSettingsView(viewModel: viewModel)
                    .tabItem {
                        Label("Filters", systemImage: "line.3.horizontal.decrease.circle")
                    }
                GeneralSettingsView(viewModel: viewModel)
                    .tabItem {
                        Label("General", systemImage: "gear")
                    }
            }

            Divider()

            HStack {
                if viewModel.saveConfirmation {
                    Text("Settings saved!")
                        .font(.caption)
                        .foregroundStyle(.green)
                }
                Spacer()
                Button("Save") {
                    viewModel.save()
                }
                .buttonStyle(.borderedProminent)
                .keyboardShortcut(.return, modifiers: .command)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 10)
        }
        .frame(width: 600, height: 400)
        .onAppear { viewModel.load() }
    }
}
