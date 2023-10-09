import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

const Duration _kDuration = Duration(milliseconds: 300);

abstract class CustomSliverAnimatedView extends StatefulWidget {
  /// Creates a sliver that animates items when they are inserted or removed.
  const CustomSliverAnimatedView({
    Key? key,
    required this.itemBuilder,
    this.initialItemCount = 0,
  })  : assert(initialItemCount >= 0),
        super(key: key);

  /// Called, as needed, to build list item widgets.
  ///
  /// List items are only built when they're scrolled into view.
  ///
  /// The [AnimatedItemBuilder] index parameter indicates the item's
  /// position in the list. The value of the index parameter will be between 0
  /// and [initialItemCount] plus the total number of items that have been
  /// inserted with [CustomSliverAnimatedViewState.insertItem] and less the total
  /// number of items that have been removed with
  /// [CustomSliverAnimatedViewState.removeItem].
  ///
  /// Implementations of this callback should assume that
  /// [CustomSliverAnimatedViewState.removeItem] removes an item immediately.
  final AnimatedItemBuilder itemBuilder;

  /// {@macro flutter.widgets.animatedList.initialItemCount}
  final int initialItemCount;

  /// The state from the closest instance of this class that encloses the given
  /// context.
  ///
  /// This method is typically used by [CustomSliverAnimatedView] item widgets that
  /// insert or remove items in response to user input.
  ///
  /// If no [CustomSliverAnimatedView] surrounds the context given, then this function
  /// will assert in debug mode and throw an exception in release mode.
  ///
  /// See also:
  ///
  ///  * [maybeOf], a similar function that will return null if no
  ///    [SliverAnimatedList] ancestor is found.
  static CustomSliverAnimatedViewState of(BuildContext context) {
    final CustomSliverAnimatedViewState? result =
        context.findAncestorStateOfType<CustomSliverAnimatedViewState>();
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
  /// This method is typically used by [CustomSliverAnimatedView] item widgets that
  /// insert or remove items in response to user input.
  ///
  /// If no [CustomSliverAnimatedView] surrounds the context given, then this function
  /// will return null.
  ///
  /// See also:
  ///
  ///  * [of], a similar function that will throw if no [CustomSliverAnimatedView]
  ///    ancestor is found.
  static CustomSliverAnimatedViewState? maybeOf(BuildContext context) {
    return context.findAncestorStateOfType<CustomSliverAnimatedViewState>();
  }
}

abstract class CustomSliverAnimatedViewState<T extends CustomSliverAnimatedView>
    extends State<T> with TickerProviderStateMixin {
  final List<ActiveItem> _incomingItems = <ActiveItem>[];
  final List<ActiveItem> _outgoingItems = <ActiveItem>[];
  int _itemsCount = 0;

  @override
  void initState() {
    super.initState();
    _itemsCount = widget.initialItemCount;
  }

  @override
  void dispose() {
    for (final ActiveItem item in _incomingItems.followedBy(_outgoingItems)) {
      item.controller!.dispose();
    }
    super.dispose();
  }

  @protected
  ActiveItem? removeActiveItemAt(List<ActiveItem> items, int itemIndex) {
    final int i = binarySearch(items, ActiveItem.index(itemIndex));
    return i == -1 ? null : items.removeAt(i);
  }

  @protected
  ActiveItem? activeItemAt(List<ActiveItem> items, int itemIndex) {
    final int i = binarySearch(items, ActiveItem.index(itemIndex));
    return i == -1 ? null : items[i];
  }

  // The insertItem() and removeItem() index parameters are defined as if the
  // removeItem() operation removed the corresponding list entry immediately.
  // The entry is only actually removed from the ListView when the remove animation
  // finishes. The entry is added to _outgoingItems when removeItem is called
  // and removed from _outgoingItems when the remove animation finishes.
  @protected
  int indexToItemIndex(int index) {
    int itemIndex = index;
    for (final ActiveItem item in _outgoingItems) {
      if (item.itemIndex <= itemIndex) {
        itemIndex += 1;
      } else {
        break;
      }
    }
    return itemIndex;
  }

  @protected
  int itemIndexToIndex(int itemIndex) {
    int index = itemIndex;
    for (final ActiveItem item in _outgoingItems) {
      assert(item.itemIndex != itemIndex);
      if (item.itemIndex < itemIndex) {
        index -= 1;
      } else {
        break;
      }
    }
    return index;
  }

  @protected
  SliverChildDelegate createDelegate() {
    return SliverChildBuilderDelegate(itemBuilder, childCount: _itemsCount);
  }

  /// Insert an item at [index] and start an animation that will be passed to
  /// [CustomSliverAnimatedView.itemBuilder] when the item is visible.
  ///
  /// This method's semantics are the same as Dart's [List.insert] method:
  /// it increases the length of the list by one and shifts all items at or
  /// after [index] towards the end of the list.
  void insertItem(int index, {Duration duration = _kDuration}) {
    assert(index >= 0);

    final int itemIndex = indexToItemIndex(index);
    if (itemIndex < 0 || itemIndex > _itemsCount) {
      return;
    }

    // Increment the incoming and outgoing item indices to account
    // for the insertion.
    for (final ActiveItem item in _incomingItems) {
      if (item.itemIndex >= itemIndex) item.itemIndex += 1;
    }
    for (final ActiveItem item in _outgoingItems) {
      if (item.itemIndex >= itemIndex) item.itemIndex += 1;
    }

    final AnimationController controller = AnimationController(
      duration: duration,
      vsync: this,
    );
    final ActiveItem incomingItem = ActiveItem.incoming(
      controller,
      itemIndex,
    );
    setState(() {
      _incomingItems
        ..add(incomingItem)
        ..sort();
      _itemsCount += 1;
    });

    controller.forward().then<void>((_) {
      removeActiveItemAt(_incomingItems, incomingItem.itemIndex)!
          .controller!
          .dispose();
    });
  }

  /// Remove the item at [index] and start an animation that will be passed
  /// to [builder] when the item is visible.
  ///
  /// Items are removed immediately. After an item has been removed, its index
  /// will no longer be passed to the [CustomSliverAnimatedView.itemBuilder]. However
  /// the item will still appear in the list for [duration] and during that time
  /// [builder] must construct its widget as needed.
  ///
  /// This method's semantics are the same as Dart's [List.remove] method:
  /// it decreases the length of the list by one and shifts all items at or
  /// before [index] towards the beginning of the list.
  void removeItem(int index, AnimatedRemovedItemBuilder builder,
      {Duration duration = _kDuration}) {
    assert(index >= 0);

    final int itemIndex = indexToItemIndex(index);
    if (itemIndex < 0 || itemIndex >= _itemsCount) {
      return;
    }

    assert(activeItemAt(_outgoingItems, itemIndex) == null);

    final ActiveItem? incomingItem =
        removeActiveItemAt(_incomingItems, itemIndex);
    final AnimationController controller = incomingItem?.controller ??
        AnimationController(duration: duration, value: 1.0, vsync: this);
    final ActiveItem outgoingItem =
        ActiveItem.outgoing(controller, itemIndex, builder);
    setState(() {
      _outgoingItems
        ..add(outgoingItem)
        ..sort();
    });
    void removeCallback() {
      removeActiveItemAt(_outgoingItems, outgoingItem.itemIndex)!
          .controller!
          .dispose();

      // Decrement the incoming and outgoing item indices to account
      // for the removal.
      for (final ActiveItem item in _incomingItems) {
        if (item.itemIndex > outgoingItem.itemIndex) item.itemIndex -= 1;
      }
      for (final ActiveItem item in _outgoingItems) {
        if (item.itemIndex > outgoingItem.itemIndex) item.itemIndex -= 1;
      }

      setState(() => _itemsCount -= 1);
    }

    if (index != 0) {
      controller.reverse().then((_) => removeCallback());
    } else {
      removeCallback();
    }
  }

  @protected
  Widget itemBuilder(BuildContext context, int itemIndex) {
    final ActiveItem? outgoingItem = activeItemAt(_outgoingItems, itemIndex);
    if (outgoingItem != null) {
      return outgoingItem.removedItemBuilder!(
        context,
        outgoingItem.controller!.view,
      );
    }

    final ActiveItem? incomingItem = activeItemAt(_incomingItems, itemIndex);
    final Animation<double> animation =
        incomingItem?.controller?.view ?? kAlwaysCompleteAnimation;
    return widget.itemBuilder(
      context,
      itemIndexToIndex(itemIndex),
      animation,
    );
  }
}

class ActiveItem implements Comparable<ActiveItem> {
  ActiveItem.incoming(this.controller, this.itemIndex)
      : removedItemBuilder = null;

  ActiveItem.outgoing(this.controller, this.itemIndex, this.removedItemBuilder);

  ActiveItem.index(this.itemIndex)
      : controller = null,
        removedItemBuilder = null;

  final AnimationController? controller;
  final AnimatedRemovedItemBuilder? removedItemBuilder;
  int itemIndex;

  @override
  int compareTo(ActiveItem other) => itemIndex - other.itemIndex;
}
