import 'package:flutter/material.dart';

import '../models/cat.dart';
import '../models/quit_data.dart';
import '../widgets/character_view.dart';

/// 初回起動時に「1日の平均本数」と「1箱の値段」を聞く画面。
class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({
    super.key,
    required this.data,
    required this.onDone,
  });

  final QuitData data;
  final VoidCallback onDone;

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  double _baseline = 10;
  final TextEditingController _priceController =
      TextEditingController(text: '500');

  @override
  void dispose() {
    _priceController.dispose();
    super.dispose();
  }

  Future<void> _start() async {
    final double price = double.tryParse(_priceController.text.trim()) ?? 500;
    await widget.data.completeOnboarding(
      baseline: _baseline.round(),
      pricePerPack: price,
    );
    widget.onDone();
  }

  @override
  Widget build(BuildContext context) {
    final ColorScheme cs = Theme.of(context).colorScheme;
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              const SizedBox(height: 12),
              const Center(child: CharacterView(mood: Mood.good, height: 200)),
              const SizedBox(height: 16),
              Text(
                'はじめまして、ヤメにゃんだにゃ',
                textAlign: TextAlign.center,
                style: Theme.of(context)
                    .textTheme
                    .headlineSmall
                    ?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text(
                'きみの禁煙、いっしょにがんばるにゃ。\nまずは今のことを教えてほしいにゃ。',
                textAlign: TextAlign.center,
                style: TextStyle(color: cs.onSurfaceVariant),
              ),
              const SizedBox(height: 32),

              // 平均本数
              Text(
                '1日の平均本数',
                style: Theme.of(context)
                    .textTheme
                    .titleMedium
                    ?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 4),
              Center(
                child: Text(
                  '${_baseline.round()} 本 / 日',
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                        color: cs.primary,
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ),
              Slider(
                value: _baseline,
                min: 1,
                max: 60,
                divisions: 59,
                label: '${_baseline.round()} 本',
                onChanged: (double v) => setState(() => _baseline = v),
              ),
              const SizedBox(height: 24),

              // 1箱の値段
              Text(
                '1箱の値段（円）',
                style: Theme.of(context)
                    .textTheme
                    .titleMedium
                    ?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _priceController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  prefixText: '¥ ',
                  border: OutlineInputBorder(),
                  hintText: '500',
                  helperText: '節約できた金額の計算に使うにゃ（20本入り想定）',
                ),
              ),
              const SizedBox(height: 40),

              FilledButton(
                onPressed: _start,
                style: FilledButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: const Text(
                  'はじめる',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
