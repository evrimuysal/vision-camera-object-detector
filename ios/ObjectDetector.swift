/**
 * Object Detector - iOS Implementation
 * =====================================
 *
 * Uses MLKit Object Detection to detect objects with bounding boxes in camera frames.
 */

import Foundation
import MLKitObjectDetection
import MLKitObjectDetectionCommon
import MLKitVision
import VisionCamera

@objc(ObjectDetector)
public class ObjectDetector: FrameProcessorPlugin {

    // MARK: - Properties

    private static var objectDetector: MLKitObjectDetection.ObjectDetector = {
        // Configure for multiple object detection with classification
        // Using SINGLE_IMAGE_MODE for better detection accuracy
        let options = ObjectDetectorOptions()
        options.detectorMode = .singleImage
        options.shouldEnableMultipleObjects = true
        options.shouldEnableClassification = true
        return MLKitObjectDetection.ObjectDetector.objectDetector(options: options)
    }()

    // MARK: - Initialization

    public override init(proxy: VisionCameraProxyHolder, options: [AnyHashable: Any]! = [:]) {
        super.init(proxy: proxy, options: options)
        print("[ObjectDetector] iOS Plugin Initialized")
    }

    // MARK: - Frame Processing

    public override func callback(
        _ frame: Frame,
        withArguments arguments: [AnyHashable: Any]?
    ) -> Any? {
        let visionImage = VisionImage(buffer: frame.buffer)
        visionImage.orientation = frame.orientation

        do {
            let objects = try ObjectDetector.objectDetector.results(in: visionImage)
            return processDetectedObjects(objects, frameWidth: frame.width, frameHeight: frame.height)
        } catch {
            print("[ObjectDetector] Error: \(error)")
            return [] as [[String: Any]]
        }
    }

    // MARK: - Object Processing

    private func processDetectedObjects(
        _ objects: [DetectedObject],
        frameWidth: Int,
        frameHeight: Int
    ) -> [[String: Any]] {
        let width = Double(frameWidth)
        let height = Double(frameHeight)

        return objects.map { obj in
            let box = obj.frame

            // Normalize bounding box coordinates to 0-1 range
            let boundingBox: [String: Double] = [
                "left": max(0, min(1, Double(box.origin.x) / width)),
                "top": max(0, min(1, Double(box.origin.y) / height)),
                "right": max(0, min(1, Double(box.origin.x + box.size.width) / width)),
                "bottom": max(0, min(1, Double(box.origin.y + box.size.height) / height))
            ]

            // Map labels with confidence
            let labels: [[String: Any]] = obj.labels.map { label in
                [
                    "text": label.text,
                    "confidence": Double(label.confidence)
                ]
            }

            var result: [String: Any] = [
                "boundingBox": boundingBox,
                "labels": labels
            ]

            // Add tracking ID if available
            if let trackingId = obj.trackingID {
                result["trackingId"] = trackingId.intValue
            }

            return result
        }
    }
}
