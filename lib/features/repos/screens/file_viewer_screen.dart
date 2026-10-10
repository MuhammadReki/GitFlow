import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../data/services/auth_storage.dart';
import '../../../data/services/github_api_service.dart';

class FileViewerScreen extends StatefulWidget {
  final String owner;
  final String repoName;
  final String path;

  const FileViewerScreen({
    super.key,
    required this.owner,
    required this.repoName,
    required this.path,
  });

  @override
  State<FileViewerScreen> createState() => _FileViewerScreenState();
}

class _FileViewerScreenState extends State<FileViewerScreen> {
  String? _content;
  bool _isLoading = true;
  String? _error;

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

    final content = await GitHubApiService.getFileContent(
      token,
      widget.owner,
      widget.repoName,
      widget.path,
    );

    if (!mounted) return;
    setState(() {
      _content = content;
      _isLoading = false;
      if (content == null) {
        _error = 'Gagal load file';
      }
    });
  }

  Future<void> _copyToClipboard() async {
    if (_content == null) return;
    await Clipboard.setData(ClipboardData(text: _content!));
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('File content di-copy'),
        backgroundColor: Color(0xFF10B981),
      ),
    );
  }

  Future<void> _openInBrowser() async {
    final url =
        'https://github.com/${widget.owner}/${widget.repoName}/blob/main/${widget.path}';
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  String get _fileName {
    final parts = widget.path.split('/');
    return parts.last;
  }

  int get _lineCount {
    if (_content == null || _content!.isEmpty) return 0;
    return _content!.split('\n').length;
  }

  int get _sizeInBytes {
    if (_content == null) return 0;
    return _content!.length;
  }

  String get _formattedSize {
    final bytes = _sizeInBytes;
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) {
      return '${(bytes / 1024).toStringAsFixed(1)} KB';
    }
    return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0D1117),
      appBar: AppBar(
        backgroundColor: const Color(0xFF161B22),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded,
              color: Color(0xFFE6EDF3)),
          onPressed: () => Navigator.pop(context),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              _fileName,
              style: const TextStyle(
                fontFamily: 'monospace',
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: Color(0xFFE6EDF3),
              ),
              overflow: TextOverflow.ellipsis,
            ),
            if (_content != null)
              Text(
                '$_lineCount lines тАв $_formattedSize',
                style: const TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 10,
                  color: Color(0xFF8B949E),
                ),
              ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.copy_rounded,
                color: Color(0xFFE6EDF3), size: 18),
            onPressed: _content != null ? _copyToClipboard : null,
            tooltip: 'Copy content',
          ),
          IconButton(
            icon: const Icon(Icons.open_in_new_rounded,
                color: Color(0xFFE6EDF3), size: 18),
            onPressed: _openInBrowser,
            tooltip: 'Open in GitHub',
          ),
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

    if (_error != null || _content == null) {
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
                _error ?? 'Gagal load file',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 14,
                  color: Color(0xFF8B949E),
                ),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _load,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF6366F1),
                ),
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      );
    }

    return _buildCodeViewer();
  }

  Widget _buildCodeViewer() {
    final lines = _content!.split('\n');
    final gutterWidth = _calculateGutterWidth(lines.length);

    return Container(
      color: const Color(0xFF0D1117),
      child: SingleChildScrollView(
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
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 0),
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
              // Code content
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
      ),
    );
  }

  double _calculateGutterWidth(int lineCount) {
    final digits = lineCount.toString().length;
    return (digits * 8) + 20;
  }
}