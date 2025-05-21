import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:provider/provider.dart';
import '../providers/user_preferences_provider.dart';
import '../theme/app_theme.dart';

class TTSPlayer extends StatefulWidget {
  final String text;
  
  const TTSPlayer({super.key, required this.text});

  @override
  State<TTSPlayer> createState() => _TTSPlayerState();
}

class _TTSPlayerState extends State<TTSPlayer> {
  final FlutterTts _flutterTts = FlutterTts();
  bool _isPlaying = false;
  bool _isInitialized = false;
  
  @override
  void initState() {
    super.initState();
    _initTts();
  }
  
  @override
  void dispose() {
    _flutterTts.stop();
    super.dispose();
  }
  
  Future<void> _initTts() async {
    try {
      await _flutterTts.setLanguage('tr-TR');
      await _flutterTts.setSpeechRate(0.5);
      await _flutterTts.setVolume(1.0);
      
      _flutterTts.setCompletionHandler(() {
        if (mounted) {
          setState(() {
            _isPlaying = false;
          });
        }
      });
      
      _flutterTts.setErrorHandler((error) {
        if (mounted) {
          setState(() {
            _isPlaying = false;
          });
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Sesli anlatım hatası: $error')),
          );
        }
      });
      
      setState(() {
        _isInitialized = true;
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Sesli anlatım başlatılamadı: $e')),
        );
      }
    }
  }
  
  Future<void> _speak() async {
    if (!_isInitialized) {
      await _initTts();
    }
    
    if (widget.text.isEmpty) return;
    
    if (_isPlaying) {
      await _flutterTts.stop();
      setState(() {
        _isPlaying = false;
      });
    } else {
      setState(() {
        _isPlaying = true;
      });
      
      try {
        await _flutterTts.speak(widget.text);
      } catch (e) {
        if (mounted) {
          setState(() {
            _isPlaying = false;
          });
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Sesli anlatım hatası: $e')),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isTTSEnabled = Provider.of<UserPreferencesProvider>(context).isTTSEnabled;
    
    if (!isTTSEnabled) {
      return const SizedBox.shrink();
    }
    
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.primaryColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: IconButton(
        icon: Icon(_isPlaying ? Icons.stop_circle : Icons.volume_up),
        onPressed: _speak,
        tooltip: _isPlaying ? 'Sesli anlatımı durdur' : 'Sesli anlat',
        color: AppTheme.primaryColor,
      ),
    );
  }
}
