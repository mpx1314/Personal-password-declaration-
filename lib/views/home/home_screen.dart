import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../controllers/auth_controller.dart';
import '../../controllers/password_controller.dart';
import '../../widgets/search/search_bar_widget.dart';
import '../../widgets/password/password_list_widget.dart';
import '../../widgets/common/app_drawer.dart';
import '../../widgets/add/add_password_dialog.dart';
import '../auth/auth_setup_screen.dart';
import '../settings/settings_screen.dart';
import '../import_export/import_export_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TextEditingController _searchController = TextEditingController();
  FocusNode _searchFocusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<PasswordController>().loadPasswordEntries();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('个人密码管理'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () => _navigateToSettings(),
          ),
        ],
      ),
      drawer: const AppDrawer(),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: SearchBarWidget(
                controller: _searchController,
                focusNode: _searchFocusNode,
                onChanged: (value) {
                  context.read<PasswordController>().searchEntries(value);
                },
                onClear: () {
                  _searchController.clear();
                  _searchFocusNode.unfocus();
                  context.read<PasswordController>().clearSearch();
                },
              ),
            ),
            Expanded(
              child: Consumer<PasswordController>(
                builder: (context, passwordController, child) {
                  if (passwordController.isLoading) {
                    return const Center(
                      child: CircularProgressIndicator(),
                    );
                  }

                  if (passwordController.filteredEntries.isEmpty) {
                    return _buildEmptyState(passwordController.searchQuery);
                  }

                  return PasswordListWidget(
                    entries: passwordController.filteredEntries,
                    searchQuery: passwordController.searchQuery,
                  );
                },
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showAddPasswordDialog,
        icon: const Icon(Icons.add),
        label: const Text('添加密码'),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }

  Widget _buildEmptyState(String searchQuery) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            searchQuery.isEmpty ? Icons.lock_outline : Icons.search_off,
            size: 64,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            searchQuery.isEmpty ? '还没有密码条目' : '没有找到匹配的密码',
            style: TextStyle(
              fontSize: 18,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            searchQuery.isEmpty ? '点击下方按钮添加第一个密码' : '尝试其他搜索关键词',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[500],
            ),
          ),
          if (searchQuery.isEmpty) ...[
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: _showAddPasswordDialog,
              icon: const Icon(Icons.add),
              label: const Text('添加密码'),
            ),
          ],
        ],
      ),
    );
  }

  void _showAddPasswordDialog() {
    showDialog(
      context: context,
      builder: (context) => const AddPasswordDialog(),
    );
  }

  void _navigateToSettings() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const SettingsScreen()),
    );
  }
}