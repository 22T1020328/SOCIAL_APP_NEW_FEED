import 'dart:async';
import 'package:flutter/material.dart';






class Toggle extends StatefulWidget {
  final bool isActivated;
  final Widget deActivatedChild;
  final Widget activatedChild;
  final int delay;
  final void Function(bool) onTrigger;
  final void Function(bool) onTap;

  const Toggle({
    Key? key,
    required this.deActivatedChild,
    required this.activatedChild,
    this.delay = 300,
    this.isActivated = false,
    required this.onTrigger,
    required this.onTap,
  }) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    
    return _ToggleState(isActivated);
  }
}

class _ToggleState extends State<Toggle> {
  late bool _isOn;
  int _count = 0;
  Timer? _debounce;

  _ToggleState(bool isActivated) {
    _isOn = isActivated;
  }

  @override
  void didUpdateWidget(Toggle oldWidget) {
    if (oldWidget.isActivated != widget.isActivated) {
      _isOn = widget.isActivated;
    }

    super.didUpdateWidget(oldWidget);
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        setState(() {
          _isOn = !_isOn;
          _count++;
        });

        widget.onTap(_isOn);

        if (_debounce?.isActive ?? false) {
          _debounce!.cancel();
        }

        _debounce = Timer(Duration(milliseconds: widget.delay), () {
          if (_count % 2 == 1) {
            _count = 0;
            widget.onTrigger(_isOn);
          }
        });
      },
      child: _isOn ? widget.activatedChild : widget.deActivatedChild,
    );
  }
  
}

