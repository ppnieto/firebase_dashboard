import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_dashboard/util.dart';
import 'package:flutter/material.dart';

class ImageFromStorage extends StatelessWidget {
  final String? url;
  final String? path;
  final BoxFit? fit;
  final double? height;
  final double? width;
  final Alignment alignment;

  const ImageFromStorage(
      {Key? key,
      this.url,
      this.path,
      this.fit,
      this.height,
      this.width,
      this.alignment = Alignment.center})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (path != null) {
      return FutureBuilder(
          future: DashboardUtils.getUrlFromStoragePath(path!),
          builder: (context, AsyncSnapshot<String> snapshot) {
            if (!snapshot.hasData)
              return Center(
                  child: Container(
                      width: 60,
                      height: 60,
                      child: CircularProgressIndicator()));

            return CachedNetworkImage(
              placeholder: (context, url) {
                return Center(
                    child: Container(
                        width: 60,
                        height: 60,
                        child: CircularProgressIndicator()));
              },
              errorWidget: (context, url, error) => Icon(
                Icons.error,
                color: Colors.red,
              ),
              imageUrl: snapshot.data!,
              fit: fit,
              height: height,
              width: width,
              alignment: alignment,
            );
          });
    } else if (url != null) {
      return FutureBuilder(
          future: DashboardUtils.fixUrls([url!]),
          builder: (context, AsyncSnapshot<List<String>> snapshot) {
            if (!snapshot.hasData)
              return Center(
                  child: Container(
                      width: 60,
                      height: 60,
                      child: CircularProgressIndicator()));

            return CachedNetworkImage(
              placeholder: (context, url) {
                return Center(
                    child: Container(
                        width: 60,
                        height: 60,
                        child: CircularProgressIndicator()));
              },
              imageUrl: snapshot.data!.first,
              fit: fit,
              height: height,
              width: width,
              alignment: alignment,
            );
          });
    } else {
      return Text("Error, hay que definir URL o PATH");
    }
  }
}
