import 'package:json_annotation/json_annotation.dart';

part 'basic_response.g.dart';

@JsonSerializable(genericArgumentFactories: true)
class BasicResponse<T> {
  BasicResponse(
      this.returnCode,
      this.message,
      this.data
      );

  T returnCode;
  T message;
  T data;

  factory BasicResponse.fromJson(Map<String, dynamic> json,
      T Function(Object? json) fromJsonT,) => _$BasicResponseFromJson(json, fromJsonT);

  Map<String, dynamic> toJson(Object Function(T value) toJsonT) => _$BasicResponseToJson(this, toJsonT);
}