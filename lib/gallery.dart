import 'dart:io';

import 'package:flutter/material.dart';
import 'package:photo_manager/photo_manager.dart';
import 'package:provider/provider.dart';

class SelectedCount extends ChangeNotifier {
  List _isSelect = [];

  void add(var img) {
    _isSelect.add(img);
    notifyListeners();
  }

  void clear() {
    _isSelect.clear();
    WidgetsBinding.instance!.addPostFrameCallback((_) {
      notifyListeners();
    });
  }

  bool contains(var img) {
    return _isSelect.contains(img);
  }

  void remove(var img) {
    _isSelect.remove(img);
    notifyListeners();
  }
}

class ActionsProvider extends StatelessWidget {
  const ActionsProvider({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) => ChangeNotifierProvider(
        create: (context) => SelectedCount(),
        child: const GalleryScreen(),
      );
}

class GalleryScreen extends StatefulWidget {
  const GalleryScreen({Key? key}) : super(key: key);

  @override
  _GalleryState createState() => _GalleryState();
}

class _GalleryState extends State<GalleryScreen>
    with AutomaticKeepAliveClientMixin<GalleryScreen> {
  // This will hold all the assets we fetched
  List<AssetEntity> assets = [];
  List<dynamic> _albums = [];
  String selectTitle = '';

  @override
  void initState() {
    // _fetchAssets();
    _fetchAssets();
    super.initState();
  }

  _fetchAssets() async {
    var result = await PhotoManager.requestPermissionExtend();
    if (result.isAuth) {
      _albums = await PhotoManager.getAssetPathList(type: RequestType.image);
      selectTitle = _albums.first.name;
      final recentAlbum = _albums.first;
      final recentAssets = await recentAlbum.getAssetListRange(
        start: 0,
        end: 500,
      );
      for (int i = 0; i < recentAssets.length; i++) {
        final a = await recentAssets[i].file;
        imgFile.add(a);
      }
      setState(() => assets = recentAssets);
    } else {}
  }

  List<File?> imgFile = [];
  _bottomSheet() {
    return showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(16),
          topRight: Radius.circular(16),
        ),
      ),
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(8),
          decoration: const BoxDecoration(),
          child: ListView.builder(
            itemCount: _albums.length,
            itemBuilder: (context, index) => ListTile(
              title: Text('${_albums[index].name}'),
              trailing: const Icon(
                Icons.chevron_right_sharp,
              ),
              onTap: () async {
                selectTitle = _albums[index].name;
                assets = await _albums[index].getAssetListRange(
                  start: 0,
                  end: 300,
                );
                imgFile.clear();
                for (int i = 0; i < assets.length; i++) {
                  final a = await assets[i].file;
                  imgFile.add(a);
                }

                Navigator.pop(context);

                setState(() {});
              },
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final model = context.read<SelectedCount>();
    model.clear();
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Padding(
          padding: const EdgeInsets.only(left: 50),
          child: TextButton(
            child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(selectTitle),
                  const SizedBox(
                    width: 10,
                  ),
                  const Icon(Icons.keyboard_arrow_down_sharp),
                ]),
            onPressed: () {
              _bottomSheet();
            },
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 50),
            child: Row(
              children: const [
                Text(
                  'Selected:',
                  style: TextStyle(
                      color: Colors.black54,
                      fontSize: 14,
                      fontWeight: FontWeight.bold),
                ),
                SizedBox(
                  width: 8,
                ),
                Counter(),
              ],
            ),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        child: GridView.builder(
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            // A grid view with 3 items per row
            crossAxisCount: 3,
            crossAxisSpacing: 10,
            mainAxisSpacing: 10,
          ),
          itemCount: imgFile.length,
          itemBuilder: (_, index) {
            return ImageView(imageFile: imgFile[index]);
          },
        ),
      ),
    );
  }

  @override
  bool get wantKeepAlive => true;
}

class Counter extends StatelessWidget {
  const Counter({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final int length = context.watch<SelectedCount>()._isSelect.length;
    return Text(
      '$length',
      style: const TextStyle(
          color: Colors.blue, fontSize: 14, fontWeight: FontWeight.bold),
    );
  }
}

class ImageView extends StatefulWidget {
  const ImageView({
    Key? key,
    required this.imageFile,
  }) : super(key: key);
  final File? imageFile;
  @override
  _ImageViewState createState() => _ImageViewState();
}

class _ImageViewState extends State<ImageView> {
  @override
  Widget build(BuildContext context) {
    final _isSelect = context.read<SelectedCount>();
    return InkWell(
      onTap: () {
        if (_isSelect.contains(widget.imageFile)) {
          _isSelect.remove(widget.imageFile);
        } else {
          _isSelect.add(widget.imageFile);
        }

        setState(() {});
      },
      child: Stack(
        children: [
          Positioned.fill(
            child: ClipRRect(
              child: Image.file(widget.imageFile as File, fit: BoxFit.cover),
              borderRadius: BorderRadius.circular(4),
            ),
          ),
          Align(
            alignment: Alignment.topRight,
            child: Container(
              alignment: Alignment.center,
              margin: const EdgeInsets.all(8),
              width: 25,
              height: 25,
              decoration: BoxDecoration(
                color: (_isSelect.contains(widget.imageFile))
                    ? Colors.blue
                    : Colors.transparent,
                border: Border.all(color: Colors.white, width: 2.0),
                shape: BoxShape.circle,
              ),
              child: (_isSelect.contains(widget.imageFile))
                  ? const Icon(Icons.check, size: 14, color: Colors.white)
                  : const SizedBox.shrink(),
            ),
          ),
        ],
      ),
    );
  }
}
/* 
class AssetThumbnail extends StatefulWidget {
  const AssetThumbnail({
    Key? key,
    required this.asset,
  }) : super(key: key);

  final AssetEntity asset;

  @override
  State<AssetThumbnail> createState() => _AssetThumbnailState();
}

class _AssetThumbnailState extends State<AssetThumbnail> {
  List isSelect = [];
  @override
  Widget build(BuildContext context) {
    // We're using a FutureBuilder since thumbData is a future
    return FutureBuilder<Uint8List?>(
      future: widget.asset.thumbData,
      builder: (_, snapshot) {
        final bytes = snapshot.data;
        // If we have no data, display a spinner
        if (bytes == null) {
          return const Center();
        }
        // If there's data, display it as an image
        return InkWell(
          onTap: () {
            if (isSelect.contains(index)) {
              isSelect.remove(index);
            } else {
              isSelect.add(index);
            }

            setState(() {});
          },
          child: Stack(
            children: [
              Positioned.fill(
                child: Image.memory(bytes, fit: BoxFit.cover),
              ),
              Align(
                alignment: Alignment.topRight,
                child: Container(
                  alignment: Alignment.center,
                  margin: const EdgeInsets.all(8),
                  width: 25,
                  height: 25,
                  decoration: BoxDecoration(
                    color: (isSelect.contains(index))
                        ? Colors.blue
                        : Colors.transparent,
                    border: Border.all(color: Colors.white, width: 2.0),
                    shape: BoxShape.circle,
                  ),
                  child: (isSelect.contains(index))
                      ? Text(
                          '${isSelect.length}',
                          style: const TextStyle(color: Colors.white),
                        )
                      : const SizedBox.shrink(),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
} */
/*
class ImageScreen extends StatelessWidget {
  const ImageScreen({
    Key? key,
    required this.imageFile,
  }) : super(key: key);

  final Future<File?> imageFile;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.black,
      alignment: Alignment.center,
      child: FutureBuilder<File?>(
        future: imageFile,
        builder: (_, snapshot) {
          final file = snapshot.data;
          if (file == null) return Container();
          return Image.file(file);
        },
      ),
    );
  }
}

class VideoScreens extends StatefulWidget {
  const VideoScreens({
    Key? key,
    required this.videoFile,
  }) : super(key: key);

  final Future<File?> videoFile;

  @override
  _VideoScreenState createState() => _VideoScreenState();
}

class _VideoScreenState extends State<VideoScreens> {
  late VideoPlayerController _controller;
  bool initialized = false;

  @override
  void initState() {
    _initVideo();
    super.initState();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  _initVideo() async {
    final video = await widget.videoFile;
    _controller = VideoPlayerController.file(video!)
      // Play the video again when it ends
      ..setLooping(true)
      // initialize the controller and notify UI when done
      ..initialize().then((_) => setState(() => initialized = true));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: initialized
          // If the video is initialized, display it
          ? Scaffold(
              body: Center(
                child: AspectRatio(
                  aspectRatio: _controller.value.aspectRatio,
                  // Use the VideoPlayer widget to display the video.
                  child: VideoPlayer(_controller),
                ),
              ),
              floatingActionButton: FloatingActionButton(
                onPressed: () {
                  // Wrap the play or pause in a call to `setState`. This ensures the
                  // correct icon is shown.
                  setState(() {
                    // If the video is playing, pause it.
                    if (_controller.value.isPlaying) {
                      _controller.pause();
                    } else {
                      // If the video is paused, play it.
                      _controller.play();
                    }
                  });
                },
                // Display the correct icon depending on the state of the player.
                child: Icon(
                  _controller.value.isPlaying ? Icons.pause : Icons.play_arrow,
                ),
              ),
            )
          // If the video is not yet initialized, display a spinner
          : const Center(child: CircularProgressIndicator()),
    );
  }
}
 */