import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';
import 'package:flutter_sparkline/flutter_sparkline.dart';
import 'dart:async';
import 'package:health/health.dart';
import 'package:flare_splash_screen/flare_splash_screen.dart';
import 'package:horizontal_calendar_widget/date_helper.dart';
import 'package:horizontal_calendar_widget/horizontal_calendar.dart';


void main() => runApp(Splash());

class Splash extends StatelessWidget{
  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Heart Beat',
      home: SplashScreen(
        'assets/Hearth.flr',
        MyApp(),
        startAnimation: 'favorite',
        backgroundColor: Color(0xff181818),
      ),
    );
  }

}
class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();

}
const labelMonth = 'Month';
const labelDate = 'Date';
const labelWeekDay = 'Week Day';

class _MyAppState extends State<MyApp> {

  DateTime firstDate = toDateMonthYear(DateTime.now().subtract(Duration(days: 30)));
  DateTime lastDate = toDateMonthYear(DateTime.now().add(Duration(days: 1)));
  String dateFormat = 'dd';
  String monthFormat = 'MMM';
  String weekDayFormat = 'EEE';
  List<String> order = [labelMonth, labelDate, labelWeekDay];
  bool forceRender = false;
//  DateTime _selectedValue = DateTime.now();
  GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey();
  double hr;
  var hrlists;
  List hrlist = new List();
  var count = 0;
  var total = 0;
  var _healthKitOutput;
  var _healthDataList = List<HealthDataPoint>();
  bool _isAuthorized = false;


  Color defaultDecorationColor = Colors.transparent;
  BoxShape defaultDecorationShape = BoxShape.rectangle;
  bool isCircularRadiusDefault = true;

  Color selectedDecorationColor = Colors.red;
  BoxShape selectedDecorationShape = BoxShape.rectangle;
  bool isCircularRadiusSelected = true;

  Color disabledDecorationColor = Colors.grey;
  BoxShape disabledDecorationShape = BoxShape.rectangle;
  bool isCircularRadiusDisabled = true;

  int maxSelectedDateCount = 1;

  @override
  void initState() {
    super.initState();
    initPlatformState();
  }

  LabelType toLabelType(String label) {
    LabelType type;
    switch (label) {
      case labelMonth:
        type = LabelType.month;
        break;
      case labelDate:
        type = LabelType.date;
        break;
      case labelWeekDay:
        type = LabelType.weekday;
        break;
    }
    return type;
  }
  // Platform messages are asynchronous, so we initialize in an async method.
  Future<void> initPlatformState() async {
    total=0;
    count=0;
    DateTime startDate = DateTime.utc(2020, 03, 29);
    DateTime endDate = DateTime.now();

    Future.delayed(Duration(seconds: 1), () async {
      _isAuthorized = await Health.requestAuthorization();

      if (_isAuthorized) {
        print('Authorized');

        bool weightAvailable =
        Health.isDataTypeAvailable(HealthDataType.WEIGHT);
        print("is WEIGHT data type available?: $weightAvailable");

        /// Specify the wished data types
        List<HealthDataType> types = [
//          HealthDataType.WEIGHT,
//          HealthDataType.HEIGHT,
//          HealthDataType.STEPS,
//          HealthDataType.BODY_MASS_INDEX,
//          HealthDataType.WAIST_CIRCUMFERENCE,
//          HealthDataType.BODY_FAT_PERCENTAGE,
//          HealthDataType.ACTIVE_ENERGY_BURNED,
//          HealthDataType.BASAL_ENERGY_BURNED,
          HealthDataType.HEART_RATE,
//          HealthDataType.BLOOD_PRESSURE_SYSTOLIC,
//          HealthDataType.BLOOD_PRESSURE_DIASTOLIC,
//          HealthDataType.RESTING_HEART_RATE,
//          HealthDataType.BLOOD_GLUCOSE,
//          HealthDataType.BLOOD_OXYGEN,
        ];

        for (HealthDataType type in types) {
          /// Calls to 'Health.getHealthDataFromType'
          /// must be wrapped in a try catch block.b
          try {
            List<HealthDataPoint> healthData =
            await Health.getHealthDataFromType(startDate, endDate, type);
            _healthDataList.addAll(healthData);
          } catch (exception) {
            print(exception.toString());
          }
        }
        for (var x in _healthDataList) {
          hrlist.add(x.value.toDouble());
          count=count+1;
          total = total + x.value.toInt();
        }
        print("$total / $count");
        print("Heart Rates: $hrlist");
        hrlists = new List<double>.from(hrlist);
        hr = (total/count);
        print("$hr");
        /// Print the results
        for (var x in _healthDataList) {

          print("Data point: $x");
        }

        /// Update the UI to display the results
        setState(() {});
      } else {
        print('Not authorized');
      }
    });

    // If the widget was removed from the tree while the asynchronous platform
    // message was in flight, we want to discard the reply rather than calling
    // setState to update our non-existent appearance.
    if (!mounted) return;
  }

  /// with selected date

  Future<void> onDateForHeart(date) async {
    DateTime selectedDate = date;
    total=0;
    count=0;
    DateTime endDate = DateTime.now();
    _healthDataList.clear();
    hrlist.clear();

    Future.delayed(Duration(seconds: 1), () async {
      _isAuthorized = await Health.requestAuthorization();

      if (_isAuthorized) {
        print('Authorized');

        /// Calls to 'Health.getHealthDataFromType'
        /// must be wrapped in a try catch block.b
        try {
          List<HealthDataPoint> healthData;
          healthData =
          await Health.getHealthDataFromType(selectedDate, endDate,HealthDataType.HEART_RATE);
          _healthDataList.addAll(healthData);
        } catch (exception) {
          print(exception.toString());
        }


        print("HRList after clear : $hrlist");
        for (var x in _healthDataList) {
          hrlist.add(x.value.toDouble());
          count=count+1;
          total = total + x.value.toInt();
        }
        print("$total / $count");
        print("Heart Rates: $hrlist");
        hrlists = new List<double>.from(hrlist);
        hr = (total/count);
        print("$hr");
        /// Print the results
        for (var x in _healthDataList) {

          print("Data point: $x");
        }

        /// Update the UI to display the results
        setState(() {});
      } else {
        print('Not authorized');
      }
    });

    // If the widget was removed from the tree while the asynchronous platform
    // message was in flight, we want to discard the reply rather than calling
    // setState to update our non-existent appearance.
    if (!mounted) return;
  }


  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        key: _scaffoldKey,
        appBar: AppBar(
          backgroundColor: Colors.black,
          title: const Text('Heart Rate'),
          actions: <Widget>[
            IconButton(
              icon: Icon(Icons.sync),
              onPressed: () {
                initPlatformState();
              },
            )
          ],
        ),
        body: SafeArea(
          child: _healthDataList.isEmpty
              ? Text('$_healthKitOutput\n')
              : ListView(
//                crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[

              Container(

                margin: EdgeInsets.symmetric(horizontal: 5.0, vertical: 15.0),
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(24.0),
                    color: Colors.white,
                    boxShadow: [BoxShadow(
                      color: Color(0x802196F3),
                      offset: Offset(0.0,1.0),
                      blurRadius: 6.0,
                    )]
                ),
                child: HorizontalCalendar(
                  key: forceRender ? UniqueKey() : Key('Calendar'),
                  height: 92,
                  padding: EdgeInsets.all(22),
                  firstDate: firstDate,
                  lastDate: lastDate,
                  dateFormat: dateFormat,
                  weekDayFormat: weekDayFormat,
                  monthFormat: monthFormat,
                  defaultDecoration: BoxDecoration(
                    color: defaultDecorationColor,
                    shape: defaultDecorationShape,
                    borderRadius: defaultDecorationShape == BoxShape.rectangle &&
                        isCircularRadiusDefault
                        ? BorderRadius.circular(8)
                        : null,
                  ),
                  selectedDecoration: BoxDecoration(
                    color: selectedDecorationColor,
                    shape: selectedDecorationShape,
                    borderRadius: selectedDecorationShape == BoxShape.rectangle &&
                        isCircularRadiusSelected
                        ? BorderRadius.circular(8)
                        : null,
                  ),
                  disabledDecoration: BoxDecoration(
                    color: disabledDecorationColor,
                    shape: disabledDecorationShape,
                    borderRadius: disabledDecorationShape == BoxShape.rectangle &&
                        isCircularRadiusDisabled
                        ? BorderRadius.circular(8)
                        : null,
                  ),
//                      isDateDisabled: (date) => date.weekday == 7,
                  labelOrder: order.map(toLabelType).toList(),
                  maxSelectedDateCount: maxSelectedDateCount,

                  //date selection
                  onDateSelected: (date) async {
                    onDateForHeart(date);
                  },
                ),
              ),
              Container(
                margin: EdgeInsets.symmetric(horizontal: 5.0, vertical: 5.0),
                padding: EdgeInsets.symmetric(vertical: 15.0, horizontal: 10.0),
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(24.0),
                    color: Colors.white,
                    boxShadow: [BoxShadow(
                      color: Color(0x802196F3),
                      offset: Offset(0.0,1.0),
                      blurRadius: 6.0,
                    )]
                ),
                height: 300,
//                  width: 300,
                child: ListView.builder(
                    itemCount: _healthDataList.length,
                    itemBuilder: (_, index) => Container(
                      margin: EdgeInsets.symmetric(vertical: 2.0),
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(24.0),
                          color: Colors.black,
                          boxShadow: [BoxShadow(
                            color: Color(0x802196F3),
                            offset: Offset(0.0,1.0),
                            blurRadius: 6.0,
                          )]
                      ),
                      child: ListTile(
                        title: Text(
                          "${_healthDataList[index].dataType.toString()}: ${_healthDataList[index].value.toString()}",
                          style: TextStyle(color: Colors.white),),
                        trailing: Icon(Icons.favorite,color: Colors.red,),
                        subtitle: Text(
                          '${DateTime.fromMillisecondsSinceEpoch(_healthDataList[index].dateFrom)} - ${DateTime.fromMillisecondsSinceEpoch(_healthDataList[index].dateTo)}',
                          style: TextStyle(color: Colors.white),),
                      ),
                    )
                ),
              ),

              Padding(
                padding: const EdgeInsets.symmetric(vertical: 16.0),
                child: Container(
                    height: 220,
                    width: 50,
                    margin: EdgeInsets.symmetric(horizontal: 5.0, vertical: 5.0),
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(24.0),
                        color: Colors.white,
                        boxShadow: [BoxShadow(
                          color: Color(0x802196F3),
                          offset: Offset(0.0,1.0),
                          blurRadius: 6.0,
                        )]
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(10.0),
                      child: new Sparkline(
                        data: hrlists,
                        lineColor:  Color(0xffff6101),
                        pointsMode: PointsMode.all,
                        pointSize: 8.0,
                      ),
                    )
                ),
              ),

              Center(
                child: Padding(
                  padding: EdgeInsets.symmetric(vertical: 1.0),
                  child: RaisedButton(
                    onPressed: ()=> _scaffoldKey.currentState.showSnackBar(
                        SnackBar(
                            duration: Duration(seconds: 3),
                            content: Text("Average heart beat is $hr",)
                        )
                    ),

                    disabledColor: Colors.black,
                    disabledTextColor: Colors.white,
                    color: Colors.black,
                    textColor: Colors.white,
                    child: Text("Analyze"),
                    elevation: 5.0,
                    disabledElevation: 5.0,
                    hoverColor: Color(0x802196F3),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}