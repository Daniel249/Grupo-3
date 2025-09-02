class Course {
  Course({
    this.id,
    required this.name,
    required this.description,
    //required this.quantity,
  });

  String? id;
  String name;
  String description;
  List<String> studentsNames = [];
  List<String> teachersNames = [];
  //int quantity;
}
