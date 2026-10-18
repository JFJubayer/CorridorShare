import 'dart:convert';
import 'package:corridorshare/core/errors/failure.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

/// Codec to translate between standard Dart JSON maps and Firestore REST API JSON.
class FirestoreRestCodec {
  const FirestoreRestCodec._();

  static Map<String, dynamic> encodeFields(Map<String, dynamic> data) {
    final fields = <String, dynamic>{};
    for (final entry in data.entries) {
      if (entry.key == 'id') continue; // document id is in the path
      fields[entry.key] = encodeValue(entry.value);
    }
    return fields;
  }

  static Map<String, dynamic> encodeValue(dynamic value) {
    if (value == null) {
      return <String, dynamic>{'nullValue': null};
    }
    if (value is bool) {
      return <String, dynamic>{'booleanValue': value};
    }
    if (value is int) {
      return <String, dynamic>{'integerValue': value.toString()};
    }
    if (value is double) {
      return <String, dynamic>{'doubleValue': value};
    }
    if (value is String) {
      return <String, dynamic>{'stringValue': value};
    }
    if (value is DateTime) {
      return <String, dynamic>{'timestampValue': value.toUtc().toIso8601String()};
    }
    if (value is List) {
      return <String, dynamic>{
        'arrayValue': {
          'values': value.map(encodeValue).toList(),
        }
      };
    }
    if (value is Map) {
      return <String, dynamic>{
        'mapValue': {
          'fields': value.map((k, v) => MapEntry(k.toString(), encodeValue(v))),
        }
      };
    }
    return <String, dynamic>{'stringValue': value.toString()};
  }

  static Map<String, dynamic> decodeDocument(Map<String, dynamic> doc) {
    final fields = (doc['fields'] as Map<String, dynamic>?) ?? <String, dynamic>{};
    final map = <String, dynamic>{};
    for (final entry in fields.entries) {
      map[entry.key] = decodeValue(entry.value as Map<String, dynamic>);
    }
    if (!map.containsKey('id') && doc.containsKey('name')) {
      final name = doc['name'] as String;
      map['id'] = name.split('/').last;
    }
    return map;
  }

  static dynamic decodeValue(Map<String, dynamic> field) {
    if (field.containsKey('stringValue')) return field['stringValue'];
    if (field.containsKey('integerValue')) {
      return int.tryParse(field['integerValue'].toString()) ?? 0;
    }
    if (field.containsKey('doubleValue')) {
      return (field['doubleValue'] as num).toDouble();
    }
    if (field.containsKey('booleanValue')) return field['booleanValue'];
    if (field.containsKey('timestampValue')) return field['timestampValue'];
    if (field.containsKey('nullValue')) return null;
    if (field.containsKey('arrayValue')) {
      final values = field['arrayValue']['values'] as List<dynamic>?;
      return values?.map((e) => decodeValue(e as Map<String, dynamic>)).toList() ?? <dynamic>[];
    }
    if (field.containsKey('mapValue')) {
      final fields = field['mapValue']['fields'] as Map<String, dynamic>?;
      return fields?.map((k, v) => MapEntry(k, decodeValue(v as Map<String, dynamic>))) ?? <String, dynamic>{};
    }
    return null;
  }
}

/// Standalone REST service for Cloud Firestore operations.
///
/// Enables complete Firestore communication across desktop, mobile, and web
/// platforms, including platforms lacking native FlutterFire plugin registrants.
class FirestoreRestService {
  FirestoreRestService({
    String? projectId,
    http.Client? client,
  })  : projectId = projectId ?? 'corridorshare-dev',
        _client = client ?? http.Client();

  static final FirestoreRestService instance = FirestoreRestService();

  final String projectId;
  final http.Client _client;

  String? _idToken;
  String? _userId;

  String? get idToken => _idToken;
  String? get userId => _userId;

  void setAuth({required String token, required String userId}) {
    _idToken = token;
    _userId = userId;
  }

  void clearAuth() {
    _idToken = null;
    _userId = null;
  }

  String get _baseUrl =>
      'https://firestore.googleapis.com/v1/projects/$projectId/databases/(default)/documents';

  Map<String, String> _headers() {
    final headers = <String, String>{
      'Content-Type': 'application/json',
    };
    if (_idToken != null && _idToken!.isNotEmpty) {
      headers['Authorization'] = 'Bearer $_idToken';
    }
    return headers;
  }

  /// Lists documents in [collection].
  Future<List<Map<String, dynamic>>> getDocuments(String collection) async {
    final uri = Uri.parse('$_baseUrl/$collection');
    try {
      final response = await _client.get(uri, headers: _headers());
      if (response.statusCode == 200) {
        final body = json.decode(response.body) as Map<String, dynamic>;
        final docs = body['documents'] as List<dynamic>?;
        if (docs == null) return <Map<String, dynamic>>[];
        return docs
            .map((d) => FirestoreRestCodec.decodeDocument(d as Map<String, dynamic>))
            .toList();
      } else if (response.statusCode == 404) {
        return <Map<String, dynamic>>[];
      } else {
        _handleError(response);
        return <Map<String, dynamic>>[];
      }
    } catch (e) {
      if (e is Failure) rethrow;
      throw ServerFailure('Firestore fetch error ($collection): $e');
    }
  }

  /// Gets a single document by [docId] in [collection].
  Future<Map<String, dynamic>?> getDocument(String collection, String docId) async {
    final uri = Uri.parse('$_baseUrl/$collection/$docId');
    try {
      final response = await _client.get(uri, headers: _headers());
      if (response.statusCode == 200) {
        final body = json.decode(response.body) as Map<String, dynamic>;
        return FirestoreRestCodec.decodeDocument(body);
      } else if (response.statusCode == 404) {
        return null;
      } else {
        _handleError(response);
        return null;
      }
    } catch (e) {
      if (e is Failure) rethrow;
      throw ServerFailure('Firestore get error ($collection/$docId): $e');
    }
  }

  /// Sets or overwrites a document by [docId] in [collection].
  Future<Map<String, dynamic>> setDocument(
    String collection,
    String docId,
    Map<String, dynamic> data,
  ) async {
    final uri = Uri.parse('$_baseUrl/$collection/$docId');
    try {
      final fields = FirestoreRestCodec.encodeFields(data);
      final response = await _client.patch(
        uri,
        headers: _headers(),
        body: json.encode({'fields': fields}),
      );
      if (response.statusCode == 200) {
        final body = json.decode(response.body) as Map<String, dynamic>;
        final decoded = FirestoreRestCodec.decodeDocument(body);
        decoded['id'] = docId;
        return decoded;
      } else {
        _handleError(response);
        return data;
      }
    } catch (e) {
      if (e is Failure) rethrow;
      throw ServerFailure('Firestore save error ($collection/$docId): $e');
    }
  }

  /// Partially updates document fields in [collection].
  Future<Map<String, dynamic>> updateDocument(
    String collection,
    String docId,
    Map<String, dynamic> fieldsToUpdate,
  ) async {
    final queryParams = fieldsToUpdate.keys
        .map((k) => 'updateMask.fieldPaths=$k')
        .join('&');
    final uri = Uri.parse('$_baseUrl/$collection/$docId?$queryParams');
    try {
      final fields = FirestoreRestCodec.encodeFields(fieldsToUpdate);
      final response = await _client.patch(
        uri,
        headers: _headers(),
        body: json.encode({'fields': fields}),
      );
      if (response.statusCode == 200) {
        final body = json.decode(response.body) as Map<String, dynamic>;
        return FirestoreRestCodec.decodeDocument(body);
      } else {
        _handleError(response);
        return fieldsToUpdate;
      }
    } catch (e) {
      if (e is Failure) rethrow;
      throw ServerFailure('Firestore update error ($collection/$docId): $e');
    }
  }

  /// Deletes a document by [docId] in [collection].
  Future<void> deleteDocument(String collection, String docId) async {
    final uri = Uri.parse('$_baseUrl/$collection/$docId');
    try {
      final response = await _client.delete(uri, headers: _headers());
      if (response.statusCode != 200 && response.statusCode != 204) {
        _handleError(response);
      }
    } catch (e) {
      if (e is Failure) rethrow;
      throw ServerFailure('Firestore delete error ($collection/$docId): $e');
    }
  }

  void _handleError(http.Response response) {
    if (kDebugMode) {
      debugPrint('Firestore REST error: ${response.statusCode} - ${response.body}');
    }
    try {
      final body = json.decode(response.body) as Map<String, dynamic>;
      final error = body['error'] as Map<String, dynamic>?;
      final message = error?['message'] as String? ?? response.body;
      final status = error?['status'] as String?;
      if (status == 'PERMISSION_DENIED') {
        throw const AuthFailure('Permission denied. Please ensure you are logged in.');
      }
      if (status == 'NOT_FOUND') {
        throw const NotFoundFailure('Document not found in database.');
      }
      throw ServerFailure(message);
    } catch (e) {
      if (e is Failure) rethrow;
      throw ServerFailure('Firestore HTTP ${response.statusCode}: ${response.body}');
    }
  }
}
