import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';
import 'package:flutter_sparkline/flutter_sparkline.dart';
import 'dart:async';
import 'package:health/health.dart';
import 'package:flare_splash_screen/flare_splash_screen.dart';
import 'package:horizontal_calendar_widget/date_helper.dart';
import 'package:horizontal_calendar_widget/horizontal_calendar.dart';
import 'package:introduction_screen/introduction_screen.dart';

///completed all , need to add intro screens

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
        OnBoardingPage(),
        startAnimation: 'favorite',
        backgroundColor: Color(0xff181818),
      ),
    );
  }
}

class OnBoardingPage extends StatefulWidget {
  @override
  _OnBoardingPageState createState() => _OnBoardingPageState();
}

class _OnBoardingPageState extends State<OnBoardingPage> {
  final introKey = GlobalKey<IntroductionScreenState>();

  void _onIntroEnd(context) {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => MyApp()),
    );
  }

  Widget _buildImage(String assetName) {
    return Align(
      child: Image.asset('assets/$assetName', width: 350.0),
      alignment: Alignment.bottomCenter,
    );
  }

  @override
  Widget build(BuildContext context) {
    const bodyStyle = TextStyle(fontSize: 19.0);
    const pageDecoration = const PageDecoration(
      titleTextStyle: TextStyle(fontSize: 28.0, fontWeight: FontWeight.w700),
      bodyTextStyle: bodyStyle,
      descriptionPadding: EdgeInsets.fromLTRB(16.0, 0.0, 16.0, 16.0),
      pageColor: Colors.white,
      imagePadding: EdgeInsets.zero,
    );

    return IntroductionScreen(
      key: introKey,
      pages: [
        PageViewModel(
          title: "Pick a Date",
          body:
          "Choose a date on which you want your heart beats on.",
          image: _buildImage('img3.gif'),
          decoration: pageDecoration,
        ),
        PageViewModel(
          title: "Connect your smart bands",
          body:
          " Connect your smart bands with google fit for android or apple fit for ios.",
          image: _buildImage('img1.png'),
          decoration: pageDecoration,
        ),
        PageViewModel(
          title: "Track your heartbeats",
          body: "Monitor every minute of your Heart Beats",
          image: _buildImage('img2.jpg'),
          decoration: pageDecoration,
        ),
      ],
      onDone: () => _onIntroEnd(context),
      //onSkip: () => _onIntroEnd(context), // You can override onSkip callback
      showSkipButton: true,
      skipFlex: 0,
      nextFlex: 0,
      skip: const Text('Skip'),
      next: const Icon(Icons.arrow_forward),
      done: const Text('Done', style: TextStyle(fontWeight: FontWeight.w600)),
      dotsDecorator: const DotsDecorator(
        size: Size(10.0, 10.0),
        color: Color(0xFFBDBDBD),
        activeSize: Size(22.0, 10.0),
        activeShape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(25.0)),
        ),
      ),
    );
  }
}
class MyApp extends StatefulWidget{
  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return MyAppState();
  }
}

// constants for horizontal Calendar
const labelMonth = 'Month';
const labelDate = 'Date';
const labelWeekDay = 'Week Day';

class MyAppState extends State<MyApp>{

  DateTime firstDate = toDateMonthYear(DateTime.now().subtract(Duration(days: 30)));//starting date for HC
  DateTime lastDate = toDateMonthYear(DateTime.now().add(Duration(days: 1)));//ending date for HC

  //HC formats
  String dateFormat = 'dd';
  String monthFormat = 'MMM';
  String weekDayFormat = 'EEE';
  List<String> order = [labelMonth, labelDate, labelWeekDay];
  bool forceRender = false;



  GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey();
  double hr;
  var hb = 0 ;
  var _maxHeartRate=0, _minHeartRate = 0, _avgHeartRate=0;
  var hrlists;
  List hrlist = new List();
  List<double> _heartBeatList = [72.0];
  var count = 0;
  var total = 0;
  var _healthDataList = List<HealthDataPoint>();
  bool _isAuthorized = false;
  bool _showAnalysis = false;

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
  }

  ///Method for labelling months,dates and weekdays in HC
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

  Future<void> onDateForHeart(date) async{
    _maxHeartRate=0;
    _minHeartRate = 240;
    _avgHeartRate=0;
    print("Start Date: $date");
    DateTime selectedDate = date;
    total=0;
    count=0;
    DateTime endDate = date.add(Duration(hours: 23));
    print("End Date: $endDate");
    _healthDataList.clear();
    hrlist.clear();
    _heartBeatList.clear();

    Future.delayed(Duration(seconds: 0), () async {
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

        for (var x in _healthDataList) {
          hrlist.add(x.value.toDouble());
          _heartBeatList.add(x.value.toDouble());
          count=count+1;
          total = total + x.value.toInt();
          hb = x.value.toInt();
          if(_minHeartRate >= hb){
            _minHeartRate = hb;
          }
          if(_maxHeartRate <= hb){
            _maxHeartRate = hb;
          }
        }
        print("Min Heart Rate: $_minHeartRate");
        print("Max Heart Rate: $_maxHeartRate");
        print("$total / $count");
        print("Heart Rates: $hrlist");
        hrlists = new List<double>.from(hrlist);
        hr = (total/count);
        _avgHeartRate = hr.toInt();
        print("Average Heart Rate : $hr");
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
    // TODO: implement build
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        key: _scaffoldKey,
        appBar: AppBar(
          backgroundColor: Colors.black,
          title: const Text('Heart Rate'),
        ),
        body: SafeArea(
          child: ListView(
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
                  labelOrder: order.map(toLabelType).toList(),
                  maxSelectedDateCount: maxSelectedDateCount,

                  //date selection
                  onDateSelected: (date) async {
                    onDateForHeart(date);
                  },
                ),
              ),
              _healthDataList.isEmpty
                  ? Text('\n')
                  : Container(
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
                      child:  new Sparkline(
                        data: _heartBeatList,
                        lineColor:  Color(0xffff6101),
                        pointsMode: PointsMode.all,
                        pointSize: 0.0,
                      ),
                    )
                ),
              ),

              _showAnalysis? Text('\n')
              : Container(
              height: 70.0,
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
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: <Widget>[
                        Container(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: <Widget>[
                              Center(
                                  child: Text("$_maxHeartRate",
                                    style: TextStyle(fontSize: 24,
                                      color: Colors.red,
                                      fontWeight: FontWeight.bold
                                    ),
                                  )
                              ),
                              Text("Max Heart Rate"),
                            ],
                          ),
                        ),
                        Container(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: <Widget>[
                              Center(
                                  child: Text("$_avgHeartRate",
                                    style: TextStyle(
                                        fontSize: 24,
                                      color: Colors.blueAccent,
                                        fontWeight: FontWeight.bold
                                    ),
                                  )
                              ),
                              Text("Average Heart Rate"),
                            ],
                          ),
                        ),
                        Container(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: <Widget>[
                              Center(
                                  child: Text("$_minHeartRate",
                                    style: TextStyle(
                                        fontSize: 24,
                                      color: Colors.greenAccent,
                                        fontWeight: FontWeight.bold
                                    ),
                                  )
                              ),
                              Text("Min Heart Rate"),
                            ],
                          ),
                        ),
                      ],
                    ),
            ),
              Center(
                child: Padding(
                  padding: EdgeInsets.symmetric(vertical: 1.0),
                  child: RaisedButton(
                    onPressed: (){
//                      _showAnalysis = true;
                      print("ANALYZE BUTTON CLICKED");
                    },
//                    onPressed: ()=> _showAnalysis = true,
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