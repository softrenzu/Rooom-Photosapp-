import SwiftUI

struct UploadStatusBadge: View {
    let status: UploadItem.Status

    private var color: Color {
        switch status {
        case .queued: return .orange
        case .uploading: return .cyan
        case .uploaded: return .green
        case .failed: return .red
        }
    }

    private var icon: String {
        switch status {
        case .queued: return "clock.fill"
        case .uploading: return "arrow.up.circle.fill"
        case .uploaded: return "checkmark.circle.fill"
        case .failed: return "exclamationmark.triangle.fill"
        }
    }

    private var key: String {
        switch status {
        case .queued: return "status.queued"
        case .uploading: return "status.uploading"
        case .uploaded: return "status.uploaded"
        case .failed: return "status.failed"
        }
    }

    var body: some View {
        Label(NSLocalizedString(key, comment: ""), systemImage: icon)
            .font(.caption.weight(.semibold))
            .foregroundStyle(color)
            .padding(.horizontal, 10)
            .padding(.vertical, 6)
            .background(color.opacity(0.13), in: Capsule())
    }
}

