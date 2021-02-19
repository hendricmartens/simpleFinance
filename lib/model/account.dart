import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:simple_finance/model/transaction.dart';

part 'account.g.dart';

@HiveType(typeId: 0)
class Account extends HiveObject {
  @HiveField(0)
  String name;

  @HiveField(1)
  double balance;

  @HiveField(2)
  int categoryId;

  @HiveField(3)
  DateTime timestamp;

  @HiveField(4)
  String icon;

  Account({this.name, this.balance = 0.0, this.categoryId, this.timestamp, this.icon});

}
