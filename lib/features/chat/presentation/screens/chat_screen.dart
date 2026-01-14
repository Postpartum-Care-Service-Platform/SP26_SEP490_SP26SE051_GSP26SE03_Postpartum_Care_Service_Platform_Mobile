import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/di/injection_container.dart';
import '../../../../core/utils/app_responsive.dart';
import '../../../../core/widgets/app_drawer_form.dart';
import '../bloc/chat_bloc.dart';
import '../bloc/chat_event.dart';
import '../bloc/chat_state.dart';
import '../widgets/chat_header.dart';
import '../widgets/conversation_detail.dart';
import '../widgets/conversation_list.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _messageScrollController = ScrollController();

  @override
  void dispose() {
    _messageController.dispose();
    _messageScrollController.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_messageScrollController.hasClients) return;
      _messageScrollController.animateTo(
        _messageScrollController.position.maxScrollExtent + 80,
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOut,
      );
    });
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
                  borderSide: const BorderSide(color: AppColors.primary, width: 2),
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

  Future<void> _showSupportDialog(BuildContext context) async {
    final controller = TextEditingController();
    final scale = AppResponsive.scaleFactor(context);
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return AppDrawerForm(
          title: AppStrings.chatRequestSupport,
          saveButtonText: AppStrings.send,
          isCompact: true,
          onSave: () {
            final reason = controller.text.trim();
            if (reason.isEmpty) {
              Navigator.of(ctx).pop();
              return;
            }
            context.read<ChatBloc>().add(ChatRequestSupportSubmitted(reason));
            Navigator.of(ctx).pop();
          },
          children: [
            SizedBox(height: 12 * scale),
            TextField(
              controller: controller,
              maxLines: 3,
              decoration: InputDecoration(
                hintText: AppStrings.chatRequestSupportReason,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12 * scale),
                  borderSide: const BorderSide(color: AppColors.borderLight),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12 * scale),
                  borderSide: const BorderSide(color: AppColors.primary, width: 2),
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

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => InjectionContainer.chatBloc..add(const ChatStarted()),
      child: BlocListener<ChatBloc, ChatState>(
        listenWhen: (p, c) => p.selectedConversation != c.selectedConversation,
        listener: (context, state) => _scrollToBottom(),
        child: BlocBuilder<ChatBloc, ChatState>(
          builder: (context, state) {
            _scrollToBottom();
            final width = MediaQuery.sizeOf(context).width;
            final isDesktop = width >= AppResponsive.desktopBp;
            final scale = AppResponsive.scaleFactor(context);

            return Scaffold(
              backgroundColor: AppColors.background,
              body: SafeArea(
                child: Padding(
                  padding: AppResponsive.pagePadding(context),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ChatHeader(
                        onCreateConversation: () => _showCreateConversationDialog(context),
                      ),
                      SizedBox(height: 16 * scale),
                      Expanded(
                        child: isDesktop
                            ? Row(
                                children: [
                                  SizedBox(
                                    width: 320 * scale,
                                    child: ConversationList(
                                      onCreate: () => _showCreateConversationDialog(context),
                                    ),
                                  ),
                                  SizedBox(width: 16 * scale),
                                  Expanded(
                                    child: ConversationDetail(
                                      onSupport: () => _showSupportDialog(context),
                                      controller: _messageController,
                                      scrollController: _messageScrollController,
                                    ),
                                  ),
                                ],
                              )
                            : Column(
                                children: [
                                  SizedBox(
                                    height: 280 * scale,
                                    child: ConversationList(
                                      onCreate: () => _showCreateConversationDialog(context),
                                    ),
                                  ),
                                  SizedBox(height: 12 * scale),
                                  Expanded(
                                    child: ConversationDetail(
                                      onSupport: () => _showSupportDialog(context),
                                      controller: _messageController,
                                      scrollController: _messageScrollController,
                                    ),
                                  ),
                                ],
                              ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

