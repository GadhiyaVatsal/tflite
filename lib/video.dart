import 'package:chewie/chewie.dart';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

class Video extends StatefulWidget {
  @override
  _VideoState createState() => _VideoState();
}

class _VideoState extends State<Video> {
  VideoPlayerController _controller;
  ChewieController _chewieController;

  @override
  void initState() {
    super.initState();
    _controller = VideoPlayerController.network(
        'https://www.sample-videos.com/video123/mp4/720/big_buck_bunny_720p_20mb.mp4');

    _chewieController = ChewieController(
      videoPlayerController: _controller,
      aspectRatio: 16 / 9,
      // Prepare the video to be played and display the first frame
      autoInitialize: true,
      looping: true,
      // Errors can occur for example when trying to play a video
      // from a non-existent URL
      errorBuilder: (context, errorMessage) {
        return Center(
          child: Text(
            errorMessage,
            style: TextStyle(color: Colors.white),
          ),
        );
      },
    );
  }

  @override
  void dispose() {
    super.dispose();
    _controller.dispose();
    _chewieController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: EdgeInsets.all(10.0),
        child: Chewie(
          controller: _chewieController,
        ),
      ),
    );
  }
}
