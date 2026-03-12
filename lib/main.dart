import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'dart:io';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'YouTube Downloader',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.red),
        useMaterial3: true,
      ),
      home: const DownloaderPage(),
    );
  }
}

class DownloaderPage extends StatefulWidget {
  const DownloaderPage({super.key});

  @override
  State<DownloaderPage> createState() => _DownloaderPageState();
}

class _DownloaderPageState extends State<DownloaderPage> {
  final _linkController = TextEditingController();
  String _status = '';
  bool _isLoading = false;
  String _format = 'mp3';
  String _category = 'videos';

  Future<void> _download() async {
    await Permission.storage.request();
    setState(() {
      _isLoading = true;
      _status = 'מוריד...';
    });

    try {
      final ytDlp = '/data/data/com.example.youtube_downloader/files/yt-dlp';
      final output = '/sdcard/Download/MyDownloader/%(uploader)s/%(title)s.%(ext)s';
      
      List<String> args = [ytDlp];
      
      if (_category == 'videos') {
        args.addAll(['--match-filter', 'duration > 60 & !is_live']);
      } else if (_category == 'shorts') {
        args.addAll(['--match-filter', 'duration <= 60 & !is_live']);
      }

      if (_format == 'mp3') {
        args.addAll(['-x', '--audio-format', 'mp3', '--audio-quality', '0']);
      } else {
        args.addAll(['-f', 'bestvideo[ext=mp4]+bestaudio[ext=m4a]/best[ext=mp4]']);
      }

      args.addAll(['-o', output, _linkController.text]);

      final result = await Process.run(args[0], args.sublist(1));
      
      setState(() {
        _status = result.exitCode == 0 ? '✅ הורדה הושלמה!' : '❌ שגיאה: ${result.stderr}';
      });
    } catch (e) {
      setState(() => _status = '❌ שגיאה: $e');
    }

    setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('YouTube Downloader'),
        backgroundColor: Colors.red,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _linkController,
              decoration: const InputDecoration(
                labelText: 'הכנס לינק YouTube',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.link),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                const Text('קטגוריה: '),
                DropdownButton<String>(
                  value: _category,
                  items: const [
                    DropdownMenuItem(value: 'videos', child: Text('סרטונים')),
                    DropdownMenuItem(value: 'shorts', child: Text('Shorts')),
                    DropdownMenuItem(value: 'all', child: Text('הכל')),
                  ],
                  onChanged: (v) => setState(() => _category = v!),
                ),
              ],
            ),
            Row(
              children: [
                const Text('פורמט: '),
                DropdownButton<String>(
                  value: _format,
                  items: const [
                    DropdownMenuItem(value: 'mp3', child: Text('MP3')),
                    DropdownMenuItem(value: 'mp4', child: Text('MP4')),
                  ],
                  onChanged: (v) => setState(() => _format = v!),
                ),
              ],
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _download,
                style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                child: _isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text('הורד', style: TextStyle(color: Colors.white, fontSize: 18)),
              ),
            ),
            const SizedBox(height: 16),
            Text(_status, style: const TextStyle(fontSize: 16)),
          ],
        ),
      ),
    );
  }
}
