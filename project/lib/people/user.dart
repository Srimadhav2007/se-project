class User {
  String ? _name;
  String? _id;
  String ? _password;
  User(this._name,this._password);
  String? getPassword(){
    return _password;
  }
  String? getName(){
    return _name;
  }
  String? getId(){
    return _id;
  }
  
}