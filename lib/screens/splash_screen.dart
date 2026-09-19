import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../theme.dart';
import 'shell.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with TickerProviderStateMixin {
  static const _title = "Vivre pour les Autres";
  static const _letterStep = Duration(milliseconds: 45);
  static const _startDelay = Duration(milliseconds: 350);

  final _visible = List<bool>.filled(_title.length, false);
  bool _taglineVisible = false;
  bool _lineVisible = false;

  late final AnimationController _lineCtrl = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1400),
  );

  final List<_Mote> _motes = List.generate(18, (i) => _Mote.random());

  @override
  void initState() {
    super.initState();
    _run();
  }

  Future<void> _run() async {
    await Future.delayed(_startDelay);
    if (!mounted) return;
    setState(() => _lineVisible = true);
    _lineCtrl.forward();

    for (var i = 0; i < _title.length; i++) {
      if (_title[i] != ' ') {
        await Future.delayed(_letterStep);
        if (!mounted) return;
        setState(() => _visible[i] = true);
      }
    }

    await Future.delayed(const Duration(milliseconds: 550));
    if (!mounted) return;
    setState(() => _taglineVisible = true);

    await Future.delayed(const Duration(milliseconds: 1600));
    if (!mounted) return;
    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        transitionDuration: const Duration(milliseconds: 500),
        pageBuilder: (_, anim, __) => FadeTransition(opacity: anim, child: const MainShell()),
      ),
    );
  }

  @override
  void dispose() {
    _lineCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final serif = GoogleFonts.cormorantGaramond();

    return Scaffold(
      backgroundColor: AppColors.vertFonce,
      body: Stack(
        fit: StackFit.expand,
        children: [
          ..._motes.map((m) => _MoteWidget(mote: m)),
          Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 28),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 1200),
                    curve: Curves.easeOut,
                    width: _lineVisible ? 140 : 0,
                    height: 1,
                    color: AppColors.or.withOpacity(0.85),
                    margin: const EdgeInsets.only(bottom: 22),
                  ),
                  FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        for (var i = 0; i < _title.length; i++)
                          AnimatedOpacity(
                            opacity: _visible[i] ? 1 : 0,
                            duration: const Duration(milliseconds: 500),
                            curve: Curves.easeOut,
                            child: AnimatedSlide(
                              offset: _visible[i] ? Offset.zero : const Offset(0, 0.25),
                              duration: const Duration(milliseconds: 500),
                              curve: Curves.easeOut,
                              child: Text(
                                _title[i] == ' ' ? '\u00A0' : _title[i],
                                style: serif.copyWith(
                                  fontSize: 34,
                                  fontWeight: FontWeight.w600,
                                  color: const Color(0xFFF0CF8E),
                                  letterSpacing: 0.5,
                                  shadows: [
                                    Shadow(color: AppColors.or.withOpacity(0.35), blurRadius: 24),
                                  ],
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                  AnimatedOpacity(
                    opacity: _taglineVisible ? 1 : 0,
                    duration: const Duration(milliseconds: 900),
                    curve: Curves.easeOut,
                    child: Padding(
                      padding: const EdgeInsets.only(top: 2),
                      child: Text(
                        '« Votre amour fait éclairer leur espoir »',
                        textAlign: TextAlign.center,
                        style: serif.copyWith(
                          fontSize: 15,
                          fontStyle: FontStyle.italic,
                          color: const Color(0xFFCFE3DF),
                          letterSpacing: 0.2,
                        ),
                      ),
                    ),
                  ),
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 1000),
                    curve: Curves.easeOut,
                    width: _taglineVisible ? 140 : 0,
                    height: 1,
                    color: AppColors.or.withOpacity(0.85),
                    margin: const EdgeInsets.only(top: 22),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Mote {
  _Mote(this.left, this.bottom, this.delay, this.duration, this.size);

  final double left;
  final double bottom;
  final Duration delay;
  final Duration duration;
  final double size;

  static _Mote random() {
    final r = Random();
    return _Mote(
      r.nextDouble(),
      r.nextDouble() * 0.2,
      Duration(milliseconds: r.nextInt(4000)),
      Duration(milliseconds: 4500 + r.nextInt(3000)),
      2 + r.nextDouble() * 2,
    );
  }
}

class _MoteWidget extends StatefulWidget {
  const _MoteWidget({required this.mote});
  final _Mote mote;

  @override
  State<_MoteWidget> createState() => _MoteWidgetState();
}

class _MoteWidgetState extends State<_MoteWidget> with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl = AnimationController(vsync: this, duration: widget.mote.duration);
  late final Animation<double> _rise = Tween<double>(begin: 0, end: 140).animate(_ctrl);
  late final Animation<double> _fade = TweenSequence<double>([
    TweenSequenceItem(tween: Tween(begin: 0.0, end: 0.9), weight: 15),
    TweenSequenceItem(tween: Tween(begin: 0.9, end: 0.4), weight: 70),
    TweenSequenceItem(tween: Tween(begin: 0.4, end: 0.0), weight: 15),
  ]).animate(_ctrl);

  @override
  void initState() {
    super.initState();
    Future.delayed(widget.mote.delay, () {
      if (mounted) _ctrl.repeat();
    });
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _ctrl,
      builder: (context, _) {
        return Positioned(
          left: widget.mote.left * MediaQuery.of(context).size.width,
          bottom: widget.mote.bottom * MediaQuery.of(context).size.height + _rise.value,
          child: Opacity(
            opacity: _fade.value,
            child: Container(
              width: widget.mote.size,
              height: widget.mote.size,
              decoration: const BoxDecoration(color: Color(0xFFF0CF8E), shape: BoxShape.circle),
            ),
          ),
        );
      },
    );
  }
}
