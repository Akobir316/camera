import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:animation_bottom_bar/camera.dart';
import 'package:animation_bottom_bar/gallery.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations(
    [DeviceOrientation.portraitUp, DeviceOrientation.portraitDown],
  );
  final cameras = await availableCameras();
  runApp(
    MyApp(
      cameras: cameras,
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key, required this.cameras}) : super(key: key);
  final List<CameraDescription> cameras;
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Camera Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(
        cameras: cameras,
      ),
      debugShowCheckedModeBanner: false,
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({
    Key? key,
    required this.cameras,
  }) : super(key: key);
  final List<CameraDescription> cameras;
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  late double galleryBottom;
  late double galleryLeft;
  late double cameraBottom;
  late double cameraLeft;
  late double videoBottom;
  late double videoLeft;
  var size;

  late final List<Widget> _pages;
  final PageController _pageController = PageController();
  final selectStyle =
      const TextStyle(fontSize: 12, fontWeight: FontWeight.w800);
  final unSelectStyle =
      const TextStyle(fontSize: 10, fontWeight: FontWeight.w400);
  @override
  void didChangeDependencies() {
    position();
    super.didChangeDependencies();
  }

  @override
  void initState() {
    _pages = [
      const ActionsProvider(),
      CameraScreen(
        cameras: widget.cameras,
      ),
    ];

    super.initState();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void position() {
    size = MediaQuery.of(context).size;
    galleryBottom = 30;
    galleryLeft = size.width / 2 - 30;
    cameraBottom = 8;
    cameraLeft = size.width * 0.64; //size.width - 150;
    videoBottom = 8;
    videoLeft = size.width * 0.82; // - 80;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PageView.builder(
        itemCount: _pages.length,
        controller: _pageController,
        pageSnapping: false,
        allowImplicitScrolling: true,
        clipBehavior: Clip.none,
        itemBuilder: (context, index) => SizedBox(child: _pages[index]),
      ),
      bottomNavigationBar: BottomAppBar(
        child: SizedBox(
          height: 64,
          child: Stack(
            fit: StackFit.loose,
            children: [
              AnimatedPositioned(
                bottom: galleryBottom,
                left: galleryLeft,
                duration: const Duration(milliseconds: 300),
                child: InkWell(
                  borderRadius: BorderRadius.circular(30),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: galleryBottom != 8 ? 60 : 50,
                        height: galleryBottom != 8 ? 60 : 50,
                        alignment: Alignment.center,
                        child: Icon(
                          Icons.photo_size_select_actual_rounded,
                          color: Colors.white,
                          size: galleryBottom != 8 ? 30 : 24,
                        ),
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.cyan,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Gallery',
                        style: galleryBottom != 8 ? selectStyle : unSelectStyle,
                      ),
                    ],
                  ),
                  onTap: () {
                    galleryBottom = 30;
                    galleryLeft = size.width / 2 - 30;
                    cameraBottom = 8;
                    cameraLeft = size.width * 0.64;
                    videoLeft = size.width * 0.82;
                    videoBottom = 8;
                    setState(() {});

                    _pageController.animateToPage(0,
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.linear);
                  },
                ),
              ),
              AnimatedPositioned(
                bottom: cameraBottom,
                left: cameraLeft,
                duration: const Duration(milliseconds: 300),
                child: InkWell(
                  borderRadius: BorderRadius.circular(30),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: cameraBottom != 8 ? 60 : 50,
                        height: cameraBottom != 8 ? 60 : 50,
                        alignment: Alignment.center,
                        child: Icon(
                          Icons.camera_alt_rounded,
                          color: Colors.white,
                          size: cameraBottom != 8 ? 30 : 24,
                        ),
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.redAccent,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Photo',
                        style: cameraBottom != 8 ? selectStyle : unSelectStyle,
                      ),
                    ],
                  ),
                  onTap: () async {
                    cameraLeft = size.width / 2 - 30;
                    cameraBottom = 30;
                    galleryBottom = 8;
                    galleryLeft = size.width * 0.36 - 50;
                    videoLeft = size.width * 0.64;
                    videoBottom = 8;
                    setState(() {});
                    _pageController.animateToPage(1,
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.linear);
                  },
                ),
              ),
              AnimatedPositioned(
                bottom: videoBottom,
                left: videoLeft,
                duration: const Duration(milliseconds: 300),
                child: InkWell(
                  borderRadius: BorderRadius.circular(30),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: videoBottom != 8 ? 60 : 50,
                        height: videoBottom != 8 ? 60 : 50,
                        alignment: Alignment.center,
                        child: Icon(
                          Icons.videocam,
                          color: Colors.white,
                          size: videoBottom != 8 ? 30 : 24,
                        ),
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.purple,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Video',
                        style: videoBottom != 8 ? selectStyle : unSelectStyle,
                      ),
                    ],
                  ),
                  onTap: () {
                    videoLeft = size.width / 2 - 30;
                    videoBottom = 30;
                    cameraLeft = size.width * 0.36 - 50;
                    cameraBottom = 8;
                    galleryLeft = size.width * 0.06;
                    galleryBottom = 8;

                    _pageController.animateToPage(1,
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.linear);
                    setState(() {});
                  },
                ),
              ),
            ],
            clipBehavior: Clip.none,
          ),
        ),
      ),
    );
  }
}
