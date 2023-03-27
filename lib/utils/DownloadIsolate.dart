import 'dart:io';
import 'dart:isolate';

import 'package:dio/dio.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:streamit_flutter/models/DownloadData.dart';
import 'package:streamit_flutter/models/MovieData.dart';
import 'package:streamit_flutter/store/AppStore.dart';
import 'package:streamit_flutter/utils/Common.dart';
import 'package:streamit_flutter/utils/Constants.dart';

class DownloadFile {
  static Dio _dio = Dio();

  static Future<void> downloadFileFromUrl(String url, {MovieData? movieData, Episode? episodeData}) async {
    AppStore appStore = AppStore();
    Isolate.spawn(getFileFromUrl, url).then((value) async {
      final _localPath = await prepareSaveDir();
      final savedDir = Directory(_localPath);
      bool hasExisted = await savedDir.exists();
      if (!hasExisted) {
        savedDir.create();
      }
      appStore.setDownloading(false);
      appStore.setDownloadPercentage(0);
      DownloadData data = DownloadData();
      data.id = movieData != null ? movieData.id! : episodeData!.id!;
      data.title = movieData != null ? movieData.title! : episodeData!.title!;
      data.image = movieData != null ? movieData.image! : episodeData!.image!;
      data.description = movieData != null ? movieData.description! : episodeData!.description!;
      data.duration = movieData != null ? movieData.runTime! : episodeData!.runTime!;
      data.filePath = movieData != null ? "${savedDir.path}/${movieData.file!.split('/').last}" : "${savedDir.path}/${episodeData!.file!.split('/').last}";
      data.userId = getIntAsync(USER_ID);
      addOrRemoveFromLocalStorage(data);
    });
  }

  static void getFileFromUrl(String path) async {
    final _localPath = await prepareSaveDir();
    final savedDir = Directory("$_localPath/downloads/");
    bool hasExisted = await savedDir.exists();
    if (!hasExisted) {
      savedDir.create();
    }
    DownloadFile._dio.download(path, savedDir).then((value) {
      print("File Downloaded");
    }).catchError((e) {
      print(("=====>Download File error : ${e.toString()}<======"));
    });
  }
}
