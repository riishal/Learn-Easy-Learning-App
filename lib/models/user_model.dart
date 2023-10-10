class UserModel {
  String? uid;
  String? fullName;
  String? email;
  String? profilepic;
  String? age;
  String? class0;
  String? location;
  UserModel(
      {this.uid,
      this.fullName,
      this.email,
      this.profilepic,
      this.age,
      this.class0,
      this.location});

  UserModel.fromMap(Map<String, dynamic> map) {
    uid = map["uid"];
    fullName = map["fullName"];
    email = map["email"];
    profilepic = map["profilepic"];
    age = map["age"];
    class0 = map["class0"];
    location = map["location"];
  }
  Map<String, dynamic> toMap() {
    return {
      "uid": uid,
      "fullName": fullName,
      "email": email,
      "profilepic": profilepic,
      "age": age,
      "class0": class0,
      "location": location
    };
  }
}
