// lib/widgets/navbar/components/navbar_security_badge.dart
import 'package:flutter/material.dart';
import '../../security/security_certificate_dialog.dart';

class NavbarSecurityBadge extends StatefulWidget {
  final bool isCompact;
  const NavbarSecurityBadge({super.key, this.isCompact = false});

  @override
  State<NavbarSecurityBadge> createState() => _NavbarSecurityBadgeState();
}

class _NavbarSecurityBadgeState extends State<NavbarSecurityBadge> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: GestureDetector(
        onTap: () => SecurityCertificateDialog.show(context),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: EdgeInsets.symmetric(
            horizontal: widget.isCompact ? 8 : 10,
            vertical: widget.isCompact ? 4 : 6,
          ),
          decoration: BoxDecoration(
            color: _isHovered
                ? const Color(0xFF2E7D32).withValues(alpha: 0.15)
                : Colors.white.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: _isHovered
                  ? const Color(0xFF81C784)
                  : const Color(0xFFD4AF37).withValues(alpha: 0.5),
              width: 1,
            ),
            boxShadow: _isHovered
                ? [
                    BoxShadow(
                      color: const Color(0xFF81C784).withValues(alpha: 0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ]
                : null,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 6,
                height: 6,
                decoration: const BoxDecoration(
                  color: Color(0xFF4CAF50),
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 6),
              const Icon(
                Icons.lock_outline_rounded,
                size: 13,
                color: Color(0xFFD4AF37),
              ),
              const SizedBox(width: 4),
              Text(
                widget.isCompact ? 'TLS 1.3' : 'TLS 1.3 & E2EE',
                style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                  letterSpacing: 0.3,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
