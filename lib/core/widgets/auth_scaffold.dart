import 'package:flutter/material.dart';

import '../constants/app_colors.dart';
import '../utils/app_responsive.dart';

class _NoOverscrollBehavior extends MaterialScrollBehavior {
  const _NoOverscrollBehavior();

  @override
  Widget buildOverscrollIndicator(
    BuildContext context,
    Widget child,
    ScrollableDetails details,
  ) {
    return child;
  }
}

class AuthScaffold extends StatelessWidget {
  final List<Widget> children;
  final Widget? footer;
  final EdgeInsets? extraPadding;

  const AuthScaffold({
    super.key,
    required this.children,
    this.footer,
    this.extraPadding,
  });

  @override
  Widget build(BuildContext context) {
    final contentWidth = AppResponsive.maxContentWidth(context);
    final keyboardBottom = MediaQuery.viewInsetsOf(context).bottom;
    final isKeyboardOpen = keyboardBottom > 0;

    final basePadding =
        AppResponsive.pagePadding(context).add(extraPadding ?? EdgeInsets.zero);

    return Scaffold(
      backgroundColor: AppColors.background,
      resizeToAvoidBottomInset: true,
      body: SafeArea(
        child: ScrollConfiguration(
          behavior: const _NoOverscrollBehavior(),
          child: LayoutBuilder(
            builder: (context, viewport) {
              return SingleChildScrollView(
                keyboardDismissBehavior:
                    ScrollViewKeyboardDismissBehavior.onDrag,
                physics: const ClampingScrollPhysics(),
                padding: basePadding.add(const EdgeInsets.only(bottom: 24)),
                child: ConstrainedBox(
                  constraints: BoxConstraints(minHeight: viewport.maxHeight),
                  child: Align(
                    alignment:
                        isKeyboardOpen ? Alignment.topCenter : Alignment.center,
                    child: ConstrainedBox(
                      constraints: BoxConstraints(maxWidth: contentWidth),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          SizedBox(height: AppResponsive.topSpacing(context)),
                          ...children,
                          if (footer != null) ...[
                            const SizedBox(height: 24),
                            footer!,
                          ],
                          const SizedBox(height: 40),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
