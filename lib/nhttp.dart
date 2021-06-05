import 'dart:async';
import 'package:flutter/services.dart';

const MethodChannel _channel = const MethodChannel('nhttp');

Future<Response> get(String url, {Map<String, String>? headers}) async {
  final Map<String, dynamic> request = {
    "method": "GET",
    "url": url,
    "headers": headers ?? const {}
  };
  return await _sendRequest(request);
}

Future<Response> post(String url, {Map<String, String>? headers, String? body}) async {
  final Map<String, dynamic> request = {
    "method": "POST",
    "url": url,
    "headers": headers ?? const {},
    "body": body ?? ""
  };
  return await _sendRequest(request);
}

Future<Response> put(String url, {Map<String, String>? headers, String? body}) async {
  final Map<String, dynamic> request = {
    "method": "PUT",
    "url": url,
    "headers": headers ?? const {},
    "body": body ?? ""
  };
  return await _sendRequest(request);
}

Future<Response> delete(String url, {Map<String, String>? headers}) async {
  final Map<String, dynamic> request = {
    "method": "DELETE",
    "url": url,
    "headers": headers ?? const {}
  };
  return await _sendRequest(request);
}

Future<Response> _sendRequest(Map<String, dynamic> request) async {
  final Map<String, dynamic>? response = await _channel.invokeMapMethod<String, dynamic>('sendRequest', request);
  return Response.fromMap(response ?? {});
}

class Response {
  int statusCode;
  String body;

  Response({required this.statusCode, required this.body});

  static Response fromMap(Map<String, dynamic> response){
    return Response(statusCode: response["statusCode"], body: response["body"]);
  }
}
