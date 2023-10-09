import 'package:flutter/material.dart';

typedef ImplicitlyAnimatedItemBuilder<W extends Widget, E> = W Function(
    BuildContext context, Animation<double> animation, E item, int i);

typedef RemovedItemBuilder<W extends Widget, E> = W Function(
    BuildContext context, Animation<double> animation, E item);

typedef UpdatedItemBuilder<W extends Widget, E> = W Function(
    BuildContext context, Animation<double> animation, E item);
