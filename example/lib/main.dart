import 'dart:io';

import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:flutter_picker/flutter_picker.dart';
import 'PickerData.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

void main() => runApp(MyApp());

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

final String _fontFamily = Platform.isWindows ? "Roboto" : "";

class _MyAppState extends State<MyApp> {

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        theme: ThemeData(
          primarySwatch: Colors.blue,
          fontFamily: _fontFamily,
          primaryTextTheme: TextTheme().apply(fontFamily: _fontFamily),
        ),

        localizationsDelegates: [
          PickerLocalizationsDelegate.delegate, // 如果要使用本地化，请添加此行，则可以显示中文按钮
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
        ],
        supportedLocales: [
          const Locale('en', 'US'),
          const Locale('zh', 'CH'),
          const Locale('ko', 'KO'),
          const Locale('it', 'IT'),
          const Locale('ar', 'AR'),
          const Locale('tr','TR')
        ],

        home: MyHomePage());
  }
}

class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final double listSpec = 4.0;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  String stateText = "";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        title: Text('Picker ${stateText.isEmpty ? "" : " - " + stateText}'),
        automaticallyImplyLeading: false,
        elevation: 0.0,
      ),
      body: Container(
        padding: EdgeInsets.all(10.0),
        alignment: Alignment.topCenter,
        child: ListView(
          children: <Widget>[
            ListTile(
              title: Text('Picker Show'),
              onTap: () {
                showPicker(context);
              },
            ),
            ListTile(
              title: Text('Picker Show Modal'),
              onTap: () {
                showPickerModal(context);
              },
            ),
            ListTile(
              title: Text('Picker Show Icons'),
              onTap: () {
                showPickerIcons(context);
              },
            ),
            ListTile(
              title: Text('Picker Show (Array)'),
              onTap: () {
                showPickerArray(context);
              },
            ),
            ListTile(
              title: Text('Picker Show Number'),
              onTap: () {
                showPickerNumber(context);
              },
            ),
            ListTile(
              title: Text('Picker Show Number FormatValue'),
              onTap: () {
                showPickerNumberFormatValue(context);
              },
            ),
            ListTile(
              title: Text('Picker Show Date'),
              onTap: () {
                showPickerDate(context);
              },
            ),
            ListTile(
              title: Text('Picker Show Datetime'),
              onTap: () {
                showPickerDateTime(context);
              },
            ),
            ListTile(
              title: Text('Picker Show Date (Custom)'),
              onTap: () {
                showPickerDateCustom(context);
              },
            ),
            ListTile(
              title: Text('Picker Show Datetime (24)'),
              onTap: () {
                showPickerDateTime24(context);
              },
            ),
            ListTile(
              title: Text('Picker Show Datetime (Round background)'),
              onTap: () {
                showPickerDateTimeRoundBg(context);
              },
            ),
            ListTile(
              title: Text('Picker Show Date Range'),
              onTap: () {
                showPickerDateRange(context);
              },
            ),
          ],
        ),
      ),
    );
  }

  showPicker(BuildContext context) {
    Picker picker = Picker(
      adapter: PickerDataAdapter<String>(pickerdata: JsonDecoder().convert(PickerData)),
      changeToFirst: false,
      textAlign: TextAlign.left,
      textStyle: TextStyle(color: Colors.blue, fontFamily: _fontFamily),
      selectedTextStyle: TextStyle(color: Colors.red),
      columnPadding: const EdgeInsets.all(8.0),
      onConfirm: (Picker picker, List value) {
        print(value.toString());
        print(picker.getSelectedValues());
      }
    );
    picker.show(_scaffoldKey.currentState);
  }

  showPickerModal(BuildContext context) {
    Picker(
      adapter: PickerDataAdapter<String>(pickerdata: JsonDecoder().convert(PickerData)),
      changeToFirst: true,
      hideHeader: false,
      selectedTextStyle: TextStyle(color: Colors.blue),
      onConfirm: (Picker picker, List value) {
        print(value.toString());
        print(picker.adapter.text);
      }
    ).showModal(this.context); //_scaffoldKey.currentState);
  }

  showPickerIcons(BuildContext context) {
    Picker(
        adapter: PickerDataAdapter(data: [
          PickerItem(text: Icon(Icons.add), value: Icons.add, children: [
            PickerItem(text: Icon(Icons.more)),
            PickerItem(text: Icon(Icons.aspect_ratio)),
            PickerItem(text: Icon(Icons.android)),
            PickerItem(text: Icon(Icons.menu)),
          ]),
          PickerItem(text: Icon(Icons.title), value: Icons.title, children: [
            PickerItem(text: Icon(Icons.more_vert)),
            PickerItem(text: Icon(Icons.ac_unit)),
            PickerItem(text: Icon(Icons.access_alarm)),
            PickerItem(text: Icon(Icons.account_balance)),
          ]),
          PickerItem(text: Icon(Icons.face), value: Icons.face, children: [
            PickerItem(text: Icon(Icons.add_circle_outline)),
            PickerItem(text: Icon(Icons.add_a_photo)),
            PickerItem(text: Icon(Icons.access_time)),
            PickerItem(text: Icon(Icons.adjust)),
          ]),
          PickerItem(text: Icon(Icons.linear_scale), value: Icons.linear_scale, children: [
            PickerItem(text: Icon(Icons.assistant_photo)),
            PickerItem(text: Icon(Icons.account_balance)),
            PickerItem(text: Icon(Icons.airline_seat_legroom_extra)),
            PickerItem(text: Icon(Icons.airport_shuttle)),
            PickerItem(text: Icon(Icons.settings_bluetooth)),
          ]),
          PickerItem(text: Icon(Icons.close), value: Icons.close),
        ]),
        title: Text("Select Icon"),
        selectedTextStyle: TextStyle(color: Colors.blue),
        onConfirm: (Picker picker, List value) {
          print(value.toString());
          print(picker.getSelectedValues());
        },
    ).show(_scaffoldKey.currentState);
  }


  showPickerDialog(BuildContext context) {
    Picker(
        adapter: PickerDataAdapter<String>(pickerdata: JsonDecoder().convert(PickerData)),
        hideHeader: true,
        title: Text("Select Data"),
        selectedTextStyle: TextStyle(color: Colors.blue),
        onConfirm: (Picker picker, List value) {
          print(value.toString());
          print(picker.getSelectedValues());
        }
    ).showDialog(context);
  }

  showPickerArray(BuildContext context) {
    Picker(
        adapter: PickerDataAdapter<String>(
          pickerdata: JsonDecoder().convert(PickerData2),
          isArray: true,
        ),
        hideHeader: true,
        selecteds: [3, 0, 2],
        title: Text("Please Select"),
        selectedTextStyle: TextStyle(color: Colors.blue),
        cancel: TextButton(onPressed: () {
          Navigator.pop(context);
        }, child: Icon(Icons.child_care)),
        onConfirm: (Picker picker, List value) {
          print(value.toString());
          print(picker.getSelectedValues());
        }
    ).showDialog(context);
  }

  showPickerNumber(BuildContext context) {
    Picker(
        adapter: NumberPickerAdapter(data: [
          NumberPickerColumn(begin: 0, end: 999, postfix: Text("\$"), suffix: Icon(Icons.insert_emoticon)),
          NumberPickerColumn(begin: 200, end: 100, jump: -10),
        ]),
        delimiter: [
          PickerDelimiter(child: Container(
            width: 30.0,
            alignment: Alignment.center,
            child: Icon(Icons.more_vert),
          ))
        ],
        hideHeader: true,
        title: Text("Please Select"),
        selectedTextStyle: TextStyle(color: Colors.blue),
        onConfirm: (Picker picker, List value) {
          print(value.toString());
          print(picker.getSelectedValues());
        }
    ).showDialog(context);
  }

  showPickerNumberFormatValue(BuildContext context) {
    Picker(
        adapter: NumberPickerAdapter(data: [
          NumberPickerColumn(
              begin: 0,
              end: 999,
              onFormatValue: (v) {
                return v < 10 ? "0$v" : "$v";
              }
          ),
          NumberPickerColumn(begin: 100, end: 200),
        ]),
        delimiter: [
          PickerDelimiter(child: Container(
            width: 30.0,
            alignment: Alignment.center,
            child: Icon(Icons.more_vert),
          ))
        ],
        hideHeader: true,
        title: Text("Please Select"),
        selectedTextStyle: TextStyle(color: Colors.blue),
        onConfirm: (Picker picker, List value) {
          print(value.toString());
          print(picker.getSelectedValues());
        }
    ).showDialog(context);
  }

  showPickerDate(BuildContext context) {
    Picker(
      hideHeader: true,
      adapter: DateTimePickerAdapter(),
      title: Text("Select Data"),
      selectedTextStyle: TextStyle(color: Colors.blue),
      onConfirm: (Picker picker, List value) {
        print((picker.adapter as DateTimePickerAdapter).value);
      }
    ).showDialog(context);
  }

  showPickerDateCustom(BuildContext context) {
    Picker(
        hideHeader: true,
        adapter: DateTimePickerAdapter(
          customColumnType: [2,1,0,3,4],
        ),
        title: Text("Select Data"),
        selectedTextStyle: TextStyle(color: Colors.blue),
        onConfirm: (Picker picker, List value) {
          print((picker.adapter as DateTimePickerAdapter).value);
        }
    ).showDialog(context);
  }

  showPickerDateTime(BuildContext context) {
    Picker(
        adapter: DateTimePickerAdapter(
          type: PickerDateTimeType.kYMD_AP_HM,
          isNumberMonth: true,
          //strAMPM: const["上午", "下午"],
          yearSuffix: "年",
          monthSuffix: "月",
          daySuffix: "日",
          minValue: DateTime.now(),
          minuteInterval: 30,
          minHour: 1,
          maxHour: 23,
          // twoDigitYear: true,
        ),
        title: Text("Select DateTime"),
        textAlign: TextAlign.right,
        selectedTextStyle: TextStyle(color: Colors.blue),
        delimiter: [
          PickerDelimiter(column: 5, child: Container(
            width: 16.0,
            alignment: Alignment.center,
            child: Text(':', style: TextStyle(fontWeight: FontWeight.bold)),
            color: Colors.white,
          ))
        ],
        footer: Container(
          height: 50.0,
          alignment: Alignment.center,
          child: Text('Footer'),
        ),
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

  showPickerDateRange(BuildContext context) {
    print("canceltext: ${PickerLocalizations.of(context).cancelText}");

    Picker ps = Picker(
        hideHeader: true,
        adapter: DateTimePickerAdapter(type: PickerDateTimeType.kYMD, isNumberMonth: true),
        onConfirm: (Picker picker, List value) {
          print((picker.adapter as DateTimePickerAdapter).value);
        }
    );

    Picker pe = Picker(
        hideHeader: true,
        adapter: DateTimePickerAdapter(type: PickerDateTimeType.kYMD),
        onConfirm: (Picker picker, List value) {
          print((picker.adapter as DateTimePickerAdapter).value);
        }
    );

    List<Widget> actions = [
      TextButton(
          onPressed: () {
            Navigator.pop(context);
          },
          child: Text(PickerLocalizations.of(context).cancelText)),
      TextButton(
          onPressed: () {
            Navigator.pop(context);
            ps.onConfirm(ps, ps.selecteds);
            pe.onConfirm(pe, pe.selecteds);
          },
          child: Text(PickerLocalizations.of(context).confirmText))
    ];

    showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text("Select Date Range"),
            actions: actions,
            content: Container(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Text("Begin:"),
                  ps.makePicker(),
                  Text("End:"),
                  pe.makePicker()
                ],
              ),
            ),
          );
        });
  }

  showPickerDateTime24(BuildContext context) {
    Picker(
        adapter: DateTimePickerAdapter(
            type: PickerDateTimeType.kMDYHM,
            isNumberMonth: true,
            yearSuffix: "年",
            monthSuffix: "月",
            daySuffix: "日",
            minHour: 8,
            maxHour: 19,
            yearBegin: 1950,
            yearEnd: 1998,
        ),
        title: Text("Select DateTime"),
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

  /// 圆角背景
  showPickerDateTimeRoundBg(BuildContext context) {
    var picker = Picker(
        backgroundColor: Colors.transparent,
        headerDecoration: BoxDecoration(
            border: Border(bottom: BorderSide(color: Colors.black12, width: 0.5))
        ),
        adapter: DateTimePickerAdapter(
            type: PickerDateTimeType.kMDYHM,
            isNumberMonth: true,
            yearSuffix: "年",
            monthSuffix: "月",
            daySuffix: "日"
        ),
        delimiter: [
          PickerDelimiter(column: 3, child: Container(
            width: 8.0,
            alignment: Alignment.center,
          )),
          PickerDelimiter(column: 5, child: Container(
            width: 12.0,
            alignment: Alignment.center,
            child: Text(':', style: TextStyle(fontWeight: FontWeight.bold)),
            color: Colors.white,
          )),
        ],
        title: Text("Select DateTime"),
        onConfirm: (Picker picker, List value) {
          print(picker.adapter.text);
        },
        onSelect: (Picker picker, int index, List<int> selecteds) {
          this.setState(() {
            stateText = picker.adapter.toString();
          });
        }
    );

    showModalBottomSheet(context: context, backgroundColor: Colors.transparent, builder: (context) {
      return Material(
        color: Colors.white,
        borderRadius: BorderRadius.only(topLeft: Radius.circular(10), topRight: Radius.circular(10)),
        child: Container(
          padding: const EdgeInsets.only(top: 4),
          child: picker.makePicker(null, true),
        )
      );
    });
  }

}
