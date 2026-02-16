import SwiftUI

struct StatusIndicator: View {
    let pipeline: PipelineStatus?

    var body: some View {
        Circle()
            .fill(color)
    }

    private var color: Color {
        guard let pipeline else { return .gray }
        switch pipeline {
        case .success: return .green
        case .failed: return .red
        case .running: return .orange
        case .pending, .waiting, .preparing, .created: return .yellow
        case .canceled: return .gray
        case .manual: return .blue
        case .skipped, .scheduled, .unknown: return .gray
        }
    }
}
