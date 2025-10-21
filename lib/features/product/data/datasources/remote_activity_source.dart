import 'dart:convert';
import 'package:loggy/loggy.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../domain/models/activity.dart';
import 'package:http/http.dart' as http;

import 'i_remote_activity_source.dart';

class RemoteActivitySource implements IActivitySource {
  final http.Client httpClient;
  final String baseUrl =
      "https://roble-api.openlab.uninorte.edu.co/database/pruebadavid_a9af0fb6f8";

  RemoteActivitySource(this.httpClient);

  @override
  Future<List<Activity>> getActivities(String? courseId) async {
    if (courseId == null) {
      logError("Course ID is null. Cannot fetch activities.");
      return [];
    }

    try {
      final headers = await _getHeaders();

      // Fetch activities from Activities table
      final activitiesResponse = await httpClient.get(
        Uri.parse('$baseUrl/read?tableName=Activities&CourseID=$courseId'),
        headers: headers,
      );

      if (activitiesResponse.statusCode != 200) {
        logError(
          "Failed to get activities: ${activitiesResponse.statusCode} - ${activitiesResponse.body}",
        );
        return [];
      }

      final dynamic activitiesJson = jsonDecode(activitiesResponse.body);
      List<dynamic> activitiesData;

      if (activitiesJson is List) {
        activitiesData = activitiesJson;
      } else if (activitiesJson is Map<String, dynamic>) {
        if (activitiesJson.containsKey('Activities')) {
          activitiesData = activitiesJson['Activities'] as List<dynamic>;
        } else if (activitiesJson.containsKey('data')) {
          activitiesData = activitiesJson['data'] as List<dynamic>;
        } else {
          activitiesData = [activitiesJson];
        }
      } else {
        logError("Unexpected API response structure for Activities");
        return [];
      }

      // Fetch all Notas
      final notasResponse = await httpClient.get(
        Uri.parse('$baseUrl/read?tableName=Notas'),
        headers: headers,
      );

      Map<String, Map<String, dynamic>> notasMap = {};
      if (notasResponse.statusCode == 200) {
        final dynamic notasJson = jsonDecode(notasResponse.body);
        List<dynamic> notasData;

        if (notasJson is List) {
          notasData = notasJson;
        } else if (notasJson is Map<String, dynamic>) {
          if (notasJson.containsKey('Notas')) {
            notasData = notasJson['Notas'] as List<dynamic>;
          } else if (notasJson.containsKey('data')) {
            notasData = notasJson['data'] as List<dynamic>;
          } else {
            notasData = [notasJson];
          }
        } else {
          notasData = [];
        }

        // Create map of activityId -> notas data
        for (var nota in notasData) {
          if (nota is Map<String, dynamic> && nota['ActID'] != null) {
            notasMap[nota['ActID'].toString()] = nota;
          }
        }
      }

      // Parse activities and match with notas
      List<Activity> activities = [];
      for (var activityJson in activitiesData) {
        if (activityJson is Map<String, dynamic>) {
          final activity = _parseActivityFromJson(activityJson, notasMap);
          activities.add(activity);
        }
      }

      return activities;
    } catch (e) {
      logError("Error getting activities: $e");
      return [];
    }
  }

  Activity _parseActivityFromJson(
    Map<String, dynamic> json,
    Map<String, Map<String, dynamic>> notasMap,
  ) {
    final String id = (json['_id'] ?? json['id'])?.toString() ?? '0';
    final String name = (json['Nombre'] ?? json['Name'] ?? '').toString();
    final String description = (json['Description'] ?? '').toString();
    final String courseId = (json['CourseID'] ?? '').toString();
    final String categoryId = (json['CatID'] ?? json['CategoryID'] ?? '')
        .toString();
    final bool assessment = (json['Assessment'] ?? false);

    // Parse results from Notas table
    Map<String, List<List<int>>> results = {};

    if (notasMap.containsKey(id)) {
      final notaData = notasMap[id]!;

      // Get Students array - may be JSON encoded
      List<dynamic> students = [];
      final studentsData = notaData['Students'];
      if (studentsData is String) {
        try {
          final decoded = jsonDecode(studentsData);
          if (decoded is List) {
            students = decoded;
          }
        } catch (e) {
          students = [];
        }
      } else if (studentsData is List) {
        students = studentsData;
      }

      // Get N1, N2, N3, N4 arrays - may be JSON encoded
      List<dynamic> n1 = _parseJsonArray(notaData['N1']);
      List<dynamic> n2 = _parseJsonArray(notaData['N2']);
      List<dynamic> n3 = _parseJsonArray(notaData['N3']);
      List<dynamic> n4 = _parseJsonArray(notaData['N4']);

      // Create results map
      for (int i = 0; i < students.length; i++) {
        final String studentName = students[i].toString();

        // Parse each field as a List<int>
        final List<int> field1 = _parseFieldScores(
          i < n1.length ? n1[i] : null,
        );
        final List<int> field2 = _parseFieldScores(
          i < n2.length ? n2[i] : null,
        );
        final List<int> field3 = _parseFieldScores(
          i < n3.length ? n3[i] : null,
        );
        final List<int> field4 = _parseFieldScores(
          i < n4.length ? n4[i] : null,
        );

        results[studentName] = [field1, field2, field3, field4];
      }
    }

    return Activity(
      id: id,
      name: name,
      description: description,
      course: courseId,
      category: categoryId,
      results: results,
      assessment: assessment,
      assessName: json['AssessName']?.toString(),
      isPublic: json['IsPublic'] as bool?,
      time: json['Time'] != null ? _parseDateTime(json['Time']) : null,
    );
  }

  // Helper method to parse DateTime from various formats
  DateTime? _parseDateTime(dynamic timeValue) {
    if (timeValue == null) return null;

    try {
      if (timeValue is String) {
        return DateTime.parse(timeValue);
      } else if (timeValue is int) {
        // Unix timestamp in milliseconds
        return DateTime.fromMillisecondsSinceEpoch(timeValue);
      } else if (timeValue is DateTime) {
        return timeValue;
      }
    } catch (e) {
      // Return null if parsing fails
      return null;
    }

    return null;
  }

  List<dynamic> _parseJsonArray(dynamic arrayData) {
    if (arrayData == null) return [];

    if (arrayData is String) {
      try {
        final decoded = jsonDecode(arrayData);
        if (decoded is List) {
          return decoded;
        }
      } catch (e) {
        return [];
      }
    } else if (arrayData is List) {
      return arrayData;
    }

    return [];
  }

  List<int> _parseFieldScores(dynamic fieldData) {
    if (fieldData == null) return [];

    if (fieldData is String) {
      try {
        // Try to parse as JSON array
        final decoded = jsonDecode(fieldData);
        if (decoded is List) {
          return decoded
              .map((e) => e is int ? e : int.tryParse(e.toString()) ?? -1)
              .toList();
        }
      } catch (e) {
        // If not JSON, treat as empty
        return [];
      }
    } else if (fieldData is List) {
      return fieldData
          .map((e) => e is int ? e : int.tryParse(e.toString()) ?? -1)
          .toList();
    }

    return [];
  }

  Future<Map<String, String>> _getHeaders() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('access_token');
    return {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  @override
  Future<bool> addActivity(Activity activity) async {
    logInfo("Web service, Adding activity ${activity.name}");

    try {
      final uri = Uri.parse('$baseUrl/insert');
      final headers = await _getHeaders();

      // Insert into Activities table
      final activityJson = {
        'Nombre': activity.name,
        'Description': activity.description,
        'CourseID': activity.course,
        'CatID': activity.category,
        'Assessment': activity.assessment,
        if (activity.assessName != null) 'AssessName': activity.assessName,
        if (activity.isPublic != null) 'IsPublic': activity.isPublic,
        if (activity.time != null)
          'Time': activity.time!.toUtc().toIso8601String(),
      };

      final activityBody = jsonEncode({
        "tableName": "Activities",
        "records": [activityJson],
      });

      final activityResponse = await httpClient.post(
        uri,
        headers: headers,
        body: activityBody,
      );

      if (activityResponse.statusCode != 200) {
        logError(
          "Error adding activity: ${activityResponse.statusCode} - ${activityResponse.body}",
        );
        return false;
      }

      // Get the inserted activity ID from response
      final responseData = jsonDecode(activityResponse.body);
      String? activityId = activity.id;

      // Try to extract ID from response
      if (responseData is Map<String, dynamic>) {
        activityId =
            responseData['_id']?.toString() ??
            responseData['id']?.toString() ??
            activity.id;
      }

      // Insert into Notas table if there are results
      if (activity.results.isNotEmpty && activityId != null) {
        final List<String> students = activity.results.keys.toList();
        final List<String> n1 = [];
        final List<String> n2 = [];
        final List<String> n3 = [];
        final List<String> n4 = [];

        for (var studentName in students) {
          final fields = activity.results[studentName] ?? [[], [], [], []];
          // Store each field as a JSON string
          n1.add(jsonEncode(fields.isNotEmpty ? fields[0] : []));
          n2.add(jsonEncode(fields.length > 1 ? fields[1] : []));
          n3.add(jsonEncode(fields.length > 2 ? fields[2] : []));
          n4.add(jsonEncode(fields.length > 3 ? fields[3] : []));
        }

        final notasJson = {
          'ActID': activityId,
          'Students': jsonEncode(students),
          'N1': jsonEncode(n1),
          'N2': jsonEncode(n2),
          'N3': jsonEncode(n3),
          'N4': jsonEncode(n4),
        };

        final notasBody = jsonEncode({
          "tableName": "Notas",
          "records": [notasJson],
        });

        final notasResponse = await httpClient.post(
          uri,
          headers: headers,
          body: notasBody,
        );

        if (notasResponse.statusCode != 200) {
          logError(
            "Error adding notas: ${notasResponse.statusCode} - ${notasResponse.body}",
          );
        }
      }

      logInfo("Activity added successfully");
      return true;
    } catch (e) {
      logError("Error adding activity: $e");
      return false;
    }
  }

  @override
  Future<bool> updateActivity(Activity activity) async {
    logInfo("Web service, Updating activity with id ${activity.id}");

    try {
      final uri = Uri.parse('$baseUrl/update');
      final headers = await _getHeaders();

      // Update Activities table
      final activityJson = {
        'Nombre': activity.name,
        'Description': activity.description,
        'CourseID': activity.course,
        'CatID': activity.category,
        'Assessment': activity.assessment,
        if (activity.assessName != null) 'AssessName': activity.assessName,
        if (activity.isPublic != null) 'IsPublic': activity.isPublic,
        if (activity.time != null)
          'Time': activity.time!.toUtc().toIso8601String(),
      };
      logInfo("Activity JSON being sent: $activityJson");
      final activityBody = jsonEncode({
        "tableName": "Activities",
        "idColumn": "_id",
        "idValue": activity.id,
        "updates": activityJson,
      });

      final activityResponse = await httpClient.put(
        uri,
        headers: headers,
        body: activityBody,
      );

      if (activityResponse.statusCode != 200) {
        logError(
          "Error updating activity: ${activityResponse.statusCode} - ${activityResponse.body}",
        );
        return false;
      }

      // Update Notas table
      if (activity.results.isNotEmpty) {
        final List<String> students = activity.results.keys.toList();
        final List<String> n1 = [];
        final List<String> n2 = [];
        final List<String> n3 = [];
        final List<String> n4 = [];

        for (var studentName in students) {
          final fields = activity.results[studentName] ?? [[], [], [], []];
          // Store each field as a JSON string
          n1.add(jsonEncode(fields.isNotEmpty ? fields[0] : []));
          n2.add(jsonEncode(fields.length > 1 ? fields[1] : []));
          n3.add(jsonEncode(fields.length > 2 ? fields[2] : []));
          n4.add(jsonEncode(fields.length > 3 ? fields[3] : []));
        }

        final notasJson = {
          'ActID': activity.id,
          'Students': jsonEncode(students),
          'N1': jsonEncode(n1),
          'N2': jsonEncode(n2),
          'N3': jsonEncode(n3),
          'N4': jsonEncode(n4),
        };

        final notasBody = jsonEncode({
          "tableName": "Notas",
          "idColumn": "ActID",
          "idValue": activity.id,
          "updates": notasJson,
        });

        final notasResponse = await httpClient.put(
          uri,
          headers: headers,
          body: notasBody,
        );

        if (notasResponse.statusCode != 200) {
          logError(
            "Error updating notas: ${notasResponse.statusCode} - ${notasResponse.body}",
          );
        }
      }

      logInfo("Activity updated successfully");
      return true;
    } catch (e) {
      logError("Error updating activity: $e");
      return false;
    }
  }

  @override
  Future<bool> deleteActivity(Activity activity) async {
    logInfo("Web service, Deleting activity with id ${activity.id}");

    try {
      final uri = Uri.parse('$baseUrl/delete');
      final headers = await _getHeaders();

      // Delete from Notas table first
      final notasBody = jsonEncode({
        'tableName': "Notas",
        'idColumn': 'ActID',
        'idValue': activity.id,
      });

      await httpClient.delete(uri, headers: headers, body: notasBody);

      // Delete from Activities table
      final activityBody = jsonEncode({
        'tableName': "Activities",
        'idColumn': '_id',
        'idValue': activity.id,
      });

      final activityResponse = await httpClient.delete(
        uri,
        headers: headers,
        body: activityBody,
      );

      if (activityResponse.statusCode == 200) {
        logInfo("Activity deleted successfully");
        return true;
      } else {
        logError(
          "Error deleting activity: ${activityResponse.statusCode} - ${activityResponse.body}",
        );
        return false;
      }
    } catch (e) {
      logError("Error deleting activity: $e");
      return false;
    }
  }

  @override
  Future<bool> deleteActivities() async {
    logInfo("Web service, Deleting all activities not implemented");
    return Future.value(false);
  }
}
