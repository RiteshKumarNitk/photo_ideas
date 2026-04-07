import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:permission_handler/permission_handler.dart';
import '../../../core/models/photo_model.dart';
import 'dart:async';
import 'dart:math' as math;
import 'package:sensors_plus/sensors_plus.dart';
import 'package:gal/gal.dart';
import 'dart:io';
import 'package:photo_view/photo_view.dart';
import 'package:google_mlkit_pose_detection/google_mlkit_pose_detection.dart';
import '../../../core/services/pose_detection_service.dart';
import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';
import '../../../core/services/face_detection_service.dart';
import '../../../core/services/filter_asset_service.dart';
import '../models/face_filter_model.dart';
import '../widgets/face_painter.dart';
import '../../../core/services/tts_service.dart';
import '../../../core/utils/mlkit_utils.dart';
import '../../../core/utils/sound_utils.dart';
import '../../../core/services/selfie_segmentation_service.dart';
import 'package:google_mlkit_object_detection/google_mlkit_object_detection.dart';
import 'package:google_mlkit_image_labeling/google_mlkit_image_labeling.dart';
import '../../../core/utils/gesture_detector.dart';
import '../../../utils/image_downloader.dart';
import '../../../core/services/face_filter_service.dart';
import '../../../core/utils/face_filter_processor.dart';

class MagicCameraScreen extends StatefulWidget {
  final PhotoModel? photo;

  const MagicCameraScreen({super.key, this.photo});

  @override
  State<MagicCameraScreen> createState() => _MagicCameraScreenState();
}

class _MagicCameraScreenState extends State<MagicCameraScreen>
    with WidgetsBindingObserver {
  CameraController? _controller;
  List<CameraDescription> _cameras = [];
  bool _isInit = false;

  // AI Settings State
  bool _aiCoachEnabled = false;
  bool _handGestureEnabled = false;
  bool _emotionCaptureEnabled = false;
  bool _objectDetectionEnabled = false;
  bool _sceneRecognitionEnabled = false;
  bool _smartCompositionEnabled = false;

  // Pro Settings
  int _gridMode = 0;
  int _timerDuration = 0;
  FlashMode _flashMode = FlashMode.auto;
  bool _isCountingDown = false;
  int _countdownValue = 0;

  // Zoom
  double _currentZoom = 1.0;
  double _minZoom = 1.0;
  double _maxZoom = 1.0;
  double _scaleFactorBase = 1.0;

  // Split/Ghost
  bool _isSplitMode = false;
  bool _isLevelerActive = false;
  bool _isGhostMode = false;
  double _deviceRoll = 0.0;
  StreamSubscription? _sensorSubscription;

  // AI Services
  final PoseDetectionService _poseService = PoseDetectionService();
  final FaceDetectionService _faceService = FaceDetectionService();
  ObjectDetector? _objectDetector;
  ImageLabeler? _imageLabeler;
  final SelfieSegmentationService _segmentationService =
      SelfieSegmentationService();
  final TtsService _ttsService = TtsService();

  // Detected Data
  List<Face> _detectedFaces = [];
  List<DetectedObject> _detectedObjects = [];
  List<ImageLabel> _sceneLabels = [];
  Pose? _detectedPose;
  Pose? _referencePose;
  String? _dominantScene;
  String? _lastDetectedGesture;

  // Face Filters
  bool _isFaceFilterActive = false;
  List<FaceFilter> _availableFilters = [];
  int _selectedFilterIndex = 0;
  bool _isLoadingAssets = false;
  bool _isPortraitMode = false;
  bool _isAutoShutterEnabled = false;
  bool _isProcessingFrame = false;

  // Auto-Shutter
  Timer? _autoTriggerTimer;
  int _consecutiveGoodFrames = 0;
  bool _isAutoTriggering = false;

  // Gesture Detection
  final GestureMLService _gestureService = GestureMLService();
  List<HandGesture> _lastGestures = [];
  DateTime? _lastGestureTime;

  // Match Score
  double _matchScore = 0.0;
  String _feedbackText = "Align body with skeleton";

  int _selectedCameraIndex = 0;
  ResolutionPreset _currentResolutionPreset = ResolutionPreset.high;
  XFile? _lastCapturedPhoto;

  int _currentAspectRatioIndex = 0;
  final List<double> _aspectRatios = [3 / 4, 9 / 16, 1.0];
  final List<String> _aspectRatioLabels = ["3:4", "9:16", "1:1"];

  int _filterIndex = 0;
  final List<ColorFilter?> _filters = [
    null,
    const ColorFilter.matrix([
      0.33,
      0.33,
      0.33,
      0,
      0,
      0.33,
      0.33,
      0.33,
      0,
      0,
      0.33,
      0.33,
      0.33,
      0,
      0,
      0,
      0,
      0,
      1,
      0,
    ]),
    const ColorFilter.matrix([
      0.393,
      0.769,
      0.189,
      0,
      0,
      0.349,
      0.686,
      0.168,
      0,
      0,
      0.272,
      0.534,
      0.131,
      0,
      0,
      0,
      0,
      0,
      1,
      0,
    ]),
    const ColorFilter.matrix([
      1,
      0,
      0,
      0,
      0,
      0,
      1,
      0,
      0,
      0,
      0,
      0,
      1.2,
      0,
      0,
      0,
      0,
      0,
      1,
      0,
    ]),
  ];
  final List<String> _filterLabels = ["Norm", "B&W", "Sepia", "Cold"];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);

    // Initialize ML services with correct API
    _objectDetector = ObjectDetector(
      options: ObjectDetectorOptions(
        mode: DetectionMode.single,
        classifyObjects: true,
        multipleObjects: true,
      ),
    );
    _imageLabeler = ImageLabeler(
      options: ImageLabelerOptions(confidenceThreshold: 0.5),
    );

    _initCamera();
    _loadReferencePose();
    _loadFaceFilters();
  }

  Future<void> _loadFaceFilters() async {
    final filters = await FaceFilterService.getFilters();
    if (mounted) {
      setState(() {
        _availableFilters = filters;
      });
    }
  }

  Future<void> _loadReferencePose() async {
    if (widget.photo == null) return;
    try {
      final file = await ImageDownloader.downloadToTemp(widget.photo!.url);
      if (file != null) {
        final inputImage = InputImage.fromFilePath(file.path);
        final poses = await _poseService.processImage(inputImage);
        if (poses.isNotEmpty) {
          if (mounted) setState(() => _referencePose = poses.first);
        }
      }
    } catch (e) {
      debugPrint("Error loading reference pose: $e");
    }
  }

  Future<void> _initCamera() async {
    final status = await Permission.camera.request();
    if (status.isDenied) {
      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Camera permission is required')),
        );
      }
      return;
    }

    try {
      _cameras = await availableCameras();
      if (_cameras.isEmpty) return;

      _controller = CameraController(
        _cameras[_selectedCameraIndex],
        _currentResolutionPreset,
        enableAudio: false,
        imageFormatGroup: Platform.isAndroid
            ? ImageFormatGroup.nv21
            : ImageFormatGroup.bgra8888,
      );

      await _controller!.initialize();
      await _controller!.setFlashMode(_flashMode);

      _minZoom = await _controller!.getMinZoomLevel();
      _maxZoom = await _controller!.getMaxZoomLevel();

      if (mounted) {
        setState(() => _isInit = true);
      }
    } catch (e) {
      debugPrint("Camera error: $e");
    }
  }

  Future<void> _updateImageStream() async {
    if (_controller == null || !_controller!.value.isInitialized) return;

    final shouldStream =
        _aiCoachEnabled ||
        _isFaceFilterActive ||
        _handGestureEnabled ||
        _emotionCaptureEnabled ||
        _objectDetectionEnabled;

    if (shouldStream && !_controller!.value.isStreamingImages) {
      try {
        await _controller!.startImageStream(_processCameraImage);
      } catch (e) {
        debugPrint("Error starting stream: $e");
      }
    } else if (!shouldStream && _controller!.value.isStreamingImages) {
      await _controller!.stopImageStream();
    }
  }

  void _processCameraImage(CameraImage image) async {
    if (_isProcessingFrame) return;
    if (!_aiCoachEnabled &&
        !_isFaceFilterActive &&
        !_handGestureEnabled &&
        !_emotionCaptureEnabled &&
        !_objectDetectionEnabled &&
        !_sceneRecognitionEnabled)
      return;

    _isProcessingFrame = true;

    try {
      final inputImage = MLKitUtils.convertCameraImage(
        image,
        _cameras[_selectedCameraIndex],
      );
      if (inputImage == null) {
        _isProcessingFrame = false;
        return;
      }

      // Face Detection & Emotion
      if (_isFaceFilterActive || _emotionCaptureEnabled) {
        final faces = await _faceService.processImage(inputImage);
        if (mounted) {
          setState(() => _detectedFaces = faces);
        }

        if (_emotionCaptureEnabled) {
          for (final face in faces) {
            if (face.smilingProbability != null &&
                face.smilingProbability! > 0.8) {
              if (!_isCountingDown &&
                  !_controller!.value.isTakingPicture &&
                  _isAutoShutterEnabled) {
                _takePicture();
                _ttsService.speak("Nice smile!");
              }
            }
          }
        }
      }

      // Hand Gesture Detection
      if (_handGestureEnabled) {
        final gestures = await _gestureService.detectGestures(inputImage);
        if (gestures.isNotEmpty && mounted) {
          final now = DateTime.now();
          if (_lastGestureTime == null ||
              now.difference(_lastGestureTime!) > const Duration(seconds: 2)) {
            _lastGestures = gestures;
            _lastGestureTime = now;

            for (final gesture in gestures) {
              if (gesture == HandGesture.raisedHand &&
                  !_controller!.value.isTakingPicture) {
                _takePicture();
                _ttsService.speak("Captured!");
                break;
              } else if (gesture == HandGesture.peace) {
                _toggleCamera();
                _ttsService.speak("Camera switched");
                break;
              } else if (gesture == HandGesture.thumbsUp) {
                _toggleFlash();
                _ttsService.speak("Flash toggled");
                break;
              } else if (gesture == HandGesture.openPalm) {
                _toggleTimer();
                _ttsService.speak(
                  _timerDuration > 0
                      ? "Timer: ${_timerDuration}s"
                      : "Timer off",
                );
                break;
              }
            }
          }
        }
      }

      // Object Detection
      if (_objectDetectionEnabled && _objectDetector != null) {
        final objects = await _objectDetector!.processImage(inputImage);
        if (mounted) {
          setState(() => _detectedObjects = objects);
        }
      }

      // Scene Recognition
      if (_sceneRecognitionEnabled && _imageLabeler != null) {
        final labels = await _imageLabeler!.processImage(inputImage);
        if (labels.isNotEmpty && mounted) {
          setState(() {
            _sceneLabels = labels;
            _dominantScene = labels.first.label;
          });
        }
      }

      // Pose Detection
      if (_aiCoachEnabled) {
        final poses = await _poseService.processImage(inputImage);
        if (poses.isNotEmpty) {
          final pose = poses.first;
          double score = 0.0;
          String feedback = "Hold steady...";

          if (_referencePose != null) {
            score = _poseService.calculateSimilarity(_referencePose!, pose);
            feedback = _poseService.getPoseFeedback(_referencePose!, pose);
          }

          if (mounted) {
            setState(() {
              _detectedPose = pose;
              _matchScore = score;
              _feedbackText = feedback;
            });

            if (_isAutoShutterEnabled &&
                !_isAutoTriggering &&
                !_controller!.value.isTakingPicture) {
              if (score > 85) {
                _consecutiveGoodFrames++;
                if (_consecutiveGoodFrames > 20) {
                  _isAutoTriggering = true;
                  _takePicture().then((_) {
                    if (mounted) {
                      setState(() {
                        _isAutoTriggering = false;
                        _consecutiveGoodFrames = 0;
                      });
                    }
                  });
                }
              } else {
                _consecutiveGoodFrames = 0;
              }
            }
          }
        }
      }
    } catch (e) {
      debugPrint("Error processing frame: $e");
    } finally {
      _isProcessingFrame = false;
    }
  }

  void _showSettingsPanel() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.black87,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      isScrollControlled: true,
      builder: (context) => _buildSettingsPanel(),
    );
  }

  Widget _buildSettingsPanel() {
    return DraggableScrollableSheet(
      initialChildSize: 0.6,
      minChildSize: 0.3,
      maxChildSize: 0.9,
      expand: false,
      builder: (context, scrollController) {
        return SingleChildScrollView(
          controller: scrollController,
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.white30,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                const Text(
                  'Camera Settings',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 20),

                _buildSettingsSection('AI Features', [
                  _buildSwitchTile(
                    'Hand Gesture Control',
                    'Raise hand to capture, peace to switch camera',
                    Icons.pan_tool,
                    _handGestureEnabled,
                    (v) {
                      setState(() => _handGestureEnabled = v);
                      _updateImageStream();
                    },
                  ),
                  _buildSwitchTile(
                    'Emotion Capture',
                    'Auto-capture when everyone smiles',
                    Icons.sentiment_satisfied_alt,
                    _emotionCaptureEnabled,
                    (v) {
                      setState(() {
                        _emotionCaptureEnabled = v;
                        if (v) _isAutoShutterEnabled = true;
                      });
                      _updateImageStream();
                    },
                  ),
                  _buildSwitchTile(
                    'AI Coach',
                    'Pose matching with skeleton overlay',
                    Icons.accessibility_new,
                    _aiCoachEnabled,
                    (v) {
                      setState(() => _aiCoachEnabled = v);
                      _updateImageStream();
                    },
                  ),
                  _buildSwitchTile(
                    'Object Detection',
                    'Show labels on detected objects',
                    Icons.category,
                    _objectDetectionEnabled,
                    (v) {
                      setState(() => _objectDetectionEnabled = v);
                      _updateImageStream();
                    },
                  ),
                  _buildSwitchTile(
                    'Scene Recognition',
                    'Auto-detect what you\'re photographing',
                    Icons.auto_awesome,
                    _sceneRecognitionEnabled,
                    (v) {
                      setState(() => _sceneRecognitionEnabled = v);
                      _updateImageStream();
                    },
                  ),
                  _buildSwitchTile(
                    'Smart Composition',
                    'AI composition guide',
                    Icons.rule,
                    _smartCompositionEnabled,
                    (v) {
                      setState(() => _smartCompositionEnabled = v);
                    },
                  ),
                  _buildSwitchTile(
                    'Face Filters',
                    'AR face masks and effects',
                    Icons.face_retouching_natural,
                    _isFaceFilterActive,
                    (v) {
                      setState(() => _isFaceFilterActive = v);
                      _updateImageStream();
                    },
                  ),
                ]),

                const SizedBox(height: 20),
                _buildSettingsSection('Camera Controls', [
                  _buildSwitchTile(
                    'Portrait Mode',
                    'Background blur effect',
                    Icons.blur_on,
                    _isPortraitMode,
                    (v) => setState(() => _isPortraitMode = v),
                  ),
                  _buildSwitchTile(
                    'Grid Overlay',
                    'Composition grid lines',
                    Icons.grid_on,
                    _gridMode != 0,
                    (v) => setState(() => _gridMode = v ? 1 : 0),
                  ),
                  _buildSwitchTile(
                    'Leveler',
                    'Device tilt indicator',
                    Icons.screen_rotation,
                    _isLevelerActive,
                    (v) => _toggleLeveler(),
                  ),
                  _buildSwitchTile(
                    'Ghost Mode',
                    'Reference photo overlay',
                    Icons.contrast,
                    _isGhostMode,
                    (v) => setState(() => _isGhostMode = v),
                  ),
                  _buildSwitchTile(
                    'Split View',
                    'Side-by-side camera and reference',
                    Icons.vertical_split,
                    _isSplitMode,
                    (v) => setState(() => _isSplitMode = v),
                  ),
                  _buildSwitchTile(
                    'Auto-Shutter',
                    'Auto-capture when pose matches',
                    Icons.hdr_auto,
                    _isAutoShutterEnabled,
                    (v) => setState(() => _isAutoShutterEnabled = v),
                  ),
                ]),

                const SizedBox(height: 20),
                _buildSettingsSection('Quick Settings', [
                  _buildSliderTile(
                    'Timer',
                    '${_timerDuration}s',
                    Icons.timer,
                    0,
                    10,
                    _timerDuration.toDouble(),
                    (v) => setState(() => _timerDuration = v.round()),
                  ),
                  _buildOptionTile(
                    'Flash',
                    _getFlashLabel(),
                    Icons.flash_on,
                    () => _cycleFlash(),
                  ),
                  _buildOptionTile(
                    'Resolution',
                    _currentResolutionPreset == ResolutionPreset.high
                        ? 'HD'
                        : 'Max',
                    Icons.hd,
                    () => _toggleResolution(),
                  ),
                  _buildOptionTile(
                    'Aspect Ratio',
                    _aspectRatioLabels[_currentAspectRatioIndex],
                    Icons.crop,
                    () => _toggleAspectRatio(),
                  ),
                  _buildOptionTile(
                    'Filter',
                    _filterLabels[_filterIndex],
                    Icons.palette,
                    () => _toggleFilter(),
                  ),
                ]),

                const SizedBox(height: 30),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildSettingsSection(String title, List<Widget> children) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            color: Colors.amber,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 10),
        ...children,
      ],
    );
  }

  Widget _buildSwitchTile(
    String title,
    String subtitle,
    IconData icon,
    bool value,
    ValueChanged<bool> onChanged,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: Colors.white10,
        borderRadius: BorderRadius.circular(12),
      ),
      child: SwitchListTile(
        title: Text(
          title,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w500,
          ),
        ),
        subtitle: Text(
          subtitle,
          style: const TextStyle(color: Colors.white54, fontSize: 12),
        ),
        secondary: Icon(icon, color: value ? Colors.amber : Colors.white54),
        value: value,
        onChanged: onChanged,
        activeColor: Colors.amber,
      ),
    );
  }

  Widget _buildSliderTile(
    String title,
    String value,
    IconData icon,
    double min,
    double max,
    double current,
    ValueChanged<double> onChanged,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white10,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: Colors.white54),
              const SizedBox(width: 10),
              Text(title, style: const TextStyle(color: Colors.white)),
              const Spacer(),
              Text(
                value,
                style: const TextStyle(
                  color: Colors.amber,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          Slider(
            value: current,
            min: min,
            max: max,
            onChanged: onChanged,
            activeColor: Colors.amber,
          ),
        ],
      ),
    );
  }

  Widget _buildOptionTile(
    String title,
    String value,
    IconData icon,
    VoidCallback onTap,
  ) {
    return ListTile(
      leading: Icon(icon, color: Colors.white54),
      title: Text(title, style: const TextStyle(color: Colors.white)),
      trailing: Text(value, style: const TextStyle(color: Colors.amber)),
      onTap: onTap,
    );
  }

  Future<void> _toggleCamera() async {
    if (_cameras.length < 2) return;
    setState(() {
      _selectedCameraIndex = (_selectedCameraIndex + 1) % _cameras.length;
      _isInit = false;
    });
    await _controller?.dispose();
    await _initCamera();
    _updateImageStream();
  }

  void _toggleResolution() {
    setState(() {
      _currentResolutionPreset =
          _currentResolutionPreset == ResolutionPreset.high
          ? ResolutionPreset.max
          : ResolutionPreset.high;
      _isInit = false;
    });
    _initCamera();
  }

  void _toggleAspectRatio() {
    setState(() {
      _currentAspectRatioIndex =
          (_currentAspectRatioIndex + 1) % _aspectRatios.length;
    });
  }

  void _toggleFilter() {
    setState(() {
      _filterIndex = (_filterIndex + 1) % _filters.length;
    });
  }

  void _toggleLeveler() {
    setState(() => _isLevelerActive = !_isLevelerActive);

    if (_isLevelerActive) {
      _sensorSubscription = accelerometerEventStream().listen((event) {
        if (!mounted) return;
        setState(() {
          _deviceRoll = -math.atan2(event.x, event.y);
        });
      });
    } else {
      _sensorSubscription?.cancel();
      _sensorSubscription = null;
    }
  }

  void _toggleTimer() {
    setState(() {
      _timerDuration = _timerDuration == 0 ? 3 : (_timerDuration == 3 ? 10 : 0);
    });
  }

  void _toggleFlash() {
    _cycleFlash();
  }

  void _cycleFlash() {
    FlashMode newMode;
    switch (_flashMode) {
      case FlashMode.auto:
        newMode = FlashMode.off;
        break;
      case FlashMode.off:
        newMode = FlashMode.always;
        break;
      default:
        newMode = FlashMode.auto;
    }
    _controller?.setFlashMode(newMode);
    setState(() => _flashMode = newMode);
  }

  String _getFlashLabel() {
    switch (_flashMode) {
      case FlashMode.auto:
        return 'Auto';
      case FlashMode.off:
        return 'Off';
      case FlashMode.always:
        return 'On';
      default:
        return 'Auto';
    }
  }

  void _handleScaleStart(ScaleStartDetails details) {
    _scaleFactorBase = _currentZoom;
  }

  Future<void> _handleScaleUpdate(ScaleUpdateDetails details) async {
    double newZoom = _scaleFactorBase * details.scale;
    newZoom = newZoom.clamp(_minZoom, _maxZoom);
    if (newZoom != _currentZoom) {
      setState(() => _currentZoom = newZoom);
      await _controller?.setZoomLevel(newZoom);
    }
  }

  Future<void> _takePicture() async {
    if (_controller == null || _controller!.value.isTakingPicture) return;

    if (_timerDuration > 0) {
      setState(() {
        _isCountingDown = true;
        _countdownValue = _timerDuration;
      });
      for (int i = 0; i < _timerDuration; i++) {
        await Future.delayed(const Duration(seconds: 1));
        if (!mounted) return;
        setState(() => _countdownValue--);
      }
      setState(() => _isCountingDown = false);
    }

    try {
      await SoundUtils.playShutterSound();
      var image = await _controller!.takePicture();

      if (_isFaceFilterActive && _selectedFilterIndex > 0) {
        final filteredPath = await FaceFilterProcessor.applyFilterToImage(
          image.path,
          _availableFilters[_selectedFilterIndex],
        );
        if (filteredPath != null) {
          image = XFile(filteredPath);
        }
      }

      if (mounted) {
        setState(() => _lastCapturedPhoto = image);
      }

      try {
        await Gal.putImage(image.path);
      } catch (e) {
        debugPrint("Gallery save error: $e");
      }
    } catch (e) {
      debugPrint("Error taking picture: $e");
    }
  }

  double _calculateCoverScale() {
    if (_controller == null || !_controller!.value.isInitialized) return 1.0;
    return 1.0;
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _controller?.dispose();
    _sensorSubscription?.cancel();
    _objectDetector?.close();
    _imageLabeler?.close();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    final cameraController = _controller;
    if (cameraController == null || !cameraController.value.isInitialized)
      return;
    if (state == AppLifecycleState.inactive) {
      cameraController.dispose();
    } else if (state == AppLifecycleState.resumed) {
      _initCamera();
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!_isInit || _controller == null) {
      return const Scaffold(
        backgroundColor: Colors.black,
        body: Center(child: CircularProgressIndicator(color: Colors.white)),
      );
    }

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        fit: StackFit.expand,
        children: [
          _isSplitMode ? _buildSplitView() : _buildOverlayView(),

          // AI Overlays
          if (_gridMode != 0) Positioned.fill(child: _buildGrid()),
          if (_isLevelerActive) Positioned.fill(child: _buildLeveler()),
          if (_isFaceFilterActive)
            Positioned.fill(child: _buildFaceFilterOverlay()),
          if (_aiCoachEnabled && _detectedPose != null)
            Positioned.fill(child: _buildSkeleton()),
          if (_objectDetectionEnabled)
            Positioned.fill(child: _buildObjectLabels()),
          if (_sceneRecognitionEnabled && _dominantScene != null)
            Positioned.fill(child: _buildSceneLabel()),
          if (_smartCompositionEnabled)
            Positioned.fill(child: _buildSmartComposition()),

          if (_aiCoachEnabled) _buildAiScore(),

          // Gesture indicator
          if (_handGestureEnabled && _lastGestures.isNotEmpty)
            _buildGestureIndicator(),

          // Top bar with settings button
          _buildTopBar(),

          // Bottom controls
          _buildBottomControls(),

          if (_isCountingDown) _buildCountdown(),
        ],
      ),
    );
  }

  Widget _buildTopBar() {
    return Positioned(
      top: 50,
      left: 10,
      right: 10,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            icon: const Icon(Icons.close, color: Colors.white, size: 28),
            onPressed: () => Navigator.pop(context),
          ),
          Row(
            children: [
              if (_timerDuration > 0)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.black54,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    '${_timerDuration}s',
                    style: const TextStyle(
                      color: Colors.amber,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              const SizedBox(width: 8),
              IconButton(
                icon: Icon(Icons.settings, color: Colors.white, size: 28),
                onPressed: _showSettingsPanel,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBottomControls() {
    return Positioned(
      bottom: 40,
      left: 20,
      right: 20,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (_lastCapturedPhoto != null)
            GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => Scaffold(
                      backgroundColor: Colors.black,
                      appBar: AppBar(
                        backgroundColor: Colors.transparent,
                        leading: const BackButton(color: Colors.white),
                      ),
                      body: PhotoView(
                        imageProvider: FileImage(
                          File(_lastCapturedPhoto!.path),
                        ),
                      ),
                    ),
                  ),
                );
              },
              child: Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 2),
                  image: DecorationImage(
                    image: FileImage(File(_lastCapturedPhoto!.path)),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            )
          else
            const SizedBox(width: 50),

          const SizedBox(height: 20),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              IconButton(
                onPressed: _toggleCamera,
                icon: const Icon(
                  Icons.cameraswitch,
                  color: Colors.white,
                  size: 30,
                ),
              ),
              GestureDetector(
                onTap: _takePicture,
                child: Container(
                  width: 70,
                  height: 70,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 4),
                  ),
                  child: Container(
                    margin: const EdgeInsets.all(4),
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
              IconButton(
                onPressed: () {
                  setState(() {
                    _gridMode = (_gridMode + 1) % 3;
                  });
                },
                icon: Icon(
                  _gridMode == 0 ? Icons.grid_off : Icons.grid_on,
                  color: Colors.white,
                  size: 30,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildOverlayView() {
    return GestureDetector(
      onScaleStart: _handleScaleStart,
      onScaleUpdate: _handleScaleUpdate,
      child: Center(
        child: AspectRatio(
          aspectRatio: _aspectRatios[_currentAspectRatioIndex],
          child: ClipRect(
            child: Stack(
              fit: StackFit.expand,
              children: [
                Transform.scale(
                  scale: _calculateCoverScale(),
                  child: Center(
                    child: ColorFiltered(
                      colorFilter:
                          _filters[_filterIndex] ??
                          const ColorFilter.mode(
                            Colors.transparent,
                            BlendMode.dst,
                          ),
                      child: CameraPreview(_controller!),
                    ),
                  ),
                ),
                if (widget.photo != null)
                  Opacity(
                    opacity: _isGhostMode ? 0.5 : 0,
                    child: Image.network(
                      widget.photo!.url,
                      fit: BoxFit.contain,
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSplitView() {
    return Column(
      children: [
        Expanded(
          child: widget.photo != null
              ? Image.network(
                  widget.photo!.url,
                  fit: BoxFit.contain,
                  width: double.infinity,
                )
              : Container(color: Colors.black),
        ),
        Expanded(
          child: GestureDetector(
            onScaleStart: _handleScaleStart,
            onScaleUpdate: _handleScaleUpdate,
            child: CameraPreview(_controller!),
          ),
        ),
      ],
    );
  }

  Widget _buildFaceFilterOverlay() {
    return CustomPaint(
      painter: FacePainter(
        faces: _detectedFaces,
        imageSize: Platform.isAndroid
            ? Size(
                _controller!.value.previewSize!.height,
                _controller!.value.previewSize!.width,
              )
            : Size(
                _controller!.value.previewSize!.width,
                _controller!.value.previewSize!.height,
              ),
        rotation: InputImageRotation.rotation90deg,
        cameraLensDirection: _cameras[_selectedCameraIndex].lensDirection,
        filter: _availableFilters[_selectedFilterIndex],
      ),
    );
  }

  Widget _buildObjectLabels() {
    return IgnorePointer(
      child: CustomPaint(
        painter: ObjectLabelPainter(
          objects: _detectedObjects,
          imageSize: Size(
            _controller!.value.previewSize!.width,
            _controller!.value.previewSize!.height,
          ),
        ),
      ),
    );
  }

  Widget _buildSceneLabel() {
    return Positioned(
      top: 100,
      left: 0,
      right: 0,
      child: Center(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: Colors.black54,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.auto_awesome, color: Colors.amber, size: 18),
              const SizedBox(width: 8),
              Text(
                _dominantScene ?? '',
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSmartComposition() {
    return IgnorePointer(
      child: CustomPaint(
        painter: SmartCompositionPainter(
          faces: _detectedFaces,
          imageSize: Size(
            _controller!.value.previewSize!.width,
            _controller!.value.previewSize!.height,
          ),
        ),
      ),
    );
  }

  Widget _buildSkeleton() {
    return IgnorePointer(
      child: CustomPaint(
        painter: SkeletonPainter(
          pose: _detectedPose,
          referencePose: _isGhostMode ? _referencePose : null,
        ),
        child: Container(),
      ),
    );
  }

  Widget _buildAiScore() {
    return Positioned(
      top: 100,
      left: 20,
      right: 20,
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.black54,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: _matchScore > 80
                    ? Colors.greenAccent
                    : Colors.yellowAccent,
                width: 2,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.auto_awesome,
                  color: _matchScore > 80
                      ? Colors.greenAccent
                      : Colors.yellowAccent,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Text(
                  "Match: ${_matchScore.toInt()}%",
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          ),
          if (_matchScore < 90 && _detectedPose != null)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Text(
                _feedbackText,
                style: const TextStyle(
                  color: Colors.white,
                  shadows: [Shadow(color: Colors.black)],
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildGestureIndicator() {
    String gestureText = '';
    IconData gestureIcon = Icons.pan_tool;

    if (_lastGestures.contains(HandGesture.raisedHand)) {
      gestureText = 'Raise Hand - Capturing!';
      gestureIcon = Icons.back_hand;
    } else if (_lastGestures.contains(HandGesture.peace)) {
      gestureText = 'Peace - Camera Switch';
      gestureIcon = Icons.vibration;
    } else if (_lastGestures.contains(HandGesture.thumbsUp)) {
      gestureText = 'Thumbs Up - Flash Toggled';
      gestureIcon = Icons.thumb_up;
    }

    return Positioned(
      top: 150,
      left: 0,
      right: 0,
      child: Center(
        child: AnimatedOpacity(
          opacity: 1.0,
          duration: const Duration(seconds: 1),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.green.withOpacity(0.8),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(gestureIcon, color: Colors.white, size: 20),
                const SizedBox(width: 8),
                Text(
                  gestureText,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildGrid() {
    return IgnorePointer(
      child: CustomPaint(
        painter: GridPainter(mode: _gridMode),
        child: Container(),
      ),
    );
  }

  Widget _buildLeveler() {
    return IgnorePointer(
      child: CustomPaint(
        painter: LevelerPainter(angle: _deviceRoll),
        child: Container(),
      ),
    );
  }

  Widget _buildCountdown() {
    return Center(
      child: Text(
        "$_countdownValue",
        style: const TextStyle(
          fontSize: 120,
          color: Colors.white,
          fontWeight: FontWeight.bold,
          shadows: [Shadow(blurRadius: 10, color: Colors.black)],
        ),
      ),
    );
  }
}

// Custom Painters
class SkeletonPainter extends CustomPainter {
  final Pose? pose;
  final Pose? referencePose;
  SkeletonPainter({this.pose, this.referencePose});

  @override
  void paint(Canvas canvas, Size size) {
    if (referencePose != null) {
      final paintRef = Paint()
        ..color = Colors.blueAccent.withOpacity(0.6)
        ..strokeWidth = 3;
      _drawPose(canvas, referencePose!, paintRef);
    }
    if (pose != null) {
      final paintUser = Paint()
        ..color = Colors.greenAccent
        ..strokeWidth = 3;
      _drawPose(canvas, pose!, paintUser);
    }
  }

  void _drawPose(Canvas canvas, Pose p, Paint paint) {
    void drawLine(PoseLandmarkType t1, PoseLandmarkType t2) {
      final l1 = p.landmarks[t1];
      final l2 = p.landmarks[t2];
      if (l1 != null &&
          l2 != null &&
          l1.likelihood > 0.5 &&
          l2.likelihood > 0.5) {
        canvas.drawLine(Offset(l1.x, l1.y), Offset(l2.x, l2.y), paint);
      }
    }

    drawLine(PoseLandmarkType.leftShoulder, PoseLandmarkType.leftElbow);
    drawLine(PoseLandmarkType.leftElbow, PoseLandmarkType.leftWrist);
    drawLine(PoseLandmarkType.rightShoulder, PoseLandmarkType.rightElbow);
    drawLine(PoseLandmarkType.rightShoulder, PoseLandmarkType.rightWrist);
    drawLine(PoseLandmarkType.leftShoulder, PoseLandmarkType.rightShoulder);
    drawLine(PoseLandmarkType.leftShoulder, PoseLandmarkType.leftHip);
    drawLine(PoseLandmarkType.rightShoulder, PoseLandmarkType.rightHip);
    drawLine(PoseLandmarkType.leftHip, PoseLandmarkType.rightHip);
    drawLine(PoseLandmarkType.leftHip, PoseLandmarkType.leftKnee);
    drawLine(PoseLandmarkType.leftKnee, PoseLandmarkType.leftAnkle);
    drawLine(PoseLandmarkType.rightHip, PoseLandmarkType.rightKnee);
    drawLine(PoseLandmarkType.rightKnee, PoseLandmarkType.rightAnkle);
  }

  @override
  bool shouldRepaint(covariant SkeletonPainter oldDelegate) => true;
}

class GridPainter extends CustomPainter {
  final int mode;
  GridPainter({required this.mode});

  @override
  void paint(Canvas canvas, Size size) {
    if (mode == 0) return;
    final paint = Paint()
      ..color = Colors.white.withOpacity(0.4)
      ..strokeWidth = 1;
    double stepW = size.width / 3;
    double stepH = size.height / 3;
    if (mode == 2) {
      stepW = size.width * 0.382;
      stepH = size.height * 0.382;
    }
    canvas.drawLine(Offset(stepW, 0), Offset(stepW, size.height), paint);
    canvas.drawLine(
      Offset(size.width - stepW, 0),
      Offset(size.width - stepW, size.height),
      paint,
    );
    canvas.drawLine(Offset(0, stepH), Offset(size.width, stepH), paint);
    canvas.drawLine(
      Offset(0, size.height - stepH),
      Offset(size.width, size.height - stepH),
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

class LevelerPainter extends CustomPainter {
  final double angle;
  LevelerPainter({required this.angle});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final isLevel = angle.abs() < 0.05;
    final color = isLevel ? Colors.greenAccent : Colors.redAccent;
    final paint = Paint()
      ..color = color
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round;

    canvas.save();
    canvas.translate(center.dx, center.dy);
    canvas.rotate(angle);
    canvas.drawCircle(Offset.zero, 5, paint..style = PaintingStyle.fill);
    canvas.drawLine(
      Offset(-size.width * 0.4, 0),
      Offset(size.width * 0.4, 0),
      paint,
    );
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant LevelerPainter oldDelegate) =>
      oldDelegate.angle != angle;
}

class ObjectLabelPainter extends CustomPainter {
  final List<DetectedObject> objects;
  final Size imageSize;
  ObjectLabelPainter({required this.objects, required this.imageSize});

  @override
  void paint(Canvas canvas, Size size) {
    final scaleX = size.width / imageSize.width;
    final scaleY = size.height / imageSize.height;

    for (final obj in objects) {
      final rect = obj.boundingBox;
      final left = rect.left * scaleX;
      final top = rect.top * scaleY;
      final width = rect.width * scaleX;
      final height = rect.height * scaleY;

      final paint = Paint()
        ..color = Colors.amber
        ..strokeWidth = 2
        ..style = PaintingStyle.stroke;

      canvas.drawRect(Rect.fromLTWH(left, top, width, height), paint);

      for (final label in obj.labels) {
        final textPainter = TextPainter(
          text: TextSpan(
            text: '${label.text} ${(label.confidence * 100).toInt()}%',
            style: const TextStyle(
              color: Colors.amber,
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ),
          textDirection: TextDirection.ltr,
        );
        textPainter.layout();

        final bgPaint = Paint()..color = Colors.black54;
        canvas.drawRRect(
          RRect.fromRectAndRadius(
            Rect.fromLTWH(left, top - 20, textPainter.width + 10, 20),
            const Radius.circular(4),
          ),
          bgPaint,
        );
        textPainter.paint(canvas, Offset(left + 5, top - 16));
      }
    }
  }

  @override
  bool shouldRepaint(covariant ObjectLabelPainter oldDelegate) => true;
}

class SmartCompositionPainter extends CustomPainter {
  final List<Face> faces;
  final Size imageSize;
  SmartCompositionPainter({required this.faces, required this.imageSize});

  @override
  void paint(Canvas canvas, Size size) {
    if (faces.isEmpty) return;

    double centerX = 0, centerY = 0;
    for (final face in faces) {
      centerX += face.boundingBox.center.dx;
      centerY += face.boundingBox.center.dy;
    }
    centerX /= faces.length;
    centerY /= faces.length;

    final scaleX = size.width / imageSize.width;
    final scaleY = size.height / imageSize.height;

    final targetX = size.width * 0.5;
    final targetY = size.height * 0.38;

    final paint = Paint()
      ..color = Colors.greenAccent.withOpacity(0.5)
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    canvas.drawLine(
      Offset(centerX * scaleX, centerY * scaleY),
      Offset(targetX, targetY),
      paint,
    );
    canvas.drawCircle(
      Offset(targetX, targetY),
      5,
      paint..style = PaintingStyle.fill,
    );

    final guidePaint = Paint()
      ..color = Colors.greenAccent.withOpacity(0.3)
      ..strokeWidth = 1;

    canvas.drawLine(
      Offset(size.width * 0.5, 0),
      Offset(size.width * 0.5, size.height),
      guidePaint,
    );
    canvas.drawLine(
      Offset(0, size.height * 0.38),
      Offset(size.width, size.height * 0.38),
      guidePaint,
    );
  }

  @override
  bool shouldRepaint(covariant SmartCompositionPainter oldDelegate) => true;
}
