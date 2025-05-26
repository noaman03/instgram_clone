class UserModel {
  String email;
  String name;
  String bio;
  String profile;
  List followers;
  List following;
  UserModel(this.bio, this.email, this.followers, this.following, this.profile,
      this.name);
}
