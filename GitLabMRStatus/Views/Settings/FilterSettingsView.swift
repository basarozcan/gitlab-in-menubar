import SwiftUI

struct FilterSettingsView: View {
    @ObservedObject var viewModel: SettingsViewModel

    var body: some View {
        Form {
            Section("State") {
                Picker("Show MRs with state:", selection: $viewModel.filterState) {
                    ForEach(MRFilterState.allCases) { state in
                        Text(state.label).tag(state)
                    }
                }
                .pickerStyle(.segmented)
            }

            Section("Scope") {
                Picker("Scope:", selection: $viewModel.filterScope) {
                    ForEach(MRFilterScope.allCases) { scope in
                        Text(scope.label).tag(scope)
                    }
                }
                .pickerStyle(.radioGroup)
            }

            Section("Author") {
                TextField("Author username", text: $viewModel.filterAuthorUsername, prompt: Text("e.g. johndoe (leave empty for all)"))
                    .textFieldStyle(.roundedBorder)
                Text("Filter MRs to a specific author. Leave empty to show all authors.")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            Section("Drafts") {
                Toggle("Hide draft MRs", isOn: $viewModel.filterHideDrafts)
            }
        }
        .padding()
    }
}
