// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'comment_meta_data.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CommentMetaData _$CommentMetaDataFromJson(Map<String, dynamic> json) =>
    CommentMetaData(
      react: json['react'] as Map<String, dynamic>?,
      yourReact: (json['your_react'] as num?)?.toInt(),
    );

Map<String, dynamic> _$CommentMetaDataToJson(CommentMetaData instance) =>
    <String, dynamic>{
      'react': instance.react,
      'your_react': instance.yourReact,
    };
