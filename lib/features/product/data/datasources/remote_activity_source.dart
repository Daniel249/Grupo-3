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

      // Parse activities (Notas is now a JSON column in Activities table)
      List<Activity> activities = [];
      for (var activityJson in activitiesData) {
        if (activityJson is Map<String, dynamic>) {
          final activity = _parseActivityFromJson(activityJson);
          activities.add(activity);
        }
      }

      return activities;
    } catch (e) {
      logError("Error getting activities: $e");
      return [];
    }
  }

  Activity _parseActivityFromJson(Map<String, dynamic> json) {
    final String id = (json['_id'] ?? json['id'])?.toString() ?? '0';
    final String name = (json['Nombre'] ?? json['Name'] ?? '').toString();
    final String description = (json['Description'] ?? '').toString();
    final String courseId = (json['CourseID'] ?? '').toString();
    final String categoryId = (json['CatID'] ?? json['CategoryID'] ?? '')
        .toString();
    final bool assessment = (json['Assessment'] ?? false);

    // Parse results from Notas column in Activities table
    // New structure: Map<evaluatorName, Map<evaluatedStudent, List<int>>>
    // Stored as JSON in Notas column
    Map<String, Map<String, List<int>>> results = {};

    final notasData = json['Notas'];
    if (notasData != null) {
      try {
        Map<String, dynamic> decodedResults;
        if (notasData is String) {
          decodedResults = jsonDecode(notasData);
        } else if (notasData is Map) {
          decodedResults = Map<String, dynamic>.from(notasData);
        } else {
          decodedResults = {};
        }

        // Parse each evaluator's scores
        // Structure: {evaluatorName: {peerName: [score1, score2, score3, score4]}}
        decodedResults.forEach((evaluatorName, peerScoresData) {
          final Map<String, List<int>> parsedPeerScores = {};

          if (peerScoresData is Map) {
            peerScoresData.forEach((peerName, scores) {
              if (scores is List) {
                parsedPeerScores[peerName.toString()] = scores
                    .map((e) => e is int ? e : int.tryParse(e.toString()) ?? -1)
                    .toList();
              }
            });
          }

          // Always add the evaluator to results, even if they have no peer scores
          // This handles the case where a user completes an empty assessment
          results[evaluatorName.toString()] = parsedPeerScores;
        });
      } catch (e) {
        logError("Error parsing results from Notas column: $e");
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
      already: _parseAlreadyList(json['Already']),
    );
  }

  // Helper method to parse Already list
  List<String>? _parseAlreadyList(dynamic alreadyValue) {
    if (alreadyValue == null) return null;

    try {
      if (alreadyValue is String) {
        final decoded = jsonDecode(alreadyValue);
        if (decoded is List) {
          return decoded.map((e) => e.toString()).toList();
        }
      } else if (alreadyValue is List) {
        return alreadyValue.map((e) => e.toString()).toList();
      }
    } catch (e) {
      return null;
    }

    return null;
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

      // Insert into Activities table with Notas as JSON column
      final activityJson = {
        'Nombre': activity.name,
        'Description': activity.description,
        'CourseID': activity.course,
        'CatID': activity.category,
        'Assessment': activity.assessment,
        'Notas': jsonEncode(activity.results), // Store results in Notas column
        if (activity.assessName != null) 'AssessName': activity.assessName,
        if (activity.isPublic != null) 'IsPublic': activity.isPublic,
        if (activity.time != null)
          'Time': activity.time!.toUtc().toIso8601String(),
        if (activity.already != null) 'Already': jsonEncode(activity.already),
      };

      final activityBody = jsonEncode({
        "tableName": "Activities",
        "records": [activityJson],
      });

      logInfo("Adding activity - Request body: $activityBody");

      final activityResponse = await httpClient.post(
        uri,
        headers: headers,
        body: activityBody,
      );

      logInfo(
        "Adding activity - Response: ${activityResponse.statusCode} - ${activityResponse.body}",
      );

      if (activityResponse.statusCode != 200) {
        logError(
          "Error adding activity: ${activityResponse.statusCode} - ${activityResponse.body}",
        );
        return false;
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

      // Update Activities table with Notas as JSON column
      final activityJson = {
        'Nombre': activity.name,
        'Description': activity.description,
        'CourseID': activity.course,
        'CatID': activity.category,
        'Assessment': activity.assessment,
        'Notas': jsonEncode(activity.results), // Store results in Notas column
        if (activity.assessName != null) 'AssessName': activity.assessName,
        if (activity.isPublic != null) 'IsPublic': activity.isPublic,
        if (activity.time != null)
          'Time': activity.time!.toUtc().toIso8601String(),
        //if (activity.already != null) 'Already': jsonEncode(activity.already),
      };
      logInfo("Activity JSON being sent: $activityJson");
      final activityBody = jsonEncode({
        "tableName": "Activities",
        "idColumn": "_id",
        "idValue": activity.id,
        "updates": activityJson,
      });

      logInfo("Updating activity - Request body: $activityBody");

      final activityResponse = await httpClient.put(
        uri,
        headers: headers,
        body: activityBody,
      );

      logInfo(
        "Updating activity - Response: ${activityResponse.statusCode} - ${activityResponse.body}",
      );

      if (activityResponse.statusCode != 200) {
        logError(
          "Error updating activity: ${activityResponse.statusCode} - ${activityResponse.body}",
        );
        return false;
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

      // Delete from Activities table (Notas is now a column in Activities)
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
