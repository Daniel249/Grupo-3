import 'package:loggy/loggy.dart';
import '../../domain/models/course.dart';
import 'package:http/http.dart' as http;

import 'i_remote_course_source.dart';

class RemoteCourseSource implements IRemoteCourseSource {
  final http.Client httpClient;

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
