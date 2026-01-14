import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/di/injection_container.dart';
import '../../../../core/utils/app_responsive.dart';
import '../../../../core/utils/app_text_styles.dart';
import '../../../../core/widgets/app_widgets.dart';
import '../../../../core/widgets/app_drawer_form.dart';
import '../bloc/chat_bloc.dart';
import '../bloc/chat_event.dart';
import '../widgets/conversation_list.dart';
import 'conversation_detail_screen.dart';

class ConversationListScreen extends StatefulWidget {
  const ConversationListScreen({super.key});

  @override
  State<ConversationListScreen> createState() => _ConversationScreenState();
}

class _ConversationScreenState extends State<ConversationListScreen> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _showCreateConversationDialog(BuildContext context) async {
    final controller = TextEditingController();
    final scale = AppResponsive.scaleFactor(context);
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return AppDrawerForm(
          title: AppStrings.chatNewConversation,
          saveButtonText: AppStrings.add,
          isCompact: true,
          onSave: () {
            final name = controller.text.trim();
            if (name.isEmpty) {
              Navigator.of(ctx).pop();
              return;
            }
            context.read<ChatBloc>().add(ChatCreateConversationSubmitted(name));
            Navigator.of(ctx).pop();
          },
          children: [
            SizedBox(height: 12 * scale),
            TextField(
              controller: controller,
              decoration: InputDecoration(
                hintText: AppStrings.chatNewConversationPlaceholder,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12 * scale),
                  borderSide: const BorderSide(color: AppColors.borderLight),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12 * scale),
                  borderSide:
                      const BorderSide(color: AppColors.primary, width: 2),
                ),
                filled: true,
                fillColor: AppColors.white,
                contentPadding: EdgeInsets.symmetric(
                  horizontal: 14 * scale,
                  vertical: 12 * scale,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  void _openConversation(BuildContext context, int conversationId) {
    final chatBloc = context.read<ChatBloc>()..add(ChatConversationSelected(conversationId));
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => BlocProvider.value(
          value: chatBloc,
          child: const ConversationDetailScreen(),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final scale = AppResponsive.scaleFactor(context);
    return BlocProvider(
      create: (_) => InjectionContainer.chatBloc
        ..add(const ChatStarted(autoSelectFirstConversation: false)),
      child: Builder(
        builder: (contextWithBloc) {
          return Scaffold(
            backgroundColor: Colors.transparent,
            body: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    AppColors.background,
                    AppColors.white,
                  ],
                ),
              ),
              child: SafeArea(
                child: Padding(
                  padding: AppResponsive.pagePadding(contextWithBloc),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        AppStrings.chatTitle,
                        style: AppTextStyles.tinos(
                          fontSize: 22 * scale,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      SizedBox(height: 4 * scale),
                      Text(
                        AppStrings.chatSubtitle,
                        style: AppTextStyles.arimo(
                          fontSize: 13 * scale,
                          color: AppColors.textSecondary,
                        ),
                      ),
                      SizedBox(height: 12 * scale),
                      _SearchBar(controller: _searchController),
                      SizedBox(height: 16 * scale),
                      Expanded(
                        child: ConversationList(
                          onCreate: () =>
                              _showCreateConversationDialog(contextWithBloc),
                          onConversationTap: (id) =>
                              _openConversation(contextWithBloc, id),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            floatingActionButton: AppWidgets.primaryFabIcon(
              context: contextWithBloc,
              icon: Icons.add_comment_rounded,
              onPressed: () => _showCreateConversationDialog(contextWithBloc),
            ),
          );
        },
      ),
    );
  }
}

class _SearchBar extends StatelessWidget {
  final TextEditingController controller;

  const _SearchBar({required this.controller});

  @override
  Widget build(BuildContext context) {
    final scale = AppResponsive.scaleFactor(context);
    return Container(
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16 * scale),
        border: Border.all(color: AppColors.borderLight.withValues(alpha: 0.6)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 16 * scale,
            offset: Offset(0, 6 * scale),
          ),
        ],
      ),
      child: TextField(
        controller: controller,
        decoration: InputDecoration(
          prefixIcon: Icon(
            Icons.search_rounded,
            color: AppColors.textSecondary,
          ),
          suffixIcon: Padding(
            padding: EdgeInsets.only(right: 8 * scale),
            child: Container(
              width: 32 * scale,
              height: 32 * scale,
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(12 * scale),
              ),
              child: Icon(
                Icons.tune_rounded,
                size: 18 * scale,
                color: AppColors.primary,
              ),
            ),
          ),
          suffixIconConstraints: BoxConstraints(
            minWidth: 40 * scale,
            minHeight: 40 * scale,
          ),
          hintText: AppStrings.chatSearchHint,
          border: InputBorder.none,
          contentPadding:
              EdgeInsets.symmetric(horizontal: 12 * scale, vertical: 14 * scale),
        ),
      ),
    );
  }
}

