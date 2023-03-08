import '../config/config.dart';

class User {
  final String _userUID;
  final String _userName;
  final String _userEmail;
  final String _userImageUrl;
  final List _userProjects;

  User(this._userUID, this._userName, this._userEmail, this._userImageUrl,this._userProjects);

  User.fromJson(Map<String, dynamic> json)
      : _userUID = json[KanQ.userUID],
        _userName = json[KanQ.userName],
        _userEmail = json[KanQ.userEmail],
        _userImageUrl = json[KanQ.userImageUrl],
        _userProjects = json[KanQ.userProjects];

  Map<String, dynamic> toJson() => {
        KanQ.userUID: _userUID,
        KanQ.userName: _userName,
        KanQ.userEmail: _userEmail,
        KanQ.userImageUrl: _userImageUrl,
        KanQ.userProjects: _userProjects,
      };
}
