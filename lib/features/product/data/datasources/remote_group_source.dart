import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:loggy/loggy.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../domain/models/group.dart';
import 'i_group_source.dart';

class RemoteGroupSource implements IGroupSource {
  final http.Client httpClient;
  final String baseUrl =
      "https://roble-api.openlab.uninorte.edu.co/database/pruebadavid_a9af0fb6f8";

  RemoteGroupSource(this.httpClient);

  @override
  Future<List<Group>> getGroups() async {
    try {
      final headers = await _getHeaders();
      final response = await httpClient.get(
        Uri.parse('$baseUrl/read?tableName=Groups'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        final dynamic decodedJson = jsonDecode(response.body);

        List<dynamic> groupsData;
        if (decodedJson is List) {
          groupsData = decodedJson;
        } else if (decodedJson is Map<String, dynamic>) {
          if (decodedJson.containsKey('groups')) {
            groupsData = decodedJson['groups'] as List<dynamic>;
          } else if (decodedJson.containsKey('data')) {
            groupsData = decodedJson['data'] as List<dynamic>;
          } else if (decodedJson.containsKey('records')) {
            groupsData = decodedJson['records'] as List<dynamic>;
          } else {
            groupsData = [decodedJson];
          }
        } else {
          logError(
            "Unexpected API response structure: ${decodedJson.runtimeType}",
          );
          return [];
        }

        return groupsData
            .whereType<Map<String, dynamic>>()
            .map((groupJson) => _parseGroupFromJson(groupJson))
            .toList();
      } else if (response.statusCode == 401) {
        logError("Authentication failed. Token may be expired or invalid.");
        throw Exception('Authentication required');
      } else {
        logError(
          "Failed to get groups: ${response.statusCode} - ${response.body}",
        );
        return [];
      }
    } catch (e) {
      logError("Error getting groups: $e");
      return [];
    }
  }

  Group _parseGroupFromJson(Map<String, dynamic> json) {
    final String id = (json['_id'] ?? json['id'])?.toString() ?? '0';
    final String name = (json['Name'] ?? json['name'] ?? '').toString();
    final String? categoryId = (json['CategoryId'] ?? json['categoryId'])?.toString();
    final List<String> students =
        (json['Students'] ?? json['students'] ?? const [])
            .map<String>((e) => e.toString())
            .toList();

    return Group(
      name: name,
      studentsNames: students,
      id: id,
      categoryId: categoryId,
    );
  }

  Future<Map<String, String>> _getHeaders() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('access_token');
    logInfo("Using token: $token");
    return {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  @override
  Future<bool> addGroup(Group group) async {
    logInfo("Web service, Adding group $group");

    final uri = Uri.parse('$baseUrl/insert');
    final headers = await _getHeaders();

    final groupJson = {'Name': group.name, 'Students': group.studentsNames};

    final body = jsonEncode({
      "tableName": "Groups",
      "records": [groupJson],
    });

    final response = await httpClient.post(uri, headers: headers, body: body);

    if (response.statusCode == 200) {
      logInfo("Web service, Group added successfully");
      return Future.value(true);
    } else {
      logError(
        "Web service, Error adding group: ${response.statusCode} - ${response.body}",
      );
      return Future.value(false);
    }
  }

  @override
  Future<bool> updateGroup(Group group) async {
    logInfo("Web service, Updating group ${group.id}");

    final uri = Uri.parse('$baseUrl/update');
    final headers = await _getHeaders();

    final groupJson = {'Name': group.name, 'Students': group.studentsNames};

    final body = jsonEncode({
      "tableName": "Groups",
      "idColum": "_id",
      "idValue": group.id,
      "updates": groupJson,
    });

    final response = await httpClient.put(uri, headers: headers, body: body);

    if (response.statusCode == 200) {
      logInfo("Web service, Group updated successfully");
      return Future.value(true);
    } else {
      logError(
        "Web service, Error updating group: ${response.statusCode} - ${response.body}",
      );
      return Future.value(false);
    }
  }

  @override
  Future<bool> deleteGroup(Group group) async {
    logInfo("Web service, Deleting group with id ${group.id}");

    final uri = Uri.parse('$baseUrl/delete');
    final headers = await _getHeaders();

    final body = jsonEncode({
      'tableName': "Groups",
      'idColumn': '_id',
      'idValue': group.id,
    });

    final response = await httpClient.delete(uri, headers: headers, body: body);

    if (response.statusCode == 200) {
      logInfo("Web service, Group deleted successfully");
      return Future.value(true);
    } else {
      logError(
        "Web service, Error deleting group: ${response.statusCode} - ${response.body}",
      );
      return Future.value(false);
    }
  }
}
