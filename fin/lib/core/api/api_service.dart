// простий HTTP wrapper
import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  final String baseUrl;
  final http.Client client;
  ApiService(this.baseUrl, {http.Client? client})
    : client = client ?? http.Client();

  Uri _uri(String path) => Uri.parse(baseUrl + path);

  Future<dynamic> get(String path) async {
    final r = await client.get(_uri(path));
    if (r.statusCode >= 200 && r.statusCode < 300) return json.decode(r.body);
    throw Exception('GET $path failed ${r.statusCode}: ${r.body}');
  }

  Future<dynamic> post(String path, Map body) async {
    final r = await client.post(
      _uri(path),
      headers: {'Content-Type': 'application/json'},
      body: json.encode(body),
    );
    if (r.statusCode >= 200 && r.statusCode < 300) return json.decode(r.body);
    throw Exception('POST $path failed ${r.statusCode}: ${r.body}');
  }

  Future<dynamic> put(String path, Map body) async {
    final r = await client.put(
      _uri(path),
      headers: {'Content-Type': 'application/json'},
      body: json.encode(body),
    );
    if (r.statusCode >= 200 && r.statusCode < 300) return json.decode(r.body);
    throw Exception('PUT $path failed ${r.statusCode}: ${r.body}');
  }

  Future<void> delete(String path) async {
    final r = await client.delete(_uri(path));
    if (r.statusCode < 200 || r.statusCode >= 300)
      throw Exception('DELETE $path failed ${r.statusCode}: ${r.body}');
  }
}
