import 'package:hive_r_and_d/model_interface.dart';

class Model implements ModelInterface {
  String? userName;
  String? userData;

  Model.fromJson(json) {
    userName = json['userName'];
    userData = json['userData'];
  }

  @override
  Map<String, dynamic> toJson() {
    var map = <String, dynamic>{};
    map['userName'] = userName;
    map['userData'] = userData;
    return map;
  }
}
