import 'package:flutter/material.dart';

import 'custom_sliver_animated_view.dart';

class CustomSliverAnimatedGrid extends CustomSliverAnimatedView {
  /// Creates a sliver that animates items when they are inserted or removed.
  const CustomSliverAnimatedGrid({
    Key? key,
    required super.itemBuilder,
    required this.gridDelegate,
    super.initialItemCount = 0,
  }) : super(key: key);

  /// A delegate that controls the layout of the children within the [GridView].
  final SliverGridDelegate gridDelegate;

  @override
  CustomSliverAnimatedGridState createState() =>
      CustomSliverAnimatedGridState();

  /// The state from the closest instance of this class that encloses the given
  /// context.
  ///
  /// This method is typically used by [CustomSliverAnimatedGrid] item widgets that
  /// insert or remove items in response to user input.
  ///
  /// If no [CustomSliverAnimatedGrid] surrounds the context given, then this function
  /// will assert in debug mode and throw an exception in release mode.
  ///
  /// See also:
  ///
  ///  * [maybeOf], a similar function that will return null if no
  ///    [SliverAnimatedList] ancestor is found.
  static CustomSliverAnimatedGridState of(BuildContext context) {
    final CustomSliverAnimatedGridState? result =
        context.findAncestorStateOfType<CustomSliverAnimatedGridState>();
    assert(() {
      if (result == null) {
        throw FlutterError(
          'SliverAnimatedList.of() called with a context that does not contain a SliverAnimatedList.\n'
          'No SliverAnimatedListState ancestor could be found starting from the '
          'context that was passed to SliverAnimatedListState.of(). This can '
          'happen when the context provided is from the same StatefulWidget that '
          'built the AnimatedList. Please see the SliverAnimatedList documentation '
          'for examples of how to refer to an AnimatedListState object: '
          'https://api.flutter.dev/flutter/widgets/SliverAnimatedListState-class.html\n'
          'The context used was:\n'
          '  $context',
        );
      }
      return true;
    }());
    return result!;
  }

  /// The state from the closest instance of this class that encloses the given
  /// context.
  ///
  /// This method is typically used by [CustomSliverAnimatedGrid] item widgets that
  /// insert or remove items in response to user input.
  ///
  /// If no [CustomSliverAnimatedGrid] surrounds the context given, then this function
  /// will return null.
  ///
  /// See also:
  ///
  ///  * [of], a similar function that will throw if no [CustomSliverAnimatedGrid]
  ///    ancestor is found.
  static CustomSliverAnimatedGridState? maybeOf(BuildContext context) {
    return context.findAncestorStateOfType<CustomSliverAnimatedGridState>();
  }
}

class CustomSliverAnimatedGridState
    extends CustomSliverAnimatedViewState<CustomSliverAnimatedGrid> {
  @override
  Widget build(BuildContext context) {
    return SliverGrid(
      delegate: createDelegate(),
      gridDelegate: widget.gridDelegate,
    );
  }
}
