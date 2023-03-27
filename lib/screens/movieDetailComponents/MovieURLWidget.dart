import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:streamit_flutter/components/FileVideoPlayerWidget.dart';
import 'package:streamit_flutter/models/ResumeVideoModel.dart';
import 'package:streamit_flutter/utils/Common.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';

import '../../main.dart';

// ignore: must_be_immutable
class MovieURLWidget extends StatefulWidget {
  static String tag = '/MovieURLWidget';

  String? url;
  final String? title;
  final String? image;
  final String videoId;
  final String videoDuration;

  MovieURLWidget(
    this.url, {
    this.title,
    this.image,
    required this.videoId,
    required this.videoDuration,
  });

  @override
  MovieURLWidgetState createState() => MovieURLWidgetState();
}

class MovieURLWidgetState extends State<MovieURLWidget> {
  bool isYoutubeUrl = true;
  YoutubePlayerController? _controller;

  @override
  void initState() {
    super.initState();
    init();
  }

  bool get isMovieFromGoogleDriveLink => widget.url.validate().startsWith("https://drive.google.com");

  Future<void> init() async {
    isYoutubeUrl = widget.url.validate().isYoutubeUrl;
    if (isYoutubeUrl) {
      _controller = YoutubePlayerController(
        initialVideoId: widget.url.toYouTubeId(),
        flags: const YoutubePlayerFlags(),
      );
    }
  }

  @override
  void setState(fn) {
    if (mounted) super.setState(fn);
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return isYoutubeUrl
        ? Observer(builder: (context) {
            return SizedBox(
              width: context.width(),
              height: appStore.hasInFullScreen ? context.height() - context.statusBarHeight : null,
              child: YoutubePlayerBuilder(
                player: YoutubePlayer(
                  controller: _controller!,
                  onReady: () {
                    //
                  },
                  onEnded: (data) {
                    //
                  },
                ),
                onEnterFullScreen: () {
                  appStore.setToFullScreen(true);
                },
                onExitFullScreen: () {
                  appStore.setToFullScreen(false);
                },
                builder: (context, player) {
                  return player;
                },
              ),
            );
          })
        : widget.url.validate().isVideoPlayerFile
            ? FileVideoPlayerWidget(
                videoUrl: widget.url.validate(),
                videoImage: widget.image.validate(),
                videoTitle: widget.title.validate(),
                videoId: widget.videoId,
                videoDuration: widget.videoDuration,
              )
            : isMovieFromGoogleDriveLink
                ? SizedBox(
                    width: context.width(),
                    height: appStore.hasInFullScreen ? context.height() - context.statusBarHeight : context.height() * 0.3,
                    child: Stack(
                      children: [
                        WebView(
                          initialUrl: Uri.dataFromString(movieEmbedCode, mimeType: "text/html").toString(),
                          javascriptMode: JavascriptMode.unrestricted,
                          onWebViewCreated: (controller) {},
                        ),
                        Positioned(
                          bottom: 0,
                          right: 0,
                          child: IconButton(
                            onPressed: () {
                              if (appStore.hasInFullScreen) {
                                appStore.setToFullScreen(false);
                              } else {
                                appStore.setToFullScreen(true);
                              }
                            },
                            icon: Icon(appStore.hasInFullScreen ? Icons.fullscreen_exit : Icons.fullscreen_sharp),
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  )
                : SizedBox(
                    width: context.width(),
                    height: appStore.hasInFullScreen ? context.height() - context.statusBarHeight : null,
                    child: Stack(
                      children: [
                        WebView(
                          initialUrl: widget.url,
                          javascriptMode: JavascriptMode.unrestricted,
                          onWebResourceError: (e) {
                            log(e.toString());
                          },
                        ),
                        Positioned(
                          bottom: 0,
                          right: 0,
                          child: IconButton(
                            onPressed: () {
                              if (appStore.hasInFullScreen) {
                                appStore.setToFullScreen(false);
                              } else {
                                appStore.setToFullScreen(true);
                              }
                            },
                            icon: Icon(appStore.hasInFullScreen ? Icons.fullscreen_exit : Icons.fullscreen_sharp),
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  );
  }

  String get movieEmbedCode => '''<html>
      <head>
      <script src="https://ajax.googleapis.com/ajax/libs/jquery/2.1.1/jquery.min.js"></script>
      </head>
      <body style="background-color: #000000;">
        <iframe></iframe>
      </body>
      <script>
        \$(function(){
        \$('iframe').attr('src','${widget.url.validate()}');
        \$('iframe').css('border','none');
        \$('iframe').attr('width','100%');
        \$('iframe').attr('height','100%');
        \$(document).ready(function(){
              \$(".ndfHFb-c4YZDc-Wrql6b").hide();
            });
        });
      </script>
    </html> ''';
}
