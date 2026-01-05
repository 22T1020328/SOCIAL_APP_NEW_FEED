import 'package:json_annotation/json_annotation.dart';

part 'paging.g.dart';

@JsonSerializable()
class Paging {
  @JsonKey(name: 'cursor')
  String? cursor;

  @JsonKey(name: 'next_cursor')
  String? nextCursor;

  @JsonKey(name: 'limit')
  int? limit;

  @JsonKey(name: 'total')
  int? total;

  @JsonKey(name: 'page')
  int? page;

  @JsonKey(name: 'has_next', defaultValue: false)
  bool? hasNext;

  Paging({
    this.cursor,
    this.nextCursor,
    this.total,
    this.limit,
    this.page,
    this.hasNext,
  });

  factory Paging.fromJson(Map<String, dynamic> json) => _$PagingFromJson(json);

  Map<String, dynamic> toJson() => _$PagingToJson(this);
}

