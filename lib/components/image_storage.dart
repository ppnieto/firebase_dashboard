import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_dashboard/util.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/foundation/key.dart';
import 'package:flutter/src/widgets/container.dart';
import 'package:flutter/src/widgets/framework.dart';

class ImageFromStorage extends StatelessWidget {
  final String url;
  final BoxFit? fit;
  final double? height;
  final double? width;
  final Alignment alignment;

  const ImageFromStorage({Key? key, required this.url, this.fit, this.height, this.width, this.alignment = Alignment.center}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: DashboardUtils.fixUrls([url]),
        builder: (context, AsyncSnapshot<List<String>> snapshot) {
          if (!snapshot.hasData) return Center(child: Container(width: 60, height: 60, child: CircularProgressIndicator()));

          return CachedNetworkImage(
            placeholder: (context, url) {
              return Center(child: Container(width: 60, height: 60, child: CircularProgressIndicator()));
            },
            imageUrl: snapshot.data!.first,
            fit: fit,
            height: height,
            width: width,
            alignment: alignment,
          );
        });
  }
}
