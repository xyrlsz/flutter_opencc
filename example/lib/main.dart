import 'package:flutter/material.dart';
import 'package:flutter_opencc/flutter_opencc.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final TextEditingController _inputController = TextEditingController();
  String _output = '';
  OpenCCConfig _selectedConfig = OpenCCConfig.s2t;
  String? _dataDir;
  bool _preparing = true;

  @override
  void initState() {
    super.initState();
    _initData();
  }

  Future<void> _initData() async {
    try {
      final dataDir = await OpenCCData.prepareData();
      setState(() {
        _dataDir = dataDir;
        _preparing = false;
      });
    } catch (e) {
      setState(() {
        _preparing = false;
        _output = 'Failed to prepare data: $e';
      });
    }
  }

  void _convert() async {
    if (_dataDir == null) return;
    try {
      final result = OpenCCSimple.convert(
        _inputController.text,
        _selectedConfig,
        dataDir: _dataDir!,
      );
      setState(() {
        _output = result;
      });
    } catch (e) {
      setState(() {
        _output = 'Error: $e';
      });
    }
  }

  @override
  void dispose() {
    _inputController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Flutter OpenCC'),
          backgroundColor: Colors.blue,
          foregroundColor: Colors.white,
        ),
        body: _preparing
            ? const Center(child: CircularProgressIndicator())
            : _buildBody(),
      ),
    );
  }

  Widget _buildBody() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Configuration selector
          DropdownButtonFormField<OpenCCConfig>(
            value: _selectedConfig,
            decoration: const InputDecoration(
              labelText: '转换类型',
              border: OutlineInputBorder(),
            ),
            items: OpenCCConfig.values.map((config) {
              return DropdownMenuItem(
                value: config,
                child: Text('${config.name} — ${config.description}'),
              );
            }).toList(),
            onChanged: (value) {
              if (value != null) {
                setState(() => _selectedConfig = value);
              }
            },
          ),
          const SizedBox(height: 16),

          // Input text field
          TextField(
            controller: _inputController,
            decoration: const InputDecoration(
              labelText: '输入文本',
              border: OutlineInputBorder(),
              hintText: '在此输入要转换的文本...',
            ),
            maxLines: 5,
          ),
          const SizedBox(height: 16),

          // Convert button
          ElevatedButton(
            onPressed: _convert,
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
            ),
            child: const Text('转换', style: TextStyle(fontSize: 18)),
          ),
          const SizedBox(height: 16),

          // Output text
          const Text(
            '转换结果：',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey),
              borderRadius: BorderRadius.circular(4),
            ),
            child: SelectableText(
              _output.isEmpty ? '等待输入...' : _output,
              style: const TextStyle(fontSize: 16),
            ),
          ),
        ],
      ),
    );
  }
}
