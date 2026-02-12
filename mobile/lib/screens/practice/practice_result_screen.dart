import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:confetti/confetti.dart';
import 'providers/practice_provider.dart';

class PracticeResultScreen extends StatefulWidget {
  final String scenarioId;
  
  const PracticeResultScreen({super.key, required this.scenarioId});

  @override
  State<PracticeResultScreen> createState() => _PracticeResultScreenState();
}

class _PracticeResultScreenState extends State<PracticeResultScreen> {
  ConfettiController? _confettiController;
  
  @override
  void initState() {
    super.initState();
    _confettiController = ConfettiController(
      duration: const Duration(seconds: 3),
    );
    _confettiController!.play();
  }

  @override
  void dispose() {
    _confettiController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<PracticeProvider>();
    final result = provider.result;
    
    if (result == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Stack(
      children: [
        Scaffold(
          body: SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  // Score Grade
                  _buildScoreGrade(result.totalScore),
                  
                  const SizedBox(height: 32),
                  
                  // Score Cards
                  _buildScoreCards(result),
                  
                  const SizedBox(height: 32),
                  
                  // Feedback
                  _buildFeedback(result.feedback),
                  
                  if (result.suggestions.isNotEmpty) ...[
                    const SizedBox(height: 24),
                    _buildSuggestions(result.suggestions),
                  ],
                  
                  const SizedBox(height: 32),
                  
                  // Actions
                  _buildActions(),
                ],
              ),
            ),
          ),
        ),
        
        // Confetti
        Align(
          alignment: Alignment.topCenter,
          child: ConfettiController(
            controller: _confettiController!,
            blastDirectionality: BlastDirectionality.explode,
          ),
        ),
      ],
    );
  }

  Widget _buildScoreGrade(int score) {
    final grade = provider.getScoreGrade(score);
    final color = score >= 80 
        ? Colors.green 
        : score >= 60 ? Colors.orange : Colors.red;
    
    return Center(
      child: Column(
        children: [
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: color,
              boxShadow: [
                BoxShadow(
                  color: color.withOpacity(0.3),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Center(
              child: Text(
                grade,
                style: const TextStyle(
                  fontSize: 64,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            _getScoreLabel(score),
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '總分 $score 分',
            style: const TextStyle(fontSize: 16, color: Colors.grey),
          ),
        ],
      ),
    );
  }

  Widget _buildScoreCards(PracticeResult result) {
    final scores = [
      ('發音', result.pronunciationScore, Colors.blue),
      ('語法', result.grammarScore, Colors.purple),
      ('用詞', result.vocabularyScore, Colors.orange),
      ('流暢度', result.fluencyScore, Colors.cyan),
    ];

    return Wrap(
      spacing: 16,
      runSpacing: 16,
      children: scores.map((item) {
        return Container(
          width: (MediaQuery.of(context).size.width - 64) / 2,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: item.$3.withOpacity(0.1),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            children: [
              Text(
                item.$1,
                style: TextStyle(
                  fontSize: 14,
                  color: item.$3,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                '${item.$2}',
                style: TextStyle(
                  fontSize: 36,
                  fontWeight: FontWeight.bold,
                  color: item.$3,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                '分',
                style: TextStyle(fontSize: 12, color: Colors.grey[500]),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _buildFeedback(String feedback) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.blue[50],
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.blue[100]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.lightbulb_outline, color: Colors.blue[700]),
              const SizedBox(width: 8),
              Text(
                'AI 評語',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.blue[700],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            feedback.isEmpty ? '持續練習可以提升您的英語會話能力！' : feedback,
            style: TextStyle(
              fontSize: 15,
              color: Colors.blue[900],
              height: 1.6,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSuggestions(List<String> suggestions) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.amber[50],
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.amber[100]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.tips_and_updates, color: Colors.amber[700]),
              const SizedBox(width: 8),
              Text(
                '改進建議',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.amber[700],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ...suggestions.map((suggestion) => Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(Icons.arrow_right, size: 20, color: Colors.amber[700]),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(
                    suggestion,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.amber[900],
                    ),
                  ),
                ),
              ],
            ),
          )),
        ],
      ),
    );
  }

  Widget _buildActions() {
    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          height: 56,
          child: ElevatedButton(
            onPressed: () => context.go('/scenarios'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).primaryColor,
            ),
            child: const Text(
              '繼續練習其他情境',
              style: TextStyle(fontSize: 18),
            ),
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          width: double.infinity,
          height: 56,
          child: OutlinedButton(
            onPressed: () => context.go('/home'),
            child: const Text(
              '返回首頁',
              style: TextStyle(fontSize: 18),
            ),
          ),
        ),
      ],
    );
  }

  String _getScoreLabel(int score) {
    if (score >= 90) return '太棒了！';
    if (score >= 80) return '很不錯！';
    if (score >= 70) return '還可以！';
    if (score >= 60) return '繼續加油！';
    return '需要多練習！';
  }
}
