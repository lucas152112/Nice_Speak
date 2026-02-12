import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:record/record.dart';
import 'providers/practice_provider.dart';
import 'package:assets_audio_player/assets_audio_player.dart';

class PracticeScreen extends StatefulWidget {
  final String scenarioId;
  
  const PracticeScreen({super.key, required this.scenarioId});

  @override
  State<PracticeScreen> createState() => _PracticeScreenState();
}

class _PracticeScreenState extends State<PracticeScreen> {
  final AudioRecorder _audioRecorder = AudioRecorder();
  final AssetsAudioPlayer _audioPlayer = AssetsAudioPlayer();
  
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _startPractice();
    });
  }

  Future<void> _startPractice() async {
    try {
      await context.read<PracticeProvider>().startPractice(widget.scenarioId);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('載入失敗: $e')),
        );
        context.go('/scenarios/${widget.scenarioId}');
      }
    }
  }

  @override
  void dispose() {
    _audioRecorder.dispose();
    _audioPlayer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<PracticeProvider>();
    
    if (provider.isProcessing) {
      return const Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(),
              SizedBox(height: 16),
              Text('準備中...'),
            ],
          ),
        ),
      );
    }
    
    if (provider.session == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('練習中'),
        leading: IconButton(
          onPressed: () => _showExitDialog(context),
          icon: const Icon(Icons.close),
        ),
        actions: [
          Center(
            child: Padding(
              padding: const EdgeInsets.only(right: 16),
              child: Text(
                '${provider.currentDialogueIndex + 1}/${provider.totalDialogues}',
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          // Progress
          LinearProgressIndicator(
            value: provider.progress,
            minHeight: 4,
          ),
          
          // Dialogue Content
          Expanded(
            child: provider.currentDialogue != null
                ? _buildDialogueContent(provider)
                : const Center(child: Text('練習完成')),
          ),
          
          // Controls
          _buildControls(provider),
        ],
      ),
    );
  }

  Widget _buildDialogueContent(PracticeProvider provider) {
    final dialogue = provider.currentDialogue!;
    final isLast = provider.isLastDialogue;
    
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // AI Speaker
          _buildSpeakerBubble(
            icon: Icons.android,
            color: Colors.blue,
            name: 'AI 角色',
            message: dialogue.text,
          ),
          
          const SizedBox(height: 32),
          
          // Recording Area
          _buildRecordingArea(provider),
          
          const SizedBox(height: 32),
          
          // Actions
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Play Audio
              IconButton(
                onPressed: () async {
                  // TODO: Play reference audio
                },
                icon: const Icon(Icons.play_circle_outline, size: 32),
                tooltip: '播放範例',
              ),
              
              const SizedBox(width: 24),
              
              // Record Button
              _buildRecordButton(provider),
              
              const SizedBox(width: 24),
              
              // Replay
              IconButton(
                onPressed: provider.canNext ? () => _playOwnAudio(provider) : null,
                icon: Icon(
                  Icons.replay,
                  size: 32,
                  color: provider.canNext ? null : Colors.grey,
                ),
                tooltip: '重新錄製',
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSpeakerBubble({
    required IconData icon,
    required Color color,
    required String name,
    required String message,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: Colors.white, size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: color,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  message,
                  style: const TextStyle(fontSize: 18, height: 1.5),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecordButton(PracticeProvider provider) {
    final isRecording = provider.isRecording;
    
    return SizedBox(
      width: 80,
      height: 80,
      child: ElevatedButton(
        onPressed: isRecording ? _stopRecording : _startRecording,
        style: ElevatedButton.styleFrom(
          shape: const CircleBorder(),
          backgroundColor: isRecording ? Colors.red : Theme.of(context).primaryColor,
        ),
        child: Icon(
          isRecording ? Icons.stop : Icons.mic,
          size: 40,
          color: Colors.white,
        ),
      ),
    );
  }

  Widget _buildRecordingArea(PracticeProvider provider) {
    if (provider.isRecording) {
      return Column(
        children: [
          Container(
            width: 100,
            height: 100,
            decoration: const BoxDecoration(
              color: Colors.red,
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.mic, size: 48, color: Colors.white),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 8,
                height: 8,
                decoration: const BoxDecoration(
                  color: Colors.red,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 8),
              const Text('錄音中...', style: TextStyle(color: Colors.red)),
            ],
          ),
        ],
      );
    }
    
    return Column(
      children: [
        Container(
          width: 100,
          height: 100,
          decoration: BoxDecoration(
            color: Colors.grey[200],
            shape: BoxShape.circle,
          ),
          child: const Icon(Icons.mic_none, size: 48, color: Colors.grey),
        ),
        const SizedBox(height: 16),
        const Text('點擊麥克風開始錄音'),
      ],
    );
  }

  Widget _buildControls(PracticeProvider provider) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: SafeArea(
        child: SizedBox(
          width: double.infinity,
          height: 56,
          child: ElevatedButton(
            onPressed: provider.canNext
                ? provider.isLastDialogue
                    ? _submitPractice
                    : _nextDialogue
                : null,
            child: Text(
              provider.isLastDialogue ? '完成練習' : '下一題',
              style: const TextStyle(fontSize: 18),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _startRecording() async {
    if (await _audioRecorder.hasPermission()) {
      final path = await _audioRecorder.start(
        const RecordConfig(),
        path: 'practice_${DateTime.now().millisecondsSinceEpoch}.m4a',
      );
      
      context.read<PracticeProvider>().setRecording(true);
      context.read<PracticeProvider>().setCurrentAudio(path);
    }
  }

  Future<void> _stopRecording() async {
    await _audioRecorder.stop();
    context.read<PracticeProvider>().setRecording(false);
  }

  void _playOwnAudio(PracticeProvider provider) {
    // TODO: Play recorded audio
  }

  void _nextDialogue() {
    context.read<PracticeProvider>().nextDialogue();
  }

  Future<void> _submitPractice() async {
    try {
      await context.read<PracticeProvider>().submitPractice();
      if (mounted) {
        context.go('/practice/${widget.scenarioId}/result');
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('提交失敗: $e')),
      );
    }
  }

  Future<bool> _showExitDialog(BuildContext context) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('確定要退出嗎？'),
        content: const Text('退出後練習進度將不會保存。'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('繼續練習'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('退出'),
          ),
        ],
      ),
    );
    
    if (result == true) {
      context.read<PracticeProvider>().reset();
      context.go('/scenarios/${widget.scenarioId}');
    }
    return result ?? false;
  }
}
