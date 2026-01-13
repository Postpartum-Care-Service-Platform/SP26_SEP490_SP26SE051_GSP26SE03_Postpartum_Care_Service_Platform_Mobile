import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/utils/app_responsive.dart';
import '../../../../core/utils/app_text_styles.dart';
import '../../../../core/widgets/app_drawer_form.dart';

/// Map drawer widget for displaying appointment location
class AppointmentMapDrawer extends StatelessWidget {
  const AppointmentMapDrawer({super.key});

  // Coordinates for The Joyful Nest resort
  static const LatLng _locationLatLng = LatLng(10.7305976, 106.7040098);

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final scale = AppResponsive.scaleFactor(context);
    final address = AppStrings.appointmentLocationAddress;

    return Container(
      constraints: BoxConstraints(
        maxHeight: screenHeight * 0.7,
      ),
      child: AppDrawerForm(
        title: AppStrings.appointmentLocation,
        saveButtonText: null,
        onSave: null,
        children: [
          // Location name
          Container(
            padding: EdgeInsets.all(16 * scale),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12 * scale),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.place,
                  color: AppColors.primary,
                  size: 24 * scale,
                ),
                SizedBox(width: 12 * scale),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        AppStrings.appointmentLocationName,
                        style: AppTextStyles.arimo(
                          fontSize: 16 * scale,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      SizedBox(height: 4 * scale),
                      Text(
                        address,
                        style: AppTextStyles.arimo(
                          fontSize: 12 * scale,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 16 * scale),
          // Map container
          Container(
            height: 280 * scale,
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.circular(16 * scale),
              border: Border.all(color: AppColors.borderLight),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 8 * scale,
                  offset: Offset(0, 2 * scale),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(16 * scale),
              child: FlutterMap(
                options: MapOptions(
                  initialCenter: _locationLatLng,
                  initialZoom: 16,
                  interactionOptions: const InteractionOptions(
                    flags: InteractiveFlag.pinchZoom |
                        InteractiveFlag.drag |
                        InteractiveFlag.doubleTapZoom,
                  ),
                ),
                children: [
                  TileLayer(
                    urlTemplate:
                        'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                    userAgentPackageName: 'com.example.postpartum_service',
                  ),
                  MarkerLayer(
                    markers: [
                      Marker(
                        point: _locationLatLng,
                        width: 40 * scale,
                        height: 40 * scale,
                        child: Container(
                          decoration: BoxDecoration(
                            color: AppColors.primary,
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color:
                                    AppColors.primary.withValues(alpha: 0.4),
                                blurRadius: 8 * scale,
                                offset: Offset(0, 2 * scale),
                              ),
                            ],
                          ),
                          child: Icon(
                            Icons.place,
                            color: AppColors.white,
                            size: 24 * scale,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          SizedBox(height: 16 * scale),
          // Open in Google Maps button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () async {
                // Try geo: URI first (works with Google Maps app)
                final geoUri = Uri.parse(
                    'geo:${_locationLatLng.latitude},${_locationLatLng.longitude}?q=${_locationLatLng.latitude},${_locationLatLng.longitude}');
                
                // Fallback to Google Maps web URL
                final webUri = Uri.parse(
                    'https://www.google.com/maps?q=${_locationLatLng.latitude},${_locationLatLng.longitude}');
                
                try {
                  if (await canLaunchUrl(geoUri)) {
                    await launchUrl(geoUri, mode: LaunchMode.externalApplication);
                  } else if (await canLaunchUrl(webUri)) {
                    await launchUrl(webUri, mode: LaunchMode.externalApplication);
                  }
                } catch (e) {
                  // If geo: fails, try web URL
                  if (await canLaunchUrl(webUri)) {
                    await launchUrl(webUri, mode: LaunchMode.externalApplication);
                  }
                }
              },
              icon: Icon(
                Icons.open_in_new,
                size: 18 * scale,
              ),
              label: Text(
                'Mở trong Google Maps',
                style: AppTextStyles.arimo(
                  fontSize: 14 * scale,
                  fontWeight: FontWeight.w600,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: AppColors.white,
                padding: EdgeInsets.symmetric(
                  horizontal: 20 * scale,
                  vertical: 12 * scale,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12 * scale),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
