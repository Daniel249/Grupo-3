import 'package:f_clean_template/features/auth/data/datasources/remote/authentication_source_service_Roble.dart';
import 'package:loggy/loggy.dart';
import '../../domain/models/course.dart';
import 'package:http/http.dart' as http;

import 'i_course_source.dart';

class RemoteCourseSource implements ICourseSource {
  String tokem = AuthenticationSourceServiceRoble().token;
  final http.Client httpClient;
  final String baseUrl =
      "https://roble-api.openlab.uninorte.edu.co/database/grupo3_e9c5902986/create-table";
  RemoteCourseSource(this.httpClient);

  @override
  Future<List<Course>> getCourses() async {
    List<Course> courses = [];

    return Future.value(courses);
  }

  @override
  Future<bool> addCourse(Course course) async {
    logInfo("Web service, Adding course $course");
    return Future.value(true);
  }

  @override
  Future<bool> updateCourse(Course course) async {
    logInfo("Web service, Updating course with id $course");
    return Future.value(true);
  }

  @override
  Future<bool> deleteCourse(Course course) async {
    logInfo("Web service, Deleting course with id $course");
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
