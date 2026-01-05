// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'picture.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Picture _$PictureFromJson(Map<String, dynamic> json) => Picture(
  url: json['url'] as String?,
  orgWidth: (json['org_width'] as num?)?.toInt(),
  orgHeight: (json['org_height'] as num?)?.toInt(),
  orgUrl: json['org_url'] as String?,
  cloudName: json['cloud_name'] as String?,
);

Map<String, dynamic> _$PictureToJson(Picture instance) => <String, dynamic>{
  'url': ?instance.url,
  'org_width': ?instance.orgWidth,
  'org_height': ?instance.orgHeight,
  'org_url': ?instance.orgUrl,
  'cloud_name': ?instance.cloudName,
};
