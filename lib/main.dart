import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'dart:math';
import 'package:vector_math/vector_math.dart' as v;

void main() => runApp(new MyApp());

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return new MaterialApp(
      title: 'Flutter Demo',
      theme: new ThemeData(
        // This is the theme of your application.
        //
        // Try running your application with "flutter run". You'll see the
        // application has a blue toolbar. Then, without quitting the app, try
        // changing the primarySwatch below to Colors.green and then invoke
        // "hot reload" (press "r" in the console where you ran "flutter run",
        // or press Run > Flutter Hot Reload in IntelliJ). Notice that the
        // counter didn't reset back to zero; the application is not restarted.
        primarySwatch: Colors.blue,
      ),
      home: new MyHomePage(title: 'Flutter Demo Home Page'),
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
  double lat = 0, lon = 0, lat2 = 0, lon2 = 0;
  Random rnd = new Random();
  double R = 6378.1, brng = 1.57, d; //Radius of the Earth
  void initState() {
    super.initState();
    initPlatformState();
  }

  initPlatformState() async {
    pos = await Geolocator().getCurrentPosition(desiredAccuracy: LocationAccuracy.high);


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

  @override
  Widget build(BuildContext context) {
    if (pos != null) {
      lat = pos.latitude;
      lon = pos.longitude;
      d = 8; //#Distance in km

      double lat1 = v.radians(lat);// #Current lat point converted to radians
      double lon1 = v.radians(lon);// #Current long point converted to radians

      lat2 = asin( sin(lat1)*cos(d/R) +
          cos(lat1)*sin(d/R)*(brng));

      lon2 = lon1 + atan2(sin(brng)*sin(d/R)*cos(lat1),
          cos(d/R)-sin(lat1)*sin(lat2));

      lat2 = v.degrees(lat2);
      lon2 = v.degrees(lon2);
    }
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
      body: new Center(
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
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            new Text(
              lat.toString() + ', ' + lon.toString(),
              style: Theme.of(context).textTheme.display1,
            ),
            new Text(
              lat2.toStringAsFixed(7) + ', ' + lon2.toStringAsFixed(7),
              style: Theme.of(context).textTheme.display1,
            ),
            new TextFormField(
              controller: myController,
              decoration: new InputDecoration(
                labelText: "Enter Address",
                fillColor: Colors.blue,
                border: new OutlineInputBorder(
                  borderRadius: new BorderRadius.circular(25.0),
                  borderSide: new BorderSide(
                  ),
                ),
                //fillColor: Colors.black,
              ),
              validator: (val) {
//                if(val.length==0) {
//                  return "Email cannot be empty";
//                }else{
//                  return null;
//                }
              },
              keyboardType: TextInputType.emailAddress,
              style: new TextStyle(
                fontFamily: "Poppins",
                color: Colors.black,
              ),
            ),

          ],
        ),
      ),
      floatingActionButton: new FloatingActionButton(
        onPressed: _saveAddress,
        child: new Icon(Icons.text_fields),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}