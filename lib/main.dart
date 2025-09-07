import 'package:f_clean_template/features/product/data/datasources/local/local_product_source.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:loggy/loggy.dart';

import 'central.dart';
import 'core/app_theme.dart';

import 'features/auth/data/datasources/remote/authentication_source_service.dart';
import 'features/auth/data/datasources/remote/i_authentication_source.dart';
import 'features/auth/data/repositories/auth_repository.dart';
import 'features/auth/domain/repositories/i_auth_repository.dart';
import 'features/auth/domain/use_case/authentication_usecase.dart';
import 'features/auth/ui/controller/authentication_controller.dart';
import 'features/product/data/datasources/i_remote_product_source.dart';
import 'features/product/data/datasources/remote_product_source.dart';
import 'features/product/data/repositories/product_repository.dart';
import 'features/product/domain/repositories/i_product_repository.dart';
import 'features/product/domain/repositories/i_course_repository.dart';
import 'features/product/domain/use_case/product_usecase.dart';
import 'features/product/ui/controller/product_controller.dart';
//import 'features/product/data/datasources/i_remote_course_source.dart';
import 'features/product/data/datasources/remote_course_source.dart';
import 'features/product/data/repositories/course_repository.dart';
import 'features/product/domain/use_case/course_usecase.dart';
import 'features/product/ui/controller/course_controller.dart';
import 'features/product/data/datasources/i_course_source.dart';
import 'features/product/data/datasources/local/local_course_source.dart';
import 'features/product/data/datasources/local/local_category_source.dart';
import 'features/product/data/datasources/i_category_source.dart';
import 'features/product/data/repositories/category_repository.dart';
import 'features/product/domain/repositories/i_category_repository.dart';
import 'features/product/domain/use_case/category_usecase.dart';
import 'features/product/ui/controller/category_controller.dart';
import 'dart:ui'; // for PlatformDispatcher

void main() {
  // 🔹 Make Flutter print full stack traces instead of folding them
  FlutterError.demangleStackTrace = (StackTrace stack) {
    // You can do filtering here if needed,
    // but returning the stack as-is gives you the full trace with file + line.
    return stack;
  };

  // 🔹 Catch uncaught async errors and print them with stack traces
  PlatformDispatcher.instance.onError = (error, stack) {
    debugPrint('Uncaught async error: $error');
    debugPrint('Stack trace: $stack');
    return true; // mark as handled so Flutter doesn't double-print
  };

  Loggy.initLoggy(logPrinter: const PrettyPrinter(showColors: true));

  Get.put(http.Client(), tag: 'apiClient');

  // Auth
  Get.put<IAuthenticationSource>(AuthenticationSourceService());
  Get.put<IAuthRepository>(AuthRepository(Get.find()));
  Get.put(AuthenticationUseCase(Get.find()));
  Get.put(AuthenticationController(Get.find()));

  // Product
  //Get.put<IProductSource>(
  //  RemoteProductSource(Get.find<http.Client>(tag: 'apiClient')),
  //);
  Get.put<IProductSource>(LocalProductSource());
  Get.put<IProductRepository>(ProductRepository(Get.find()));
  Get.put(ProductUseCase(Get.find()));
  Get.lazyPut(() => ProductController());

  // Course
  //Get.put<IRemoteCourseSource>(
  //  RemoteCourseSource(Get.find<http.Client>(tag: 'apiClient')),
  //);
  Get.put<ICourseSource>(LocalCourseSource());
  Get.put<ICourseRepository>(CourseRepository(Get.find()));
  Get.put(CourseUseCase(Get.find()));
  Get.lazyPut(() => CourseController());

  // Category
  Get.put<ICategorySource>(LocalCategorySource());
  // or for remote: Get.put<ICategorySource>(RemoteCategorySource(Get.find<http.Client>(tag: 'apiClient')));
  Get.put<ICategoryRepository>(CategoryRepository(Get.find()));
  Get.put(CategoryUseCase(Get.find()));
  Get.lazyPut(() => CategoryController());

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Clean template',
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      debugShowCheckedModeBanner: false,
      home: const Central(),
      enableLog: true, // 🔹 Enables GetX logs
      logWriterCallback: (String text, {bool isError = false}) {
        // 🔹 Every log from GetX will come through here
        debugPrint('GETX LOG: $text');
        if (isError) {
          // 🔹 Print stack trace when there is an error
          debugPrint(StackTrace.current.toString());
        }
      },
    );
  }
}
