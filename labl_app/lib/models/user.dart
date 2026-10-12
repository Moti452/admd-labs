class User {
  String name;
  int? age;
  String? email;

  User({required this.name, this.age, this.email});

  String getDisplayAge() {
    return age?.toString() ?? "Age not specified";
  }
}