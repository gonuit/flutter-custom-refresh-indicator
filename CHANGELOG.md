## 3.0.0
- **CustomRefreshIndicator**:
  - Deprecated *indicatorFinalizeDuration*, *indicatorSettleDuration*, *indicatorCancelDuration* and *completeStateDuration* parameters in favor of *durations*.
  - The indicator widget will now be rebuilt every time *state* changes, even if the *autoRebuilt* parameter is set to false. This will make managing the state of the indicator widget simpler.
  - Deprecated *IndicatorDelegate* and *MaterialIndicatorDelegate* in favor of *CustomMaterialIndicator* widget.
- **IndicatorController**:
  - The controller now extends *Animation<double>*. This allows it to be used directly with *Transition* widgets to further improve animation performance.
  - New *ClampedAnimation* class for constraining the *IndicatorController* animation value within a specific range using the *clamp* method.
  - Drag interaction details are now available, enabling pointer-position-based animations.
- **Example app**:
  - The checkmark indicator example has been simplified.
  - Minor corrections to the envelope indicator.
  - Added image precaching.
  - Removed unused code.
## 2.2.1
- Fixed typos in documentation
## 2.2.0
- Added *clipBehavior* and the *elevation* arguments of the *MaterialIndicatorDelegate* class.
## 2.1.0
- Updated the dart sdk constraints
## 2.0.1
- Added missing *isCanceling* and *isSettling* getters for *IndicatorState* and *IndicatorController* enum.
## 2.0.0
## Breaking changes
- Added `autoRebuild` flag which is by default set to `true`.
  From now on, there is no need to wrap widgets in the builder function with the `AnimatedBuilder` widget, as it will be automatically rebuilt. For optimization purposes, you can use the old behavior by setting the `autoRebuild` argument to false.
- Remove *IndicatorState.hiding* state. Instead introduced *IndicatorState.finalizing* and *IndicatorState.canceling*.
- Split *IndicatorState.loading* state into two phases: *IndicatorState.settling* and *IndicatorState.loading*.
- Renamed `extentPercentageToArmed` argument to `containerExtentPercentageToArmed` which better describes what it exactly does.
- Changed the default value of the `defaultContainerExtentPercentageToArmed` from `0.20` to `0.1(6)` to match the behavior of the built-in indicator widget.
- Removed deprecated **IndicatorStateHelper** class. Instead use **CustomRefreshIndicator.onStateChanged** method.
- Removed deprecated **leadingGlowVisible** and **trailingGlowVisible** arguments. Instead use **leadingScrollIndicatorVisible** and  **trailingScrollIndicatorVisible** accordingly.
- Allow setting the edge of the list that will trigger the pull to refresh action.
  - Introduced **IndicatorEdge**, **IndicatorTrigger**, **IndicatorSide** and **IndicatorTriggerMode** classes.
  - Replaced **reversed** argument of the **CustomRefreshIndicator** class with **trigger**.
  - Added **edge** and **side** properties to the **IndicatorController** class.
- Added extension with utility getters for **IndicatorState** class.
- Trigger mode support added. Equivalent to trigger mode of the built-in **RefreshIndicator** widget.
- The **PositionedIndicatorContainer** class is no longer exported from this package, however the source code is available in the example application. 
- Now the *onRefresh* function will be triggered immediately when the indicator is released in the armed state. Previously, the *onRefresh* function was triggered when the indicator reached a target value in the loading state of `1.0`.
- Fixed a bug causing the *onRefresh* method not to be triggered on the iOS platform due to bounce physics.
- Implemented equality operator for *IndicatorStateChange* class.
- Improved code coverage with tests
- Multiple minor fixes, improvements and optimizations.
## 1.2.1
- Flutter 3.0.0 migration backward compatibility fix ([#31](https://github.com/gonuit/flutter-custom-refresh-indicator/pull/31)) by [Jordan1122](https://github.com/Jordan1122)
## 1.2.0
### Improvements:
- Compatibility improvements for Flutter 3.0.
## 1.1.2
### Fixes:
  - Fixed assertion issue reported and resolved by [ziqq](https://github.com/ziqq) in [#29](https://github.com/gonuit/flutter-custom-refresh-indicator/pull/29). For more information, please take a look at the following issue [#28](https://github.com/gonuit/flutter-custom-refresh-indicator/issues/28)
## 1.1.1
### Fixes:
  - Pub.dev readme file fix.
  - Fix code formatting issues
## 1.1.0

### Fixes:

- Handle errors thrown from the `onRefresh` method.

### Improvements:

- Updated example app
  - Added support for the Android embedding v2
  - Added web support
  - Added windows support.
- Added a web based demo app (url in the readme file).
- Replaced the deprecated `disallowGlow` method calls with `disallowIndicator`.
- Added `onStateChanged` function argument that allows tracking indicator state changes.
- The `IndicatorStateHelper` class is now deprecated in favor of `onStateChange` function and `IndicatorStateChange` class.
- Initial support for programmatically-controlled indicators has been added. Added the `show`,` hide` and `refresh` methods to the` CustomRefreshIndicatorState` class. It can be accessed via GlobalKey. Take a look at an [programmatically-controlled screen example](/example/lib/screens/programmatically_controlled_indicator_screen.dart).
- Use the `flutter_lints` package for analysis.
- Deprecate `leadingGlowVisible` and `trailingGlowVisible` in favor of `leadingScrollIndicatorVisible` and `trailingScrollIndicatorVisible` arguments.
- Added `reversed` argument that allows you to trigger a refresh indicator from the end of the list.
- Added `envelope` example.
- Added `pull to fetch more` example.

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
- `IndicatorController` changes:
  - Added `previousState` property.
  - Added `didStateChange` helper method.
  - Added `wasArmed`, `wasDragging`, `wasLoading`, `wasHiding` and `wasIdle` properties.
- Added `notificationPredicate` property to the `CustomRefreshIndicator` widget.
- Example app:
  - Added initial version of `check_mark_indicator`. Example that shows how to make use of `complete` state.

## 0.8.0+1

## BREAKING API CHANGES

- Changed long identifier names:
  - `CustomRefreshIndicatorData` => `IndicatorController`
  - `CustomRefreshIndicatorState` => `IndicatorState`
- `indicatorBuilder` argument is no longer present. Instead use `builder` argument which has some significant changes.

To animate indicator based on `IndicatorController` you can use `AnimationBuilder` widget and pass `IndicatorData` object as `animation` argument. Because of that you can implement your own widget rebuild system what can improve your custom indicator performance (instead of building indicator eg. 300 times you can decide when you want to do it). Example:

```dart
return CustomRefreshIndicator(
    child: ListView(children: <Widget>[/* ... */]),
    builder: (
      BuildContext context,
      /// Subtree that contains scrollable widget and was passed
      /// to child argument
      Widget child,
      /// Now all your data will be stored in controller.
      /// To get controller outside of this function you can either:
      /// - Create controller in parent widget and pass it to CustomRefreshIndicator widget
      /// - Assign [GlobalKey] to CustomRefreshIndicator and access `key.currentState.controller`.
      IndicatorController controller
    ) {
      return AnimatedBuilder(
        // IndicatorData extends ChangeNotifier class so it is possible to
        // assign it to an AnimationBuilder widget and take advantage of subtree rebuild
        animation: controller,
        child: MyWidget(),
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

- Added support for `BouncingScrollPhysics` - ios default scroll physics
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
