import 'package:json_annotation/json_annotation.dart';

part 'comment_meta_data.g.dart';

@JsonSerializable()
class CommentMetaData {
  @JsonKey(name: 'react', includeIfNull: true)
  Map<dynamic, dynamic>? react;
  
  
  
  
  
  
  
  

  @JsonKey(name: 'your_react', includeIfNull: true)
  int? yourReact;

  CommentMetaData({
    this.react,
    this.yourReact,
  });

  factory CommentMetaData.fromJson(Map<String, dynamic> json) =>
      _$CommentMetaDataFromJson(json);

  Map<String, dynamic> toJson() => _$CommentMetaDataToJson(this);
}

