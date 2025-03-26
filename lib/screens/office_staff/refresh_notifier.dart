import 'package:flutter/material.dart';

class RefreshNotifier extends ValueNotifier<bool> {
  RefreshNotifier() : super(false);
}

final refreshNotifier = RefreshNotifier();
