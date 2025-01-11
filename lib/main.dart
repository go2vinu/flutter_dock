import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: Center(
          child: Dock(
            items: const [
              Icons.person,
              Icons.message,
              Icons.call,
              Icons.camera,
              Icons.photo,
            ],
            builder: (e) {
              return Container(
                constraints: const BoxConstraints(minWidth: 48),
                height: 48,
                margin: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  color: Colors.primaries[e.hashCode % Colors.primaries.length],
                ),
                child: Center(child: Icon(e, color: Colors.white)),
              );
            },
          ),
        ),
      ),
    );
  }
}

class Dock<T> extends StatefulWidget {
  const Dock({
    super.key,
    this.items = const [],
    required this.builder,
  });

  final List<T> items;
  final Widget Function(T) builder;

  @override
  State<Dock<T>> createState() => _DockState<T>();
}

class _DockState<T> extends State<Dock<T>> {
  late final List<T> _items = widget.items.toList();
  int? _draggedIndex;
  double? _dragPosition;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: Colors.black12,
      ),
      padding: const EdgeInsets.all(4),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: _buildDockItems(),
      ),
    );
  }

  List<Widget> _buildDockItems() {
    return List.generate(_items.length, (index) {
      return DragTarget<int>(
        onWillAccept: (data) => true,
        onAccept: (draggedIndex) {
          setState(() {
            final item = _items.removeAt(draggedIndex);
            _items.insert(index, item);
          });
        },
        builder: (context, candidateData, rejectedData) {
          return Draggable<int>(
            data: index,
            feedback: Material(
              color: Colors.transparent,
              child: DockItem(
                child: widget.builder(_items[index]),
                onHover: (_) {},
              ),
            ),
            childWhenDragging: DockItem(
              child: Opacity(
                opacity: 0.3,
                child: widget.builder(_items[index]),
              ),
              onHover: (_) {},
            ),
            child: DockItem(
              child: widget.builder(_items[index]),
              onHover: (isHovering) {
                setState(() {
                  _draggedIndex = isHovering ? index : null;
                  if (isHovering) {
                    final RenderBox box =
                        context.findRenderObject() as RenderBox;
                    _dragPosition = box.localToGlobal(Offset.zero).dx;
                  }
                });
              },
            ),
          );
        },
      );
    });
  }
}

class DockItem extends StatefulWidget {
  const DockItem({
    super.key,
    required this.child,
    required this.onHover,
  });

  final Widget child;
  final ValueChanged<bool> onHover;

  @override
  State<DockItem> createState() => _DockItemState();
}

class _DockItemState extends State<DockItem>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  bool _isHovered = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.5).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) {
        setState(() {
          _isHovered = true;
          widget.onHover(true);
        });
        _controller.forward();
      },
      onExit: (_) {
        setState(() {
          _isHovered = false;
          widget.onHover(false);
        });
        _controller.reverse();
      },
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: widget.child,
      ),
    );
  }
}
