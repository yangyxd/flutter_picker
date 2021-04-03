import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/material.dart' as Dialog;
import 'dart:async';
import 'PickerLocalizations.dart';

const bool __printDebug = false;

/// Picker selected callback.
typedef PickerSelectedCallback = void Function(
    Picker picker, int index, List<int> selecteds);

/// Picker confirm callback.
typedef PickerConfirmCallback = void Function(
    Picker picker, List<int> selecteds);

/// Picker value format callback.
typedef PickerValueFormat<T> = String Function(T value);

/// Picker
class Picker {
  static const double DefaultTextSize = 20.0;

  /// Index of currently selected items
  late List<int> selecteds;

  /// Picker adapter, Used to provide data and generate widgets
  late PickerAdapter adapter;

  /// insert separator before picker columns
  final List<PickerDelimiter>? delimiter;

  final VoidCallback? onCancel;
  final PickerSelectedCallback? onSelect;
  final PickerConfirmCallback? onConfirm;

  /// When the previous level selection changes, scroll the child to the first item.
  final changeToFirst;

  /// Specify flex for each column
  final List<int>? columnFlex;

  final Widget? title;
  final Widget? cancel;
  final Widget? confirm;
  final String? cancelText;
  final String? confirmText;

  final double height;

  /// Height of list item
  final double itemExtent;

  final TextStyle? textStyle,
      cancelTextStyle,
      confirmTextStyle,
      selectedTextStyle;
  final TextAlign textAlign;
  final IconThemeData? selectedIconTheme;

  /// Text scaling factor
  final double? textScaleFactor;

  final EdgeInsetsGeometry? columnPadding;
  final Color? backgroundColor, headerColor, containerColor;

  /// Hide head
  final bool hideHeader;

  /// Show pickers in reversed order
  final bool reversedOrder;

  /// Generate a custom header， [hideHeader] = true
  final WidgetBuilder? builderHeader;

  /// List item loop
  final bool looping;

  /// Delay generation for smoother animation, This is the number of milliseconds to wait. It is recommended to > = 200
  final int smooth;

  final Widget? footer;

  /// A widget overlaid on the picker to highlight the currently selected entry.
  final Widget selectionOverlay;

  final Decoration? headerDecoration;

  final double magnification;
  final double diameterRatio;
  final double squeeze;

  Widget? _widget;
  PickerWidgetState? _state;

  Picker(
      {required this.adapter,
      this.delimiter,
      List<int>? selecteds,
      this.height = 150.0,
      this.itemExtent = 28.0,
      this.columnPadding,
      this.textStyle,
      this.cancelTextStyle,
      this.confirmTextStyle,
      this.selectedTextStyle,
      this.selectedIconTheme,
      this.textAlign = TextAlign.start,
      this.textScaleFactor,
      this.title,
      this.cancel,
      this.confirm,
      this.cancelText,
      this.confirmText,
      this.backgroundColor = Colors.white,
      this.containerColor,
      this.headerColor,
      this.builderHeader,
      this.changeToFirst = false,
      this.hideHeader = false,
      this.looping = false,
      this.reversedOrder = false,
      this.headerDecoration,
      this.columnFlex,
      this.footer,
      this.smooth = 0,
      this.magnification = 1.0,
      this.diameterRatio = 1.1,
      this.squeeze = 1.45,
      this.selectionOverlay = const CupertinoPickerDefaultSelectionOverlay(),
      this.onCancel,
      this.onSelect,
      this.onConfirm}) {
    this.selecteds = selecteds == null ? <int>[] : selecteds;
  }

  Widget? get widget => _widget;
  PickerWidgetState? get state => _state;
  int _maxLevel = 1;

  /// 生成picker控件
  /// Build picker control
  Widget makePicker([ThemeData? themeData, bool isModal = false]) {
    _maxLevel = adapter.maxLevel;
    adapter.picker = this;
    adapter.initSelects();
    _widget = PickerWidget(
      key: ValueKey(this),
      child:
          _PickerWidget(picker: this, themeData: themeData, isModal: isModal),
      data: this,
    );
    return _widget!;
  }

  /// show picker
  void show(ScaffoldState state, [ThemeData? themeData]) {
    state.showBottomSheet((BuildContext context) {
      return makePicker(themeData);
    });
  }

  /// Display modal picker
  Future<T?> showModal<T>(BuildContext context,
      [ThemeData? themeData, bool isScrollControlled = false]) async {
    return await showModalBottomSheet<T>(
        context: context, //state.context,
        isScrollControlled: isScrollControlled,
        builder: (BuildContext context) {
          return makePicker(themeData, true);
        });
  }

  /// show dialog picker
  Future<List<int>?> showDialog(BuildContext context,
      {bool barrierDismissible = true, Key? key}) {
    return Dialog.showDialog<List<int>>(
        context: context,
        barrierDismissible: barrierDismissible,
        builder: (BuildContext context) {
          final actions = <Widget>[];

          if (cancel == null) {
            String? _cancelText =
                cancelText ?? PickerLocalizations.of(context).cancelText;
            if (_cancelText != null && _cancelText != "") {
              actions.add(TextButton(
                  style: _getButtonStyle(ButtonTheme.of(context)),
                  onPressed: () {
                    Navigator.pop<List<int>>(context, null);
                    if (onCancel != null) {
                      onCancel!();
                    }
                  },
                  child: cancelTextStyle == null
                      ? Text(_cancelText)
                      : DefaultTextStyle(
                          child: Text(_cancelText), style: cancelTextStyle!)));
            }
          } else {
            actions.add(cancel!);
          }

          if (confirm == null) {
            String? _confirmText =
                confirmText ?? PickerLocalizations.of(context).confirmText;
            if (_confirmText != null && _confirmText != "") {
              actions.add(TextButton(
                  style: _getButtonStyle(ButtonTheme.of(context)),
                  onPressed: () {
                    Navigator.pop<List<int>>(context, selecteds);
                    onConfirm!(this, selecteds);
                  },
                  child: confirmTextStyle == null
                      ? Text(_confirmText)
                      : DefaultTextStyle(
                          child: Text(_confirmText),
                          style: confirmTextStyle!)));
            }
          } else {
            actions.add(confirm!);
          }

          return AlertDialog(
            key: key ?? Key('picker-dialog'),
            title: title,
            actions: actions,
            content: makePicker(),
          );
        });
  }

  /// 获取当前选择的值
  /// Get the value of the current selection
  List getSelectedValues() {
    return adapter.getSelectedValues();
  }

  /// 取消
  void doCancel(BuildContext context) {
    Navigator.of(context).pop<List<int>>(null);
    if (onCancel != null) onCancel!();
    _widget = null;
  }

  /// 确定
  void doConfirm(BuildContext context) {
    Navigator.of(context).pop<List<int>>(selecteds);
    if (onConfirm != null) onConfirm!(this, selecteds);
    _widget = null;
  }

  /// 弹制更新指定列的内容
  /// 当 onSelect 事件中，修改了当前列前面的列的内容时，可以调用此方法来更新显示
  void updateColumn(int index, [bool all = false]) {
    if (all) {
      _state?.update();
      return;
    }
    adapter.setColumn(index - 1);
    if (_state?._keys[index] != null) _state?._keys[index]!(() => null);
  }

  static ButtonStyle _getButtonStyle(ButtonThemeData? theme) => ButtonStyle(
      minimumSize: MaterialStateProperty.all(Size(theme?.minWidth ?? 0.0, 42)),
      padding: MaterialStateProperty.all(theme?.padding));
}

/// 分隔符
class PickerDelimiter {
  final Widget? child;
  final int column;
  PickerDelimiter({required this.child, this.column = 1});
}

/// picker data list item
class PickerItem<T> {
  /// 显示内容
  final Widget? text;

  /// 数据值
  final T? value;

  /// 子项
  final List<PickerItem<T>>? children;

  PickerItem({this.text, this.value, this.children});
}

class PickerWidget<T> extends InheritedWidget {
  final Picker data;
  const PickerWidget({Key? key, required this.data, required Widget child})
      : super(key: key, child: child);
  @override
  bool updateShouldNotify(covariant PickerWidget oldWidget) =>
      oldWidget.data != data;

  static PickerWidget of(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<PickerWidget>()
        as PickerWidget;
  }
}

class _PickerWidget<T> extends StatefulWidget {
  final Picker picker;
  final ThemeData? themeData;
  final bool isModal;
  _PickerWidget(
      {Key? key, required this.picker, this.themeData, required this.isModal})
      : super(key: key);

  @override
  PickerWidgetState createState() =>
      PickerWidgetState<T>(picker: this.picker, themeData: this.themeData);
}

class PickerWidgetState<T> extends State<_PickerWidget> {
  final Picker picker;
  final ThemeData? themeData;
  PickerWidgetState({required this.picker, this.themeData});

  ThemeData? theme;
  final List<FixedExtentScrollController> scrollController = [];
  final List<StateSetter?> _keys = [];

  @override
  void initState() {
    super.initState();
    picker._state = this;
    picker.adapter.doShow();

    if (scrollController.length == 0) {
      for (int i = 0; i < picker._maxLevel; i++) {
        scrollController
            .add(FixedExtentScrollController(initialItem: picker.selecteds[i]));
        _keys.add(null);
      }
    }
  }

  void update() {
    setState(() {});
  }

  // var ref = 0;
  @override
  Widget build(BuildContext context) {
    // print("picker build ${ref++}");
    theme = themeData ?? Theme.of(context);

    if (_wait && picker.smooth > 0) {
      Future.delayed(Duration(milliseconds: picker.smooth), () {
        if (!_wait) return;
        setState(() {
          _wait = false;
        });
      });
    } else
      _wait = false;

    var _body = <Widget>[];
    if (!picker.hideHeader) {
      if (picker.builderHeader != null) {
        _body.add(picker.headerDecoration == null
            ? picker.builderHeader!(context)
            : DecoratedBox(
                child: picker.builderHeader!(context),
                decoration: picker.headerDecoration!));
      } else {
        _body.add(DecoratedBox(
          child: Row(
            children: _buildHeaderViews(context),
          ),
          decoration: picker.headerDecoration ??
              BoxDecoration(
                border: Border(
                  top: BorderSide(color: theme!.dividerColor, width: 0.5),
                  bottom: BorderSide(color: theme!.dividerColor, width: 0.5),
                ),
                color: picker.headerColor == null
                    ? (theme!.bottomAppBarColor)
                    : picker.headerColor,
              ),
        ));
      }
    }
    _body.add(_wait
        ? Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: _buildViews(),
          )
        : AnimatedSwitcher(
            duration: Duration(milliseconds: 300),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: _buildViews(),
            ),
          ));

    if (picker.footer != null) _body.add(picker.footer!);
    Widget v = Column(
      mainAxisSize: MainAxisSize.min,
      children: _body,
    );
    if (widget.isModal) {
      return GestureDetector(
        onTap: () {},
        child: v,
      );
    }
    return v;
  }

  List<Widget>? _headerItems;

  Widget _buildHeaderButton(BuildContext context,
      {required String text,
      required VoidCallback onPressed,
      TextStyle? style}) {
    return TextButton(
        style: Picker._getButtonStyle(ButtonTheme.of(context)),
        onPressed: onPressed,
        child: Text(text,
            overflow: TextOverflow.ellipsis,
            textScaleFactor: MediaQuery.of(context).textScaleFactor,
            style: style ??
                theme!.textTheme.button!.copyWith(
                    color: theme!.accentColor,
                    fontSize: Picker.DefaultTextSize)));
  }

  List<Widget> _buildHeaderViews(BuildContext context) {
    if (_headerItems != null) return _headerItems!;
    if (theme == null) theme = Theme.of(context);
    List<Widget> items = [];

    if (picker.cancel != null) {
      items.add(DefaultTextStyle(
          style: picker.cancelTextStyle ??
              theme!.textTheme.button!.copyWith(
                  color: theme!.accentColor, fontSize: Picker.DefaultTextSize),
          child: picker.cancel!));
    } else {
      String? _cancelText =
          picker.cancelText ?? PickerLocalizations.of(context).cancelText;
      if (_cancelText != null || _cancelText != "") {
        items.add(_buildHeaderButton(context,
            text: _cancelText!, style: picker.cancelTextStyle, onPressed: () {
          picker.doCancel(context);
        }));
      }
    }

    items.add(Expanded(
        child: Center(
      child: picker.title == null
          ? picker.title
          : DefaultTextStyle(
              style: theme!.textTheme.headline6!.copyWith(
                fontSize: Picker.DefaultTextSize,
              ),
              child: picker.title!),
    )));

    if (picker.confirm != null) {
      items.add(DefaultTextStyle(
          style: picker.confirmTextStyle ??
              theme!.textTheme.button!.copyWith(
                  color: theme!.accentColor, fontSize: Picker.DefaultTextSize),
          child: picker.confirm!));
    } else {
      String? _confirmText =
          picker.confirmText ?? PickerLocalizations.of(context).confirmText;
      if (_confirmText != null || _confirmText != "") {
        items.add(_buildHeaderButton(context,
            text: _confirmText!, style: picker.confirmTextStyle, onPressed: () {
          picker.doConfirm(context);
        }));
      }
    }

    _headerItems = items;
    return items;
  }

  bool _changing = false;
  bool _wait = true;
  final Map<int, int> lastData = {};

  List<Widget> _buildViews() {
    if (__printDebug) print("_buildViews");
    if (theme == null) theme = Theme.of(context);

    List<Widget> items = [];

    PickerAdapter? adapter = picker.adapter;
    adapter.setColumn(-1);

    if (adapter.length > 0) {
      var _decoration = BoxDecoration(
        color: picker.containerColor == null
            ? theme!.dialogBackgroundColor
            : picker.containerColor,
      );

      for (int i = 0; i < picker._maxLevel; i++) {
        Widget view = Expanded(
          flex: adapter.getColumnFlex(i),
          child: Container(
            padding: picker.columnPadding,
            height: picker.height,
            decoration: _decoration,
            child: _wait
                ? null
                : StatefulBuilder(
                    builder: (context, state) {
                      _keys[i] = state;
                      adapter.setColumn(i - 1);

                      // 上一次是空列表
                      final _lastIsEmpty = scrollController[i].hasClients &&
                          !scrollController[i].position.hasContentDimensions;

                      final _length = adapter.length;
                      var _view = CupertinoPicker.builder(
                        key: _lastIsEmpty ? ValueKey(_length) : null,
                        backgroundColor: picker.backgroundColor,
                        scrollController: scrollController[i],
                        itemExtent: picker.itemExtent,
                        // looping: picker.looping,
                        magnification: picker.magnification,
                        diameterRatio: picker.diameterRatio,
                        squeeze: picker.squeeze,
                        selectionOverlay: picker.selectionOverlay,
                        onSelectedItemChanged: (int _index) {
                          if (__printDebug) print("onSelectedItemChanged");
                          if (_length <= 0) return;
                          var index = _index % _length;
                          picker.selecteds[i] = index;
                          updateScrollController(i);
                          adapter.doSelect(i, index);
                          if (picker.changeToFirst) {
                            for (int j = i + 1;
                                j < picker.selecteds.length;
                                j++) {
                              picker.selecteds[j] = 0;
                              scrollController[j].jumpTo(0.0);
                            }
                          }
                          if (picker.onSelect != null)
                            picker.onSelect!(picker, i, picker.selecteds);

                          if (adapter.needUpdatePrev(i))
                            setState(() {});
                          else {
                            if (_keys[i] != null) _keys[i]!(() => null);
                            if (adapter.isLinkage) {
                              for (int j = i + 1;
                                  j < picker.selecteds.length;
                                  j++) {
                                if (j == i) continue;
                                adapter.setColumn(j - 1);
                                if (_keys[j] != null) _keys[j]!(() => null);
                              }
                            }
                          }
                        },
                        itemBuilder: (context, index) {
                          adapter.setColumn(i - 1);
                          return adapter.buildItem(context, index % _length);
                        },
                        childCount: picker.looping ? null : _length,
                      );

                      if (_lastIsEmpty ||
                          (!picker.changeToFirst &&
                              picker.selecteds[i] >= _length)) {
                        Timer(Duration(milliseconds: 100), () {
                          if (!this.mounted) return;
                          if (__printDebug) print("timer last");
                          var _len = adapter.length;
                          var _index = (_len < _length ? _len : _length) - 1;
                          if (scrollController[i]
                              .position
                              .hasContentDimensions) {
                            scrollController[i].jumpToItem(_index);
                          } else {
                            scrollController[i] = FixedExtentScrollController(
                                initialItem: _index);
                            state(() => null);
                          }
                        });
                      }

                      return _view;
                    },
                  ),
          ),
        );
        items.add(view);
      }
    }

    if (picker.delimiter != null && !_wait) {
      for (int i = 0; i < picker.delimiter!.length; i++) {
        var o = picker.delimiter![i];
        if (o.child == null) continue;
        var item = Container(child: o.child, height: picker.height);
        if (o.column < 0)
          items.insert(0, item);
        else if (o.column >= items.length)
          items.add(item);
        else
          items.insert(o.column, item);
      }
    }

    if (picker.reversedOrder) return items.reversed.toList();

    return items;
  }

  void updateScrollController(int i) {
    if (_changing || !(picker.adapter.isLinkage)) return;
    _changing = true;
    for (int j = 0; j < picker.selecteds.length; j++) {
      if (j != i) {
        if (scrollController[j].hasClients &&
            scrollController[j].position.hasContentDimensions)
          scrollController[j].position.notifyListeners();
      }
    }
    _changing = false;
  }

  @override
  void debugFillProperties(properties) {
    super.debugFillProperties(properties);
    properties.add(DiagnosticsProperty<bool>('_changing', _changing));
    properties.add(DiagnosticsProperty<bool>('_changing', _changing));
  }
}

/// 选择器数据适配器
abstract class PickerAdapter<T> {
  Picker? picker;

  int getLength();
  int getMaxLevel();
  void setColumn(int index);
  void initSelects();
  Widget buildItem(BuildContext context, int index);

  /// 是否需要更新前面的列
  /// Need to update previous columns
  bool needUpdatePrev(int curIndex) {
    return false;
  }

  Widget makeText(Widget? child, String? text, bool isSel) {
    return Center(
        child: DefaultTextStyle(
            overflow: TextOverflow.ellipsis,
            maxLines: 1,
            textAlign: picker!.textAlign,
            style: picker!.textStyle ??
                TextStyle(
                    color: Colors.black87,
                    fontFamily: picker?.state?.context != null
                        ? Theme.of(picker!.state!.context)
                            .textTheme
                            .headline6!
                            .fontFamily
                        : "",
                    fontSize: Picker.DefaultTextSize),
            child: child != null
                ? (isSel && picker!.selectedIconTheme != null
                    ? IconTheme(
                        data: picker!.selectedIconTheme!,
                        child: child,
                      )
                    : child)
                : Text(text ?? "",
                    textScaleFactor: picker!.textScaleFactor,
                    style: (isSel ? picker!.selectedTextStyle : null))));
  }

  Widget makeTextEx(
      Widget? child, String text, Widget? postfix, Widget? suffix, bool isSel) {
    List<Widget> items = [];
    if (postfix != null) items.add(postfix);
    items.add(
        child ?? Text(text, style: (isSel ? picker!.selectedTextStyle : null)));
    if (suffix != null) items.add(suffix);

    Color? _txtColor = Colors.black87;
    double? _txtSize = Picker.DefaultTextSize;
    if (isSel && picker!.selectedTextStyle != null) {
      if (picker!.selectedTextStyle!.color != null)
        _txtColor = picker!.selectedTextStyle!.color;
      if (picker!.selectedTextStyle!.fontSize != null)
        _txtSize = picker!.selectedTextStyle!.fontSize;
    }

    return new Center(
        //alignment: Alignment.center,
        child: DefaultTextStyle(
            overflow: TextOverflow.ellipsis,
            maxLines: 1,
            textAlign: picker!.textAlign,
            style: picker!.textStyle ??
                TextStyle(color: _txtColor, fontSize: _txtSize),
            child: Wrap(
              children: items,
            )));
  }

  String getText() {
    return getSelectedValues().toString();
  }

  List<T> getSelectedValues() {
    return [];
  }

  void doShow() {}
  void doSelect(int column, int index) {}

  int getColumnFlex(int column) {
    if (picker!.columnFlex != null && column < picker!.columnFlex!.length)
      return picker!.columnFlex![column];
    return 1;
  }

  int get maxLevel => getMaxLevel();

  /// Content length of current column
  int get length => getLength();

  String get text => getText();

  // 是否联动，即后面的列受前面列数据影响
  bool get isLinkage => getIsLinkage();

  @override
  String toString() {
    return getText();
  }

  bool getIsLinkage() {
    return true;
  }

  /// 通知适配器数据改变
  void notifyDataChanged() {
    if (picker?.state != null) {
      picker!.adapter.doShow();
      picker!.adapter.initSelects();
      for (int j = 0; j < picker!.selecteds.length; j++) {
        picker!.state!.scrollController[j].jumpToItem(picker!.selecteds[j]);
      }
    }
  }
}

/// 数据适配器
class PickerDataAdapter<T> extends PickerAdapter<T> {
  late List<PickerItem<T>> data;
  List<PickerItem<dynamic>>? _datas;
  int _maxLevel = -1;
  int _col = 0;
  final bool isArray;

  PickerDataAdapter(
      {List? pickerdata, List<PickerItem<T>>? data, this.isArray = false}) {
    this.data = data ?? <PickerItem<T>>[];
    _parseData(pickerdata);
  }

  @override
  bool getIsLinkage() {
    return !isArray;
  }

  void _parseData(List? pickerData) {
    if (pickerData != null && pickerData.length > 0 && (data.length == 0)) {
      if (isArray) {
        _parseArrayPickerDataItem(pickerData, data);
      } else {
        _parsePickerDataItem(pickerData, data);
      }
    }
  }

  _parseArrayPickerDataItem(List? pickerData, List<PickerItem> data) {
    if (pickerData == null) return;
    var len = pickerData.length;
    for (int i = 0; i < len; i++) {
      var v = pickerData[i];
      if (!(v is List)) continue;
      List lv = v;
      if (lv.length == 0) continue;

      PickerItem item = PickerItem<T>(children: <PickerItem<T>>[]);
      data.add(item);

      for (int j = 0; j < lv.length; j++) {
        var o = lv[j];
        if (o is T) {
          item.children!.add(PickerItem<T>(value: o));
        } else if (T == String) {
          String _v = o.toString();
          item.children!.add(PickerItem<T>(value: _v as T));
        }
      }
    }
    if (__printDebug) print("data.length: ${data.length}");
  }

  _parsePickerDataItem(List? pickerData, List<PickerItem> data) {
    if (pickerData == null) return;
    var len = pickerData.length;
    for (int i = 0; i < len; i++) {
      var item = pickerData[i];
      if (item is T) {
        data.add(new PickerItem<T>(value: item));
      } else if (item is Map) {
        final Map map = item;
        if (map.length == 0) continue;

        List<T> _mapList = map.keys.toList().cast();
        for (int j = 0; j < _mapList.length; j++) {
          var _o = map[_mapList[j]];
          if (_o is List && _o.length > 0) {
            List<PickerItem<T>> _children = <PickerItem<T>>[];
            //print('add: ${data.runtimeType.toString()}');
            data.add(PickerItem<T>(value: _mapList[j], children: _children));
            _parsePickerDataItem(_o, _children);
          }
        }
      } else if (T == String && !(item is List)) {
        String _v = item.toString();
        //print('add: $_v');
        data.add(PickerItem<T>(value: _v as T));
      }
    }
  }

  void setColumn(int index) {
    if (_datas != null && _col == index + 1) return;
    _col = index + 1;
    if (isArray) {
      if (__printDebug) print("index: $index");
      if (_col < data.length)
        _datas = data[_col].children;
      else
        _datas = null;
      return;
    }
    if (index < 0) {
      _datas = data;
    } else {
      _datas = data;
      // 列数过多会有性能问题
      for (int i = 0; i <= index; i++) {
        var j = picker!.selecteds[i];
        if (_datas != null && _datas!.length > j)
          _datas = _datas![j].children;
        else {
          _datas = null;
          break;
        }
      }
    }
  }

  @override
  int getLength() => _datas?.length ?? 0;

  @override
  getMaxLevel() {
    if (_maxLevel == -1) _checkPickerDataLevel(data, 1);
    return _maxLevel;
  }

  @override
  Widget buildItem(BuildContext context, int index) {
    final PickerItem item = _datas![index];
    final isSel = index == picker!.selecteds[_col];
    if (item.text != null) {
      return isSel && picker!.selectedTextStyle != null
          ? DefaultTextStyle(
              style: picker!.selectedTextStyle!,
              child: picker!.selectedIconTheme != null
                  ? IconTheme(
                      data: picker!.selectedIconTheme!,
                      child: item.text!,
                    )
                  : item.text!)
          : item.text!;
    }
    return makeText(
        item.text, item.text != null ? null : item.value.toString(), isSel);
  }

  @override
  void initSelects() {
    // ignore: unnecessary_null_comparison
    if (picker!.selecteds == null) picker!.selecteds = <int>[];
    if (picker!.selecteds.length == 0) {
      for (int i = 0; i < _maxLevel; i++) picker!.selecteds.add(0);
    }
  }

  @override
  List<T> getSelectedValues() {
    List<T> _items = [];
    var _sLen = picker!.selecteds.length;
    if (isArray) {
      for (int i = 0; i < _sLen; i++) {
        int j = picker!.selecteds[i];
        if (j < 0 || data[i].children == null || j >= data[i].children!.length)
          break;
        _items.add(data[i].children![j].value!);
      }
    } else {
      List<PickerItem<dynamic>>? datas = data;
      for (int i = 0; i < _sLen; i++) {
        int j = picker!.selecteds[i];
        if (j < 0 || j >= datas!.length) break;
        _items.add(datas[j].value);
        datas = datas[j].children;
        if (datas == null || datas.length == 0) break;
      }
    }
    return _items;
  }

  _checkPickerDataLevel(List<PickerItem>? data, int level) {
    if (data == null) return;
    if (isArray) {
      _maxLevel = data.length;
      return;
    }
    for (int i = 0; i < data.length; i++) {
      if (data[i].children != null && data[i].children!.length > 0)
        _checkPickerDataLevel(data[i].children, level + 1);
    }
    if (_maxLevel < level) _maxLevel = level;
  }
}

class NumberPickerColumn {
  final List<int>? items;
  final int begin;
  final int end;
  final int? initValue;
  final int columnFlex;
  final int jump;
  final Widget? postfix, suffix;
  final PickerValueFormat<int>? onFormatValue;

  const NumberPickerColumn({
    this.begin = 0,
    this.end = 9,
    this.items,
    this.initValue,
    this.jump = 1,
    this.columnFlex = 1,
    this.postfix,
    this.suffix,
    this.onFormatValue,
  });

  int indexOf(int? value) {
    if (value == null) return -1;
    if (items != null) return items!.indexOf(value);
    if (value < begin || value > end) return -1;
    return (value - begin) ~/ (this.jump == 0 ? 1 : this.jump);
  }

  int valueOf(int index) {
    if (items != null) {
      return items![index];
    }
    return begin + index * (this.jump == 0 ? 1 : this.jump);
  }

  String getValueText(int index) {
    return onFormatValue == null
        ? "${valueOf(index)}"
        : onFormatValue!(valueOf(index));
  }

  int count() {
    var v = (end - begin) ~/ (this.jump == 0 ? 1 : this.jump) + 1;
    if (v < 1) return 0;
    return v;
  }
}

class NumberPickerAdapter extends PickerAdapter<int> {
  NumberPickerAdapter({required this.data});

  final List<NumberPickerColumn> data;
  NumberPickerColumn? cur;
  int _col = 0;

  @override
  int getLength() {
    if (cur == null) return 0;
    if (cur!.items != null) return cur!.items!.length;
    return cur!.count();
  }

  @override
  int getMaxLevel() => data.length;

  @override
  bool getIsLinkage() {
    return false;
  }

  @override
  void setColumn(int index) {
    if (index != -1 && _col == index + 1) return;
    _col = index + 1;
    if (_col >= data.length) {
      cur = null;
    } else {
      cur = data[_col];
    }
  }

  @override
  void initSelects() {
    int _maxLevel = getMaxLevel();
    // ignore: unnecessary_null_comparison
    if (picker!.selecteds == null) picker!.selecteds = <int>[];
    if (picker!.selecteds.length == 0) {
      for (int i = 0; i < _maxLevel; i++) {
        int v = data[i].indexOf(data[i].initValue);
        if (v < 0) v = 0;
        picker!.selecteds.add(v);
      }
    }
  }

  @override
  Widget buildItem(BuildContext context, int index) {
    if (cur!.postfix == null && cur!.suffix == null)
      return makeText(
          null, cur!.getValueText(index), index == picker!.selecteds[_col]);
    else
      return makeTextEx(null, cur!.getValueText(index), cur!.postfix,
          cur!.suffix, index == picker!.selecteds[_col]);
  }

  @override
  int getColumnFlex(int column) {
    return data[column].columnFlex;
  }

  @override
  List<int> getSelectedValues() {
    List<int> _items = [];
    for (int i = 0; i < picker!.selecteds.length; i++) {
      int j = picker!.selecteds[i];
      int v = data[i].valueOf(j);
      _items.add(v);
    }
    return _items;
  }
}

/// Picker DateTime Adapter Type
class PickerDateTimeType {
  static const int kMDY = 0; // m, d, y
  static const int kHM = 1; // hh, mm
  static const int kHMS = 2; // hh, mm, ss
  static const int kHM_AP = 3; // hh, mm, ap(AM/PM)
  static const int kMDYHM = 4; // m, d, y, hh, mm
  static const int kMDYHM_AP = 5; // m, d, y, hh, mm, AM/PM
  static const int kMDYHMS = 6; // m, d, y, hh, mm, ss

  static const int kYMD = 7; // y, m, d
  static const int kYMDHM = 8; // y, m, d, hh, mm
  static const int kYMDHMS = 9; // y, m, d, hh, mm, ss
  static const int kYMD_AP_HM = 10; // y, m, d, ap, hh, mm

  static const int kYM = 11; // y, m
  static const int kDMY = 12; // d, m, y
  static const int kY = 13; // y
}

class DateTimePickerAdapter extends PickerAdapter<DateTime> {
  /// display type, ref: columnType
  final int type;

  /// Whether to display the month in numerical form.If true, months is not used.
  final bool isNumberMonth;

  /// custom months strings
  final List<String>? months;

  /// Custom AM, PM strings
  final List<String>? strAMPM;

  /// year begin...end.
  final int? yearBegin, yearEnd;

  /// hour min ... max, min >= 0, max <= 23, max > min
  final int? minHour, maxHour;

  /// minimum datetime
  final DateTime? minValue, maxValue;

  /// jump minutes, user could select time in intervals of 30min, 5mins, etc....
  final int? minuteInterval;

  /// Year, month, day suffix
  final String? yearSuffix, monthSuffix, daySuffix;

  /// use two-digit year, 2019, displayed as 19
  final bool twoDigitYear;

  /// year 0, month 1, day 2, hour 3, minute 4, sec 5, am/pm 6, hour-ap: 7
  final List<int>? customColumnType;

  static const List<String> MonthsList_EN = const [
    "Jan",
    "Feb",
    "Mar",
    "Apr",
    "May",
    "Jun",
    "Jul",
    "Aug",
    "Sep",
    "Oct",
    "Nov",
    "Dec"
  ];

  static const List<String> MonthsList_EN_L = const [
    "January",
    "February",
    "March",
    "April",
    "May",
    "June",
    "July",
    "August",
    "September",
    "October",
    "November",
    "December"
  ];

  DateTimePickerAdapter({
    Picker? picker,
    this.type = 0,
    this.isNumberMonth = false,
    this.months = MonthsList_EN,
    this.strAMPM,
    this.yearBegin = 1900,
    this.yearEnd = 2100,
    this.value,
    this.minValue,
    this.maxValue,
    this.minHour,
    this.maxHour,
    this.yearSuffix,
    this.monthSuffix,
    this.daySuffix,
    this.minuteInterval,
    this.customColumnType,
    this.twoDigitYear = false,
  }) : assert(minuteInterval == null ||
            (minuteInterval >= 1 &&
                minuteInterval <= 30 &&
                (60 % minuteInterval == 0))) {
    super.picker = picker;
    _yearBegin = yearBegin ?? 0;
    if (minValue != null && minValue!.year > _yearBegin) {
      _yearBegin = minValue!.year;
    }
    // Judge whether the day is in front of the month
    // If in the front, set "needUpdatePrev" = true
    List<int> _columnType;
    if (customColumnType != null)
      _columnType = customColumnType!;
    else
      _columnType = columnType[type];
    var month = _columnType.indexWhere((element) => element == 1);
    var day = _columnType.indexWhere((element) => element == 2);
    _needUpdatePrev =
        day < month || day < _columnType.indexWhere((element) => element == 0);
    if (value == null) value = DateTime.now();
  }

  int _col = 0;
  int _colAP = -1;
  int _colHour = -1;
  int _colDay = -1;
  int _yearBegin = 0;
  bool _needUpdatePrev = false;

  /// Currently selected value
  DateTime? value;

  // but it can improve the performance, so keep it.
  static const List<List<int>> lengths = const [
    [12, 31, 0],
    [24, 60],
    [24, 60, 60],
    [12, 60, 2],
    [12, 31, 0, 24, 60],
    [12, 31, 0, 12, 60, 2],
    [12, 31, 0, 24, 60, 60],
    [0, 12, 31],
    [0, 12, 31, 24, 60],
    [0, 12, 31, 24, 60, 60],
    [0, 12, 31, 2, 12, 60],
    [0, 12],
    [31, 12, 0],
    [0],
  ];

  static const Map<int, int> columnTypeLength = {
    0: 0,
    1: 12,
    2: 31,
    3: 24,
    4: 60,
    5: 60,
    6: 2,
    7: 12
  };

  /// year 0, month 1, day 2, hour 3, minute 4, sec 5, am/pm 6, hour-ap: 7
  static const List<List<int>> columnType = const [
    [1, 2, 0],
    [3, 4],
    [3, 4, 5],
    [7, 4, 6],
    [1, 2, 0, 3, 4],
    [1, 2, 0, 7, 4, 6],
    [1, 2, 0, 3, 4, 5],
    [0, 1, 2],
    [0, 1, 2, 3, 4],
    [0, 1, 2, 3, 4, 5],
    [0, 1, 2, 6, 7, 4],
    [0, 1],
    [2, 1, 0],
    [0],
  ];

  // static const List<int> leapYearMonths = const <int>[1, 3, 5, 7, 8, 10, 12];

  // 获取当前列的类型
  int getColumnType(int index) {
    if (customColumnType != null) return customColumnType![index];
    List<int> items = columnType[type];
    if (index >= items.length) return -1;
    return items[index];
  }

  @override
  int getLength() {
    int v = (customColumnType == null
        ? lengths[type][_col]
        : columnTypeLength[customColumnType![_col]])!;
    if (v == 0) {
      int ye = yearEnd!;
      if (maxValue != null) ye = maxValue!.year;
      return ye - _yearBegin + 1;
    }
    if (v == 31) return _calcDateCount(value!.year, value!.month);
    int _type = getColumnType(_col);
    switch (_type) {
      case 3: // hour
        if ((minHour != null && minHour! >= 0) ||
            (maxHour != null && maxHour! <= 23))
          return (maxHour ?? 23) - (minHour ?? 0) + 1;
        break;
      case 4: // minute
        if (minuteInterval != null && minuteInterval! > 1)
          return v ~/ minuteInterval!;
        break;
      case 7: // hour am/pm
        if ((minHour != null && minHour! >= 0) ||
            (maxHour != null && maxHour! <= 23)) if (_colAP < 0) {
          // I don't know am or PM
          return 12;
        } else {
          var _min = 0;
          var _max = 0;
          if (picker!.selecteds[_colAP] == 0) {
            // am
            _min = minHour == null
                ? 1
                : minHour! >= 12
                    ? 12
                    : minHour! + 1;
            _max = maxHour == null
                ? 12
                : maxHour! >= 12
                    ? 12
                    : maxHour! + 1;
          } else {
            // pm
            _min = minHour == null
                ? 1
                : minHour! >= 12
                    ? 24 - minHour! - 12
                    : 1;
            _max = maxHour == null
                ? 12
                : maxHour! >= 12
                    ? maxHour! - 12
                    : 1;
          }
          return _max > _min ? _max - _min + 1 : _min - _max + 1;
        }
        break;
    }
    return v;
  }

  @override
  int getMaxLevel() {
    return customColumnType == null
        ? lengths[type].length
        : customColumnType!.length;
  }

  @override
  bool needUpdatePrev(int curIndex) {
    if (_needUpdatePrev && value?.month == 2) {
      // Only February needs to be dealt with
      var _curType = getColumnType(curIndex);
      return _curType == 1 || _curType == 0;
    }
    return false;
  }

  @override
  void setColumn(int index) {
    //print("setColumn index: $index");
    _col = index + 1;
    if (_col < 0) _col = 0;
  }

  @override
  void initSelects() {
    _colAP = _getAPColIndex();
    int _maxLevel = getMaxLevel();
    // ignore: unnecessary_null_comparison
    if (picker!.selecteds == null) picker!.selecteds = <int>[];
    if (picker!.selecteds.length == 0) {
      for (int i = 0; i < _maxLevel; i++) picker!.selecteds.add(0);
    }
  }

  @override
  Widget buildItem(BuildContext context, int index) {
    String _text = "";
    int colType = getColumnType(_col);
    switch (colType) {
      case 0:
        if (twoDigitYear) {
          _text = "${_yearBegin + index}";
          var _l = _text.length;
          _text =
              "${_text.substring(_l - (_l - 2), _l)}${_checkStr(yearSuffix)}";
        } else
          _text = "${_yearBegin + index}${_checkStr(yearSuffix)}";
        break;
      case 1:
        if (isNumberMonth) {
          _text = "${index + 1}${_checkStr(monthSuffix)}";
        } else {
          if (months != null)
            _text = "${months![index]}";
          else {
            List _months =
                PickerLocalizations.of(context).months ?? MonthsList_EN;
            _text = "${_months[index]}";
          }
        }
        break;
      case 2:
        _text = "${index + 1}${_checkStr(daySuffix)}";
        break;
      case 3:
        _text = "${intToStr(index + (minHour ?? 0))}";
        break;
      case 5:
        _text = "${intToStr(index)}";
        break;
      case 4:
        if (minuteInterval == null || minuteInterval! < 2)
          _text = "${intToStr(index)}";
        else
          _text = "${intToStr(index * minuteInterval!)}";
        break;
      case 6:
        List? _ampm = strAMPM ?? PickerLocalizations.of(context).ampm;
        if (_ampm == null) _ampm = const ['AM', 'PM'];
        _text = "${_ampm[index]}";
        break;
      case 7:
        _text =
            "${intToStr(index + (minHour == null ? 0 : (picker!.selecteds[_colAP] == 0 ? minHour! : 0)) + 1)}";
        break;
    }

    return makeText(null, _text, picker!.selecteds[_col] == index);
  }

  @override
  String getText() {
    return value.toString();
  }

  @override
  int getColumnFlex(int column) {
    if (picker!.columnFlex != null && column < picker!.columnFlex!.length)
      return picker!.columnFlex![column];
    if (getColumnType(column) == 0) return 3;
    return 2;
  }

  @override
  void doShow() {
    if (_yearBegin == 0) getLength();
    var _maxLevel = getMaxLevel();
    for (int i = 0; i < _maxLevel; i++) {
      int colType = getColumnType(i);
      switch (colType) {
        case 0:
          picker!.selecteds[i] = yearEnd != null && value!.year > yearEnd!
              ? yearEnd! - _yearBegin
              : value!.year - _yearBegin;
          break;
        case 1:
          picker!.selecteds[i] = value!.month - 1;
          break;
        case 2:
          picker!.selecteds[i] = value!.day - 1;
          break;
        case 3:
          var h = value!.hour;
          if ((minHour != null && minHour! >= 0) ||
              (maxHour != null && maxHour! <= 23))
            h = (maxHour ?? 23) - (minHour ?? 0) + 1;
          picker!.selecteds[i] = h;
          break;
        case 4:
          picker!.selecteds[i] = minuteInterval == null || minuteInterval! < 2
              ? value!.minute
              : value!.minute ~/ minuteInterval!;
          break;
        case 5:
          picker!.selecteds[i] = value!.second;
          break;
        case 6:
          picker!.selecteds[i] = (value!.hour > 12 || value!.hour == 0) ? 1 : 0;
          break;
        case 7:
          picker!.selecteds[i] = value!.hour == 0
              ? 11
              : (value!.hour > 12)
                  ? value!.hour - 12 - 1
                  : value!.hour - 1;
          break;
      }
    }
  }

  @override
  void doSelect(int column, int index) {
    int year, month, day, h, m, s;
    year = value!.year;
    month = value!.month;
    day = value!.day;
    h = value!.hour;
    m = value!.minute;
    s = value!.second;
    if (type != 2 && type != 6) s = 0;

    int colType = getColumnType(column);
    switch (colType) {
      case 0:
        year = _yearBegin + index;
        break;
      case 1:
        month = index + 1;
        break;
      case 2:
        day = index + 1;
        break;
      case 3:
        h = index + (minHour ?? 0);
        break;
      case 4:
        m = (minuteInterval == null || minuteInterval! < 2)
            ? index
            : index * minuteInterval!;
        break;
      case 5:
        s = index;
        break;
      case 6:
        if (picker!.selecteds[_colAP] == 0) {
          if (h == 0) h = 12;
          if (h > 12) h = h - 12;
        } else {
          if (h < 12) h = h + 12;
          if (h == 12) h = 0;
        }
        if (minHour != null || maxHour != null) {
          if (minHour != null && _colHour >= 0) {
            if (h < minHour!) {
              picker!.selecteds[_colHour] = 0;
              picker!.updateColumn(_colHour);
              return;
            }
          }
          if (maxHour != null && h > maxHour!) h = maxHour!;
        }
        break;
      case 7:
        h = index +
            (minHour == null
                ? 0
                : (picker!.selecteds[_colAP] == 0 ? minHour! : 0)) +
            1;
        if (_colAP >= 0 && picker!.selecteds[_colAP] == 1) h = h + 12;
        if (h > 23) h = 0;
        break;
    }
    int __day = _calcDateCount(year, month);

    bool _isChangeDay = false;
    if (day > __day) {
      day = __day;
      _isChangeDay = true;
    }
    value = DateTime(year, month, day, h, m, s);

    if (minValue != null &&
        (value!.millisecondsSinceEpoch < minValue!.millisecondsSinceEpoch)) {
      value = minValue;
      notifyDataChanged();
    } else if (maxValue != null &&
        value!.millisecondsSinceEpoch > maxValue!.millisecondsSinceEpoch) {
      value = maxValue;
      notifyDataChanged();
    } else if (_isChangeDay && _colDay >= 0) {
      doShow();
      picker!.updateColumn(_colDay);
    }
  }

  int _getAPColIndex() {
    List<int> items = customColumnType ?? columnType[type];
    _colHour = items.indexWhere((e) => e == 7);
    _colDay = items.indexWhere((e) => e == 2);
    for (int i = 0; i < items.length; i++) {
      if (items[i] == 6) return i;
    }
    return -1;
  }

  int _calcDateCount(int year, int month) {
    switch (month) {
      case 1:
      case 3:
      case 5:
      case 7:
      case 8:
      case 10:
      case 12:
        return 31;
      case 2:
        {
          if ((year % 4 == 0 && year % 100 != 0) || year % 400 == 0) {
            return 29;
          }
          return 28;
        }
    }
    return 30;
  }

  String intToStr(int v) {
    return (v < 10) ? "0$v" : "$v";
  }

  String _checkStr(String? v) {
    return v == null ? "" : v;
  }
}
