import 'package:corridorshare/l10n/generated/app_localizations.dart';
import 'package:flutter/material.dart';

class MyPostsPage extends StatelessWidget {
  const MyPostsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: Text(l10n.tabMyPosts),
          bottom: TabBar(
            tabs: <Widget>[
              Tab(text: l10n.myPostsSending),
              Tab(text: l10n.myPostsCarrying),
            ],
          ),
        ),
        body: const TabBarView(
          children: <Widget>[
            _EmptyTab(),
            _EmptyTab(),
          ],
        ),
      ),
    );
  }
}

class _EmptyTab extends StatelessWidget {
  const _EmptyTab();

  @override
  Widget build(BuildContext context) {
    return const Center(child: Icon(Icons.inbox_outlined, size: 48));
  }
}
