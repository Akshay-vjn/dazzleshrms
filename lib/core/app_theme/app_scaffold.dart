import 'package:flutter/material.dart';
import 'app_visuals.dart';

class AppScaffold extends StatelessWidget {
  final PreferredSizeWidget? appBar;
  final Widget? body;
  final Widget? floatingActionButton;

  const AppScaffold({
    super.key,
    this.appBar,
    this.body,
    this.floatingActionButton,
  });

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: AppVisuals.of(context).backdrop,
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: appBar,
        body: body,
        floatingActionButton: floatingActionButton,
      ),
    );
  }
}
