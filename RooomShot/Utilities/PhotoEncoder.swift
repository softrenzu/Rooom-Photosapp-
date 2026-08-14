import UIKit

enum PhotoEncoder {
    enum EncodingError: LocalizedError {
        case invalidImage

        var errorDescription: String? {
            NSLocalizedString("error.photoEncoding", comment: "")
        }
    }

    static func jpegData(from image: UIImage, quality: UploadQuality) throws -> Data {
        let targetSize = scaledSize(for: image.size, maximumDimension: quality.maximumDimension)
        let format = UIGraphicsImageRendererFormat()
        format.scale = 1
        format.opaque = true

        let renderer = UIGraphicsImageRenderer(size: targetSize, format: format)
        let normalized = renderer.image { _ in
            UIColor.black.setFill()
            UIRectFill(CGRect(origin: .zero, size: targetSize))
            image.draw(in: CGRect(origin: .zero, size: targetSize))
        }

        guard let data = normalized.jpegData(compressionQuality: quality.compressionQuality) else {
            throw EncodingError.invalidImage
        }
        return data
    }

    private static func scaledSize(for size: CGSize, maximumDimension: CGFloat?) -> CGSize {
        guard let maximumDimension,
              max(size.width, size.height) > maximumDimension else {
            return size
        }

        let scale = maximumDimension / max(size.width, size.height)
        return CGSize(width: floor(size.width * scale), height: floor(size.height * scale))
    }
}

