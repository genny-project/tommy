class UserToken {
  String _token;
  int _id;

  UserToken(token);

  UserToken.map(dynamic obj) {
    this._token = obj['token'];
    this._id = obj['id'];
  }

  String get token => _token;
  int get id => _id;

  Map<String, dynamic> toMap() {
    var map = new Map<String, dynamic>();
    map["token"] = _token;

    if (id != null) {
      map['id'] = _id;
    }
    return map;
  }

  UserToken.fromMap(Map<String, dynamic> map) {
    this._token = map["token"];
    this._id = map["id"];
  }
  
}
