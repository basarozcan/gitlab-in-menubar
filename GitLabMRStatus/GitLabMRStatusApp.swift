import SwiftUI

@main
struct GitLabMRStatusApp: App {
    @StateObject private var viewModel = MRListViewModel()

    var body: some Scene {
        MenuBarExtra {
            MenuBarView(viewModel: viewModel)
                .onAppear { viewModel.startIfNeeded() }
        } label: {
            Label("GitLab MRs (\(viewModel.menuBarCount))", systemImage: viewModel.menuBarSystemImage)
        }
        .menuBarExtraStyle(.window)
    }
}
