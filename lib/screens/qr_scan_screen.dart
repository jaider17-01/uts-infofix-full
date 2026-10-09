import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import '../widgets/app_header.dart';
import '../utils/app_theme.dart';

class QrScanScreen extends StatefulWidget {
  const QrScanScreen({super.key});
  @override
  State<QrScanScreen> createState() => _QrScanScreenState();
}

class _QrScanScreenState extends State<QrScanScreen> {
  late final MobileScannerController _controller;
  String? _scannedCode;
  bool _hasScanned = false;
  bool _torchOn = false;

  @override
  void initState() {
    super.initState();
    _controller = MobileScannerController(
      detectionSpeed: DetectionSpeed.noDuplicates,
      facing: CameraFacing.back,
      torchEnabled: false,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onDetect(BarcodeCapture capture) {
    if (_hasScanned) return;
    final raw = capture.barcodes.firstOrNull?.rawValue;
    if (raw == null || raw.isEmpty) return;
    _controller.stop();
    setState(() { _hasScanned = true; _scannedCode = raw; });
  }

  void _reset() {
    setState(() { _hasScanned = false; _scannedCode = null; });
    _controller.start();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Column(
        children: [
          AppHeader(showBack: true, onBack: () => Navigator.pop(context)),
          Expanded(
            child: _hasScanned && _scannedCode != null
                ? _buildResult()
                : _buildScanner(),
          ),
        ],
      ),
    );
  }

  // ── SCANNER VIEW (funciona en web Y nativo) ──────────────
  Widget _buildScanner() {
    return Stack(
      children: [
        // MobileScanner usa la cámara real tanto en web como en Android/iOS
        MobileScanner(
          controller: _controller,
          onDetect: _onDetect,
        ),

        // Overlay con marco de escaneo
        CustomPaint(
          painter: _ScanOverlayPainter(),
          size: Size.infinite,
        ),

        // Instrucciones arriba
        Positioned(
          top: 24, left: 16, right: 16,
          child: Column(children: [
            const Text(
              'Escanear código',
              style: TextStyle(color: Colors.white, fontSize: 18,
                  fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 6),
            Text(
              'Apunta la cámara al código QR o de barras\ndel dispositivo a reportar',
              style: TextStyle(color: Colors.white.withValues(alpha: 0.85),
                  fontSize: 13),
              textAlign: TextAlign.center,
            ),
          ]),
        ),

        // Botones abajo
        Positioned(
          bottom: 48, left: 0, right: 0,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _CamBtn(
                icon: _torchOn
                    ? Icons.flash_on_rounded
                    : Icons.flash_off_rounded,
                label: 'Linterna',
                onTap: () {
                  setState(() => _torchOn = !_torchOn);
                  _controller.toggleTorch();
                },
              ),
              const SizedBox(width: 40),
              _CamBtn(
                icon: Icons.close_rounded,
                label: 'Cancelar',
                onTap: () => Navigator.pop(context),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // ── RESULTADO ──────────────────────��──────────────────────
  Widget _buildResult() {
    final code = _scannedCode!;
    return Container(
      color: AppColors.background,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(children: [
          const SizedBox(height: 16),
          Container(
            width: 80, height: 80,
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.1),
              shape: BoxShape.circle),
            child: const Icon(Icons.check_circle_rounded,
                color: AppColors.primary, size: 48)),
          const SizedBox(height: 16),
          const Text('Código escaneado',
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
          const SizedBox(height: 24),

          // Código card
          Container(
            width: double.infinity,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [BoxShadow(
                  color: Colors.black.withValues(alpha: 0.06), blurRadius: 8)],
            ),
            child: Column(children: [
              Container(
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.08),
                  borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(16))),
                padding: const EdgeInsets.all(20),
                child: Row(children: [
                  Container(
                    width: 52, height: 52,
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.15),
                      shape: BoxShape.circle),
                    child: const Icon(Icons.qr_code_rounded,
                        color: AppColors.primary, size: 28)),
                  const SizedBox(width: 14),
                  Expanded(child: Text(
                      code,
                      style: const TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 20))),
                ]),
              ),
              const Divider(height: 1),
              _InfoRow(icon: Icons.album_rounded,
                  label: 'Valor del código', value: code),
            ]),
          ),

          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () => Navigator.pushReplacementNamed(
                context, '/new-report',
                arguments: {
                  'type': 'grave',
                  'lab': '',
                  'equipment': code,
                  'deviceType': '',
                },
              ),
              icon: const Icon(Icons.add_circle_outline_rounded,
                  color: Colors.white),
              label: const Text('Crear Reporte con este código',
                style: TextStyle(color: Colors.white,
                    fontWeight: FontWeight.w600, fontSize: 15)),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14))),
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: _reset,
              icon: const Icon(Icons.qr_code_scanner_rounded,
                  color: AppColors.primary),
              label: const Text('Escanear otro código',
                style: TextStyle(color: AppColors.primary,
                    fontWeight: FontWeight.w600)),
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: AppColors.primary),
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14))),
            ),
          ),
        ]),
      ),
    );
  }
}

// ── OVERLAY ───────────────────────────────────────────────
class _ScanOverlayPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = Colors.black.withValues(alpha: 0.55);
    const s = 260.0;
    final cx = size.width / 2;
    final cy = size.height / 2 - 40;
    final rect = Rect.fromCenter(
        center: Offset(cx, cy), width: s, height: s);
    canvas.drawRect(
        Rect.fromLTRB(0, 0, size.width, rect.top), paint);
    canvas.drawRect(
        Rect.fromLTRB(0, rect.top, rect.left, rect.bottom), paint);
    canvas.drawRect(
        Rect.fromLTRB(rect.right, rect.top, size.width, rect.bottom), paint);
    canvas.drawRect(
        Rect.fromLTRB(0, rect.bottom, size.width, size.height), paint);
    final cp = Paint()
      ..color = AppColors.primary
      ..strokeWidth = 4
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;
    const len = 32.0;
    canvas.drawLine(rect.topLeft, rect.topLeft + const Offset(len, 0), cp);
    canvas.drawLine(rect.topLeft, rect.topLeft + const Offset(0, len), cp);
    canvas.drawLine(
        rect.topRight, rect.topRight + const Offset(-len, 0), cp);
    canvas.drawLine(rect.topRight, rect.topRight + const Offset(0, len), cp);
    canvas.drawLine(
        rect.bottomLeft, rect.bottomLeft + const Offset(len, 0), cp);
    canvas.drawLine(
        rect.bottomLeft, rect.bottomLeft + const Offset(0, -len), cp);
    canvas.drawLine(
        rect.bottomRight, rect.bottomRight + const Offset(-len, 0), cp);
    canvas.drawLine(
        rect.bottomRight, rect.bottomRight + const Offset(0, -len), cp);
  }
  @override
  bool shouldRepaint(_) => false;
}

// ── HELPERS ───────────────────────────────────────────────
class _CamBtn extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  const _CamBtn(
      {required this.icon, required this.label, required this.onTap});
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(children: [
        Container(
          width: 56, height: 56,
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.15),
            shape: BoxShape.circle,
            border: Border.all(color: Colors.white30)),
          child: Icon(icon, color: Colors.white, size: 26)),
        const SizedBox(height: 6),
        Text(label,
            style: const TextStyle(color: Colors.white70, fontSize: 11)),
      ]),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  const _InfoRow(
      {required this.icon, required this.label, required this.value});
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(children: [
        Icon(icon, color: AppColors.primary, size: 20),
        const SizedBox(width: 12),
        Text(label,
            style: const TextStyle(color: AppColors.textGray, fontSize: 13)),
        const Spacer(),
        Flexible(
          child: Text(value,
              style: const TextStyle(
                  fontWeight: FontWeight.bold, fontSize: 13),
              overflow: TextOverflow.ellipsis),
        ),
      ]),
    );
  }
}
