# flutter_picker

Flutter plugin picker.

> Supported  Platforms
> * Android
> * IOS

## How to Use

```yaml
# add this line to your dependencies
image_jpeg:
  git: git://github.com/yangyxd/flutter_picker.git
```

![Alt text](https://github.com/yangyxd/flutter_picker/blob/master/raw/views.gif)

```dart
import 'package:flutter_picker/flutter_picker.dart';

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
            RaisedButton(
              color: Colors.blue,
              child: Text('Picker Show'),
              onPressed: () {
                showPicker(context);
              },
            ),
            SizedBox(height: 16.0),
            RaisedButton(
              color: Colors.green,
              child: Text('Picker Show Modal'),
              onPressed: () {
                showPickerModal(context);
              },
            ),
            SizedBox(height: 16.0),
            RaisedButton(
              color: Colors.cyan,
              child: Text('Picker Show Icons'),
              onPressed: () {
                showPickerIcons(context);
              },
            )
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
      onConfirm: (Picker picker, List value) {
        print(value.toString());
      }
    ).showModal(_scaffoldKey.currentState);
  }

  showPickerIcons(BuildContext context) {
    new Picker<IconData>(
        data: <PickerItem<IconData>>[
          new PickerItem(text: Icon(Icons.add), value: Icons.add, children: <PickerItem<IconData>>[
            new PickerItem(text: Icon(Icons.more)),
            new PickerItem(text: Icon(Icons.aspect_ratio)),
            new PickerItem(text: Icon(Icons.android)),
            new PickerItem(text: Icon(Icons.menu)),
          ]),
          new PickerItem(text: Icon(Icons.title), value: Icons.title, children: <PickerItem<IconData>>[
            new PickerItem(text: Icon(Icons.more_vert)),
            new PickerItem(text: Icon(Icons.ac_unit)),
            new PickerItem(text: Icon(Icons.access_alarm)),
            new PickerItem(text: Icon(Icons.account_balance)),
          ]),
          new PickerItem(text: Icon(Icons.face), value: Icons.face, children: <PickerItem<IconData>>[
            new PickerItem(text: Icon(Icons.add_circle_outline)),
            new PickerItem(text: Icon(Icons.add_a_photo)),
            new PickerItem(text: Icon(Icons.access_time)),
            new PickerItem(text: Icon(Icons.adjust)),
          ]),
          new PickerItem(text: Icon(Icons.linear_scale), value: Icons.linear_scale, children: <PickerItem<IconData>>[
            new PickerItem(text: Icon(Icons.assistant_photo)),
            new PickerItem(text: Icon(Icons.account_balance)),
            new PickerItem(text: Icon(Icons.airline_seat_legroom_extra)),
            new PickerItem(text: Icon(Icons.airport_shuttle)),
            new PickerItem(text: Icon(Icons.settings_bluetooth)),
          ]),
          new PickerItem(text: Icon(Icons.close), value: Icons.close, children: <PickerItem<IconData>>[

          ]),
        ],
        title: new Text("选择图标", style: Theme.of(context).textTheme.button),
        onConfirm: (Picker picker, List value) {
          print(value.toString());
          print(picker.getSelectedValues());
        }
    ).show(_scaffoldKey.currentState);
  }
}

```

```dart
const PickerData = '''
[
    {
        "a": [
            {
                "a1": [
                    1,
                    2,
                    3,
                    4
                ]
            },
            {
                "a2": [
                    5,
                    6,
                    7,
                    8
                ]
            },
            {
                "a3": [
                    9,
                    10,
                    11,
                    12
                ]
            }
        ]
    },
    {
        "b": [
            {
                "b1": [
                    11,
                    22,
                    33,
                    44
                ]
            },
            {
                "b2": [
                    55,
                    66,
                    77,
                    88
                ]
            },
            {
                "b3": [
                    99,
                    1010,
                    1111,
                    1212
                ]
            }
        ]
    },
    {
        "c": [
            {
                "c1": [
                    "a",
                    "b",
                    "c"
                ]
            },
            {
                "c2": [
                    "aa",
                    "bb",
                    "cc"
                ]
            },
            {
                "c3": [
                    "aaa",
                    "bbb",
                    "ccc"
                ]
            }
        ]
    }
]
    ''';
```
