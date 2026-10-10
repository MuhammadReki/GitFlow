import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../data/models/github_gist.dart';
import '../../../data/services/auth_storage.dart';
import '../../../data/services/github_api_service.dart';

class GistDetailScreen extends StatefulWidget {
  final String gistId;

  const GistDetailScreen({
    super.key,
    required this.gistId,
  });

  @override
  State<GistDetailScreen> createState() => _GistDetailScreenState();
}

class _GistDetailScreenState extends State<GistDetailScreen> {
  GitHubGist? _gist;
  bool _isLoading = true;
  String? _error;
  String? _selectedFilename;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    final token = await AuthStorage.getToken();
    if (token == null) {
      setState(() {
        _error = 'Token tidak ditemukan';
        _isLoading = false;
      });
      return;
    }

    final gist = await GitHubApiService.getGistDetail(token, widget.gistId);

    if (!mounted) return;
    setState(() {
      _gist = gist;
      _isLoading = false;
      if (gist != null && gist.files.isNotEmpty) {
        _selectedFilename = gist.files.keys.first;
      }
    });
  }

  Future<void> _copyContent(String content) async {
    await Clipboard.setData(ClipboardData(text: content));
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Content di-copy'),
        backgroundColor: Color(0xFF10B981),
      ),
    );
  }

  Future<void> _openInBrowser() async {
    if (_gist?.htmlUrl == null) return;
    final uri = Uri.parse(_gist!.htmlUrl!);
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
        title: const Text(
          'Gist',
          style: TextStyle(
            fontFamily: 'Inter',
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: Color(0xFF111827),
          ),
        ),
        actions: [
          if (_gist != null) ...[
            IconButton(
              icon: const Icon(Icons.copy_rounded,
                  color: Color(0xFF6366F1), size: 20),
              onPressed: () {
                final file = _gist!.files[_selectedFilename];
                if (file?.content != null) {
                  _copyContent(file!.content!);
                }
              },
              tooltip: 'Copy content',
            ),
            IconButton(
              icon: const Icon(Icons.open_in_new_rounded,
                  color: Color(0xFF6366F1), size: 20),
              onPressed: _openInBrowser,
            ),
          ],
        ],
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(color: Color(0xFF6366F1)),
      );
    }

    if (_error != null || _gist == null) {
      return Center(
        child: Text(
          _error ?? 'Gist gak ketemu',
          style: const TextStyle(fontFamily: 'Inter'),
        ),
      );
    }

    final gist = _gist!;

    return Column(
      children: [
        // Gist header info
        Container(
          width: double.infinity,
          color: Colors.white,
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (gist.description != null &&
                  gist.description!.isNotEmpty) ...[
                Text(
                  gist.description!,
                  style: const TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF111827),
                  ),
                ),
                const SizedBox(height: 10),
              ],
              Row(
                children: [
                  if (gist.ownerAvatar != null)
                    Container(
                      width: 24,
                      height: 24,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        image: DecorationImage(
                          image: NetworkImage(gist.ownerAvatar!),
                          fit: BoxFit.cover,
                        ),
                      ),
                    )
                  else
                    const Icon(Icons.person,
                        size: 18, color: Color(0xFF6B7280)),
                  const SizedBox(width: 8),
                  Text(
                    gist.ownerLogin ?? 'unknown',
                    style: const TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 12,
                      color: Color(0xFF6B7280),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'тАв ${gist.formattedDate}',
                    style: const TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 12,
                      color: Color(0xFF9CA3AF),
                    ),
                  ),
                  const Spacer(),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: (gist.public
                              ? const Color(0xFF10B981)
                              : const Color(0xFF6B7280))
                          .withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      gist.public ? 'Public' : 'Secret',
                      style: TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        color: gist.public
                            ? const Color(0xFF10B981)
                            : const Color(0xFF6B7280),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),

        // File tabs (kalo ada >1 file)
        if (gist.files.length > 1)
          Container(
            color: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: gist.files.keys.map((filename) {
                  final isSelected = _selectedFilename == filename;
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: GestureDetector(
                      onTap: () =>
                          setState(() => _selectedFilename = filename),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 8),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? const Color(0xFF6366F1)
                              : Colors.transparent,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          filename,
                          style: TextStyle(
                            fontFamily: 'monospace',
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: isSelected
                                ? Colors.white
                                : const Color(0xFF6B7280),
                          ),
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
          ),

        // Code content
        Expanded(
          child: Container(
            color: const Color(0xFF0D1117),
            child: _buildCodeView(
              gist.files[_selectedFilename]?.content ?? '',
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCodeView(String content) {
    if (content.isEmpty) {
      return const Center(
        child: Text(
          'File kosong',
          style: TextStyle(
            fontFamily: 'Inter',
            fontSize: 14,
            color: Color(0xFF8B949E),
          ),
        ),
      );
    }

    final List<String> lines = content.split('\n');
    final int lineCount = lines.length;
    final int digitCount = lineCount.toString().length;
    final double gutterWidth = (digitCount * 8.0) + 20.0;

    return SingleChildScrollView(
      scrollDirection: Axis.vertical,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Line numbers
            Container(
              width: gutterWidth,
              padding: const EdgeInsets.symmetric(vertical: 12),
              decoration: const BoxDecoration(
                color: Color(0xFF161B22),
                border: Border(
                  right: BorderSide(color: Color(0xFF30363D)),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: List.generate(lines.length, (i) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    child: Text(
                      '${i + 1}',
                      style: const TextStyle(
                        fontFamily: 'monospace',
                        fontSize: 11,
                        color: Color(0xFF6E7681),
                        height: 1.55,
                      ),
                    ),
                  );
                }),
              ),
            ),
            // Content
            Container(
              padding: const EdgeInsets.symmetric(
                  vertical: 12, horizontal: 12),
              constraints: const BoxConstraints(minWidth: 300),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: lines.map((line) {
                  return Text(
                    line.isEmpty ? ' ' : line,
                    style: const TextStyle(
                      fontFamily: 'monospace',
                      fontSize: 11,
                      color: Color(0xFFE6EDF3),
                      height: 1.55,
                    ),
                  );
                }).toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}