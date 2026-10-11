import 'package:corridorshare/l10n/generated/app_localizations.dart';
import 'package:flutter/material.dart';

class ChatsPage extends StatelessWidget {
  const ChatsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(title: Text(l10n.tabChats)),
      body: Center(
        child: Text(l10n.chatsEmpty),
      ),
    );
  }
}
