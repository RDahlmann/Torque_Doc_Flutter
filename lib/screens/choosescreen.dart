import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../styles/app_colors.dart';
import '../styles/app_text_styles.dart';
import '../widgets/app_template.dart';
import '../widgets/app_buttons.dart';
import '../utils/translation.dart';

class Auswahlscreen extends StatefulWidget {
const Auswahlscreen({super.key});

@override
State<Auswahlscreen> createState() => _Auswahlscreenstate();
}

class _Auswahlscreenstate extends State<Auswahlscreen> {
Widget _buildHeader({
required String title,
required String subtitle,
}) {
return Container(
width: double.infinity,
padding: const EdgeInsets.all(20),
decoration: BoxDecoration(
gradient: LinearGradient(
begin: Alignment.topLeft,
end: Alignment.bottomRight,
colors: [
AppColors.primary,
AppColors.primary.withValues(alpha: 0.82),
],
),
borderRadius: BorderRadius.circular(20),
boxShadow: const [
BoxShadow(
color: AppColors.shadow,
blurRadius: 16,
offset: Offset(0, 6),
),
],
),
child: Row(
crossAxisAlignment: CrossAxisAlignment.start,
children: [
Container(
width: 48,
height: 48,
decoration: BoxDecoration(
color: AppColors.white.withValues(alpha: 0.16),
borderRadius: BorderRadius.circular(14),
),
child: const Icon(
Icons.dashboard_customize_rounded,
color: AppColors.textOnPrimary,
size: 27,
),
),
const SizedBox(width: 14),
Expanded(
child: Column(
crossAxisAlignment: CrossAxisAlignment.start,
children: [
Text(
title,
style: AppTextStyles.headline.copyWith(
color: AppColors.textOnPrimary,
fontSize: 22,
),
),
const SizedBox(height: 6),
Text(
subtitle,
style: AppTextStyles.body.copyWith(
color: AppColors.textOnPrimary.withValues(alpha: 0.88),
fontSize: 14,
),
),
],
),
),
],
),
);
}

Widget _buildOptionCard({
required IconData icon,
required String title,
required String description,
required String buttonText,
required VoidCallback onPressed,
}) {
return Container(
width: double.infinity,
padding: const EdgeInsets.all(18),
decoration: BoxDecoration(
color: AppColors.backgroundCard,
borderRadius: BorderRadius.circular(18),
border: Border.all(
color: AppColors.border,
width: 1,
),
boxShadow: const [
BoxShadow(
color: AppColors.shadow,
blurRadius: 10,
offset: Offset(0, 4),
),
],
),
child: Column(
crossAxisAlignment: CrossAxisAlignment.start,
children: [
Container(
width: 48,
height: 48,
decoration: BoxDecoration(
color: AppColors.primary.withValues(alpha: 0.10),
borderRadius: BorderRadius.circular(14),
),
child: Icon(
icon,
color: AppColors.primary,
size: 26,
),
),
const SizedBox(height: 14),
Text(
title,
style: AppTextStyles.body.copyWith(
color: AppColors.textPrimary,
fontSize: 18,
fontWeight: FontWeight.w700,
),
),
const SizedBox(height: 6),
Text(
description,
style: AppTextStyles.body.copyWith(
color: AppColors.textSecondary,
fontSize: 14,
fontWeight: FontWeight.w400,
),
),
const SizedBox(height: 18),
SizedBox(
width: double.infinity,
child: AppButtons.primaryText(
text: buttonText,
onPressed: onPressed,
verticalPadding: 16,
),
),
],
),
);
}

@override
Widget build(BuildContext context) {
final t = Provider.of<Translations>(context);

return WillPopScope(
onWillPop: () async => false,
child: AppTemplate(
child: SingleChildScrollView(
padding: const EdgeInsets.all(16),
child: Column(
crossAxisAlignment: CrossAxisAlignment.start,
children: [
_buildHeader(
title: t.text('selection_title'),
subtitle: t.text('selection_subtitle'),
),
const SizedBox(height: 24),

Text(
t.text('selection_section'),
style: AppTextStyles.body.copyWith(
color: AppColors.textPrimary,
fontSize: 19,
fontWeight: FontWeight.w700,
),
),
const SizedBox(height: 14),

_buildOptionCard(
icon: Icons.speed_rounded,
title: t.text('selection_pressure_title'),
description: t.text('selection_pressure_description'),
buttonText: t.text('ch1'),
onPressed: () {
Navigator.pushNamed(context, '/pressure');
},
),

const SizedBox(height: 16),

_buildOptionCard(
icon: Icons.handyman_rounded,
title: t.text('selection_tools_title'),
description: t.text('selection_tools_description'),
buttonText: t.text('ch2'),
onPressed: () {
Navigator.pushNamed(context, '/tools');
},
),

const SizedBox(height: 16),
],
),
),
),
);
}
}

