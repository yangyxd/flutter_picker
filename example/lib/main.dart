import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:flutter_picker/flutter_picker.dart';
import 'PickerData.dart';

void main() => runApp(new MyApp());

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => new _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  Widget build(BuildContext context) {
    return new MaterialApp(
        theme: ThemeData(
          primarySwatch: Colors.blue,
        ),
        home: new MyHomePage());
  }
}

class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  String stateText;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        title: Text('Picker'),
        automaticallyImplyLeading: false,
      ),
      body: Container(
        padding: EdgeInsets.all(10.0),
        alignment: Alignment.topCenter,
        child: new Column(
          children: <Widget>[
            (stateText != null) ? Text(stateText) : Container(),
            RaisedButton(
              child: Text('Picker Show'),
              onPressed: () {
                showPicker(context);
              },
            ),
            SizedBox(height: 16.0),
            RaisedButton(
              child: Text('Picker Show Modal'),
              onPressed: () {
                showPickerModal(context);
              },
            ),
            SizedBox(height: 16.0),
            RaisedButton(
              child: Text('Picker Show Icons'),
              onPressed: () {
                showPickerIcons(context);
              },
            ),
            SizedBox(height: 16.0),
            RaisedButton(
              child: Text('Picker Show Dialog'),
              onPressed: () {
                showPickerDialog(context);
              },
            ),
            SizedBox(height: 16.0),
            RaisedButton(
              child: Text('Picker Show Date'),
              onPressed: () {
                showPickerDate(context);
              },
            ),
            SizedBox(height: 16.0),
            RaisedButton(
              child: Text('Picker Show Datetime'),
              onPressed: () {
                showPickerDateTime(context);
              },
            ),
          ],
        ),
      ),
    );
  }

  showPicker(BuildContext context) {
    Picker<String> picker = new Picker(
      pickerdata: new JsonDecoder().convert(PickerData),
      changeToFirst: true,
      textAlign: TextAlign.left,
      columnPadding: const EdgeInsets.all(8.0),
      onConfirm: (Picker picker, List value) {
        print(value.toString());
        print(picker.getSelectedValues());
      }
    );
    picker.show(_scaffoldKey.currentState);
  }

  showPickerModal(BuildContext context) {
    new Picker<String>(
      pickerdata: new JsonDecoder().convert(PickerData),
      changeToFirst: true,
      hideHeader: false,
      onConfirm: (Picker picker, List value) {
        print(value.toString());
        print(picker.adapter.text);
      }
    ).showModal(_scaffoldKey.currentState);
  }

  showPickerIcons(BuildContext context) {
    new Picker(
        data: [
          new PickerItem(text: Icon(Icons.add), value: Icons.add, children: [
            new PickerItem(text: Icon(Icons.more)),
            new PickerItem(text: Icon(Icons.aspect_ratio)),
            new PickerItem(text: Icon(Icons.android)),
            new PickerItem(text: Icon(Icons.menu)),
          ]),
          new PickerItem(text: Icon(Icons.title), value: Icons.title, children: [
            new PickerItem(text: Icon(Icons.more_vert)),
            new PickerItem(text: Icon(Icons.ac_unit)),
            new PickerItem(text: Icon(Icons.access_alarm)),
            new PickerItem(text: Icon(Icons.account_balance)),
          ]),
          new PickerItem(text: Icon(Icons.face), value: Icons.face, children: [
            new PickerItem(text: Icon(Icons.add_circle_outline)),
            new PickerItem(text: Icon(Icons.add_a_photo)),
            new PickerItem(text: Icon(Icons.access_time)),
            new PickerItem(text: Icon(Icons.adjust)),
          ]),
          new PickerItem(text: Icon(Icons.linear_scale), value: Icons.linear_scale, children: [
            new PickerItem(text: Icon(Icons.assistant_photo)),
            new PickerItem(text: Icon(Icons.account_balance)),
            new PickerItem(text: Icon(Icons.airline_seat_legroom_extra)),
            new PickerItem(text: Icon(Icons.airport_shuttle)),
            new PickerItem(text: Icon(Icons.settings_bluetooth)),
          ]),
          new PickerItem(text: Icon(Icons.close), value: Icons.close),
        ],
        title: new Text("Select Icon"),
        onConfirm: (Picker picker, List value) {
          print(value.toString());
          print(picker.getSelectedValues());
        }
    ).show(_scaffoldKey.currentState);
  }

  showPickerDialog(BuildContext context) {
    new Picker<String>(
        pickerdata: new JsonDecoder().convert(PickerData),
        hideHeader: true,
        title: new Text("Select Data"),
        onConfirm: (Picker picker, List value) {
          print(value.toString());
        }
    ).showDialog(context);
  }

  showPickerDate(BuildContext context) {
    new Picker(
      hideHeader: true,
      adapter: new DateTimePickerAdapter(),
      title: new Text("Select Data"),
      onConfirm: (Picker picker, List value) {
        print((picker.adapter as DateTimePickerAdapter).value);
      }
    ).showDialog(context);
  }

  showPickerDateTime(BuildContext context) {
    new Picker(
        adapter: new DateTimePickerAdapter(
          type: PickerDateTimeType.kYMD_AP_HM,
          isNumberMonth: true,
          strAMPM: const["上午", "下午"],
          year_suffix: "年",
          month_suffix: "月",
          day_suffix: "日"
        ),
        title: new Text("Select DateTime"),
        onConfirm: (Picker picker, List value) {
          print(picker.adapter.text);
        },
        onSelect: (Picker picker, int index, List<int> selecteds) {
          this.setState(() {
            stateText = picker.adapter.toString();
          });
        }
    ).show(_scaffoldKey.currentState);
  }



}
