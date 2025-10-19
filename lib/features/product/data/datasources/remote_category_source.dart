import 'dart:convert';
import 'package:f_clean_template/features/product/domain/models/group.dart';
import 'package:http/http.dart' as http;
import 'package:loggy/loggy.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../domain/models/category.dart';
import 'i_category_source.dart';
import '../../domain/models/group.dart';
import 'i_category_source.dart';

class RemoteCategorySource implements ICategorySource {
  final http.Client httpClient;
  final String baseUrl =
      "https://roble-api.openlab.uninorte.edu.co/database/pruebadavid_a9af0fb6f8";

  RemoteCategorySource(this.httpClient);

  @override
  Future<List<Category>> getCategories(String? courseId) async {
    if (courseId == null) {
      logError("Course ID is null. Cannot fetch categories.");
      return [];
    }
    try {
      final headers = await _getHeaders();
      final response = await httpClient.get(
        Uri.parse('$baseUrl/read?tableName=Category&CourseID=$courseId'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        final dynamic decodedJson = jsonDecode(response.body);

        List<dynamic> categoriesData;
        if (decodedJson is List) {
          categoriesData = decodedJson;
        } else if (decodedJson is Map<String, dynamic>) {
          if (decodedJson.containsKey('Category')) {
            categoriesData = decodedJson['Category'] as List<dynamic>;
          } else if (decodedJson.containsKey('data')) {
            categoriesData = decodedJson['data'] as List<dynamic>;
          } else {
            categoriesData = [decodedJson];
          }
        } else {
          logError(
            "Unexpected API response structure: ${decodedJson.runtimeType}",
          );
          return [];
        }
        final List<Category> retCategories = categoriesData
            .map(
              (categoryJson) =>
                  _parseCategoryFromJson(categoryJson as Map<String, dynamic>),
            )
            .toList();
        return retCategories;
      } else if (response.statusCode == 401) {
        logError("Authentication failed. Token may be expired or invalid.");
        throw Exception('Authentication required');
      } else {
        logError(
          "Failed to get categories: ${response.statusCode} - ${response.body}",
        );
        return [];
      }
    } catch (e) {
      logError("Error getting categories: $e");
      return [];
    }
  }

  Category _parseCategoryFromJson(Map<String, dynamic> json) {
    return Category(
      id: json['_id']?.toString() ?? json['id']?.toString() ?? '0',
      courseID: json['CourseID']?.toString(),
      name: (json['Name'] ?? '').toString(),
      isRandomSelection:
          (json['IsRandom'] ?? false) == true ||
          (json['IsRandomSelection'] ?? false) == true,
      groupSize: (json['CourseSize'] is int)
          ? json['CourseSize'] as int
          : int.tryParse('${json['CourseSize'] ?? 1}') ?? 1,
    );
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
  Future<bool> addCategory(Category category) async {
    logInfo("Web service, Adding category $category");

    final uri = Uri.parse('$baseUrl/insert');
    final headers = await _getHeaders();

    // Convert category to JSON without groups (they're in separate table)
    final categoryJson = {
      'CourseID': category.courseID,
      'Name': category.name,
      'IsRandom': category.isRandomSelection,
      //'IsRandomSelection': category.isRandomSelection,
      'CourseSize': category.groupSize,
      'GroupsId': [], // Groups handled separately
    };

    final body = jsonEncode({
      "tableName": "Category",
      "records": [categoryJson],
    });
    logInfo("Request body: $body");
    final response = await httpClient.post(uri, headers: headers, body: body);

    if (response.statusCode == 200) {
      logInfo("Web service, Category added successfully");
      return Future.value(true);
    } else {
      logError(
        "Web service, Error adding category: ${response.statusCode} - ${response.body}",
      );
      return Future.value(false);
    }
  }

  @override
  Future<bool> updateCategory(Category category) async {
    logInfo("Web service, Updating category ${category.id}");

    final uri = Uri.parse('$baseUrl/update');
    final headers = await _getHeaders();

    // Convert category to JSON without groups
    final categoryJson = {
      'CourseID': category.courseID,
      'Name': category.name,
      'IsRandomSelection': category.isRandomSelection ? 1 : 0,
      'CourseSize': category.groupSize,
      // No groups field - they're stored separately
    };

    final body = jsonEncode({
      "tableName": "Category",
      "idColumn": "_id",
      "idValue": category.id,
      "updates": categoryJson,
    });

    final response = await httpClient.put(uri, headers: headers, body: body);

    if (response.statusCode == 200) {
      logInfo("Web service, Category updated successfully");
      return Future.value(true);
    } else {
      logError(
        "Web service, Error updating category: ${response.statusCode} - ${response.body}",
      );
      return Future.value(false);
    }
  }

  @override
  Future<bool> deleteCategory(Category category) async {
    logInfo("Web service, Deleting category with id ${category.id}");

    final uri = Uri.parse('$baseUrl/delete');
    final headers = await _getHeaders();

    final body = jsonEncode({
      'tableName': "Category",
      'idColumn': '_id',
      'idValue': category.id,
    });

    final response = await httpClient.delete(uri, headers: headers, body: body);

    if (response.statusCode == 200) {
      logInfo("Web service, Category deleted successfully");
      return Future.value(true);
    } else {
      logError(
        "Web service, Error deleting category: ${response.statusCode} - ${response.body}",
      );
      return Future.value(false);
    }
  }
}
