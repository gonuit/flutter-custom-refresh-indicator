# Flutter Custom Refresh Indicator

- [Flutter Custom Refresh Indicator](#flutter-custom-refresh-indicator)
  - [Examples:](#examples)
    - [Use of `SimpleIndicatorContainer` with `Icon` as child LINK](#use-of-simpleindicatorcontainer-with-icon-as-child-link)
    - [Envelope indicator](#envelope-indicator)
    - [Blur indicator](#blur-indicator)
  - [Getting started](#getting-started)
    - [`CustomRefreshIndicator`](#customrefreshindicator)
      - [Arguments](#arguments)
    - [`CustomRefreshIndicatorData`](#customrefreshindicatordata)
      - [Props](#props)
    - [`CustomRefreshIndicatorState`](#customrefreshindicatorstate)
      - [`idle`](#idle)
      - [`draging`](#draging)
      - [`armed`](#armed)
      - [`hiding`](#hiding)
      - [`loading`](#loading)

This package adds `CustomRefreshIndicator` widget that make it easy to implement custom refresh indicator.

## Examples:

### Use of `SimpleIndicatorContainer` with `Icon` as child [LINK](example/lib/indicators/simple_indicator.dart)  
![simple_indicator](readme/simple_container.gif)

### [Envelope indicator](https://pub.dev/packages/letter_refresh_indicator)  
![letter_indicator](readme/letter_indicator.gif)

### [Blur indicator](example/lib/indicators/blur_indicator.dart) 
![blur_indicator](readme/blur_indicator.gif)

## Getting started

### `CustomRefreshIndicator`
`CustomRefreshIndicator` is not the same as the` RefreshIndicator` widget. It has an absolute minimum functionality that allows you to create and set your own custom indicators.

#### Arguments
| Argument                   | type           | default value   | required                                                                                                  |
| :--- | :--- | :---| :--- |
| child                    | `Widget`        | --- | true |      |
| onRefresh         | `Future<void> Function()` | --- | true |                                                                                               |
| indicatorBuilder         | `Widget Function(BuildContext, CustomRefreshIndicatorData)`             | --- | true |   |
| dragingToIdleDuration            | `Duration`            | `Duration(milliseconds: 300)`            | false |                                                                                                   |
| armedToLoadingDuration           | `Duration`            | `Duration(milliseconds: 200)`         | false |                                                                                                     |
| loadingToIdleDuration           | `Duration`            | `Duration(milliseconds: 100)`          | false |                                                                                                    |
| leadingGlowVisible    | `bool`       | `false`        | false |                                                                                                      |
| trailingGlowVisible         | `bool`       | `true`      | false |                                                                                                        |



### `CustomRefreshIndicatorData`
Object containig data provided by `CustomRefreshIndicator`.

#### Props

| prop               | type                          |
|--------------------|-------------------------------|
| value              | `double`                      |
| direction          | `AxisDirection`               |
| scrollingDirection | `ScrollDirection`             |
| indicatorState     | `CustomRefreshIndicatorState` |

### `CustomRefreshIndicatorState`
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
  -  decreasing `CustomRefreshIndicatorData.value` to `1` in duration specified by `CustomRefreshIndicator.armedToLoadingDuration`)
  
  (`CustomRefreshIndicatorData.value >= 1`)

#### `hiding`
  `CustomRefreshIndicator` is hiding indicator when `onRefresh` future is resolved or indicator was canceled (scroll ended when [CustomRefreshIndicatorState] was equal to `dragging` so `value` was less than `1` or the user started scrolling through the list)
  
  (`CustomRefreshIndicatorData.value` decreases to `0` in duration specified by `CustomRefreshIndicator.dragingToIdleDuration`)

#### `loading`
  `CustomRefreshIndicator` is awaiting on `onRefresh` call result. When `onRefresh` will resolve `CustomRefreshIndicator` will change state from `loading` to `hiding` and decrease `CustomRefreshIndicatorData.value` from `1` to `0` in duration specified by `CustomRefreshIndicator.loadingToIdleDuration`
  
  (`CustomRefreshIndicatorData.value == 1`)