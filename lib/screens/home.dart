import 'package:date_util/date_util.dart';
import 'package:fading_edge_scrollview/fading_edge_scrollview.dart';
import 'package:flutter/material.dart';
import 'package:flutter_swiper/flutter_swiper.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:month_picker_dialog/month_picker_dialog.dart';
import 'package:provider/provider.dart';
import 'package:simple_finance/constants/db_constants.dart';
import 'package:simple_finance/constants/model_constants.dart';
import 'package:simple_finance/constants/route_constants.dart';
import 'package:simple_finance/constants/ui_constants.dart';
import 'package:simple_finance/db.dart';
import 'package:simple_finance/languages/language.dart';
import 'package:simple_finance/model/account.dart';
import 'package:simple_finance/model/category.dart';
import 'package:simple_finance/model/transaction.dart';
import 'package:simple_finance/provider/preferences.dart';
import 'package:simple_finance/utils.dart';
import 'package:intl/intl.dart';
import 'package:simple_finance/widgets/shadow_box.dart';
import 'package:simple_finance/widgets/header.dart';
import 'package:simple_finance/widgets/popup_dialog.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

class HomeScreen extends StatelessWidget {
  final GlobalKey<NavigatorState> navigatorKey;

  HomeScreen(this.navigatorKey);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Theme.of(context).backgroundColor,
        body: SafeArea(
          child: SingleChildScrollView(
            child: Container(
              margin: EdgeInsets.only(top: default_page_margin.vertical),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [TransactionsList(navigatorKey), AccountsList()],
              ),
            ),
          ),
        ));
  }
}

class TransactionsList extends StatefulWidget {
  final GlobalKey<NavigatorState> navigatorKey;

  TransactionsList(this.navigatorKey);

  @override
  _TransactionsListState createState() => _TransactionsListState();
}

class _TransactionsListState extends State<TransactionsList> {
  DateTime selectedDate = DateTime(DateTime.now().year, DateTime.now().month);

  @override
  Widget build(BuildContext context) {
    var _usrPrefs = Provider.of<Preferences>(context, listen: false);
    Size size = MediaQuery.of(context).size;
    return Container(
      margin: EdgeInsets.only(bottom: default_padding),
      child: Column(
        children: [
          Header(
            headline: Language.of(context).transactions,
            margin: EdgeInsets.only(
                left: default_page_margin.horizontal,
                right: default_page_margin.horizontal,
                bottom: default_padding / 3),
            trailing: ShadowBox(
              padding: EdgeInsets.all(default_padding / 4),
              shadowRadius: 1,
              onPressed: () {
                showMonthPicker(
                  context: context,
                  lastDate: DateTime.now(),
                  initialDate: selectedDate,
                  locale: _usrPrefs.locale,
                ).then((date) {
                  if (date != null) {
                    setState(() {
                      selectedDate = date;
                    });
                  }
                });
              },
              child: Container(
                child: Text(DateFormat('MMMM y', _usrPrefs.language)
                    .format(selectedDate)),
              ),
            ),
          ),
          Container(
            height: size.height * transaction_card_height,
            child: ValueListenableBuilder(
              valueListenable:
                  Hive.box<Transaction>(BOX_TRANSACTION).listenable(),
              builder: (context, Box<Transaction> box, _) {
                List<Transaction> transactions =
                    Utils.filterTransactionsBetweenDates(
                        box.values.toList(),
                        selectedDate,
                        selectedDate.add(Duration(
                            days: DateUtil().daysInMonth(
                                    selectedDate.month, selectedDate.year) -
                                1)));
                transactions = Utils.sortTransactionsByDate(transactions);
                if (transactions.isEmpty)
                  return Center(
                    child: Text(Language.of(context).no_transactions),
                  );
                return ListView.builder(
                  itemCount: transactions.length,
                  scrollDirection: Axis.horizontal,
                  itemBuilder: (context, index) {
                    return Container(
                        margin: EdgeInsets.only(
                            left: index == 0 ? default_padding / 2 : 0),
                        child: _buildTransactionTile(transactions[index]));
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTransactionTile(Transaction transaction) {
    var usrPrefs = Provider.of<Preferences>(context, listen: false);
    Size size = MediaQuery.of(context).size;
    return Container(
      width: size.width * transaction_card_width,
      margin: EdgeInsets.only(left: default_page_margin.horizontal / 4),
      constraints:
          BoxConstraints(minWidth: size.width * transaction_card_width),
      child: ShadowBox(
        shadowRadius: 3,
        padding: EdgeInsets.symmetric(
            vertical: default_padding / 4, horizontal: default_padding / 2),
        child: Column(
          children: [
            Flexible(
              flex: 2,
              child: Container(
                alignment: Alignment.centerLeft,
                child: Text(
                  Utils.formatMoney(
                      transaction.amount, usrPrefs.language, usrPrefs.decimal,
                      compactTreshold: transaction_card_money_treshold,
                      currency: usrPrefs.currency),
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                      fontSize: money.fontSize,
                      fontWeight: money.fontWeight,
                      color: transaction.amount < 0
                          ? negative_color
                          : positive_color),
                ),
              ),
            ),
            Flexible(
              flex: 2,
              child: Container(
                  margin: EdgeInsets.only(top: 2),
                  alignment: Alignment.topLeft,
                  child: Text(
                    (transaction.purpose == null || transaction.purpose.isEmpty)
                        ? " -"
                        : transaction.purpose,
                    overflow: TextOverflow.ellipsis,
                    maxLines: 2,
                    style: Theme.of(context).textTheme.bodyText2,
                  )),
            ),
            Flexible(
              flex: 1,
              child: Container(
                alignment: Alignment.bottomLeft,
                child: Text(
                  Hive.box<Account>(BOX_ACCOUNT)
                      .get(transaction.accountId)
                      .name,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.subtitle2,
                ),
              ),
            ),
            Flexible(
              flex: 1,
              child: Container(
                alignment: Alignment.bottomLeft,
                child: Text(
                    transaction.timestamp.isAfter(DateTime(DateTime.now().year,
                            DateTime.now().month, DateTime.now().day))
                        ? Language.of(context).today
                        : (transaction.timestamp.isAfter(DateTime(
                                    DateTime.now().year,
                                    DateTime.now().month,
                                    DateTime.now().day)
                                .subtract(Duration(days: 1)))
                            ? Language.of(context).yesterday
                            : DateFormat('dd MMM yy')
                                .format(transaction.timestamp)),
                    style: Theme.of(context).textTheme.subtitle2),
              ),
            ),
          ],
        ),
        onPressed: () {
          widget.navigatorKey.currentState
              .pushNamed(route_transaction, arguments: transaction);
        },
        onLongPress: () {
          showDialog(
              useRootNavigator: false,
              context: context,
              builder: (context) => PopupDialog(
                  question: Language.of(context).delete_transaction,
                  onYes: () {
                    DB.deleteTransaction(transaction.key);
                  },
                  onNo: () {}));
        },
      ),
    );
  }
}

class AccountsList extends StatefulWidget {
  @override
  _AccountsListState createState() => _AccountsListState();
}

class _AccountsListState extends State<AccountsList> {
  DateTime _selectedMonth;

  @override
  Widget build(BuildContext context) {
    if (_selectedMonth == null) {
      _selectedMonth = DateTime(DateTime.now().year, DateTime.now().month);
    }

    var accountBox = Hive.box<Account>(BOX_ACCOUNT);
    var categoryBox = Hive.box<Category>(BOX_CATEGORY);
    var transBox = Hive.box<Transaction>(BOX_TRANSACTION);
    Size size = MediaQuery.of(context).size;

    List<Category> categories =
        Utils.sortCategoriesByDate(categoryBox.values.toList())
            .reversed
            .toList();

    return Container(
      margin: EdgeInsets.symmetric(horizontal: default_page_margin.horizontal),
      child: Column(
        children: [
          Header(
              headline: Language.of(context).balance,
              margin: EdgeInsets.only(bottom: default_padding / 2)),
          ValueListenableBuilder(
              valueListenable: accountBox.listenable(),
              builder: (context, Box<Account> box, _) {
                //preparing swiper cards
                List<Account> accounts =
                    Utils.sortAccountsByDate(box.values.toList())
                        .reversed
                        .toList();
                List<Transaction> transactions = transBox.values.toList();

                Map<int, List<Transaction>> transMap =
                    Map<int, List<Transaction>>();

                for (Account account in accounts) {
                  transMap[account.key] = Utils.filterTransactionsByAccount(
                      transactions, account.key);
                }

                List<Widget> categoryCards = List<Widget>();

                categoryCards.add(_buildCategoryCard(
                    accounts, Language.of(context).all_accounts, transMap));

                for (Category category in categories) {
                  categoryCards.add(_buildCategoryCard(
                      Utils.filterAccountsByCategory(accounts, category.key),
                      category.name,
                      transMap));
                }

                return Container(
                  height: size.height * swiper_card_height,
                  child: Swiper(
                    pagination: new SwiperPagination(
                      alignment: Alignment.bottomCenter,
                      builder: swiperDot,
                    ),
                    loop: false,
                    viewportFraction: 1,
                    scale: 0.9,
                    physics: AlwaysScrollableScrollPhysics(),
                    curve: Curves.linear,
                    itemCount: categoryCards.length,
                    itemBuilder: (context, index) {
                      return categoryCards[index];
                    },
                  ),
                );
              }),
        ],
      ),
    );
  }

  Widget _buildCategoryCard(List<Account> accounts, String categoryName,
      Map<int, List<Transaction>> transMap) {
    var usrPrefs = Provider.of<Preferences>(context, listen: false);

    List<Transaction> temp = List<Transaction>();
    for (Account account in accounts) {
      temp.addAll(transMap[account.key]);
    }

    List<Tuple<DateTime, double>> balance =
        Utils.foldTransactionsToDay(temp, true).where((element) {
      return element.key
              .isAfter(_selectedMonth.subtract(Duration(milliseconds: 1))) &&
          element.key.isBefore(
              DateTime(_selectedMonth.year, _selectedMonth.month + 1));
    }).toList();
    if (balance.length == 1) {
      balance.add(
          Tuple(key: balance.first.key.subtract(Duration(days: 1)), value: 0));
    }

    double avg = temp.fold<double>(0, (sum, element) {
          return sum + element.amount;
        }) /
        temp.length;

    double sum = accounts.fold<double>(0, (double sum, Account account) {
      return sum + account.balance;
    });

    //DateTimeIntervalType intervalType = DateTimeIntervalType.months;
    //double interval = 0.25;
    //DateFormat dateFormat = DateFormat('MMM dd', usrPrefs.language);

    return ShadowBox(
        shadowRadius: 3,
        padding: EdgeInsets.symmetric(
            vertical: default_padding / 2, horizontal: default_padding / 2),
        child: Column(
          children: [
            Flexible(
              child: Container(
                alignment: Alignment.topLeft,
                child: Text(
                  categoryName,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.headline2,
                ),
              ),
            ),
            Expanded(
              flex: 3,
              child: Container(
                margin: EdgeInsets.only(
                    left: default_padding / 2,
                    right: default_padding / 2,
                    bottom: default_padding / 1.5,
                    top: default_padding / 4),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                        flex: 3,
                        child: FadingEdgeScrollView.fromScrollView(
                          gradientFractionOnEnd: 0.9,
                          gradientFractionOnStart: 0,
                          child: ListView.builder(
                              controller: ScrollController(),
                              itemCount: accounts.length,
                              itemBuilder: (context, index) {
                                Account account = accounts[index];
                                return Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Container(
                                        child: Text(
                                      account.name,
                                      overflow: TextOverflow.ellipsis,
                                      style:
                                          Theme.of(context).textTheme.bodyText1,
                                    )),
                                    Text(
                                      Utils.formatMoney(account.balance,
                                          usrPrefs.language, usrPrefs.decimal,
                                          currency: usrPrefs.currency),
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(
                                        color: account.balance < 0
                                            ? negative_color
                                            : (account.balance > 0
                                                ? positive_color
                                                : zeroColor),
                                      ),
                                    )
                                  ],
                                );
                              }),
                        )),
                    Flexible(
                      flex: 2,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(Language.of(context).total,
                              style: Theme.of(context).textTheme.headline5),
                          Text(
                            Utils.formatMoney(
                                sum, usrPrefs.language, usrPrefs.decimal,
                                currency: usrPrefs.currency),
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                                fontWeight: money.fontWeight,
                                fontSize: money.fontSize,
                                color: sum < 0
                                    ? negative_color
                                    : (sum > 0 ? positive_color : zeroColor)),
                          )
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Flexible(
              flex: 5,
              fit: FlexFit.tight,
              child: Container(
                margin: EdgeInsets.only(
                    right: default_padding / 2, bottom: default_padding),
                child: Column(children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      ShadowBox(
                          padding: EdgeInsets.all(default_padding / 4),
                          shadowRadius: 1,
                          child: Container(
                            child: Text(DateFormat('MMMM y', usrPrefs.language)
                                .format(_selectedMonth)),
                          ),
                          onPressed: () {
                            showMonthPicker(
                              context: context,
                              lastDate: DateTime.now(),
                              initialDate: _selectedMonth,
                              locale: usrPrefs.locale,
                            ).then((date) {
                              if (date != null) {
                                setState(() {
                                  this._selectedMonth = date;
                                });
                              }
                            });
                          }),
                    ],
                  ),
                  Expanded(
                      child: Container(
                    child: SfCartesianChart(
                        plotAreaBorderWidth: 0,
                        primaryXAxis: DateTimeAxis(
                            isVisible: false,
                            minimum: _selectedMonth.subtract(Duration(days: 1)),
                            maximum: DateTime(_selectedMonth.year,
                                _selectedMonth.month + 1, 1),
                            majorGridLines: MajorGridLines(width: 0),
                            labelAlignment: LabelAlignment.start),
                        primaryYAxis: NumericAxis(
                          labelStyle: graph_label,
                          majorTickLines: MajorTickLines(width: 0),
                          axisLine: AxisLine(width: 0),
                          numberFormat: avg.abs() > graph_compact_treshold
                              ? NumberFormat.compact(locale: "en")
                              : NumberFormat(number_format, usrPrefs.language),
                          rangePadding: ChartRangePadding.auto,
                          labelFormat:
                              Utils.addCurrency("{value}", usrPrefs.currency),
                        ),
                        tooltipBehavior: TooltipBehavior(enable: true),
                        series: [
                          ColumnSeries<Tuple<DateTime, double>, DateTime>(
                              dataSource: balance,
                              xValueMapper:
                                  (Tuple<DateTime, double> tuple, _) =>
                                      tuple.key,
                              yValueMapper:
                                  (Tuple<DateTime, double> tuple, _) =>
                                      tuple.value.round(),
                              width: 0.8,
                              borderRadius:
                                  BorderRadius.all(default_box_radius),
                              pointColorMapper:
                                  (Tuple<DateTime, double> tuple, _) =>
                                      tuple.value < 0
                                          ? graph_negative
                                          : graph_positive,
                              name: Language.of(context).balance),
                        ]),
                  )),
                ]),
              ),
            )
          ],
        ));
  }
}
