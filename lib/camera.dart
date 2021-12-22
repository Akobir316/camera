import 'dart:async';

import 'dart:io';

import 'package:animation_bottom_bar/video_preview.dart';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:path_provider/path_provider.dart';
import 'package:video_player/video_player.dart';

class CameraScreen extends StatefulWidget {
  List<CameraDescription>? cameras;
  bool isVideo;
  CameraScreen({
    Key? key,
    this.cameras,
    this.isVideo = false,
  }) : super(key: key);

  @override
  _CameraScreenState createState() => _CameraScreenState();
}

class _CameraScreenState extends State<CameraScreen>
    with WidgetsBindingObserver {
  late CameraController _controller;
  VideoPlayerController? videoController;
  late Future<void> _initializeControllerFuture;
  int selectedCamera = 0;
  List<File> capturedImages = [];
  XFile? pictureImage;
  File? _videoFile;
  bool _isRecordingInProgress = false;
  initializeCamera(int cameraIndex) async {
    _controller =
        CameraController(widget.cameras![cameraIndex], ResolutionPreset.max);
    _initializeControllerFuture = _controller.initialize();
  }

  @override
  void initState() {
    initializeCamera(selectedCamera);
    super.initState();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _startVideoPlayer() async {
    if (_videoFile != null) {
      Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => VideoPreview(
              videoFile: _videoFile,
            ),
          ));
    }
  }

  int minRecordingVideo = 0;

  Future<void> startVideoRecording() async {
    final CameraController? cameraController = _controller;

    if (_controller.value.isRecordingVideo) {
      // A recording has already started, do nothing.
      return;
    }

    try {
      await cameraController!.startVideoRecording();

      _isRecordingInProgress = true;

      setState(() {});
    } on CameraException catch (e) {
      print('Error starting video recording: $e');
    }
  }

  Future<XFile?> stopVideoRecording() async {
    if (!_controller.value.isRecordingVideo) {
      // Recording is already is stopped state
      return null;
    }

    try {
      XFile file = await _controller.stopVideoRecording();
      int currentUnix = DateTime.now().millisecondsSinceEpoch;
      if (minRecordingVideo + 3050 >= currentUnix) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            duration: const Duration(seconds: 2),
            behavior: SnackBarBehavior.floating,
            margin: const EdgeInsets.fromLTRB(24, 0, 24, 60),
            backgroundColor: Colors.black.withOpacity(0.5),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            padding: const EdgeInsets.all(10),
            content: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  alignment: Alignment.center,
                  width: 16,
                  height: 16,
                  decoration: const BoxDecoration(
                    color: Colors.red,
                    shape: BoxShape.circle,
                  ),
                  child: const FaIcon(
                    FontAwesomeIcons.times,
                    color: Colors.white,
                    size: 14,
                  ),
                ),
                const SizedBox(
                  width: 5,
                ),
                const Text(
                  'Please record at least 3 seconds',
                  style: TextStyle(fontSize: 12, color: Colors.white),
                )
              ],
            ),
          ),
        );
        _isRecordingInProgress = false;
        setState(() {});
      } else {
        File videoFile = File(file.path);

        final directory = await getApplicationDocumentsDirectory();

        String fileFormat = videoFile.path.split('.').last;

        _videoFile = await videoFile.copy(
          '${directory.path}/$currentUnix.$fileFormat',
        );
        _isRecordingInProgress = false;
        setState(() {});
        _startVideoPlayer();
      }

      // return file;
    } on CameraException catch (e) {
      //  print('Error stopping video recording: $e');
      return null;
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    final CameraController? cameraController = _controller;

    // App state changed before we got the chance to initialize.
    if (cameraController == null || !cameraController.value.isInitialized) {
      return;
    }

    if (state == AppLifecycleState.inactive) {
      cameraController.dispose();
    }
  }

/*   Future<void> pauseVideoRecording() async {
    if (!_controller.value.isRecordingVideo) {
      // Video recording is not in progress
      return;
    }

    try {
      await _controller.pauseVideoRecording();
    } on CameraException catch (e) {
      print('Error pausing video recording: $e');
    }
  } */

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Stack(
        children: [
          SizedBox(
            width: double.infinity,
            child: FutureBuilder<void>(
                future: _initializeControllerFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.done) {
                    return CameraPreview(_controller);
                  } else {
                    return const Center(
                      child: CircularProgressIndicator(),
                    );
                  }
                }),
          ),
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Align(
                    alignment: Alignment.topLeft,
                    child: Container(
                      width: 32,
                      height: 32,
                      alignment: Alignment.center,
                      child: const FaIcon(
                        FontAwesomeIcons.times,
                        color: Colors.white,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.3),
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
                ),
                InkWell(
                  borderRadius: const BorderRadius.all(Radius.circular(16)),
                  child: Container(
                    width: 32,
                    height: 32,
                    child: const Icon(
                      Icons.cached_outlined,
                      color: Colors.white,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.3),
                      shape: BoxShape.circle,
                    ),
                  ),
                  onTap: () {
                    /*  if (widget.cameras!.length > 1) {
                      setState(() {
                        selectedCamera =
                            selectedCamera == 0 ? 1 : 0; // Переключение камеры
                        initializeCamera(selectedCamera);
                      });
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                        content: Text('Дополнительная камера не найдена'),
                        duration: Duration(seconds: 2),
                      ));
                    } */
                  },
                ),
                const SizedBox(
                  width: 24,
                ),
                Container(
                  width: 32,
                  height: 32,
                  child: const Icon(
                    Icons.flash_off_rounded,
                    color: Colors.white,
                    size: 18,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.3),
                    shape: BoxShape.circle,
                  ),
                ),
              ],
            ),
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: SizedBox(
              width: 50,
              height: 50,
              child: FloatingActionButton(
                  heroTag: "btn1",
                  backgroundColor: Colors.transparent,
                  onPressed: () async {
                    pictureImage = await _controller.takePicture();
                    if (pictureImage != null) {
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                        backgroundColor: Colors.white,
                        duration: const Duration(minutes: 5),
                        dismissDirection: DismissDirection.down,
                        content: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            TextButton(
                              onPressed: () {
                                Navigator.pop(context);
                                ScaffoldMessenger.of(context)
                                    .hideCurrentSnackBar();
                              },
                              child: const Text(
                                'Back',
                                style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.black,
                                    fontWeight: FontWeight.bold),
                              ),
                            ),
                            ElevatedButton(
                              onPressed: () {},
                              child: const Text(
                                'Done',
                                style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold),
                              ),
                              style: ButtonStyle(
                                backgroundColor:
                                    MaterialStateProperty.all(Colors.redAccent),
                                shape: MaterialStateProperty.all(
                                  RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ));
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => Scaffold(
                            appBar: AppBar(
                              leading: IconButton(
                                icon: const Icon(
                                  Icons.arrow_back,
                                  color: Colors.black,
                                ),
                                onPressed: () {
                                  ScaffoldMessenger.of(context)
                                      .hideCurrentSnackBar();
                                  Navigator.pop(context);
                                },
                              ),
                              backgroundColor: Colors.white,
                              elevation: 0,
                            ),
                            body: SizedBox(
                              width: double.infinity,
                              child: Image.file(
                                File(pictureImage!.path),
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                        ),
                      );
                    }
                  }),
            ),
          ),
          FloatingActionButton(
            heroTag: "btn2",
            onPressed: _isRecordingInProgress
                ? stopVideoRecording
                : startVideoRecording,
            child: _isRecordingInProgress
                ? const Icon(Icons.stop)
                : const Icon(Icons.play_arrow),
          ),
          _isRecordingInProgress
              ? Align(
                  alignment: Alignment.bottomCenter,
                  child: VideoTimer(
                    isStart: true,
                  ),
                )
              : const SizedBox.shrink(),
        ],
      ),
    );
  }
}

class VideoTimer extends StatefulWidget {
  bool isStart;
  VideoTimer({
    Key? key,
    this.isStart = false,
  }) : super(key: key);

  @override
  _VideoTimerState createState() => _VideoTimerState();
}

class _VideoTimerState extends State<VideoTimer>
    with SingleTickerProviderStateMixin {
  String displayTimer = "00:00";
  late final AnimationController _controller;
  late final Animation<double> _animation;
  late final CurvedAnimation _curve;
  Stopwatch swatch = Stopwatch();
  void startTimer() {
    Timer(const Duration(seconds: 1), keepRunning);
  }

  void keepRunning() {
    if (swatch.isRunning) {
      startTimer();
    }
    setState(() {
      displayTimer =
          (swatch.elapsed.inMinutes % 60).toString().padLeft(2, '0') +
              ":" +
              (swatch.elapsed.inSeconds % 60).toString().padLeft(2, '0');
    });
  }

  @override
  void initState() {
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(microseconds: 500),
    );
    _curve = CurvedAnimation(parent: _controller, curve: Curves.easeIn);

    _animation = Tween(
      begin: 1.0,
      end: 0.0,
    ).animate(_curve);

    if (widget.isStart) {
      swatch.start();
      startTimer();
      _controller.animateTo(1.0).then<TickerFuture>((value) =>
          _controller.animateBack(0.0)
            ..whenComplete(() => _controller.repeat(
                reverse: true, period: const Duration(milliseconds: 500))));
    }
    Future.delayed(const Duration(seconds: 15))
        .then((_) => _CameraScreenState().stopVideoRecording());
    super.initState();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Text(
          '15 secs max',
          style: TextStyle(fontSize: 10, color: Colors.white),
        ),
        const SizedBox(
          height: 8,
        ),
        Container(
          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 18),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(6),
            color: Colors.black.withOpacity(0.5),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              FadeTransition(
                  opacity: _animation,
                  child:
                      Icon(Icons.circle, color: Colors.red.shade700, size: 14)),
              const SizedBox(
                width: 5,
              ),
              Text(
                displayTimer,
                style: const TextStyle(fontSize: 14, color: Colors.white),
              )
            ],
          ),
        ),
        const SizedBox(
          height: 60,
        ),
      ],
    );
  }
}
