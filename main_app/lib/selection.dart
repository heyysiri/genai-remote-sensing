import 'package:flutter/material.dart';
import 'theme.dart';

class SelectionPage extends StatelessWidget {
  const SelectionPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('GeoVision AI'),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.white, AppTheme.backgroundColor],
          ),
        ),
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  'Choose Analysis Type',
                  style: AppTheme.headingStyle,
                ),
                const SizedBox(height: 30),
                _buildFeatureCard(
                  context: context,
                  title: 'Crop Mapping',
                  description: 'Classify and analyze crop types with AI',
                  icon: Icons.grass,
                  route: '/home',
                ),
                const SizedBox(height: 24),
                _buildFeatureCard(
                  context: context,
                  title: 'SAR Image Colorization',
                  description:
                      'Convert SAR imagery to realistic colored images',
                  icon: Icons.color_lens,
                  route: '/sar',
                ),
                const SizedBox(height: 24),
                _buildFeatureCard(
                  context: context,
                  title: 'Flood Detection',
                  description:
                      'Detect flood-affected areas using image processing',
                  icon: Icons.water,
                  route: '/flood',
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFeatureCard({
    required BuildContext context,
    required String title,
    required String description,
    required IconData icon,
    required String route,
  }) {
    return Container(
      decoration: AppTheme.cardDecoration,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: () => Navigator.pushNamed(context, route),
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppTheme.primaryColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    icon,
                    size: 36,
                    color: AppTheme.primaryColor,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: AppTheme.subheadingStyle,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        description,
                        style: AppTheme.bodyTextStyle,
                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons.arrow_forward_ios,
                  color: AppTheme.primaryColor,
                  size: 16,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
