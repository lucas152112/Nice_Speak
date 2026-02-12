import 'package:flutter/foundation.dart';
import 'services/api_service.dart';

class PracticeProvider with ChangeNotifier {
  PracticeSession? _session;
  PracticeResult? _result;
  
  bool _isRecording = false;
  bool _isProcessing = false;
  int _currentDialogueIndex = 0;
  
  // 錄音相關
  String? _currentAudioPath;
  List<String> _recordedAudios = [];
  
  PracticeSession? get session => _session;
  PracticeResult? get result => _result;
  bool get isRecording => _isRecording;
  bool get isProcessing => _isProcessing;
  int get currentDialogueIndex => _currentDialogueIndex;
  
  int get totalDialogues => _session?.dialogues.length ?? 0;
  DialogueLine? get currentDialogue => 
      _session != null && _currentDialogueIndex < _session!.dialogues.length
          ? _session!.dialogues[_currentDialogueIndex]
          : null;
  
  double get progress => totalDialogues > 0 
      ? _currentDialogueIndex / totalDialogues 
      : 0;
  
  Future<PracticeSession> startPractice(String scenarioId) async {
    _isProcessing = true;
    _currentDialogueIndex = 0;
    _recordedAudios = [];
    notifyListeners();
    
    try {
      _session = await ApiService().startPractice(scenarioId);
      return _session!;
    } finally {
      _isProcessing = false;
      notifyListeners();
    }
  }
  
  void setRecording(bool recording) {
    _isRecording = recording;
    notifyListeners();
  }
  
  void setCurrentAudio(String audioPath) {
    _currentAudioPath = audioPath;
  }
  
  void nextDialogue() {
    if (_currentAudioPath != null) {
      _recordedAudios.add(_currentAudioPath!);
      _currentAudioPath = null;
    }
    
    if (_currentDialogueIndex < totalDialogues - 1) {
      _currentDialogueIndex++;
      notifyListeners();
    }
  }
  
  bool get canNext => _currentAudioPath != null || _recordedAudios.length > _currentDialogueIndex;
  
  bool get isLastDialogue => _currentDialogueIndex >= totalDialogues - 1;
  
  Future<PracticeResult> submitPractice() async {
    if (_recordedAudios.isEmpty && _currentAudioPath != null) {
      _recordedAudios.add(_currentAudioPath!);
    }
    
    if (_session == null || _session!.id.isEmpty) {
      throw Exception('無練習會話');
    }
    
    _isProcessing = true;
    notifyListeners();
    
    try {
      _result = await ApiService().submitPractice(
        sessionId: _session!.id,
        audioUrls: _recordedAudios,
      );
      return _result!;
    } finally {
      _isProcessing = false;
      notifyListeners();
    }
  }
  
  void reset() {
    _session = null;
    _result = null;
    _isRecording = false;
    _isProcessing = false;
    _currentDialogueIndex = 0;
    _currentAudioPath = null;
    _recordedAudios = [];
    notifyListeners();
  }
  
  // 評分相關
  int get totalScore => _result?.totalScore ?? 0;
  
  String getScoreGrade(int score) {
    if (score >= 90) return 'S';
    if (score >= 80) return 'A';
    if (score >= 70) return 'B';
    if (score >= 60) return 'C';
    return 'D';
  }
}
