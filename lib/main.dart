import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'dart:math';
import 'package:vector_math/vector_math.dart' as v;
import 'package:intro_views_flutter/Models/page_view_model.dart';
import 'package:intro_views_flutter/intro_views_flutter.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'dart:async';
import 'package:url_launcher/url_launcher.dart';

void main() => runApp(new MyApp());

class MyApp extends StatelessWidget {
  Color randomColor() =>
      Color((Random().nextDouble() * 0xFFFFFF).toInt() << 0).withOpacity(1.0);
  final pages = [
    PageViewModel(
        pageColor: const Color(0xFF03A9F4),
        // \iconImageAssetPath: 'assets/air-hostess.png',
        bubble: Image.asset('assets/air-hostess.png'),
        body: Text(
          'Easily find a fun and random walking route to take!',
        ),
        title: Text(
          'Walking',
        ),
        textStyle: TextStyle(fontFamily: 'MyFont', color: Colors.white),
        mainImage: Image.asset(
          'assets/walking.png',
          scale: 0.3,
          alignment: Alignment.center,
        )),
    PageViewModel(
      pageColor: const Color(0xFF8BC34A),
      iconImageAssetPath: 'assets/waiter.png',
      body: Text(
        'Want to run? Let\'s find a route for you!',
      ),
      title: Text('Running'),
      mainImage: Image.asset(
        'assets/running.png',
        scale: 0.3,
        alignment: Alignment.center,
      ),
      textStyle: TextStyle(fontFamily: 'MyFont', color: Colors.white),
    ), 
    PageViewModel(
      pageColor: const Color(0xFF607D8B),
      iconImageAssetPath: 'assets/taxi-driver.png',
      body: Text(
        'Biker? You can easily find a great biking route to take!',
      ),
      title: Text('Biking'),
      mainImage: Image.asset(
        'assets/cycling.png',
        scale: 0.3,
        alignment: Alignment.center,
      ),
      textStyle: TextStyle(fontFamily: 'MyFont', color: Colors.white),
    ),
  ];
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'IntroViews Flutter', //title of app
      theme: ThemeData(
        primarySwatch: Colors.pink,
      ), //ThemeData
      home: Builder(
        builder: (context) => IntroViewsFlutter(
          pages,
          onTapDoneButton: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => MyHomePage(),
              ), //MaterialPageRoute
            );
          },
          pageButtonTextStyles: TextStyle(
            color: Colors.white,
            fontSize: 18.0,
          ),
        ), //IntroViewsFlutter
      ), //Builder
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  _MyHomePageState createState() => new _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  Position pos;
  double lat = 0, lon = 0, lat2 = 0, lon2 = 0, lat3 = 0, lon3 = 0;
  Random rnd = new Random();
  double R = 6378.1, brng = 1.57, d; //Radius of the Earth
  String val = "Choose one", transportation;
  double miles;
  Color walkColor = Colors.black, bikeColor = Colors.black;

  final List<String> _dropdownValues = [
    "Walking",
    "Running",
    "Biking",
  ];

  void initState() {
    super.initState();
    initPlatformState();
  }

  initPlatformState() async {
    pos = await Geolocator().getCurrentPosition(desiredAccuracy: LocationAccuracy.high);


  }
  _launchURL(link) async {
    String url = link;
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }
  void _toggleColor(String indicator) {
    transportation = indicator;
    setState(() {
      if (indicator == 'walking') {
        walkColor = Colors.black;
        bikeColor = Colors.grey;
      } else if (indicator == 'bicycling') {
        walkColor = Colors.grey;
        bikeColor = Colors.black;
      }
    });
  }

  double angleFromCoordinate(double lat1, double long1, double lat2,
      double long2) {

    double dLon = (long2 - long1);

    double y = sin(dLon) * cos(lat2);
    double x = cos(lat1) * sin(lat2) - sin(lat1)
        * cos(lat2) * cos(dLon);

    double brng = atan2(y, x);

    brng = v.degrees(brng);
    brng = (brng + 360) % 360;
    brng = 360 - brng; // count degrees counter-clockwise - remove to make clockwise

    return brng;
  }

  void getNewCoords(double value) {
    setState(() {
      if (pos != null) {
        lat = pos.latitude;
        lon = pos.longitude;
        d = value*1.60934/3; //#Distance in km
        brng = v.radians(75);
        double lat1 = v.radians(lat);// #Current lat point converted to radians
        double lon1 = v.radians(lon);// #Current long point converted to radians

        lat2 = asin( sin(lat1)*cos(d/R) +
            cos(lat1)*sin(d/R)*(brng));

        lon2 = lon1 + atan2(sin(brng)*sin(d/R)*cos(lat1),
            cos(d/R)-sin(lat1)*sin(lat2));

        brng = -v.radians(225);
        lat3 = asin( sin(lat2)*cos(d/R) +
            cos(lat2)*sin(d/R)*(brng));

        lon3 = lon2 + atan2(sin(brng)*sin(d/R)*cos(lat2),
            cos(d/R)-sin(lat2)*sin(lat3));

        lat2 = v.degrees(lat2);
        lon2 = v.degrees(lon2);
        lat3 = v.degrees(lat3);
        lon3 = v.degrees(lon3);
      }
    });

  }
  void _saveAddress() {
    setState(() {
      // This call to setState tells the Flutter framework that something has
      // changed in this State, which causes it to rerun the build method below
      // so that the display can reflect the updated values. If we changed
      // _counter without calling setState(), then the build method would not be
      // called again, and so nothing would appear to happen.
      //myController.text = t;
      brng = rnd.nextDouble()*6.2831853;// #Bearing is 90 degrees converted to radians.
    });
  }
  final myController = TextEditingController();
  void dispose() {
    // Clean up the controller when the Widget is disposed
    myController.dispose();
    super.dispose();
  }

  Completer<GoogleMapController> _controller = Completer();

  CameraPosition _kGooglePlex = CameraPosition(
    target: LatLng(34.040539, -118.255497),
    zoom: 26.4746,
  );

  @override
  Widget build(BuildContext context) {
    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.
    //
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.
    return new Scaffold(
      appBar: new AppBar(
        // Here we take the value from the MyHomePage object that was created by
        // the App.build method, and use it to set our appbar title.
        title: new Text('Kevin is dumb'),
      ),
      body:new Container(
      decoration: new BoxDecoration(
      gradient: new LinearGradient(colors: [const Color(0xFF915FB5),const Color(0xFFCA436B)],
      begin: FractionalOffset.topLeft,
      end: FractionalOffset.bottomRight,
      stops: [0.0,1.0],
      tileMode: TileMode.clamp
      ),
      ),

        // Center is a layout widget. It takes a single child and positions it
        // in the middle of the parent.
        child: new Column(

          // Column is also layout widget. It takes a list of children and
          // arranges them vertically. By default, it sizes itself to fit its
          // children horizontally, and tries to be as tall as its parent.
          //
          // Invoke "debug paint" (press "p" in the console where you ran
          // "flutter run", or select "Toggle Debug Paint" from the Flutter tool
          // window in IntelliJ) to see the wireframe for each widget.
          //
          // Column has various properties to control how it sizes itself and
          // how it positions its children. Here we use mainAxisAlignment to
          // center the children vertically; the main axis here is the vertical
          // axis because Columns are vertical (the cross axis would be
          // horizontal).
          //mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            new Container(
              margin: const EdgeInsets.all(100.0),
            child: new Row(
              crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[ new Expanded(
                child: new IconButton(
                  iconSize: 50.0,
                    color: walkColor,
                    icon: new Icon(Icons.directions_walk),
                    tooltip: 'walking',
                    onPressed: () => _toggleColor('walking'))),
            new Expanded(
                child: new IconButton(
                  iconSize: 50.0,
                    color: bikeColor,
                    icon: new Icon(Icons.directions_bike),
                    tooltip: 'driving',
                    onPressed: () => _toggleColor('bicycling'))),
            ]),

            ),
//            new Text(
//              lat.toString() + ', ' + lon.toString(),
//              style: Theme.of(context).textTheme.display1,
//            ),
//            new Text(
//              lat2.toStringAsFixed(7) + ', ' + lon2.toStringAsFixed(7),
//              style: Theme.of(context).textTheme.display1,
//            ),
            new Text(
              'How many miles would you like to run?',

              style: TextStyle(color: Colors.white) ,
              textScaleFactor: 1.5,
            ),
            Container(
              margin: EdgeInsets.all(15.0),
            child: Theme(
              data: new ThemeData(
                primaryColor: Colors.white,
                primaryColorDark: Colors.white,
              ),
              child: new TextField(
                keyboardType: TextInputType.number,
                style: new TextStyle(
                  fontFamily: "Poppins",
                  color: Colors.white,
                ),
                onChanged: (value) => getNewCoords(double.parse(value)),
                autofocus: true,
                cursorColor: Colors.white,
                controller: myController,
                decoration: new InputDecoration(
                    border: new OutlineInputBorder(
                        borderSide: new BorderSide(color: Colors.teal),
                        borderRadius: new BorderRadius.circular(25.0),),),
              ),
            ),),
            RaisedButton.icon(

              /// Documentation :
              /// Google Maps in a browser: "http://maps.google.com/?q=<lat>,<lng>"
              /// Google Maps app on an iOS mobile device : "comgooglemaps://?q=<lat>,<lng>"
              /// Google Maps app on Android : "geo:<lat>,<lng>?z=<zoom>"
              /// You can also use "google.navigation:q=latitude,longitude"
              /// z is the zoom level (1-21) , q is the search query
              /// t is the map type ("m" map, "k" satellite, "h" hybrid, "p" terrain, "e" GoogleEarth)

              onPressed: () {
                _launchURL("https://www.google.com/maps/dir/?api=1&origin=${lat},${lon}&destination=${lat},${lon}&waypoints=${lat2},${lon2}|${lat3},${lon3}&key=&travelmode=${transportation}");
              },
              icon: Icon(Icons.location_on),
              label: Text("Open Maps"),
            ),
          ],
        ),
      ),
//      floatingActionButton: new FloatingActionButton(
//        onPressed: _saveAddress,
//        child: new Icon(Icons.text_fields),
//      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}