import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:socail/modules/posts/widgets/post_img_item.dart';

import '../../../utils/photo_utils.dart';
import '../models/photo.dart';

class GridImage extends StatelessWidget {
  final List<Photo> photos;
  final double padding;

  const GridImage({
    Key? key,
    required this.photos,
    this.padding = 12,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    
    final validPhotos = photos.where((photo) => photo.image?.url != null).toList();
    if (validPhotos.isEmpty) {
      return const SizedBox();
    }
    
    final width = MediaQuery.of(context).size.width - padding;
    return buildImageGrid(validPhotos, width, context);
  }

  Widget buildImageGrid(
      List<Photo> photos, double width, BuildContext context) {
    switch (photos.length) {
      case 0:
        return const SizedBox();
      case 1:
        return _buildOneImage(photos[0], width, context);
      case 2:
        return _buildTwoImage(photos, width, context);
      case 3:
        return _buildThreeImage(photos, width, context);
      case 4:
        
        return _buildOneImage(photos[0], width, context);
      case 5:
        
        return _buildOneImage(photos[0], width, context);
      default:
        return _buildOneImage(photos[0], width, context);
    }
  }

  Widget _buildOneImage(Photo photo, double width, BuildContext context) {
    final image = photo.image;
    if (image == null || image.url == null) {
      return const SizedBox();
    }

    
    final url = image.url!;
    
    
    final heightView = (image.orgWidth != null && image.orgHeight != null)
        ? PhotoUtils.getHeightView(width, image.orgWidth!, image.orgHeight!)
        : width;

    if (heightView >= width * 3) {
      return GestureDetector(
        onTap: () => navigateToPhotoPage([photo], 0, context),
        child: SizedBox(
          height: width * 3,
          child: CachedNetworkImage(
            imageUrl: url,
            fit: BoxFit.fitHeight,
            placeholder: (context, url) => Container(
              color: Colors.grey[300],
              child: const Center(child: CircularProgressIndicator()),
            ),
            errorWidget: (context, url, error) => Container(
              color: Colors.grey[300],
              child: const Icon(Icons.image_not_supported, size: 50),
            ),
          ),
        ),
      );
    }

    return GestureDetector(
      onTap: () => navigateToPhotoPage([photo], 0, context),
      child: SizedBox(
        height: heightView,
        width: width,
        child: CachedNetworkImage(
          imageUrl: url,
          fit: BoxFit.cover,
          placeholder: (context, url) => Container(
            color: Colors.grey[300],
            child: const Center(child: CircularProgressIndicator()),
          ),
          errorWidget: (context, url, error) {
            return Container(
              color: Colors.grey[300],
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.broken_image, size: 50, color: Colors.grey),
                  const SizedBox(height: 8),
                  Text(
                    'Không thể tải ảnh',
                    style: TextStyle(color: Colors.grey[600], fontSize: 12),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildTwoImage(
      List<Photo> photos, double width, BuildContext context) {
    final firstImg = photos[0].image;

    
    
    
    
    

    

    if (firstImg != null && firstImg.orgWidth != null && firstImg.orgHeight != null && firstImg.orgWidth! > firstImg.orgHeight!) {
      return SizedBox(
        height: width,
        child: Column(
          children: <Widget>[
            Expanded(
              child: PostImgItem(
                imageUrl: photos[0].url,
              ),
            ),
            if (padding > 0) SizedBox(height: padding),
            Expanded(
              child: PostImgItem(
                imageUrl: photos[1].url,
              ),
            ),
          ],
        ),
      );
    }

    final height = width;
    return SizedBox(
      height: height,
      child: Row(
        children: <Widget>[
          Expanded(
            child: PostImgItem(
              imageUrl: photos[0].url,
              height: height,
            ),
          ),
          if (padding > 0) SizedBox(width: padding),
          Expanded(
            child: PostImgItem(
              imageUrl: photos[1].url,
              height: height,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildThreeImage(
      List<Photo> photos, double width, BuildContext context) {
    final firstImg = photos[0].image;

    
    if (firstImg != null && firstImg.orgHeight != null && firstImg.orgWidth != null && firstImg.orgHeight! > firstImg.orgWidth!) {
      final height = width;
      return SizedBox(
        height: height,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Expanded(
              child: PostImgItem(
                imageUrl: photos[0].url,
                height: height,
              ),
            ),
            if (padding > 0) SizedBox(width: padding),
            Expanded(
              child: Column(
                children: <Widget>[
                  Expanded(
                    child: PostImgItem(
                      imageUrl: photos[1].url,
                    ),
                  ),
                  if (padding > 0) SizedBox(height: padding),
                  Expanded(
                    child: PostImgItem(
                      imageUrl: photos[2].url,
                    ),
                  ),
                ],
              ),
            )
          ],
        ),
      );
    }

    final height = width;
    final itemHeight = padding > 0 ? (height - padding) / 2 : height / 2;
    return SizedBox(
      height: height,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Expanded(
            child: Row(
              children: <Widget>[
                Expanded(
                  child: PostImgItem(
                    imageUrl: photos[1].url,
                  ),
                ),
                if (padding > 0) SizedBox(width: padding),
                Expanded(
                  child: PostImgItem(
                    imageUrl: photos[2].url,
                  ),
                ),
              ],
            ),
          ),
          if (padding > 0) SizedBox(height: padding),
          SizedBox(
            height: itemHeight,
            child: PostImgItem(
              imageUrl: photos[0].url,
            ),
          ),
        ],
      ),
    );
  }

  void navigateToPhotoPage(
      List<Photo> photos, int index, BuildContext context) {

  }
}


