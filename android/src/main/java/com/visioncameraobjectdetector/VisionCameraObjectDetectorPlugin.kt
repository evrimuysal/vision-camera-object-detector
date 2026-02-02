package com.visioncameraobjectdetector

import android.media.Image
import android.util.Log
import com.google.android.gms.tasks.Tasks
import com.google.mlkit.vision.common.InputImage
import com.google.mlkit.vision.objects.DetectedObject
import com.google.mlkit.vision.objects.ObjectDetection
import com.google.mlkit.vision.objects.defaults.ObjectDetectorOptions
import com.mrousavy.camera.frameprocessors.Frame
import com.mrousavy.camera.frameprocessors.FrameProcessorPlugin

private const val TAG = "ObjectDetector"

class VisionCameraObjectDetectorPlugin() : FrameProcessorPlugin() {

    // Configure for multiple object detection with classification
    // Using SINGLE_IMAGE_MODE for better detection (STREAM_MODE is for tracking, not detection)
    private val options = ObjectDetectorOptions.Builder()
        .setDetectorMode(ObjectDetectorOptions.SINGLE_IMAGE_MODE)
        .enableMultipleObjects()
        .enableClassification()
        .build()

    private val objectDetector = ObjectDetection.getClient(options)

    init {
        Log.e(TAG, "!!! ObjectDetector Plugin INITIALIZED !!!")
    }

    override fun callback(frame: Frame, params: Map<String, Any>?): Any? {
        val mediaImage: Image? = frame.image
        if (mediaImage == null) {
            Log.e(TAG, "!!! mediaImage is NULL !!!")
            return emptyList<Map<String, Any>>()
        }

        // Get rotation from frame orientation
        val rotationDegrees = when (frame.orientation.toString()) {
            "PORTRAIT" -> 90
            "PORTRAIT_UPSIDE_DOWN" -> 270
            "LANDSCAPE_LEFT" -> 0
            "LANDSCAPE_RIGHT" -> 180
            else -> 90 // Default to portrait
        }

        val image = InputImage.fromMediaImage(mediaImage, rotationDegrees)
        val task = objectDetector.process(image)

        try {
            val detectedObjects: List<DetectedObject> = Tasks.await(task)
            Log.d(TAG, "Detected ${detectedObjects.size} objects, rotation: $rotationDegrees")

            // InputImage handles rotation internally, so use rotated dimensions
            // image.width and image.height give us the dimensions AFTER rotation
            val imageWidth = image.width.toFloat()
            val imageHeight = image.height.toFloat()

            Log.d(TAG, "Frame: ${frame.width}x${frame.height}, InputImage: ${imageWidth}x${imageHeight}")

            val result = mutableListOf<Map<String, Any>>()
            for (obj in detectedObjects) {
                val box = obj.boundingBox

                // Normalize bounding box coordinates to 0-1 range
                val boundingBox = mapOf(
                    "left" to (box.left / imageWidth).toDouble().coerceIn(0.0, 1.0),
                    "top" to (box.top / imageHeight).toDouble().coerceIn(0.0, 1.0),
                    "right" to (box.right / imageWidth).toDouble().coerceIn(0.0, 1.0),
                    "bottom" to (box.bottom / imageHeight).toDouble().coerceIn(0.0, 1.0)
                )

                Log.d(TAG, "Box raw: (${box.left}, ${box.top}) - (${box.right}, ${box.bottom})")
                Log.d(TAG, "Box normalized: $boundingBox")

                val labels = obj.labels.map { label ->
                    mapOf(
                        "text" to label.text,
                        "confidence" to label.confidence.toDouble()
                    )
                }

                val objectMap = mutableMapOf<String, Any>(
                    "boundingBox" to boundingBox,
                    "labels" to labels
                )

                obj.trackingId?.let { id ->
                    objectMap["trackingId"] = id
                }

                if (labels.isNotEmpty()) {
                    Log.d(TAG, "Object: ${labels.firstOrNull()?.get("text")} at (${box.left}, ${box.top})")
                }

                result.add(objectMap)
            }

            return result
        } catch (e: Exception) {
            Log.e(TAG, "Error processing image", e)
        }

        return emptyList<Map<String, Any>>()
    }
}
