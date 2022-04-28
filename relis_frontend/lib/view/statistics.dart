import 'dart:async';
import 'dart:collection';
import 'dart:math';
import 'dart:convert';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:relis/authentication/user.dart';
import 'package:relis/globals.dart';
import 'package:relis/widget/color_extensions.dart';
import 'package:relis/widget/indicator.dart';

//import 'package:flutter_svg/flutter_svg.dart';

class StatisticsPage extends StatefulWidget {
  final List<Color> availableColors = const [
    Colors.purpleAccent,
    Colors.yellow,
    Colors.lightBlue,
    Colors.orange,
    Colors.pink,
    Colors.redAccent,
  ];
  static const routeName = '/statisticsPage';

  @override
  _StatisticsPageState createState() => _StatisticsPageState();
}

class _StatisticsPageState extends State<StatisticsPage> {
  int touchedIndexPieChart = -1;
  int touchedIndex = -1;
  ScrollController wrapController = new ScrollController();
  final Color barBackgroundColor = const Color(0xff78ffbf);
  final Duration animDuration = const Duration(milliseconds: 250);
  var pieChartData = [];
  List<double> weeklyVal = [0, 0, 0, 0, 0, 0, 0];
  List<String> weeks = ["Mon", "Tue", "Wed", "Thu", "Fri", "Sat", "Sun"];
  List<String> weekDay = ["Mon", "Tue", "Wed", "Thu", "Fri", "Sat", "Sun"];
  List<String> weekStatsDay = ["Mon", "Tue", "Wed", "Thu", "Fri", "Sat", "Sun"];
  Map<String, double>? weekData;
 
  @override
  void initState() {
    super.initState();
    getWeeks();
    createWeklyValues();
    getGenreWiseReadBooksStats();
    getPieChartData();
  }

  getPieChartData() {
    for(var key in category.keys){
      print("Key: $key,");
      print("category: ${category[key]},");
      if(category[key].containsKey("pagesRead") && category[key]["pagesRead"] > 0) {
        print("\tpagesRead: ${category[key]["pagesRead"]},");
        pieChartData.add(key);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: appBackgroundColor,
      appBar: AppBar(
        title: Text("Your Statistics"),
        backgroundColor: appBarBackgroundColor,
        shadowColor: appBarShadowColor,
        elevation: 2.0,
      ),
      // body: LayoutBuilder(
      //   builder: (BuildContext context, BoxConstraints constraints) {
      //     if (constraints.maxWidth > 700) {
      //       return desktopView();
      //     } else {
      //       return desktopView();
      //     }
      //   },
      // ),
      body: desktopView(),
    );
  }

  Widget desktopView() {
    return SingleChildScrollView(
      // child: Column(
      child: Wrap(
        alignment: WrapAlignment.start,
        crossAxisAlignment: WrapCrossAlignment.start,
        runAlignment: WrapAlignment.start,
        spacing: 10.00,
        runSpacing: 10.00,
        direction: Axis.horizontal,
        verticalDirection: VerticalDirection.down,
        clipBehavior: Clip.antiAliasWithSaveLayer,
        children: [
          viewButton("Genre-wise Reading Stats.", "stats1", Stats1()),
          if(weeklyVal != [])
            viewButton("Weekly Reading Stats.", "stats2", Stats2()),
        ],
      ),
    );
  }

  Widget Stats1() {
    return pieChartData.length > 0 ? Container(
      height: MediaQuery.of(context).size.height / 2,
      // width: MediaQuery.of(context).size.width,
      // width: MediaQuery.of(context).size.width > 700 ? MediaQuery.of(context).size.width / 2 : MediaQuery.of(context).size.width,
      padding: EdgeInsets.fromLTRB(30, 15, 30, 15),
      margin: EdgeInsets.fromLTRB(30, 15, 30, 15),
      decoration: BoxDecoration(
        // color: Colors.black54,
        color: mainAppBlue,
        borderRadius: BorderRadius.all(Radius.circular(10)),
      ),
      constraints: BoxConstraints(
        minWidth: MediaQuery.of(context).size.width / 1.5,
      ),
      // child: Row(
      child: Wrap(
        alignment: WrapAlignment.center,
        crossAxisAlignment: WrapCrossAlignment.center,
        runAlignment: WrapAlignment.spaceEvenly,
        spacing: 5.00,
        runSpacing: 15.00,
        direction: MediaQuery.of(context).size.width > 700 ? Axis.vertical : Axis.horizontal,
        verticalDirection: VerticalDirection.down,
        clipBehavior: Clip.antiAliasWithSaveLayer,
        children: <Widget>[
          Expanded(
            flex: 2,
            child: AspectRatio(
              aspectRatio: MediaQuery.of(context).size.width > 700 ? 1.5 : 2,
              child: PieChart(
                PieChartData(
                  pieTouchData: PieTouchData(
                    touchCallback: (FlTouchEvent event, pieTouchResponse) {
                      setState(() {
                        if (!event.isInterestedForInteractions || pieTouchResponse == null || pieTouchResponse.touchedSection == null) {
                          touchedIndexPieChart = -1;
                          return;
                        }
                        touchedIndexPieChart = pieTouchResponse.touchedSection!.touchedSectionIndex;
                      });
                    },
                  ),
                  borderData: FlBorderData(
                    show: false,
                  ),
                  sectionsSpace: touchedIndexPieChart == -1 ? 0 : 5,
                  centerSpaceRadius: MediaQuery.of(context).size.width / 30,
                  sections: showingSections(),
                ),
              )
            )
          ),
          Expanded(
            flex: 1,
            child: Wrap(
                alignment: WrapAlignment.start,
                crossAxisAlignment: WrapCrossAlignment.center,
                runAlignment: WrapAlignment.spaceAround,
                spacing: 10.00,
                runSpacing: 5.00,
                direction: MediaQuery.of(context).size.width > 700 ? Axis.vertical : Axis.horizontal,
                verticalDirection: VerticalDirection.down,
                clipBehavior: Clip.antiAliasWithSaveLayer,
                children: <Widget>[
                  for(var key in pieChartData)
                    category[key]["pagesRead"] > 0 ? MaterialButton(
                      onPressed: () {
                        if(touchedIndexPieChart == pieChartData.indexOf(key))
                          touchedIndexPieChart = -1;
                        else
                          touchedIndexPieChart = pieChartData.indexOf(key);
                        setState(() {});
                      },
                      child: Indicator(
                        color: category[key]["categoryColor"],
                        text: '${category[key]["categoryName"]}',
                        isSquare: true,
                        touchedPieChart: touchedIndexPieChart == -1 ? "-1" : category[pieChartData[touchedIndexPieChart]]["categoryName"],
                      ),
                    ) : SizedBox(),
                ],
              ),
          ),
        ],
      ),
    ) : Container(
      alignment: Alignment.center,
      padding: EdgeInsets.symmetric(vertical: 10.00, horizontal: 20.00),
      margin: EdgeInsets.symmetric(vertical: 20.00, horizontal: 20.00),
      width: 600,
      height: 200,
      decoration: categoryDecoration,
      child: Text("No Books Read Yet!!", style: TextStyle(color: Colors.white, fontSize: 30),),
    );
  }

  Widget Stats2() {
    print("weeklyVal: ");
    print(weeklyVal);
    return Container(
      //color: Colors.blue,
      height: MediaQuery.of(context).size.height / 2,
      // width: MediaQuery.of(context).size.width > 700 ? MediaQuery.of(context).size.width / 2 : MediaQuery.of(context).size.width,
      padding: EdgeInsets.fromLTRB(30, 15, 30, 15),
      margin: EdgeInsets.fromLTRB(30, 15, 30, 15),
      decoration: BoxDecoration(
        // color: Colors.black54,
        color: mainAppBlue,
        borderRadius: BorderRadius.all(Radius.circular(10)),
      ),
      constraints: BoxConstraints(
        minWidth: MediaQuery.of(context).size.width / 1.5,
      ),
      child: Container(
        padding: EdgeInsets.all(5),
        decoration: BoxDecoration(
          color: mainAppAmber,
          borderRadius: BorderRadius.all(Radius.circular(10)),
        ),
        child: Expanded(
          child: AspectRatio(
            aspectRatio: MediaQuery.of(context).size.width > 700 ? 1.5 : 1,
            child: Container(
              // margin: EdgeInsets.all(4),
              padding: EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: mainAppBlue,
                borderRadius: BorderRadius.all(Radius.circular(10)),
              ),
              child: BarChart(
                mainBarData(),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget viewButton(String containerName, String visibilityName, Widget containerChild,) {
    // return Column(
    //   mainAxisSize: MainAxisSize.min,
    //   mainAxisAlignment: MainAxisAlignment.start,
    return Container(
      width: MediaQuery.of(context).size.width,
      child: Wrap(
        alignment: WrapAlignment.center,
        crossAxisAlignment: WrapCrossAlignment.center,
        runAlignment: WrapAlignment.spaceAround,
        spacing: 10.00,
        runSpacing: 20.00,
        direction: Axis.horizontal,
        verticalDirection: VerticalDirection.down,
        clipBehavior: Clip.antiAliasWithSaveLayer,
        children: [
          MaterialButton(
            splashColor: Color(0xff014b76),
            onPressed: () {
              visible[visibilityName] = !visible[visibilityName]!;
              setState(() {});
            },
            child: Container(
              alignment: Alignment.centerLeft,
              height: 50,
              padding: EdgeInsets.fromLTRB(20.00,10.00,0,1.00),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    visible[visibilityName]! ? Icons.keyboard_arrow_down_rounded : Icons.play_arrow_rounded,
                    size: 30,
                    color: mainAppBlue,
                  ),
                  SizedBox(width: 20.00,),
                  Text(
                    containerName,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 25,
                      color: mainAppBlue,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ),
          Visibility(
            visible: visible[visibilityName]!,
            child: containerChild,
          ),
        ],
      ),
    );
  }

  List<PieChartSectionData> showingSections() {
    return List.generate(pieChartData.length, (i) {
      final isTouched = i == touchedIndexPieChart;
      final fontSize = isTouched ? 25.0 : 16.0;
      final radius = isTouched ? 100.0 : 80.0;
      var key = category[pieChartData[i]]["id"];
      var readVal = (category[key]["pagesRead"] ?? 0) / (category[key]["totalPagesRead"] ?? 1);
      var readPer = readVal * 100;
      return PieChartSectionData(
        color: category[key]["categoryColor"],
        value: readVal,
        title: '${(readPer).toStringAsFixed(2)} %',
        radius: radius,
        titleStyle: TextStyle(
          fontSize: fontSize,
          fontWeight: i == touchedIndexPieChart ? FontWeight.bold : FontWeight.normal,
          color: const Color(0xffffffff),
        ),
      );
    });
  }

  BarChartGroupData makeGroupData(
    int x,
    double y, {
    bool isTouched = false,
    Color barColor = Colors.white,
    double width = 22,
    List<int> showTooltips = const [],
  }) {
    return BarChartGroupData(
      x: x,
      barRods: [
        BarChartRodData(
          y: isTouched ? y + 2 : y + 1,
          colors: isTouched ? [Colors.yellow] : [barColor],
          width: width,
          borderSide: BorderSide(
            color: isTouched ? Colors.yellow.darken() : mainAppBlue,
            width: 1,
          ),
          backDrawRodData: BackgroundBarChartRodData(
            show: true,
            // y: 20 means -> Bar max value is 20
            y: weeklyVal.reduce(max)+10,
            colors: [barBackgroundColor],
          ),
        ),
      ],
      showingTooltipIndicators: showTooltips,
    );
  }

  createWeklyValues() {
    if(user!["dailyRecords"].containsKey("pagesRead")) {
      List<double> listy = [];
      for(var day in user!["dailyRecords"]["pagesRead"].keys) {
        print("$day - ${user!["dailyRecords"]["pagesRead"][day]}");
        listy.add(user!["dailyRecords"]["pagesRead"][day]);
      }
      weeklyVal = listy;
    }
  }

  getWeeks() {
    int today = DateTime.now().weekday;
    for(int i=0; i<7; ++i) {
      var date = DateTime.now().subtract(Duration(days:i)); // weeks[(today-i-1)%7] + "\n" + 
      weekStatsDay[6-i] = "${weeks[date.weekday-1]} \n ${date.day.toString().padLeft(2, "0")} / ${date.month.toString().padLeft(2, "0")} ";
      weekDay[6-i] = "${weeks[date.weekday-1]}";
    }
    print("weekDay: ${today}");
    print(weekDay);
  }

  List<BarChartGroupData> showingGroups() => List.generate(7, (i) {
      return makeGroupData(i, weeklyVal[i], isTouched: i == touchedIndex); 
    });

  BarChartData mainBarData() {
    return BarChartData(
      //Data showed on Hover:
      barTouchData: BarTouchData(
        touchTooltipData: BarTouchTooltipData(
            tooltipBgColor: Colors.blueGrey,
            getTooltipItem: (group, groupIndex, rod, rodIndex) {
              return BarTooltipItem(
                weekStatsDay[group.x.toInt()] + '\n',
                TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
                children: <TextSpan>[
                  TextSpan(
                    text: (rod.y - 2).toString(),
                    style: const TextStyle(
                      color: Colors.yellow,
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  TextSpan(
                    text: " Page",
                    style: const TextStyle(
                      color: Colors.yellow,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              );
            },
          ),
        touchCallback: (FlTouchEvent event, barTouchResponse) {
          setState(() {
            if (!event.isInterestedForInteractions || barTouchResponse == null || barTouchResponse.spot == null) {
              touchedIndex = -1;
              return;
            }
            touchedIndex = barTouchResponse.spot!.touchedBarGroupIndex;
          });
        },
      ),
      //Data showed on X-asis:
      titlesData: FlTitlesData(
        show: true,
        rightTitles: SideTitles(showTitles: false),
        leftTitles: SideTitles(
          showTitles: false,
          getTextStyles: (context, value) => TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 14,
          ),
          margin: 4,
          getTitles: (double value) {
            return value.toString();
          },
        ),
        topTitles: SideTitles(showTitles: false),
        bottomTitles: SideTitles(
          showTitles: true,
          getTextStyles: (context, value) => TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 14,
          ),
          margin: 4,
          getTitles: (double value) {
            return weekDay[value.toInt()];
          },
        ),
      ),
      borderData: FlBorderData(
        show: false,
      ),
      barGroups: showingGroups(),
      gridData: FlGridData(show: false),
    );
  }

  Widget mobileView() {
    return Container();
  }
}
