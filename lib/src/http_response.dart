
class Response {
  int statusCode;
  String body;

  Response({required this.statusCode, required this.body});

  static Response fromMap(Map<String, dynamic> response) {
    return Response(statusCode: response["statusCode"], body: response["body"]);
  }
}
