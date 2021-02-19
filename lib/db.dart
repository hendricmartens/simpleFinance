import 'package:hive/hive.dart';
import 'package:simple_finance/constants/db_constants.dart';
import 'package:simple_finance/model/account.dart';
import 'package:simple_finance/model/category.dart';
import 'package:simple_finance/model/transaction.dart';
import 'package:simple_finance/utils.dart';

class DB {
  //create transaction
  static bool transfer(Transaction transaction) {
    bool isValid = true;

    if (isValid) {
      Account account =
          Hive.box<Account>(BOX_ACCOUNT).get(transaction.accountId);
      account.balance += transaction.amount;
      account.save();

      Hive.box<Transaction>(BOX_TRANSACTION).add(transaction);
    }

    return isValid;
  }

  static bool deleteTransaction(int transactionId) {
    bool isValid = true;

    if (isValid) {
      var box = Hive.box<Transaction>(BOX_TRANSACTION);
      Transaction transaction = box.get(transactionId);

      Account account =
          Hive.box<Account>(BOX_ACCOUNT).get(transaction.accountId);
      account.balance -= transaction.amount;
      account.save();

      box.delete(transactionId);
    }

    return isValid;
  }

  static bool updateTransaction(int transactionId, Transaction transaction) {
    bool isValid = true;

    if (isValid) {
      deleteTransaction(transactionId);
      transfer(transaction);
    }
    return isValid;
  }

  static bool createAccount(Account account, String msg) {
    bool isValid = true;

    if (isValid) {
      Account newAccount = Account(
          name: account.name,
          categoryId: account.categoryId,
          balance: 0.0,
          timestamp: DateTime.now());
      Hive.box<Account>(BOX_ACCOUNT).add(newAccount);

      if (account.balance != 0.0) {
        return transfer(Transaction(
            accountId: newAccount.key,
            amount: account.balance,
            purpose: msg,
            timestamp: DateTime.now()));
      }
    }
    return isValid;
  }

  static bool updateAccount(int accountId, Account account) {
    bool isValid = true;

    if (isValid) {
      var box = Hive.box<Account>(BOX_ACCOUNT);
      Account accountToUpdate = box.get(accountId);

      box.put(
          accountId,
          Account(
              name: account.name,
              balance: accountToUpdate.balance,
              categoryId: account.categoryId,
              icon: account.icon,
              timestamp: accountToUpdate.timestamp));
    }

    return isValid;
  }

  static bool deleteAccount(int accountId) {
    bool isValid = true;
    if (isValid) {
      var box = Hive.box<Account>(BOX_ACCOUNT);

      var transBox = Hive.box<Transaction>(BOX_TRANSACTION);
      var transactions = Utils.filterTransactionsByAccount(
          transBox.values.toList(), accountId);
      for (Transaction transaction in transactions) {
        deleteTransaction(transaction.key);
      }

      box.delete(accountId);
    }
    return isValid;
  }

  static bool validateAccountName(String name, int key) {
    List<Account> accounts = Hive.box<Account>(BOX_ACCOUNT).values.toList();

    for (Account account in accounts) {
      if (account.name == name && key != account.key) {
        return false;
      }
    }

    return true;
  }

  static bool createCategory(Category category) {
    bool isValid = true;

    if (isValid) {
      var box = Hive.box<Category>(BOX_CATEGORY);
      box.add(Category(
          name: category.name,
          use: category.use,
          icon: category.icon,
          timestamp: DateTime.now()));
    }

    return isValid;
  }

  static bool updateCategory(int categoryId, Category category) {
    bool isValid = true;

    if (isValid) {
      var box = Hive.box<Category>(BOX_CATEGORY);
      Category categoryToUpdate = box.get(categoryId);

      if (categoryToUpdate.name != category.name) {}

      box.put(
          categoryId,
          Category(
              name: category.name,
              use: category.use,
              icon: category.icon,
              timestamp: categoryToUpdate.timestamp));
    }

    return isValid;
  }

  static bool validateCategoryName(String name, int key) {
    List<Category> categories =
        Hive.box<Category>(BOX_CATEGORY).values.toList();

    for (Category category in categories) {
      if (category.name == name && key != category.key) {
        return false;
      }
    }

    return true;
  }

  static bool deleteCategory(int categoryId) {
    bool isValid = true;
    if (isValid) {
      var box = Hive.box<Category>(BOX_CATEGORY);

      var accBox = Hive.box<Account>(BOX_ACCOUNT);
      List<Account> accounts =
          Utils.filterAccountsByCategory(accBox.values.toList(), categoryId);

      for (Account account in accounts) {
        account.categoryId = null;
        account.save();
      }

      box.delete(categoryId);
    }
    return isValid;
  }

  static void deleteAll() {
    Hive.box<Transaction>(BOX_TRANSACTION).clear();
    Hive.box<Account>(BOX_ACCOUNT).clear();
    Hive.box<Category>(BOX_CATEGORY).clear();
  }

  static Future<void> convertCurrency(
      String fromCurrency, String toCurrency) async {
    double rate = await Utils.getCurrencyRate(fromCurrency, toCurrency);

    List<Transaction> transactions =
        Hive.box<Transaction>(BOX_TRANSACTION).values.toList();

    for (Transaction trans in transactions) {
      trans.amount *= rate;
      await trans.save();
    }

    List<Account> accounts = Hive.box<Account>(BOX_ACCOUNT).values.toList();
    for (Account acc in accounts) {
      acc.balance *= rate;
      await acc.save();
    }
  }
}
