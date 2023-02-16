import 'package:http/http.dart' as http;

String sessionID = '';
String baseUrl = 'http://127.0.0.1:8000';

// a method to send http request to server
Future<http.Response> sendRequest(String url) async {
  return http.get(url as Uri).timeout(const Duration(hours: 3));
}

// authenticated get (include seeionID cookie in header)

Future<http.Response> authenticatedGetRequest(String path) async {
  Uri uri = Uri.parse(baseUrl + path);
  http.Response response = await http.get(
    uri,
    headers: {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      'Cookie': 'sessionid=$sessionID',
    },
  );
  return response;
}
