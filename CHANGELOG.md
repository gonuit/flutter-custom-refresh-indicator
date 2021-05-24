## 1.0.0
- Stable nullsafety release.
- **BREAKING**: opt into null safety
  - Dart SDK constraints: >=2.12.0-0 <3.0.0
- **BREAKING**: Removed `prevState` from `IndicatorController` class.
  Because flutter only marks the widget that it is ready for rebuild, it is possible that the controller state will change more than once during a single frame what causes one or more steps to be skipped. To still use `prevState` and `didChangeState` method, you can use `IndicatorStateHelper`. Take a look at `check_mark_indicator.dart` or `warp_indicator.dart` for example usage.
- Added `IndicatorStateHelper` class.
- Added `IndicatorController` unit tests.
- Added warp indicator example.
- Added `stopDrag` method to the `IndicatorController` class. It allows you to stop current user drag.

## 0.9.0

- Improved readme documentation.
- Removed material package import.

## 0.9.0-dev.2

- Added `isComplete` and `wasComplete` controller getters.
- Removed `axis` property as it can be handled by `notificationPredicate`.

## 0.9.0-dev.1

- Added optional `complete` indicator state together with `completeStateDuration` parameter.
- `IndicatorControler` changes:
  - Added `prevoiusState` property.
  - Added `didStateChange` helper method.
  - Added `wasArmed`, `wasDragging`, `wasLoading`, `wasHiding` and `wasIdle` properties.
- Added `notificationPredicate` property to the `CustomRefreshIndicator` widget.
- Example app:
  - Added initial version of `check_mark_indicator`. Example that shows how to make use of `complete` state. 

## 0.8.0+1

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

## 0.2.1

- Upgrade example to AndroidX
- Improved README

## 0.2.0

- Added support for `BouncingScrollPhysics` - ios default sroll physics
- Improved readme

## 0.1.1

- Extracted inbox example to [`letter_refresh_indicator`](https://pub.dev/packages/letter_refresh_indicator) package

## 0.1.0

- Added basic `CustomRefreshIndicator` widget with `CustomRefreshIndicatorData` class.
- Added `SimpleIndicatorContainer` widget which simulate default `RefreshIndicator` container
- Added examples:
  - inbox
  - simple
  - blur
