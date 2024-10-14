class User {
  String? name;
  String? age;
  User({
    this.name,
    this.age,
  });

  User.fromJson(Map<String, dynamic> json) {
    name = json["name"] ?? "";
    age = json["age"] ?? "";
  }
  Map<String, dynamic> toJson() => {
    "name": name ?? "",
    "age": age ?? "",
  };
}
