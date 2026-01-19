import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import '../../../core/models/photo_model.dart';
import 'dart:async';
import 'dart:math' as math;
import 'package:sensors_plus/sensors_plus.dart';

class MagicCameraScreen extends StatefulWidget {
  final PhotoModel? photo;

  const MagicCameraScreen({super.key, this.photo});

  @override
  State<MagicCameraScreen> createState() => _MagicCameraScreenState();
}

class _MagicCameraScreenState extends State<MagicCameraScreen> with WidgetsBindingObserver {
  CameraController? _controller;
  List<CameraDescription> _cameras = [];
  bool _isInit = false;
  double _opacity = 0.5;
  
  // Pro Features State
  int _gridMode = 0; // 0: Off, 1: Thirds, 2: Golden
  int _timerDuration = 0;
  FlashMode _flashMode = FlashMode.auto;
  bool _isCountingDown = false;
  int _countdownValue = 0;

  // V2.1 Features (Zoom, Leveler, Split)
  double _currentZoom = 1.0;
  double _minZoom = 1.0;
  double _maxZoom = 1.0;
  double _scaleFactorBase = 1.0; // For pinch gesture
  
  bool _isSplitMode = false;
  bool _isLevelerActive = false;
  double _deviceRoll = 0.0; // Rotation around Z/Y axis
  StreamSubscription? _sensorSubscription;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _initCamera();
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
        _cameras.first,
        ResolutionPreset.high,
        enableAudio: false,
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

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _controller?.dispose();
    _sensorSubscription?.cancel();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    final CameraController? cameraController = _controller;
    if (cameraController == null || !cameraController.value.isInitialized) {
      return;
    }
    if (state == AppLifecycleState.inactive) {
      cameraController.dispose();
    } else if (state == AppLifecycleState.resumed) {
      _initCamera();
    }
  }

  // --- Toggles ---
  void _toggleGrid() => setState(() => _gridMode = (_gridMode + 1) % 3);
  void _toggleTimer() => setState(() => _timerDuration = _timerDuration == 0 ? 3 : (_timerDuration == 3 ? 10 : 0));
  
  void _toggleSplit() {
    setState(() {
      _isSplitMode = !_isSplitMode;
    });
  }

  void _toggleLeveler() {
    setState(() {
      _isLevelerActive = !_isLevelerActive;
    });

    if (_isLevelerActive) {
      _sensorSubscription = accelerometerEventStream().listen((AccelerometerEvent event) {
        // Calculate basic roll (tilt left/right)
        // atan2(x, y) works for portrait mode to detect Z rotation relative to gravity
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

  Future<void> _toggleFlash() async {
    if (_controller == null) return;
    FlashMode newMode;
    switch (_flashMode) {
      case FlashMode.auto: newMode = FlashMode.off; break;
      case FlashMode.off: newMode = FlashMode.always; break;
      default: newMode = FlashMode.auto;
    }
    try {
      await _controller!.setFlashMode(newMode);
      setState(() => _flashMode = newMode);
    } catch (e) { debugPrint("Flash error: $e"); }
  }

  // --- Zoom Logic ---
  void _handleScaleStart(ScaleStartDetails details) {
    _scaleFactorBase = _currentZoom;
  }

  Future<void> _handleScaleUpdate(ScaleUpdateDetails details) async {
     double newZoom = _scaleFactorBase * details.scale;
     newZoom = newZoom.clamp(_minZoom, _maxZoom); // Clamp
     
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
      final image = await _controller!.takePicture();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Photo saved to ${image.path}')));
      }
    } catch (e) {
      debugPrint("Error taking picture: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!_isInit || _controller == null) return const Scaffold(backgroundColor: Colors.black, body: Center(child: CircularProgressIndicator(color: Colors.white)));

    // Layout: If SplitMode, Row/Column. Else Stack.
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        fit: StackFit.expand,
        children: [
          // Content
          _isSplitMode ? _buildSplitView() : _buildOverlayView(),

          // Common Overlays
          if (_gridMode != 0) Positioned.fill(child: _buildGrid()),
          if (_isLevelerActive) Positioned.fill(child: _buildLeveler()),
          
          // UI Controls
          _buildTopControls(),
          _buildBottomControls(),
          
          if (_isCountingDown) _buildCountdown(),
        ],
      ),
    );
  }

  Widget _buildOverlayView() {
    return GestureDetector(
      onScaleStart: _handleScaleStart,
      onScaleUpdate: _handleScaleUpdate,
      child: Stack(
        fit: StackFit.expand,
        children: [
          CameraPreview(_controller!),
          if (widget.photo != null)
            Opacity(
              opacity: _opacity,
              child: Image.network(widget.photo!.url, fit: BoxFit.cover),
            ),
        ],
      ),
    );
  }
  
  Widget _buildSplitView() {
    return Column(
      children: [
        Expanded(
          child: widget.photo != null 
              ? Image.network(widget.photo!.url, fit: BoxFit.cover, width: double.infinity)
              : Container(color: Colors.black, child: const Center(child: Text("No Reference Photo", style: TextStyle(color: Colors.white)))),
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

  Widget _buildCountdown() {
      return Center(
        child: Text(
          "$_countdownValue",
          style: const TextStyle(fontSize: 120, color: Colors.white, fontWeight: FontWeight.bold, shadows: [Shadow(blurRadius: 10, color: Colors.black)]),
        ),
      );
  }

  Widget _buildTopControls() {
    return Positioned(
      top: 50, left: 10, right: 10,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(color: Colors.black45, borderRadius: BorderRadius.circular(30)),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            IconButton(icon: const Icon(Icons.close, color: Colors.white), onPressed: () => Navigator.pop(context)),
            IconButton(icon: Icon(_getFlashIcon(), color: Colors.white), onPressed: _toggleFlash),
            IconButton(icon: Icon(_gridMode == 0 ? Icons.grid_off : Icons.grid_on, color: _gridMode == 0 ? Colors.white54 : Colors.yellowAccent), onPressed: _toggleGrid),
            IconButton(icon: Icon(_timerDuration == 0 ? Icons.timer_off : (_timerDuration == 3 ? Icons.timer_3 : Icons.timer_10), color: _timerDuration == 0 ? Colors.white54 : Colors.yellowAccent), onPressed: _toggleTimer),
            
            // New Toggles
            IconButton(
              icon: Icon(Icons.screen_rotation, color: _isLevelerActive ? Colors.yellowAccent : Colors.white54),
              onPressed: _toggleLeveler,
            ),
             IconButton(
              icon: Icon(Icons.vertical_split, color: _isSplitMode ? Colors.yellowAccent : Colors.white54),
              onPressed: _toggleSplit,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomControls() {
    return Positioned(
      bottom: 40, left: 20, right: 20,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
           // Control Label
           if (_isSplitMode) 
            const Padding(padding: EdgeInsets.only(bottom: 10), child: Text("Split Mode", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)))
           else if (!_isCountingDown)
            const Padding(padding: EdgeInsets.only(bottom: 10), child: Text("Align subject with ghost", style: TextStyle(color: Colors.white70))),

           // Opacity Slider only in Overlay Mode
           if (!_isSplitMode)
             Row(
                children: [
                  const Icon(Icons.opacity, color: Colors.white, size: 20),
                  Expanded(child: Slider(value: _opacity, min: 0.1, max: 0.9, activeColor: Colors.yellowAccent, inactiveColor: Colors.white24, onChanged: (val) => setState(() => _opacity = val))),
                ],
             ),
             
           const SizedBox(height: 10),
           FloatingActionButton(
             onPressed: _takePicture,
             backgroundColor: Colors.white,
             child: const Icon(Icons.camera, color: Colors.black, size: 36),
           ),
        ],
      ),
    );
  }

  IconData _getFlashIcon() {
     switch (_flashMode) {
      case FlashMode.off: return Icons.flash_off;
      case FlashMode.auto: return Icons.flash_auto;
      case FlashMode.always: return Icons.flash_on;
      default: return Icons.flash_auto;
     }
  }

  Widget _buildGrid() {
    return IgnorePointer(child: CustomPaint(painter: GridPainter(mode: _gridMode), child: Container()));
  }
  
  Widget _buildLeveler() {
    return IgnorePointer(child: CustomPaint(painter: LevelerPainter(angle: _deviceRoll), child: Container()));
  }
}

class GridPainter extends CustomPainter {
  final int mode; 
  GridPainter({required this.mode});

  @override
  void paint(Canvas canvas, Size size) {
    if (mode == 0) return;
    final paint = Paint()..color = Colors.white.withOpacity(0.4)..strokeWidth = 1..style = PaintingStyle.stroke;
    
    double stepW = size.width / 3;
    double stepH = size.height / 3;
    if (mode == 2) { 
         // Golden ratio approx
         stepW = size.width * 0.382;
         stepH = size.height * 0.382;
    }

    canvas.drawLine(Offset(stepW, 0), Offset(stepW, size.height), paint);
    canvas.drawLine(Offset(size.width - stepW, 0), Offset(size.width - stepW, size.height), paint);
    canvas.drawLine(Offset(0, stepH), Offset(size.width, stepH), paint);
    canvas.drawLine(Offset(0, size.height - stepH), Offset(size.width, size.height - stepH), paint);
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
    final len = size.width * 0.4; // Line length
    final isLevel = angle.abs() < 0.05; // ~3 degrees tolerance
    final color = isLevel ? Colors.greenAccent : Colors.redAccent;
    final paint = Paint()..color = color..strokeWidth = 3..style = PaintingStyle.stroke..strokeCap = StrokeCap.round;

    canvas.save();
    canvas.translate(center.dx, center.dy);
    canvas.rotate(angle); 
    
    // Draw crosshair center
    canvas.drawCircle(Offset.zero, 5, paint..style = PaintingStyle.fill);
    
    // Draw horizon line
    canvas.drawLine(Offset(-len, 0), Offset(len, 0), paint);
    
    // Draw guide ticks
    final tickPaint = Paint()..color = Colors.white.withOpacity(0.5)..strokeWidth = 1;
    canvas.drawLine(Offset(-len, -10), Offset(-len, 10), tickPaint);
    canvas.drawLine(Offset(len, -10), Offset(len, 10), tickPaint);
    
    canvas.restore();
  }
  @override
  bool shouldRepaint(covariant LevelerPainter oldDelegate) => oldDelegate.angle != angle;
}
