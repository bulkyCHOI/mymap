// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'basic_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

BasicResponse<T> _$BasicResponseFromJson<T>(
  Map<String, dynamic> json,
  T Function(Object? json) fromJsonT,
) =>
    BasicResponse<T>(
      fromJsonT(json['returnCode']),
      fromJsonT(json['message']),
      fromJsonT(json['data']),
    );

Map<String, dynamic> _$BasicResponseToJson<T>(
  BasicResponse<T> instance,
  Object? Function(T value) toJsonT,
) =>
    <String, dynamic>{
      'returnCode': toJsonT(instance.returnCode),
      'message': toJsonT(instance.message),
      'data': toJsonT(instance.data),
    };
