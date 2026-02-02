module.exports = {
  dependency: {
    platforms: {
      android: {
        sourceDir: './android',
        packageImportPath: 'import com.visioncameraobjectdetector.VisionCameraObjectDetectorPackage;',
        packageInstance: 'new VisionCameraObjectDetectorPackage()',
      },
      ios: null, // No iOS implementation yet
    },
  },
};
