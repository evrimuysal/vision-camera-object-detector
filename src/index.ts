/**
 * Vision Camera Object Detector
 * =============================
 *
 * Frame Processor Plugin for object detection with bounding boxes using MLKit.
 */

import { useMemo } from 'react';
import { type Frame, VisionCameraProxy } from 'react-native-vision-camera';

// ============================================================================
// TYPES
// ============================================================================

export interface BoundingBox {
  /** Left coordinate (0-1 normalized) */
  left: number;
  /** Top coordinate (0-1 normalized) */
  top: number;
  /** Right coordinate (0-1 normalized) */
  right: number;
  /** Bottom coordinate (0-1 normalized) */
  bottom: number;
}

export interface DetectedObject {
  /** Bounding box of the detected object */
  boundingBox: BoundingBox;
  /** Labels for this object */
  labels: Array<{
    text: string;
    confidence: number;
  }>;
  /** Tracking ID (if tracking enabled) */
  trackingId?: number;
}

type ObjectDetectorPlugin = {
  /**
   * Detects objects in a frame with bounding boxes
   * @param frame Frame to detect objects in
   */
  detectObjects: (frame: Frame) => DetectedObject[];
};

// ============================================================================
// PLUGIN INITIALIZATION
// ============================================================================

function createObjectDetectorPlugin(): ObjectDetectorPlugin {
  let plugin: ReturnType<typeof VisionCameraProxy.initFrameProcessorPlugin> | null = null;

  console.log('[ObjectDetector] Initializing plugin...');

  try {
    plugin = VisionCameraProxy.initFrameProcessorPlugin('objectDetector', {});
    console.log('[ObjectDetector] Plugin result:', plugin ? 'SUCCESS' : 'NULL');
  } catch (e) {
    console.error('[ObjectDetector] Failed to initialize plugin:', e);
  }

  if (!plugin) {
    console.warn('[ObjectDetector] Using FALLBACK (no native plugin found)');
    return {
      detectObjects: (_frame: Frame): DetectedObject[] => {
        'worklet';
        return [];
      },
    };
  }

  console.log('[ObjectDetector] Native plugin loaded successfully!');
  return {
    detectObjects: (frame: Frame): DetectedObject[] => {
      'worklet';
      // @ts-ignore - native plugin call
      const result = plugin.call(frame);
      return (result as DetectedObject[]) || [];
    },
  };
}

// ============================================================================
// HOOK
// ============================================================================

/**
 * Hook to use the Object Detector in a Frame Processor
 *
 * @example
 * ```tsx
 * const { detectObjects } = useObjectDetector()
 *
 * const frameProcessor = useSkiaFrameProcessor((frame) => {
 *   'worklet'
 *   frame.render()
 *   const objects = detectObjects(frame)
 *   for (const obj of objects) {
 *     // Draw bounding box
 *     const rect = Skia.XYWHRect(
 *       obj.boundingBox.left * frame.width,
 *       obj.boundingBox.top * frame.height,
 *       (obj.boundingBox.right - obj.boundingBox.left) * frame.width,
 *       (obj.boundingBox.bottom - obj.boundingBox.top) * frame.height
 *     )
 *     frame.drawRect(rect, paint)
 *   }
 * }, [])
 * ```
 */
export function useObjectDetector(): ObjectDetectorPlugin {
  return useMemo(() => createObjectDetectorPlugin(), []);
}

export default useObjectDetector;
