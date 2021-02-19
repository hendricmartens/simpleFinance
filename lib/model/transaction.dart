
import 'package:hive/hive.dart';

part 'transaction.g.dart';

@HiveType(typeId: 1)
class Transaction extends HiveObject{

  @HiveField(0)
  double amount;

  @HiveField(1)
  int accountId;

  @HiveField(2)
  DateTime timestamp;

  @HiveField(3)
  String purpose;

  @HiveField(4)
  String icon;


  Transaction({this.amount, this.accountId, this.timestamp, this.purpose="", this.icon});

}