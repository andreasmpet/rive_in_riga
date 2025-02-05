import 'package:flutter/material.dart';
import 'package:rive/rive.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.green),
        useMaterial3: true,
      ),
      home: const RiveDemoPage(),
    );
  }
}

class RiveDemoPage extends StatefulWidget {
  const RiveDemoPage({super.key});

  @override
  State<RiveDemoPage> createState() => _RiveDemoPageState();
}

class _RiveDemoPageState extends State<RiveDemoPage> {
  double _progressPercentage = 0;
  bool _isActive = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Rive in Riga")),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: LayoutBuilder(builder: (context, constraints) {
          final progressBarWidth = constraints.maxWidth * 0.8;
          final progressBarHeight = constraints.maxHeight * 0.8;
          return Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(
                height: progressBarHeight,
                child: Container(
                    // color: Colors.blue,
                    child: FancyProgressBar(
                  isActive: _isActive,
                  progressPercentage: _progressPercentage,
                )),
              ),
              Slider(
                value: _progressPercentage,
                min: 0,
                max: 100,
                onChanged: (value) {
                  setState(() {
                    _progressPercentage = value;
                  });
                },
              ),
              Switch(
                value: _isActive,
                onChanged: (value) {
                  setState(() {
                    _isActive = value;
                  });
                },
              )
            ],
          );
        }),
      ),
    );
  }
}

class FancyProgressBar extends StatefulWidget {
  final bool isActive;
  final double progressPercentage;

  const FancyProgressBar({super.key, required this.isActive, required this.progressPercentage});

  @override
  State<FancyProgressBar> createState() => _FancyProgressBarState();
}

class _FancyProgressBarState extends State<FancyProgressBar> {
  Artboard? _riveArtboard;
  SMINumber? _progressPercentage;
  SMIBool? _progressActive;

  @override
  void initState() {
    super.initState();

    _loadRiveFile();
  }

  @override
  void didUpdateWidget(FancyProgressBar oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.isActive != widget.isActive || oldWidget.progressPercentage != widget.progressPercentage) {
      _updateFromWidget();
    }
  }

  Future<void> _loadRiveFile() async {
    final file = await RiveFile.asset('assets/riga_demos.riv');

    // The artboard is the root of the animation and gets drawn in the
    // Rive widget.
    final artboard = file.artboardByName("Artboard")!.instance();
    final controller = StateMachineController.fromArtboard(artboard, 'State Machine 1')!;

    // Fetch references to the properties we want to control.
    _progressActive = controller.getBoolInput("Active");
    _progressPercentage = controller.getNumberInput("Progress");
    artboard.addController(controller);

    setState(() => _riveArtboard = artboard);
    _updateFromWidget();
  }

  @override
  Widget build(BuildContext context) {
    final artboard = _riveArtboard;
    if (artboard == null) return Container();

    return Rive(artboard: artboard);
  }

  void _updateFromWidget() {
    _progressPercentage?.value = widget.progressPercentage;
    _progressActive?.value = widget.isActive;
  }
}
