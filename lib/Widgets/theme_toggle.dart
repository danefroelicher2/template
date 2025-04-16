// lib/widgets/theme_toggle.dart
import 'package:flutter/material.dart';
import '../services/theme_service.dart';

class ThemeToggle extends StatefulWidget {
  final bool showLabel;
  final double size;

  const ThemeToggle({Key? key, this.showLabel = true, this.size = 24.0})
    : super(key: key);

  @override
  _ThemeToggleState createState() => _ThemeToggleState();
}

class _ThemeToggleState extends State<ThemeToggle>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _rotationAnimation;

  @override
  void initState() {
    super.initState();

    _animationController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 500),
    );

    _rotationAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );

    // Set initial animation state based on current theme
    if (ThemeService.instance.isDarkMode) {
      _animationController.value = 1.0;
    } else {
      _animationController.value = 0.0;
    }

    // Listen for theme changes
    ThemeService.instance.themeMode.addListener(_onThemeChanged);
  }

  @override
  void dispose() {
    _animationController.dispose();
    ThemeService.instance.themeMode.removeListener(_onThemeChanged);
    super.dispose();
  }

  void _onThemeChanged() {
    if (ThemeService.instance.isDarkMode) {
      _animationController.forward();
    } else {
      _animationController.reverse();
    }
  }

  void _toggleTheme() async {
    await ThemeService.instance.toggleTheme();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (widget.showLabel)
          Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: Text(
              ThemeService.instance.isDarkMode ? 'Dark Mode' : 'Light Mode',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ),
        InkWell(
          borderRadius: BorderRadius.circular(widget.size),
          onTap: _toggleTheme,
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: AnimatedBuilder(
              animation: _animationController,
              builder: (context, child) {
                return Stack(
                  alignment: Alignment.center,
                  children: [
                    // Sun
                    Opacity(
                      opacity: 1.0 - _animationController.value,
                      child: Icon(
                        Icons.wb_sunny_rounded,
                        color:
                            Theme.of(context).brightness == Brightness.light
                                ? Colors.orange
                                : Colors.amber,
                        size: widget.size,
                      ),
                    ),
                    // Moon
                    Opacity(
                      opacity: _animationController.value,
                      child: RotationTransition(
                        turns: _rotationAnimation,
                        child: Icon(
                          Icons.nightlight_round,
                          color:
                              Theme.of(context).brightness == Brightness.light
                                  ? Colors.blueGrey
                                  : Colors.blue[100],
                          size: widget.size,
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ),
      ],
    );
  }
}

// Alternative implementation with a switch
class ThemeToggleSwitch extends StatelessWidget {
  final bool showLabel;

  const ThemeToggleSwitch({Key? key, this.showLabel = true}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: ThemeService.instance.themeMode,
      builder: (context, themeMode, child) {
        final isDark = ThemeService.instance.isDarkMode;

        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (showLabel)
              Padding(
                padding: const EdgeInsets.only(right: 8.0),
                child: Text(
                  isDark ? 'Dark Mode' : 'Light Mode',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ),
            Switch(
              value: isDark,
              onChanged: (_) => ThemeService.instance.toggleTheme(),
              activeColor: Theme.of(context).colorScheme.primary,
              activeTrackColor: Theme.of(
                context,
              ).colorScheme.primary.withOpacity(0.5),
              inactiveThumbColor: Colors.grey[300],
              inactiveTrackColor: Colors.grey[400],
              thumbIcon: MaterialStateProperty.resolveWith<Icon?>((
                Set<MaterialState> states,
              ) {
                if (states.contains(MaterialState.selected)) {
                  return Icon(
                    Icons.nightlight_round,
                    color: Colors.white,
                    size: 16,
                  );
                }
                return Icon(
                  Icons.wb_sunny_rounded,
                  color: Colors.orange,
                  size: 16,
                );
              }),
            ),
          ],
        );
      },
    );
  }
}
