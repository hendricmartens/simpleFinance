import 'package:hive/hive.dart';

part 'category.g.dart';

@HiveType(typeId: 2)
class Category extends HiveObject {
  @HiveField(0)
  String name;
  @HiveField(1)
  String use;
  @HiveField(2)
  String icon;
  @HiveField(3)
  DateTime timestamp;
  @HiveField(4)
  double budget;

  Category({this.name, this.use, this.icon, this.timestamp, this.budget});
}
