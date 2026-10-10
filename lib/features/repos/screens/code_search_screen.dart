import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../data/models/github_code_search.dart';
import '../../../data/services/auth_storage.dart';
import '../../../data/services/github_api_service.dart';
import 'file_viewer_screen.dart';

class CodeSearchScreen extends StatefulWidget {
  final String owner;
  final String repoName;

  const CodeSearchScreen({
    super.key,
    required this.owner,
    required this.repoName,
  });

  @override
  State<CodeSearchScreen> createState() => _CodeSearchScreenState();
}

class _CodeSearchScreenState extends State<CodeSearchScreen> {
  final _searchController = TextEditingController();
  final _focusNode = FocusNode();

  List<GitHubCodeSearchResult> _results = [];
  bool _isSearching = false;
  bool _hasSearched = false;
  String? _error;
  String _query = '';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _focusNode.requestFocus();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  Future<void> _doSearch() async {
    final q = _searchController.text.trim();
    if (q.isEmpty) return;

    FocusScope.of(context).unfocus();

    setState(() {
      _isSearching = true;
      _hasSearched = true;
      _query = q;
      _error = null;
      _results = [];
    });

    final token = await AuthStorage.getToken();
    if (token == null) {
      setState(() {
        _error = 'Token tidak ditemukan';
        _isSearching = false;
      });
      return;
    }

    final results = await GitHubApiService.searchCode(
      token,
      widget.owner,
      widget.repoName,
      q,
    );

    if (!mounted) return;
    setState(() {
      _results = results;
      _isSearching = false;
    });
  }

  Future<void> _openResult(GitHubCodeSearchResult result) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => FileViewerScreen(
          owner: widget.owner,
          repoName: widget.repoName,
          path: result.path,
        ),
      ),
    );
  }

  Future<void> _openInBrowser(GitHubCodeSearchResult result) async {
    if (result.htmlUrl == null) return;
    final uri = Uri.parse(result.htmlUrl!);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded,
              color: Color(0xFF111827)),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Search in ${widget.repoName}',
          style: const TextStyle(
            fontFamily: 'Inter',
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: Color(0xFF111827),
          ),
        ),
      ),
      body: Column(
        children: [
          _buildSearchBar(),
          Expanded(child: _buildBody()),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xFFF9FAFB),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: const Color(0xFFE5E7EB)),
        ),
        child: TextField(
          controller: _searchController,
          focusNode: _focusNode,
          textInputAction: TextInputAction.search,
          onSubmitted: (_) => _doSearch(),
          style: const TextStyle(
            fontFamily: 'Inter',
            fontSize: 14,
            color: Color(0xFF111827),
          ),
          decoration: InputDecoration(
            hintText: 'Cari fungsi, class, variable...',
            hintStyle: const TextStyle(
              fontFamily: 'Inter',
              fontSize: 14,
              color: Color(0xFF9CA3AF),
            ),
            prefixIcon: const Icon(Icons.search_rounded,
                color: Color(0xFF6B7280), size: 20),
            suffixIcon: IconButton(
              icon: const Icon(Icons.arrow_forward_rounded, size: 18),
              color: const Color(0xFF6366F1),
              onPressed: _doSearch,
            ),
            border: InputBorder.none,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 14,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBody() {
    if (_isSearching) {
      return const Center(
        child: CircularProgressIndicator(color: Color(0xFF6366F1)),
      );
    }

    if (_error != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline_rounded,
                  size: 60, color: Color(0xFFDC2626)),
              const SizedBox(height: 16),
              Text(
                _error!,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 14,
                  color: Color(0xFF6B7280),
                ),
              ),
            ],
          ),
        ),
      );
    }

    if (!_hasSearched) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(40),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  color: const Color(0xFF6366F1).withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.manage_search_rounded,
                  size: 50,
                  color: Color(0xFF6366F1),
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                'Cari kode di repo ini',
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF111827),
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Cari fungsi, class, variable,\natau apapun di dalam kode',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 13,
                  color: Color(0xFF6B7280),
                  height: 1.5,
                ),
              ),
            ],
          ),
        ),
      );
    }

    if (_results.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(40),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.search_off_rounded,
                  size: 60, color: Color(0xFF9CA3AF)),
              const SizedBox(height: 16),
              Text(
                'Gak ketemu hasil buat "$_query"',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 14,
                  color: Color(0xFF6B7280),
                ),
              ),
            ],
          ),
        ),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.all(20),
      itemCount: _results.length,
      separatorBuilder: (_, __) => const SizedBox(height: 10),
      itemBuilder: (_, i) => _buildResultCard(_results[i]),
    );
  }

  Widget _buildResultCard(GitHubCodeSearchResult result) {
    return GestureDetector(
      onTap: () => _openResult(result),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: const Color(0xFFE5E7EB)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: _fileTypeColor(result.extension)
                        .withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Icon(
                    Icons.insert_drive_file_rounded,
                    size: 14,
                    color: _fileTypeColor(result.extension),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    result.name,
                    style: const TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF111827),
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                GestureDetector(
                  onTap: () => _openInBrowser(result),
                  child: const Padding(
                    padding: EdgeInsets.all(4),
                    child: Icon(
                      Icons.open_in_new_rounded,
                      size: 16,
                      color: Color(0xFF9CA3AF),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(Icons.folder_outlined,
                    size: 14, color: Color(0xFF6B7280)),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    result.path,
                    style: const TextStyle(
                      fontFamily: 'monospace',
                      fontSize: 11,
                      color: Color(0xFF6B7280),
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Color _fileTypeColor(String ext) {
    switch (ext) {
      case 'dart':
        return const Color(0xFF00B4AB);
      case 'js':
      case 'jsx':
        return const Color(0xFFF1E05A);
      case 'ts':
      case 'tsx':
        return const Color(0xFF3178C6);
      case 'py':
        return const Color(0xFF3572A5);
      case 'java':
        return const Color(0xFFB07219);
      case 'kt':
        return const Color(0xFFA97BFF);
      case 'swift':
        return const Color(0xFFF05138);
      case 'go':
        return const Color(0xFF00ADD8);
      case 'rs':
        return const Color(0xFFDEA584);
      case 'cpp':
      case 'cc':
      case 'hpp':
        return const Color(0xFFF34B7D);
      case 'c':
      case 'h':
        return const Color(0xFF555555);
      case 'cs':
        return const Color(0xFF178600);
      case 'rb':
        return const Color(0xFF701516);
      case 'php':
        return const Color(0xFF4F5D95);
      case 'html':
        return const Color(0xFFE34C26);
      case 'css':
        return const Color(0xFF563D7C);
      case 'sh':
        return const Color(0xFF89E051);
      case 'md':
        return const Color(0xFF083FA1);
      case 'json':
        return const Color(0xFFF59E0B);
      case 'yml':
      case 'yaml':
        return const Color(0xFFCB171E);
      default:
        return const Color(0xFF6366F1);
    }
  }
}