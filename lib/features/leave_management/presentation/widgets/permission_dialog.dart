import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';

import 'package:dazzleshrms/core/api_config/api_config.dart';
import 'package:dazzleshrms/core/api_constants/api_constants.dart';
import 'package:dazzleshrms/core/app_theme/app_theme.dart';

class PermissionDialog extends StatefulWidget {
  const PermissionDialog({super.key});

  @override
  State<PermissionDialog> createState() => _PermissionDialogState();
}

class _PermissionDialogState extends State<PermissionDialog> {
  final Dio _dio = ApiConfig.dio;
  bool _loading = true;
  bool _generatingQr = false;
  String? _error;
  String _status = 'INSIDE';
  int? _permissionId;

  bool get _isInside => _status.toUpperCase() == 'INSIDE';

  @override
  void initState() {
    super.initState();
    _loadStatus();
  }

  Future<void> _loadStatus() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final response = await _dio.get(ApiConstants.permissions);
      final data = response.data['data'] as Map<String, dynamic>?;
      final status = (data?['permissionStatus'] ?? 'INSIDE').toString();
      final id = data?['permissionId'];
      setState(() {
        _status = status.toUpperCase();
        _permissionId = id is int ? id : null;
        _loading = false;
      });
    } on DioException catch (e) {
      setState(() {
        _error = e.response?.data?['message']?.toString() ??
            'Failed to load permission status';
        _loading = false;
      });
    } catch (_) {
      setState(() {
        _error = 'Failed to load permission status';
        _loading = false;
      });
    }
  }

  Future<void> _generatePermissionQr() async {
    setState(() {
      _generatingQr = true;
      _error = null;
    });

    try {
      // Location permission (same flow as attendance QR)
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Location permission is required'),
                backgroundColor: AppTheme.statusError,
                behavior: SnackBarBehavior.floating,
              ),
            );
          }
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                'Location permission is permanently denied. Please enable it in settings.',
              ),
              backgroundColor: AppTheme.statusError,
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
        return;
      }

      final position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
        ),
      );

      final method = _isInside ? 'PERMISSION_OUT' : 'PERMISSION_IN';

      final response = await _dio.get(
        ApiConstants.permissionsGenerate,
        data: {
          'method': method,
          'location': {
            'lat': position.latitude,
            'lng': position.longitude,
            'accuracy': position.accuracy,
          },
        },
      );

      final data = response.data['data'] as Map<String, dynamic>?;
      final qrImage = data?['qrImage'] as String?;

      if (!mounted) return;

      if (qrImage == null || qrImage.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to generate QR'),
            backgroundColor: AppTheme.statusError,
            behavior: SnackBarBehavior.floating,
          ),
        );
        return;
      }

      showDialog(
        context: context,
        barrierDismissible: true,
        builder: (_) => PermissionQrDialog(
          isPermissionIn: !_isInside,
          qrImage: qrImage,
        ),
      );
    } on DioException catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e.response?.data?['message']?.toString() ??
            'Failed to generate permission QR';
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _error = 'Failed to generate permission QR';
      });
    } finally {
      if (mounted) {
        setState(() {
          _generatingQr = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isInside = _isInside;
    final statusColor =
        isInside ? AppTheme.statusSuccess : AppTheme.statusError;
    final buttonLabel = isInside ? 'Permission Out' : 'Permission In';

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Permissions',
                  style: theme.textTheme.titleLarge
                      ?.copyWith(fontWeight: FontWeight.bold),
                ),
                IconButton(
                  icon: const Icon(Icons.close_rounded),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
            const SizedBox(height: 12),
            if (_loading)
              const Center(
                child: Padding(
                  padding: EdgeInsets.all(16.0),
                  child: CircularProgressIndicator(),
                ),
              )
            else if (_error != null)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _error!,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.error,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Align(
                    alignment: Alignment.centerRight,
                    child: FilledButton(
                      onPressed: _loadStatus,
                      child: const Text('Retry'),
                    ),
                  ),
                ],
              )
            else ...[
              Row(
                children: [
                  Container(
                    width: 10,
                    height: 10,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: statusColor,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    _status,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: statusColor,
                    ),
                  ),
                ],
              ),
              if (_permissionId != null) ...[
                const SizedBox(height: 4),
                Text(
                  'Permission ID: $_permissionId',
                  style: theme.textTheme.bodySmall,
                ),
              ],
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  onPressed:
                      _generatingQr ? null : () => _generatePermissionQr(),
                  style: FilledButton.styleFrom(
                    backgroundColor: isInside
                        ? AppTheme.statusError
                        : AppTheme.statusSuccess,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  icon: _generatingQr
                      ? const SizedBox(
                          height: 18,
                          width: 18,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor:
                                AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        )
                      : Icon(
                          isInside
                              ? Icons.logout_rounded
                              : Icons.login_rounded,
                          size: 20,
                        ),
                  label: Text(
                    buttonLabel,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class PermissionQrDialog extends StatelessWidget {
  final bool isPermissionIn;
  final String qrImage;

  const PermissionQrDialog({
    super.key,
    required this.isPermissionIn,
    required this.qrImage,
  });

  Uint8List _decodeImage(String dataUri) {
    final base64String = dataUri.split(',').last;
    return base64Decode(base64String);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final bytes = _decodeImage(qrImage);

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: AppTheme.PrimaryColor.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    isPermissionIn ? Icons.login : Icons.logout,
                    color: AppTheme.PrimaryColor,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        isPermissionIn ? "Permission In" : "Permission Out",
                        style: theme.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        "Show this QR to the scanner",
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.textTheme.bodyMedium?.color
                              ?.withOpacity(0.6),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: Colors.grey.shade200,
                  width: 2,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Image.memory(
                bytes,
                width: 220,
                height: 220,
                fit: BoxFit.contain,
                gaplessPlayback: true,
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: () => Navigator.pop(context),
                child: const Text(
                  "Close",
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

