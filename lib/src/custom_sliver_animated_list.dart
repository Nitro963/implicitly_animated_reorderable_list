import 'package:flutter/material.dart';

import 'custom_sliver_animated_view.dart';

class CustomSliverAnimatedList extends CustomSliverAnimatedView {
  /// Creates a sliver that animates items when they are inserted or removed.
  const CustomSliverAnimatedList({
    Key? key,
    required super.itemBuilder,
    super.initialItemCount = 0,
  }) : super(key: key);

  @override
  CustomSliverAnimatedListState createState() =>
      CustomSliverAnimatedListState();
}

class CustomSliverAnimatedListState
    extends CustomSliverAnimatedViewState<CustomSliverAnimatedList> {
  @override
  Widget build(BuildContext context) {
    return SliverList(
      delegate: super.createDelegate(),
    );
  }
}
