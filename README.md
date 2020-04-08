# Flutter Custom Refresh Indicator

This package provides `CustomRefreshIndicator` widget that make it easy to implement your own custom refresh indicator.

## Usage
```dart
CustomRefreshIndicator(
  // Your custom indicator builder
  indicatorBuilder: (context, data) => SimpleIndicatorContainer(
    data: data,
    child: SimpleIndicatorContent(data: data),
  ),
  onRefresh: myAsyncRefreshMethod,
  // Your child scroll widget 
  child: ListView.separated(
    itemBuilder: (BuildContext context, int index) => const SizedBox(
      height: 100,
    ),
    separatorBuilder: (BuildContext context, int index) =>
        const SizedBox(height: 20),
  ),
)
```

## Getting started

## Examples
### Use of `SimpleIndicatorContainer` with `Icon` as child [LINK](example/lib/indicators/simple_indicator.dart)  
![simple_indicator](readme/simple_container.gif)

### Envelope indicator
![letter_indicator](readme/letter_indicator.gif)



### `CustomRefreshIndicator`
`CustomRefreshIndicator` has an absolute minimum functionality that allows you to create and set your own custom indicators.

#### Arguments
| Argument                            | Type                                                            | Default value                  | Required          |    
| :---------------------------------- | :-------------------------------------------------------------- | :----------------------------- | :---------------- |
| child                               | `Widget`                                                        | none                           | true              |
| onRefresh                           | `Future<void> Function()`                                       | none                           | true              |
| indicatorBuilder                    | `Widget Function(BuildContext, CustomRefreshIndicatorData)  `   | none                           | true              |
| dragingToIdleDuration               | `Duration`                                                      | `Duration(milliseconds: 300)`  | false             |
| armedToLoadingDuration              | `Duration`                                                      | `Duration(milliseconds: 200)`  | false             |
| loadingToIdleDuration               | `Duration`                                                      | `Duration(milliseconds: 100)`  | false             |
| leadingGlowVisible                  | `bool`                                                          | `false`                        | false             |
| trailingGlowVisible                 | `bool`                                                          | `true`                         | false             |


### `CustomRefreshIndicatorData`
Contains data provided by `CustomRefreshIndicator` that could be usefull for your custom indicator implementation.

### Arguments

| argument           | type                          |
| :----------------- | :---------------------------- |
| value              | `double`                      |
| direction          | `AxisDirection`               |
| scrollingDirection | `ScrollDirection`             |
| indicatorState     | `IndicatorState` |

#### value

### `IndicatorState`
Enum which describes state of CustomRefreshIndicator.

#### `idle`
  `CustomRefreshIndicator` is idle (There is no action)
  
  (`CustomRefreshIndicatorData.value == 0`)

#### `draging`
  Whether user is draging `CustomRefreshIndicator` ending the scroll **WILL NOT** result in `onRefresh` call  
  
  (`CustomRefreshIndicatorData.value < 1`)

#### `armed`
  `CustomRefreshIndicator` is armed ending the scroll **WILL** result in:
  - `CustomRefreshIndicator.onRefresh` call
  - change of status to `loading`
  - decreasing `CustomRefreshIndicatorData.value` to `1` in duration specified by `CustomRefreshIndicator.armedToLoadingDuration`)
  
  (`CustomRefreshIndicatorData.value >= 1`)

#### `hiding`
  CustomRefreshIndicator is hiding indicator when `onRefresh` future is resolved or indicator was canceled (scroll ended when [IndicatorState] was equal to `dragging` so `value` was less than `1` or the user started scrolling through the list)
  
  (`CustomRefreshIndicatorData.value` decreases to `0` in duration specified by `CustomRefreshIndicator.dragingToIdleDuration`)

#### `loading`
  `CustomRefreshIndicator` is awaiting on `onRefresh` call result. When `onRefresh` will resolve `CustomRefreshIndicator` will change state from `loading` to `hiding` and decrease `CustomRefreshIndicatorData.value` from `1` to `0` in duration specified by `CustomRefreshIndicator.loadingToIdleDuration`
  
  (`CustomRefreshIndicatorData.value == 1`)