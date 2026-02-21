import SwiftUI

struct MRRowView: View {
    let enriched: EnrichedMR
    var showPipeline: Bool = true

    private var mr: MergeRequest { enriched.mr }

    var body: some View {
        Button(action: openInBrowser) {
            HStack(alignment: .top, spacing: 8) {
                VStack(alignment: .leading, spacing: 3) {
                    HStack(spacing: 4) {
                        if mr.draft {
                            Text("DRAFT")
                                .font(.system(size: 9, weight: .bold))
                                .foregroundStyle(.secondary)
                                .padding(.horizontal, 4)
                                .padding(.vertical, 1)
                                .background(.quaternary)
                                .cornerRadius(3)
                        }
                        Text("!\(mr.iid)")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                        Text(mr.title)
                            .font(.system(size: 12, weight: .medium))
                            .lineLimit(1)
                    }

                    HStack(spacing: 8) {
                        Text(enriched.projectName)
                            .font(.caption2)
                            .foregroundStyle(.tertiary)

                        Label(mr.sourceBranch, systemImage: "arrow.branch")
                            .font(.caption2)
                            .foregroundStyle(.secondary)
                            .lineLimit(1)

                        if showPipeline {
                            pipelineBadge
                        }

                        Spacer()

                        if enriched.totalApprovalsRequired > 0 {
                            Label(
                                "\(enriched.totalApprovalsReceived)/\(enriched.totalApprovalsRequired)",
                                systemImage: enriched.isFullyApproved
                                    ? "checkmark.seal.fill"
                                    : "checkmark.seal"
                            )
                            .font(.caption2)
                            .foregroundStyle(enriched.isFullyApproved ? .green : .secondary)
                        }

                        if let stats = enriched.discussionStats, stats.total > 0 {
                            Label(
                                "\(stats.resolved)/\(stats.total)",
                                systemImage: stats.resolved == stats.total
                                    ? "text.bubble.fill"
                                    : "text.bubble"
                            )
                            .font(.caption2)
                            .foregroundStyle(stats.resolved == stats.total ? .green : .orange)
                        }

                        if let status = mr.detailedMergeStatus, status != .mergeable {
                            Text(status.shortLabel)
                                .font(.system(size: 9))
                                .foregroundStyle(status.color)
                        }
                    }
                }
            }
            .padding(.vertical, 4)
            .padding(.horizontal, 4)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
    }

    @ViewBuilder
    private var pipelineBadge: some View {
        if let status = enriched.pipelineStatus {
            Button(action: openPipeline) {
                HStack(spacing: 3) {
                    Image(systemName: status.iconName)
                        .font(.system(size: 8))
                    Text(status.displayName)
                        .font(.system(size: 10, weight: .medium))
                }
                .foregroundColor(.white)
                .padding(.horizontal, 6)
                .padding(.vertical, 2)
                .background(status.color.opacity(0.85))
                .cornerRadius(4)
            }
            .buttonStyle(.plain)
            .help("Open pipeline in GitLab")
        } else {
            HStack(spacing: 3) {
                Image(systemName: "minus.circle")
                    .font(.system(size: 8))
                Text("No Pipeline")
                    .font(.system(size: 10, weight: .medium))
            }
            .foregroundColor(.white)
            .padding(.horizontal, 6)
            .padding(.vertical, 2)
            .background(Color.gray.opacity(0.5))
            .cornerRadius(4)
        }
    }

    private func openInBrowser() {
        if let url = URL(string: mr.webUrl) {
            NSWorkspace.shared.open(url)
        }
    }

    private func openPipeline() {
        if let url = enriched.pipelineURL {
            NSWorkspace.shared.open(url)
        }
    }
}
