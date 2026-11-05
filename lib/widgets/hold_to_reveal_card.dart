import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/mafia_role.dart';

class HoldToRevealCard extends StatefulWidget {
  final MafiaRoleInfo roleInfo;
  final VoidCallback onRevealedOnce;

  const HoldToRevealCard({
    super.key,
    required this.roleInfo,
    required this.onRevealedOnce,
  });

  @override
  State<HoldToRevealCard> createState() => _HoldToRevealCardState();
}

class _HoldToRevealCardState extends State<HoldToRevealCard>
    with SingleTickerProviderStateMixin {
  double _dragOffset = 0.0;
  late AnimationController _springController;
  late Animation<double> _springAnimation;
  bool _triggeredRevealThisDrag = false;

  @override
  void initState() {
    super.initState();
    _springController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 320),
    );
    _springAnimation = Tween<double>(begin: 0, end: 0).animate(
      CurvedAnimation(parent: _springController, curve: Curves.easeOutCubic),
    )..addListener(() {
        setState(() {
          _dragOffset = _springAnimation.value;
        });
      });
  }

  @override
  void dispose() {
    _springController.dispose();
    super.dispose();
  }

  void _onDragUpdate(DragUpdateDetails details) {
    _springController.stop();
    setState(() {
      _dragOffset = (_dragOffset - details.delta.dy).clamp(0.0, 380.0);
    });
    if (_dragOffset > 90 && !_triggeredRevealThisDrag) {
      _triggeredRevealThisDrag = true;
      HapticFeedback.mediumImpact();
      widget.onRevealedOnce();
    }
  }

  void _onDragEnd(DragEndDetails details) {
    _triggeredRevealThisDrag = false;
    _springAnimation = Tween<double>(begin: _dragOffset, end: 0.0).animate(
      CurvedAnimation(parent: _springController, curve: Curves.easeOutBack),
    );
    _springController.forward(from: 0.0);
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onVerticalDragUpdate: _onDragUpdate,
      onVerticalDragEnd: _onDragEnd,
      child: SizedBox(
        width: 280,
        height: 400,
        child: Stack(
          clipBehavior: Clip.none,
          alignment: Alignment.center,
          children: [
            // GothicRoleSurface underneath (hidden when _dragOffset <= 2 so no gold border peeks out in closed state)
            Opacity(
              opacity: _dragOffset > 2 ? 1.0 : 0.0,
              child: Container(
              width: 280,
              height: 400,
              decoration: BoxDecoration(
                color: const Color(0xFF140709),
                borderRadius: BorderRadius.circular(18),
                border: Border.all(
                  color: const Color(0xFFC5B386),
                  width: 1.5,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.75),
                    blurRadius: 24,
                    spreadRadius: 2,
                  ),
                ],
              ),
              clipBehavior: Clip.antiAlias,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  Image.asset(
                    widget.roleInfo.imageAsset,
                    fit: BoxFit.cover,
                  ),
                  Align(
                    alignment: Alignment.bottomCenter,
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.fromLTRB(18, 48, 18, 22),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.transparent,
                            Colors.black.withOpacity(0.72),
                            Colors.black.withOpacity(0.92),
                          ],
                        ),
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            widget.roleInfo.cardTitleAr,
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              fontSize: 32,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                              shadows: [
                                Shadow(
                                  color: Colors.black,
                                  blurRadius: 10,
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            widget.roleInfo.fullDesc,
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              fontSize: 15,
                              color: Color(0xFFE5DCE0),
                              height: 1.4,
                              shadows: [
                                Shadow(
                                  color: Colors.black,
                                  blurRadius: 8,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),

            ),

            // GothicCardBack on top (matches 1000124810.jpg, 1000124809.jpg, 1000124808.jpg 100% - slides up unclipped!)
            Transform.translate(
              offset: Offset(0, -_dragOffset),
              child: Container(
                width: 280,
                height: 400,
                decoration: BoxDecoration(
                  color: const Color(0xFF0A0A0A),
                  borderRadius: BorderRadius.circular(18),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.85),
                      blurRadius: 22,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                clipBehavior: Clip.antiAlias,
                child: Image.asset(
                  'assets/images/cover.png',
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
