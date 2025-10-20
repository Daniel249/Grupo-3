import 'dart:convert';

import 'package:f_clean_template/core/i_local_preferences.dart';
import 'package:f_clean_template/features/auth/data/datasources/remote/authentication_source_service_roble.dart';
import 'package:get/get.dart';
//import 'package:f_clean_template/features/auth/data/datasources/remote/authentication_source_service_Roble.dart';
import 'package:loggy/loggy.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../domain/models/course.dart';
import 'package:http/http.dart' as http;

import 'i_course_source.dart';

class RemoteCourseSource implements ICourseSource {
  final http.Client httpClient;
  final String baseUrl =
      "https://roble-api.openlab.uninorte.edu.co/database/pruebadavid_a9af0fb6f8";
  RemoteCourseSource(this.httpClient);

  @override
  Future<List<Course>> getCourses() async {
    try {
      final headers = await _getHeaders();
      final response = await httpClient.get(
        Uri.parse(
          '$baseUrl/read?tableName=Course',
        ), // Make sure this matches your actual API endpoint
        headers: headers,
      );

      if (response.statusCode == 200) {
        final dynamic decodedJson = jsonDecode(response.body);

        // Handle different possible API response structures
        List<dynamic> coursesData;

        if (decodedJson is List) {
          // Direct array of courses: [course1, course2, ...]
          coursesData = decodedJson;
        } else if (decodedJson is Map<String, dynamic>) {
          // Object containing courses: {"courses": [...]} or {"data": [...]}
          if (decodedJson.containsKey('courses')) {
            coursesData = decodedJson['courses'] as List<dynamic>;
          } else if (decodedJson.containsKey('data')) {
            coursesData = decodedJson['data'] as List<dynamic>;
          } else {
            // If the map contains course data directly, wrap it in a list
            coursesData = [decodedJson];
          }
        } else {
          logError(
            "Unexpected API response structure: ${decodedJson.runtimeType}",
          );
          return [];
        }

        return coursesData
            .map(
              (courseJson) =>
                  Course.fromJson(courseJson as Map<String, dynamic>),
            )
            .toList();
      } else if (response.statusCode == 401) {
        logError("Authentication failed. Token may be expired or invalid.");
        throw Exception('Authentication required');
      } else {
        logError(
          "Failed to get courses: ${response.statusCode} - ${response.body}",
        );
        return [];
      }
    } catch (e) {
      logError("Error getting courses: $e");
      return [];
    }
  }

  Future<Map<String, String>> _getHeaders() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('access_token');
    //logInfo("Using token: $token");
    return {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  @override
  Future<bool> addCourse(Course course) async {
    logInfo("Web service, Adding course $course");

    final uri = Uri.parse('$baseUrl/insert');
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('access_token');
    final headers = {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };

    final body = jsonEncode({
      "tableName": "Course",
      "records": [course.toJsonNoId()],
    });

    final response = await httpClient.post(uri, headers: headers, body: body);

    if (response.statusCode == 200) {
      logInfo("Web service, Course added successfully");
      return Future.value(true);
    } else {
      logError("Web service, Error adding course: ${response.statusCode}");
    }

    return Future.value(false);
  }

  @override
  Future<bool> updateCourse(Course course) async {
    logInfo("Web service, Updating course $course");

    final uri = Uri.parse('$baseUrl/update');
    final headers = await _getHeaders();

    final courseJson = course.toJsonNoId();
    logInfo("Course JSON being sent: $courseJson"); // Add this line

    final body = jsonEncode({
      "tableName": "Course",
      "idColum": "_id",
      "idValue": course.id,
      "updates": courseJson,
    });

    logInfo("Full request body: $body"); // Add this line

    final response = await httpClient.put(uri, headers: headers, body: body);

    if (response.statusCode == 200) {
      logInfo("Web service, Course updated successfully");
      return Future.value(true);
    } else {
      logError(
        "Web service, Error updating course: ${response.statusCode}, ${response.body}",
      );
    }

    return Future.value(false);
  }

  @override
  Future<bool> deleteCourse(Course course) async {
    logInfo("Web service, Deleting course with id $course");
    final uri = Uri.parse('$baseUrl/delete');

    final headers = await _getHeaders();
    final body = jsonEncode({
      'tableName': "Course",
      'idColumn': '_id',
      'idValue': course.id,
    });

    final response = await httpClient.delete(uri, headers: headers, body: body);
    if (response.statusCode == 200) {
      logInfo("Web service, Course deleted successfully");
    } else {
      logError(
        "Web service, Error deleting course: ${response.statusCode} - ${response.body}",
      );
    }
    return Future.value(true);
  }

  @override
  Future<bool> deleteCourses() async {
    List<Course> courses = await getCourses();
    for (var course in courses) {
      await deleteCourse(course);
    }
    return Future.value(true);
  }
}
