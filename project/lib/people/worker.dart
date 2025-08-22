import 'package:firebase_auth/firebase_auth.dart';

class Worker {
  String? name;
  String? id;
  List<int>? ratings;
  Worker(this.name,this.id){
    ratings = [];
  }
  void work(User user){
    
  }
}
class StreetCleaner extends Worker{
  StreetCleaner(super.name, super.id);
  
}
class Scavenger extends Worker{
  Scavenger(super.name, super.id);
}
class ConstructionLabourer extends Worker{
  ConstructionLabourer(super.name, super.id);
}
class Plumber extends Worker{
  Plumber(super.name, super.id);
}
class Electritian extends Worker{
  Electritian(super.name, super.id);
}