import 'dart:async';
import 'package:flutter/services.dart';
import 'package:nhttp/src/http_response.dart';

const MethodChannel _channel = const MethodChannel('nhttp');
const int _timeOut = 60;

Future<Response> get(String url, {Map<String, String>? headers, int? timeOut}) async {
  final Map<String, dynamic> request = {
    "method": "GET",
    "url": url,
    "headers": headers ?? const {},
    "timeOut": Duration(seconds: timeOut ?? _timeOut).inMilliseconds
  };
  return await _sendRequest(request);
}

Future<Response> post(String url, {Map<String, String>? headers, Object? body, int? timeOut}) async {
  final Map<String, dynamic> request = {
    "method": "POST",
    "url": url,
    "headers": headers ?? const {},
    "body": body ?? "",
    "timeOut": Duration(seconds: timeOut ?? _timeOut).inMilliseconds
  };
  return await _sendRequest(request);
}

Future<Response> put(String url, {Map<String, String>? headers, Object? body, int? timeOut}) async {
  final Map<String, dynamic> request = {
    "method": "PUT",
    "url": url,
    "headers": headers ?? const {},
    "body": body ?? "",
    "timeOut": Duration(seconds: timeOut ?? _timeOut).inMilliseconds
  };
  return await _sendRequest(request);
}

Future<Response> delete(String url, {Map<String, String>? headers, int? timeOut}) async {
  final Map<String, dynamic> request = {
    "method": "DELETE",
    "url": url,
    "headers": headers ?? const {},
    "timeOut": Duration(seconds: timeOut ?? _timeOut).inMilliseconds
  };
  return await _sendRequest(request);
}

Future<Response> _sendRequest(Map<String, dynamic> request) async {
  final Map<String, dynamic>? response = await _channel.invokeMapMethod<String, dynamic>('sendRequest', request);
  return Response.fromMap(response ?? {});
}
