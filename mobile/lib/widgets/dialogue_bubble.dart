import 'package:flutter/material.dart';

class DialogueBubble extends StatelessWidget {
  final String text;
  final bool isUser;
  final bool isRecording;
  final VoidCallback? onPlayAudio;
  final VoidCallback? onReRecord;

  const DialogueBubble({
    super.key,
    required this.text,
    this.isUser = false,
    this.isRecording = false,
    this.onPlayAudio,
    this.onReRecord,
  });

  @override
  Widget build(BuildContext context) {
    final bubbleColor = isUser ? Theme.of(context).primaryColor : Colors.grey[200];
    final textColor = isUser ? Colors.white : Colors.black87;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
      children: [
        if (!isUser) ...[
          _buildAvatar(),
          const SizedBox(width: 12),
        ],
        Expanded(
          child: Column(
            crossAxisAlignment: isUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: bubbleColor,
                  borderRadius: _buildBorderRadius(isUser),
                ),
                child: Text(
                  text,
                  style: TextStyle(
                    fontSize: 16,
                    color: textColor,
                    height: 1.5,
                  ),
                ),
              ),
              if (isUser) ...[
                const SizedBox(height: 8),
                _buildActionButtons(),
              ],
            ],
          ),
        ),
        if (isUser) ...[
          const SizedBox(width: 12),
          _buildAvatar(),
        ],
      ],
    );
  }

  Widget _buildAvatar() {
    return Container(
      width: 36,
      height: 36,
      decoration: BoxDecoration(
        color: isUser ? Colors.blue : Colors.purple,
        shape: BoxShape.circle,
      ),
      child: Icon(
        isUser ? Icons.person : Icons.android,
        color: Colors.white,
        size: 20,
      ),
    );
  }

  Widget _buildActionButtons() {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (isRecording)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.red[100],
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(
                  width: 8,
                  height: 8,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Colors.red,
                  ),
                ),
                const SizedBox(width: 6),
                Text(
                  '錄音中...',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.red[700],
                  ),
                ),
              ],
            ),
          ),
        if (!isRecording && onPlayAudio != null)
          TextButton.icon(
            onPressed: onPlayAudio,
            icon: const Icon(Icons.play_arrow, size: 18),
            label: const Text('播放'),
            style: TextButton.styleFrom(
              foregroundColor: Theme.of(context).primaryColor,
            ),
          ),
        if (!isRecording && onReRecord != null)
          TextButton.icon(
            onPressed: onReRecord,
            icon: const Icon(Icons.replay, size: 18),
            label: const Text('重錄'),
            style: TextButton.styleFrom(
              foregroundColor: Colors.grey[600],
            ),
          ),
      ],
    );
  }

  BorderRadius _buildBorderRadius(bool isUser) {
    if (isUser) {
      return const BorderRadius.only(
        topLeft: Radius.circular(16),
        topRight: Radius.circular(16),
        bottomLeft: Radius.circular(16),
        bottomRight: Radius.circular(4),
      );
    }
    return const BorderRadius.only(
      topLeft: Radius.circular(16),
      topRight: Radius.circular(16),
      bottomLeft: Radius.circular(4),
      bottomRight: Radius.circular(16),
    );
  }
}
