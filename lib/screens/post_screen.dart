// lib/screens/post_screen.dart
import 'package:flutter/material.dart';
import '../models/article.dart';

import 'package:share_plus/share_plus.dart';

class PostScreen extends StatefulWidget {
  final Article article;

  const PostScreen({Key? key, required this.article}) : super(key: key);

  @override
  // ignore: library_private_types_in_public_api
  _PostScreenState createState() => _PostScreenState();
}

class _PostScreenState extends State<PostScreen> {
  bool _isLoading = true;
  double _fontSize = 16.0;

  @override
  void initState() {
    super.initState();
    _loadContent();
  }

  Future<void> _loadContent() async {
    // Simulate content loading
    await Future.delayed(const Duration(seconds: 1));
    if (mounted) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : CustomScrollView(
              slivers: [
                SliverAppBar(
                  expandedHeight: 200.0,
                  floating: false,
                  pinned: true,
                  actions: [
                    IconButton(
                      icon: Icon(
                        widget.article.isSaved
                            ? Icons.bookmark
                            : Icons.bookmark_border,
                      ),
                      onPressed: () {
                        setState(() {
                          widget.article.isSaved = !widget.article.isSaved;
                        });
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              widget.article.isSaved
                                  ? 'Article saved to bookmarks'
                                  : 'Article removed from bookmarks',
                            ),
                            duration: const Duration(seconds: 2),
                          ),
                        );
                      },
                    ),
                    PopupMenuButton<String>(
                      onSelected: (value) {
                        switch (value) {
                          case 'share':
                            _shareArticle();
                            break;
                          case 'text_size':
                            _showTextSizeDialog();
                            break;
                        }
                      },
                      itemBuilder: (context) => [
                        const PopupMenuItem(
                          value: 'share',
                          child: Row(
                            children: [
                              Icon(Icons.share, color: Colors.black),
                              SizedBox(width: 8),
                              Text('Share'),
                            ],
                          ),
                        ),
                        const PopupMenuItem(
                          value: 'text_size',
                          child: Row(
                            children: [
                              Icon(Icons.text_fields, color: Colors.black),
                              SizedBox(width: 8),
                              Text('Text Size'),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                  flexibleSpace: FlexibleSpaceBar(
                    background: Hero(
                      tag: 'article_image_${widget.article.title}',
                      child: widget.article.imageUrl != null
                          ? Image.network(
                              widget.article.imageUrl!,
                              fit: BoxFit.cover,
                              loadingBuilder: (context, child, progress) {
                                if (progress == null) return child;
                                return Container(
                                  color: Colors.blue[100],
                                  child: Center(
                                    child: CircularProgressIndicator(
                                      value: progress.expectedTotalBytes != null
                                          ? progress.cumulativeBytesLoaded /
                                              progress.expectedTotalBytes!
                                          : null,
                                    ),
                                  ),
                                );
                              },
                            )
                          : Container(
                              color: Colors.blue[100],
                              child: Center(
                                child: Icon(
                                  Icons.newspaper,
                                  size: 64,
                                  color: Colors.blue[300],
                                ),
                              ),
                            ),
                    ),
                  ),
                ),
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.article.title,
                          style: Theme.of(context)
                              .textTheme
                              .headlineSmall
                              ?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            const Icon(Icons.access_time,
                                size: 16, color: Colors.grey),
                            const SizedBox(width: 4),
                            Text(
                              _formatDate(widget.article.publishDate),
                              style: const TextStyle(color: Colors.grey),
                            ),
                            const SizedBox(width: 16),
                            const Icon(Icons.source,
                                size: 16, color: Colors.grey),
                            const SizedBox(width: 4),
                            Text(
                              widget.article.source,
                              style: const TextStyle(color: Colors.grey),
                            ),
                          ],
                        ),
                        if (widget.article.author != null) ...[
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              const Icon(Icons.person,
                                  size: 16, color: Colors.grey),
                              const SizedBox(width: 4),
                              Text(
                                widget.article.author!,
                                style: const TextStyle(color: Colors.grey),
                              ),
                            ],
                          ),
                        ],
                        if (widget.article.tags.isNotEmpty) ...[
                          const SizedBox(height: 16),
                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: widget.article.tags.map((tag) {
                              return Chip(
                                label: Text(tag),
                                backgroundColor: Colors.blue[50],
                                labelStyle: TextStyle(color: Colors.blue[700]),
                              );
                            }).toList(),
                          ),
                        ],
                        const SizedBox(height: 16),
                        Text(
                          widget.article.content,
                          style:
                              Theme.of(context).textTheme.bodyLarge?.copyWith(
                                    height: 1.6,
                                    fontSize: _fontSize,
                                  ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
    );
  }

  Future<void> _shareArticle() async {
    try {
      await Share.share(
        '${widget.article.title}\n\nRead more at: [Your App URL]',
        subject: widget.article.title,
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Could not share article'),
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  void _showTextSizeDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Text Size'),
        content: StatefulBuilder(
          builder: (context, setState) => Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Slider(
                value: _fontSize,
                min: 12,
                max: 24,
                divisions: 6,
                label: _fontSize.round().toString(),
                onChanged: (value) {
                  setState(() {
                    _fontSize = value;
                  });
                  this.setState(() {});
                },
              ),
              Text(
                'Preview Text',
                style: TextStyle(fontSize: _fontSize),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Close'),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}
