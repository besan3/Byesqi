import 'dart:io';

import 'package:flick_video_player/flick_video_player.dart';
import 'package:flutter/material.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:streamit_flutter/main.dart';
import 'package:streamit_flutter/models/ResumeVideoModel.dart';
import 'package:streamit_flutter/network/RestApis.dart';
import 'package:streamit_flutter/utils/Constants.dart';
import 'package:video_player/video_player.dart';
import 'package:visibility_detector/visibility_detector.dart';

class FileVideoPlayerWidget extends StatefulWidget {
  final String videoUrl;
  final String videoImage;
  final String videoTitle;
  final bool isFromLocalStorage;
  final String videoId;
  final bool hasResumePauseVideo;
  final String videoDuration;

  @override
  _FileVideoPlayerWidgetState createState() => _FileVideoPlayerWidgetState();

  FileVideoPlayerWidget({
    Key? key,
    required this.videoUrl,
    this.videoImage = blankImage,
    this.videoTitle = "",
    this.isFromLocalStorage = false,
    required this.videoId,
    this.hasResumePauseVideo = false,
    required this.videoDuration,
  }) : super(key: key);
}

class _FileVideoPlayerWidgetState extends State<FileVideoPlayerWidget> {
  late FlickManager flickManager;
  int lastWatchDuration = 0;

  @override
  void initState() {
    if (appStore.isLogging && appStore.userContinueWatchData[widget.videoId] != null) {
      lastWatchDuration = int.parse(appStore.userContinueWatchData[widget.videoId]["watchedTime"].toString().validate(value: "0"));
    }
    super.initState();
    if (widget.isFromLocalStorage) {
      flickManager = FlickManager(
        autoPlay: false,
        videoPlayerController: VideoPlayerController.file(File(widget.videoUrl)),
      );
    } else {
      flickManager = FlickManager(
        autoPlay: false,
        videoPlayerController: VideoPlayerController.network(widget.videoUrl)
          // ..initialize().then((value) {
          //   if (appStore.isLogging) {
          //     // showResumeVideoDialog();
          //   }
          // }),
      );
    }
  }

  void storeLastVideoMoment() async {
    final duration = await getVideoLastDuration.then((value) => value?.inMilliseconds.toString());
    ResumeVideoModel _resumeVideoModel = ResumeVideoModel()
      ..postId = widget.videoId
      ..watchedTime = duration
      ..watchedTotalTime = widget.videoDuration
      ..watchedTimePercentage = (duration.toDouble() / 100).toString();

    await saveVideoContinueWatch(videoData: _resumeVideoModel).then((value) {
      getVideoContinueWatch().then((data) => appStore.userContinueWatchData.addAll(data)).catchError(print);
    }).catchError((e) {
      toast(language?.somethingWentWrong);
      log("=====>Error ${e.toString()}<=====");
    });
  }

  Future<Duration?> get getVideoLastDuration async {
    return flickManager.flickVideoManager?.videoPlayerController?.position;
  }

  // void showResumeVideoDialog() {
  //   showDialog(
  //     context: context,
  //     builder: (ctx) {
  //       return AlertDialog(
  //         title: Text(language!.resumeVideo, style: boldTextStyle()),
  //         content: Text(language!.doYouWishTo),
  //         actions: [
  //           TextButton(
  //             onPressed: () {
  //               flickManager.flickControlManager?.seekTo(Duration(seconds: 0));
  //               flickManager.flickControlManager?.play();
  //               finish(ctx);
  //             },
  //             child: Text(language!.startOver, style: primaryTextStyle()),
  //           ),
  //           TextButton(
  //             onPressed: () {
  //               flickManager.flickControlManager?.seekTo(Duration(milliseconds: lastWatchDuration));
  //               flickManager.flickControlManager?.play();
  //               finish(ctx);
  //             },
  //             child: Text(language!.resume, style: primaryTextStyle()),
  //           )
  //         ],
  //       );
  //     },
  //   );
  // }

  @override
  void dispose() {
    if (appStore.isLogging && !widget.isFromLocalStorage) storeLastVideoMoment();
    flickManager.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return VisibilityDetector(
      key: ObjectKey(flickManager),
      onVisibilityChanged: (visibility) {
        if (visibility.visibleFraction == 0 && this.mounted) {
          flickManager.flickControlManager?.autoPause();
        } else if (visibility.visibleFraction == 1) {
          flickManager.flickControlManager?.autoResume();
        }
      },
      child: FlickVideoPlayer(
        flickManager: flickManager,
        flickVideoWithControls: FlickVideoWithControls(
          closedCaptionTextStyle: TextStyle(fontSize: 8),
          controls: FlickPortraitControls(),
        ),
        flickVideoWithControlsFullscreen: FlickVideoWithControls(
          videoFit: BoxFit.contain,
          controls: FlickLandscapeControls(),
        ),
      ),
    );
  }
}
