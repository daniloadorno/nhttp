import 'dart:async';
import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'dart:io' show Platform;

const MethodChannel _channel = const MethodChannel('nhttp');
const int _timeOut = 60;
bool get _useNative => Platform.isAndroid || Platform.isIOS;

Future<http.Response> get(String url, {Map<String, String>? headers, int? timeOut}) async {
  final Map<String, dynamic> request = {
    "method": "GET",
    "url": url,
    "headers": headers ?? const {},
    "timeOut": Duration(seconds: timeOut ?? _timeOut).inMilliseconds
  };
  if (_useNative){
    return await _sendRequest(request);
  } else {
    return await http.get(
        Uri.parse(url),
        headers: headers
    ).timeout(Duration(seconds: timeOut ?? _timeOut));
  }
}

Future<http.Response> post(String url, {Map<String, String>? headers, Object? body, int? timeOut}) async {
  final Map<String, dynamic> request = {
    "method": "POST",
    "url": url,
    "headers": headers ?? const {},
    "body": body ?? "",
    "timeOut": Duration(seconds: timeOut ?? _timeOut).inMilliseconds
  };
  if (_useNative){
    return await _sendRequest(request);
  } else {
    return await http.post(
        Uri.parse(url),
        headers: headers,
        encoding: Encoding.getByName("UTF-8"),
        body: body
    ).timeout(Duration(seconds: timeOut ?? _timeOut));
  }
}

Future<http.Response> put(String url, {Map<String, String>? headers, Object? body, int? timeOut}) async {
  final Map<String, dynamic> request = {
    "method": "PUT",
    "url": url,
    "headers": headers ?? const {},
    "body": body ?? "",
    "timeOut": Duration(seconds: timeOut ?? _timeOut).inMilliseconds
  };
  if (_useNative){
    return await _sendRequest(request);
  } else {
    return await http.put(
        Uri.parse(url),
        headers: headers,
        encoding: Encoding.getByName("UTF-8"),
        body: body
    ).timeout(Duration(seconds: timeOut ?? _timeOut));
  }
}

Future<http.Response> patch(String url, {Map<String, String>? headers, Object? body, int? timeOut}) async {
  return await http.patch(
      Uri.parse(url),
      headers: headers,
      encoding: Encoding.getByName("UTF-8"),
      body: body
  ).timeout(Duration(seconds: timeOut ?? _timeOut));
}

Future<http.Response> delete(String url, {Map<String, String>? headers, int? timeOut}) async {
  final Map<String, dynamic> request = {
    "method": "DELETE",
    "url": url,
    "headers": headers ?? const {},
    "timeOut": Duration(seconds: timeOut ?? _timeOut).inMilliseconds
  };
  if (_useNative){
    return await _sendRequest(request);
  } else {
    return await http.delete(
        Uri.parse(url),
        headers: headers
    ).timeout(Duration(seconds: timeOut ?? _timeOut));
  }
}

Future<http.Response> _sendRequest(Map<String, dynamic> request) async {
  if (request["headers"] != null){
    for (var entry in request["headers"].entries){
      if (entry.key.toLowerCase() == "content-type" && !entry.value.toLowerCase().contains("charset")){
        request["headers"][entry.key] = "${entry.value}; charset=utf-8";
      }
    }
  }
  final Map<String, dynamic> response = (await _channel.invokeMapMethod<String, dynamic>('sendRequest', request)) ?? {};
  return http.Response(response["body"], response["statusCode"]);
}