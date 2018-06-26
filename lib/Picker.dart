import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

typedef PickerSelectedCallback = void Function(Picker picker, int index, List<int> selecteds);
typedef PickerConfirmCallback = void Function(Picker picker, List<int> selecteds);

class Picker<T> {
  List<PickerItem> data;
  List<int> selecteds;
  final List pickerdata;

  final VoidCallback onCancel;
  final PickerSelectedCallback onSelect;
  final PickerConfirmCallback onConfirm;

  final changeToFirst;

  final Widget title;
  final String cancelText;
  final String confirmText;

  final double height, itemExtent;
  final TextStyle textStyle;
  final TextAlign textAlign;
  final EdgeInsetsGeometry columnPadding;
  final Color backgroundColor, headercolor;

  final FixedExtentScrollController scrollController =
      new FixedExtentScrollController(initialItem: 0);

  bool _parseDataOK = false;
  int _maxLevel = 1;

  Widget _widget = null;

  Picker(
      {this.data,
      this.pickerdata,
      this.selecteds,
      this.height = 150.0,
      this.itemExtent = 28.0,
      this.columnPadding,
      this.textStyle =
          const TextStyle(color: Color(0xFF000046), fontSize: 18.0),
      this.textAlign = TextAlign.start,
      this.title,
      this.cancelText = 'Cancel',
      this.confirmText = 'Confirm',
      this.backgroundColor = Colors.white,
      this.headercolor,
      this.changeToFirst = false,
      this.onCancel,
      this.onSelect,
      this.onConfirm});

  Widget get widget => _widget;

  /** 生成picker控件 */
  Widget makePicker([ThemeData themeData]) {
    _parseData();
    _widget = new _PickerWidget(picker: this, themeData: themeData);
    return _widget;
  }

  /** 显示 picker */
  void show(ScaffoldState state, [ThemeData themeData]) {
    state.showBottomSheet((BuildContext context) {
      return makePicker(themeData);
    });
  }

  /** 显示模态 picker */
  void showModal(ScaffoldState state, [ThemeData themeData]) {
    showModalBottomSheet(context: state.context, builder: (BuildContext context) {
      return makePicker(themeData);
    });
  }

  /** 获取当前选择的值 */
  List<T> getSelectedValues() {
    List<T> items = [];
    if (selecteds != null) {
      List<PickerItem> datas = this.data;
      for (int i = 0; i < selecteds.length; i++) {
        int j = selecteds[i];
        if (j < 0 || j >= datas.length)
          break;
        items.add(datas[j].value);
        datas = datas[j].children;
        if (datas == null || datas.length == 0)
          break;
      }
    }
    return items;
  }

  _parseData() {
    if (_parseDataOK) return;
    if (pickerdata != null &&
        pickerdata.length > 0 &&
        (data == null || data.length == 0)) {
      if (data == null) data = new List<PickerItem<T>>();
      _parsePickerDataItem(pickerdata, data);
    }
    _checkPickerDataLevel(data, 1);
    //print('_maxLevel: $_maxLevel');
    if (selecteds == null || selecteds.length == 0) {
      if (selecteds == null) selecteds = new List<int>();
      for (int i = 0; i < _maxLevel; i++) selecteds.add(0);
    }
    _parseDataOK = true;
  }

  _checkPickerDataLevel(List<PickerItem> data, int level) {
    if (data == null) return;
    for (int i = 0; i < data.length; i++) {
      if (data[i].children != null && data[i].children.length > 0)
        _checkPickerDataLevel(data[i].children, level + 1);
    }
    if (_maxLevel < level) _maxLevel = level;
  }

  _parsePickerDataItem(List pickerdata, List<PickerItem> data) {
    if (pickerdata == null) return;
    for (int i = 0; i < pickerdata.length; i++) {
      var item = pickerdata[i];
      if (item is T) {
        data.add(new PickerItem<T>(value: item as T));
      } else if (item is Map) {
        final Map map = item;
        if (map.length == 0) continue;

        List<T> _maplist = map.keys.toList();
        for (int j = 0; j < _maplist.length; j++) {
          var _o = map[_maplist[j]];
          if (_o is List && _o.length > 0) {
            List<PickerItem> _children = new List<PickerItem<T>>();
            //print('add: ${_maplist[j]}');
            data.add(
                new PickerItem<T>(value: _maplist[j], children: _children));
            _parsePickerDataItem(_o, _children);
          }
        }
      } else if (T == String && !(item is List)) {
        String _v = item.toString();
        //print('add: $_v');
        data.add(new PickerItem<T>(value: _v as T));
      }
    }
  }
}

class PickerItem<T> {
  /** 显示内容  */
  final Widget text;
  /** 数据值 */
  final T value;
  /** 子项 */
  final List<PickerItem<T>> children;

  PickerItem({this.text, this.value, this.children});
}

class _PickerWidget<T> extends StatefulWidget {
  final Picker<T> picker;
  final ThemeData themeData;
  _PickerWidget({Key key, @required this.picker, @required this.themeData})
      : super(key: key);

  @override
  PickerWidgetState createState() =>
      new PickerWidgetState<T>(picker: this.picker, themeData: this.themeData);
}

class PickerWidgetState<T> extends State<_PickerWidget> {
  final Picker<T> picker;
  final ThemeData themeData;
  PickerWidgetState({Key key, @required this.picker, @required this.themeData});

  ThemeData theme;

  @override
  void initState() {
    super.initState();
    theme = themeData;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Container(
          child: Row(
            children:_buildHeaderViews(),
          ),
          decoration: BoxDecoration(
            border: new Border(top: BorderSide(color: theme.dividerColor, width: 0.5)),
            color: picker.headercolor == null ? theme.bottomAppBarColor : picker.headercolor,
          ),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: _buildViews(),
        ),
      ],
    );
  }

  List<Widget> _buildHeaderViews() {
    if (theme == null) theme = Theme.of(context);
    List<Widget> items = [];
    if (picker.cancelText != null || picker.cancelText != "") {
      items.add(new FlatButton(onPressed: () {
        if (picker.onCancel != null)
          picker.onCancel();
        Navigator.of(context).pop();
      }, child: new Text(picker.cancelText, overflow: TextOverflow.ellipsis, style: theme.textTheme.button)));
    }
    items.add(new Expanded(child: new Container(
      alignment: Alignment.center,
      child: picker.title,
    )));
    if (picker.confirmText != null || picker.confirmText != "") {
      items.add(new FlatButton(onPressed: () {
        if (picker.onConfirm != null)
          picker.onConfirm(picker, picker.selecteds);
        Navigator.of(context).pop();
      }, child: new Text(picker.confirmText, overflow: TextOverflow.ellipsis, style: theme.textTheme.button)));
    }
    return items;
  }

  List<Widget> _buildViews() {
    //print("_buildViews");
    if (theme == null) theme = Theme.of(context);

    List<Widget> items = [];
    if (picker.data != null && picker.data.length > 0) {
      List<PickerItem<T>> _datas = picker.data;

      for (int i = 0; i < picker._maxLevel; i++) {
        Widget view = new Expanded(
          flex: 1,
          child: Container(
            padding: picker.columnPadding,
            height: picker.height,
            decoration: BoxDecoration(
              border: new Border(top: BorderSide(color: theme.dividerColor, width: 0.5)),
              color: theme.backgroundColor,
            ),
            child: CupertinoPicker(
              backgroundColor: picker.backgroundColor,
              scrollController: picker.scrollController,
              itemExtent: picker.itemExtent,
              onSelectedItemChanged: (int index) {
                //print("i: $i, index: $index");
                if (picker.changeToFirst) {
                  for (int j=i+1; j<picker.selecteds.length; j++) {
                    picker.selecteds[j] = 0;
                    picker.scrollController.positions.toList()[j].jumpTo(0.0);
                  }
                }
                setState(() {
                  picker.selecteds[i] = index;
                  if (picker.onSelect != null)
                    picker.onSelect(picker, i, picker.selecteds);
                });
              },
              children: List<Widget>.generate(_datas == null ? 0 : _datas.length,
                  (int index) {
                final PickerItem item = _datas[index];
                if (item.text != null) return item.text;
                return Text(
                  item.value.toString(),
                  style: picker.textStyle,
                  textAlign: picker.textAlign,
                );
              }),
            ),
          ),
        );
        items.add(view);

        int select = picker.selecteds[i];
        //print("i: $i, select: $select");
        if (_datas != null && _datas.length > select)
          _datas = _datas[select].children;
        else
          _datas = null;
      }
    }
    return items;
  }
}
