/**
 * Object Detector - Objective-C Registration
 */

#import <Foundation/Foundation.h>
#import <VisionCamera/FrameProcessorPlugin.h>
#import <VisionCamera/FrameProcessorPluginRegistry.h>

#if defined __has_include && __has_include("VisionCameraObjectDetector-Swift.h")
#import "VisionCameraObjectDetector-Swift.h"
#else
#import "VisionCameraObjectDetector/VisionCameraObjectDetector-Swift.h"
#endif

@interface ObjectDetector (FrameProcessorPluginLoader)
@end

@implementation ObjectDetector (FrameProcessorPluginLoader)

+ (void)load {
    [FrameProcessorPluginRegistry addFrameProcessorPlugin:@"objectDetector"
        withInitializer:^FrameProcessorPlugin* _Nonnull(VisionCameraProxyHolder* _Nonnull proxy, NSDictionary* _Nullable options) {
        return [[ObjectDetector alloc] initWithProxy:proxy withOptions:options];
    }];
}

@end
