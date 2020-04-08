## [1.0.0]
## BREAKING API CHANGES
* Feedback improvements (thank you for emails!):
  * Changed long identifier names:
    * `CustomRefreshIndicatorData` => `IndicatorData`
    * `CustomRefreshIndicatorState` => `IndicatorState`
    * `CustomIndicatorBuilder` => `IndicatorBuilder`
* Changed `indicatorState` key contained in `IndicatorData` to => `state`
* ## `indicatorBuilder` function is no longer called on every `IndicatorData` change!

To animate indicator based on `IndicatorData` you can use `AnimationBuilder` widget and pass `IndicatorData` object as `animation` argument. Because of that you can implement your own widget rebuild system what can improve your custom indicator performance (instead of building indicator eg. 300 times you can decide when you want to do it). Example:
```dart
return CustomRefreshIndicator(
    child: ListView(children: <Widget>[/* ... */]),
    indicatorBuilder: (BuildContext context, IndicatorData data) {
      return AnimatedBuilder(
        // IndicatorData extends ChangeNotifier class so it is possible to
        // assign it to an AnimationBuilder and take advantage of subtree rebuild
        animation: data,
        child: MyPrebuildWidget(),
        builder: (BuildContext context, Widget child) {
          return MyCustomIndicator(child: child);
        },
      );
    },
    onRefresh: myAsyncMethod,
  );
```
## [0.2.1]
* Upgrade example to AndroidX
* Improved README
## [0.2.0] - Added support for BouncingScrollPhysics.
* Added support for `BouncingScrollPhysics` - ios default sroll physics
* Improved readme
## [0.1.1]
* Extracted inbox example to [`letter_refresh_indicator`](https://pub.dev/packages/letter_refresh_indicator) package
## [0.1.0] - Initial version.
* Added basic `CustomRefreshIndicator` widget with `CustomRefreshIndicatorData` class.
* Added `SimpleIndicatorContainer` widget which simulate default `RefreshIndicator` container
* Added examples:
  * inbox
  * simple
  * blur



