## [0.8.0+1] - April 12, 2020

## BREAKING API CHANGES

- Feedback improvements (thank you for your emails!):
  - Changed long identifier names:
    - `CustomRefreshIndicatorData` => `IndicatorController`
    - `CustomRefreshIndicatorState` => `IndicatorState`
- Update example app
- ## `indicatorBuilder` argument is no longer present. Instead use `builder` argument which has some significant changes.

To animate indicator based on `IndicatorControler` you can use `AnimationBuilder` widget and pass `IndicatorData` object as `animation` argument. Because of that you can implement your own widget rebuild system what can improve your custom indicator performance (instead of building indicator eg. 300 times you can decide when you want to do it). Example:

```dart
return CustomRefreshIndicator(
    child: ListView(children: <Widget>[/* ... */]),
    builder: (
      BuildContext context,
      /// Subtree that contains scrollable widget and was passed
      /// to child argument
      Widget child,
      /// Now all your data will be stored in controller.
      /// To get controller outside of this function
      /// 1. Create controller in parent widget and pass it to CustomRefreshIndicator
      /// 2. Assign [GlobalKey] to CustomRefreshIndicator and access `key.currentState.controller`.
      IndicatorController controller
    ) {
      return AnimatedBuilder(
        // IndicatorData extends ChangeNotifier class so it is possible to
        // assign it to an AnimationBuilder widget and take advantage of subtree rebuild
        animation: controller,
        child: MyPrebuildWidget(),
        child: child,
        builder: (BuildContext context, Widget child) {
          /// TODO: Implement your custom refresh indicator
        },
      );
    },
    onRefresh: myAsyncMethod,
  );
```

## [0.2.1]

- Upgrade example to AndroidX
- Improved README

## [0.2.0] - Added support for BouncingScrollPhysics.

- Added support for `BouncingScrollPhysics` - ios default sroll physics
- Improved readme

## [0.1.1]

- Extracted inbox example to [`letter_refresh_indicator`](https://pub.dev/packages/letter_refresh_indicator) package

## [0.1.0] - Initial version.

- Added basic `CustomRefreshIndicator` widget with `CustomRefreshIndicatorData` class.
- Added `SimpleIndicatorContainer` widget which simulate default `RefreshIndicator` container
- Added examples:
  - inbox
  - simple
  - blur
