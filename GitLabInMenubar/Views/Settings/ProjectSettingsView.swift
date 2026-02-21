import SwiftUI

struct ProjectSettingsView: View {
    @ObservedObject var viewModel: SettingsViewModel

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Watched Projects")
                .font(.headline)

            if viewModel.projects.isEmpty {
                Text("No projects configured. Add a project below.")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding(.vertical, 20)
            } else {
                List {
                    ForEach(viewModel.projects) { project in
                        HStack {
                            VStack(alignment: .leading) {
                                Text(project.name)
                                    .font(.body)
                                Text("ID: \(project.projectId)")
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }
                            Spacer()
                        }
                    }
                    .onDelete { offsets in
                        viewModel.removeProject(at: offsets)
                    }
                }
                .frame(minHeight: 80, maxHeight: 200)
            }

            Divider()

            HStack(spacing: 8) {
                TextField("Project ID", text: $viewModel.newProjectId)
                    .textFieldStyle(.roundedBorder)
                    .frame(width: 100)
                TextField("Project Name", text: $viewModel.newProjectName)
                    .textFieldStyle(.roundedBorder)
                Button("Add") {
                    viewModel.addProject()
                }
                .disabled(viewModel.newProjectId.isEmpty || viewModel.newProjectName.isEmpty)
            }

            Text("Find the Project ID in GitLab under Settings > General.")
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .padding()
    }
}
