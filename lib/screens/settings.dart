
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter_foreground_task/flutter_foreground_task.dart';

import '../globals.dart';
import '../providers/field_settings.dart';
import '../styles/app_colors.dart';
import '../styles/app_text_styles.dart';
import '../utils/translation.dart';
import '../widgets/app_template.dart';
import '../widgets/app_buttons.dart';

class Settingsscreen extends StatefulWidget {
const Settingsscreen({super.key});

@override
State<Settingsscreen> createState() => _SettingsscreenState();
}

class _SettingsscreenState extends State<Settingsscreen> {
@override
void initState() {
super.initState();
FlutterForegroundTask.initCommunicationPort();
}

void _sendCommand(String cmd) {
debugPrint('[SETTINGS_SCREEN] Sending command: $cmd');

FlutterForegroundTask.sendDataToTask({
'event': 'writeCommand',
'command': cmd,
});
}

Future<void> _openUrl(String url) async {
final uri = Uri.parse(url);

try {
final launched = await launchUrl(
uri,
mode: LaunchMode.externalApplication,
);

if (!launched && mounted) {
final t = Provider.of<Translations>(context, listen: false);
ScaffoldMessenger.of(context).showSnackBar(
SnackBar(content: Text(t.text('set_url_error'))),
);
}
} catch (_) {
if (!mounted) return;

final t = Provider.of<Translations>(context, listen: false);
ScaffoldMessenger.of(context).showSnackBar(
SnackBar(content: Text(t.text('set_url_error'))),
);
}
}

@override
Widget build(BuildContext context) {
final fields = Provider.of<FieldSettings>(context);
final t = Provider.of<Translations>(context);

return AppTemplate(
hideSettingsIcon: true,
child: SingleChildScrollView(
padding: const EdgeInsets.fromLTRB(20, 20, 20, 28),
child: Column(
crossAxisAlignment: CrossAxisAlignment.start,
children: [
_buildHeader(
title: t.text('settings_title'),
subtitle: t.text('settings_subtitle'),
),

const SizedBox(height: 24),

_buildSectionTitle(
icon: Icons.language_rounded,
title: t.text('set1'),
),

const SizedBox(height: 12),

_buildSettingsCard(
child: _buildDropdownRow<String>(
icon: Icons.translate_rounded,
label: t.text('set1'),
value: fields.language == 'de' ? 'de' : 'en',
items: [
DropdownMenuItem(
value: 'de',
child: Text(t.text('settings_german')),
),
DropdownMenuItem(
value: 'en',
child: Text(t.text('settings_english')),
),
],
  onChanged: (value) async {
    if (value == null) return;

    fields.setLanguage(value);
    await t.setLocale(value);

    if (mounted) {
      setState(() {});
    }
  },
),
),

const SizedBox(height: 24),

_buildSectionTitle(
icon: Icons.tune_rounded,
title: t.text('settings_mode_section'),
),

const SizedBox(height: 12),

_buildSettingsCard(
child: _buildDropdownRow<bool>(
icon: Icons.settings_suggest_outlined,
label: t.text('settings_mode_label'),
value: fields.automatik,
items: [
DropdownMenuItem(
value: true,
child: Text(t.text('set3')),
),
DropdownMenuItem(
value: false,
child: Text(t.text('set4')),
),
],
onChanged: (value) {
if (value != null) {
fields.setAutomatik(value);
}
},
),
),

const SizedBox(height: 24),

_buildSectionTitle(
icon: Icons.description_outlined,
title: t.text('set14'),
),

const SizedBox(height: 12),

_buildSettingsCard(
child: Column(
children: [
_buildCheckboxRow(
title: t.text('settings_csv'),
subtitle: t.text('settings_csv_description'),
icon: Icons.table_chart_outlined,
value: fields.csv,
onChanged: (value) => fields.setCSV(value),
),
_buildDivider(),
_buildCheckboxRow(
title: t.text('settings_pdf'),
subtitle: t.text('settings_pdf_description'),
icon: Icons.picture_as_pdf_outlined,
value: fields.pdf,
onChanged: (value) => fields.setPDF(value),
),
],
),
),

const SizedBox(height: 24),

_buildSectionTitle(
icon: Icons.speed_rounded,
title: t.text('settings_units_section'),
),

const SizedBox(height: 12),

_buildSettingsCard(
child: Column(
children: [
_buildDropdownRow<String>(
icon: Icons.compress_rounded,
label: t.text('set10'),
value: DRUCK_EINHEIT,
items: const [
DropdownMenuItem(
value: 'Bar',
child: Text('Bar'),
),
DropdownMenuItem(
value: 'PSI',
child: Text('PSI'),
),
],
onChanged: (value) async {
if (value == null) return;

DRUCK_EINHEIT = value;
await saveSettings();

if (mounted) setState(() {});
},
),
_buildDivider(),
_buildDropdownRow<String>(
icon: Icons.build_circle_outlined,
label: t.text('set13'),
value: DREHMOMENT_EINHEIT,
items: const [
DropdownMenuItem(
value: 'Nm',
child: Text('Nm'),
),
DropdownMenuItem(
value: 'Ft Lbs.',
child: Text('Ft Lbs.'),
),
],
onChanged: (value) async {
if (value == null) return;

DREHMOMENT_EINHEIT = value;
await saveSettings();

if (mounted) setState(() {});
},
),
],
),
),

const SizedBox(height: 24),

_buildSectionTitle(
icon: Icons.checklist_rounded,
title: t.text('set5'),
),

const SizedBox(height: 12),

_buildSettingsCard(
child: Column(
children: [
_buildCheckboxRow(
title: t.text('set6'),
subtitle: t.text('settings_name_required_description'),
icon: Icons.person_outline_rounded,
value: fields.requireName,
onChanged: (value) {
fields.setField('requireName', value);
},
),
_buildDivider(),
_buildCheckboxRow(
title: t.text('set7'),
subtitle: t.text('settings_tool_required_description'),
icon: Icons.handyman_outlined,
value: fields.requireSerialTool,
onChanged: (value) {
fields.setField('requireSerialTool', value);
},
),
_buildDivider(),
_buildCheckboxRow(
title: t.text('set8'),
subtitle: t.text('settings_hose_required_description'),
icon: Icons.water_outlined,
value: fields.requireSerialHose,
onChanged: (value) {
fields.setField('requireSerialHose', value);
},
),
],
),
),

const SizedBox(height: 24),

_buildSectionTitle(
icon: Icons.system_update_alt_rounded,
title: t.text('settings_update_section'),
),

const SizedBox(height: 12),

AppButtons.primary(
text: t.text('set9'),
icon: Icons.system_update_alt_rounded,
minHeight: 54,
onPressed: () {
Navigator.pushNamed(context, '/update');
},
),

const SizedBox(height: 24),

_buildSectionTitle(
icon: Icons.policy_outlined,
title: t.text('settings_legal_section'),
),

const SizedBox(height: 12),

_buildSettingsCard(
child: Column(
children: [
_buildLinkRow(
icon: Icons.gavel_outlined,
title: t.text('set11'),
onTap: () {
_openUrl(
'https://stephandahlmann.com/?route=imprint',//Standard
// 'https://www.alkitronic.com/impressum/', //Alkitronic
);
},
),
_buildDivider(),
_buildLinkRow(
icon: Icons.privacy_tip_outlined,
title: t.text('set12'),
onTap: () {
_openUrl(
'https://stephandahlmann.com/?route=datasecurity', //Standard
//'https://www.alkitronic.com/datenschutz/',//Alkitronic
);
},
),
],
),
),

const SizedBox(height: 28),

AppButtons.primaryText(
text: t.text('zurueck'),
onPressed: _goBack,
backgroundColor: AppColors.secondary,
minHeight: 54,
verticalPadding: 8,
),
],
),
),
);
}

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
boxShadow: [
BoxShadow(
color: AppColors.shadow,
blurRadius: 16,
offset: const Offset(0, 6),
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
child: Icon(
Icons.settings_rounded,
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

Widget _buildSectionTitle({
required IconData icon,
required String title,
}) {
return Row(
children: [
Container(
width: 38,
height: 38,
decoration: BoxDecoration(
color: AppColors.lightBlue,
borderRadius: BorderRadius.circular(11),
),
child: Icon(
icon,
color: AppColors.primary,
size: 21,
),
),
const SizedBox(width: 12),
Expanded(
child: Text(
title,
style: AppTextStyles.body.copyWith(
color: AppColors.textPrimary,
fontSize: 17,
fontWeight: FontWeight.bold,
),
),
),
],
);
}

Widget _buildSettingsCard({
required Widget child,
}) {
return Container(
width: double.infinity,
padding: const EdgeInsets.symmetric(
horizontal: 14,
vertical: 6,
),
decoration: BoxDecoration(
color: AppColors.backgroundCard,
borderRadius: BorderRadius.circular(16),
border: Border.all(
color: AppColors.border,
),
boxShadow: [
BoxShadow(
color: AppColors.shadow,
blurRadius: 10,
offset: const Offset(0, 3),
),
],
),
child: child,
);
}

Widget _buildDropdownRow<T>({
required IconData icon,
required String label,
required T value,
required List<DropdownMenuItem<T>> items,
required ValueChanged<T?> onChanged,
}) {
return Padding(
padding: const EdgeInsets.symmetric(vertical: 8),
child: Row(
children: [
_buildLeadingIcon(icon),
const SizedBox(width: 12),
Expanded(
child: Column(
crossAxisAlignment: CrossAxisAlignment.start,
children: [
Text(
label,
style: AppTextStyles.body.copyWith(
color: AppColors.textPrimary,
fontSize: 15,
),
),
const SizedBox(height: 4),
DropdownButtonHideUnderline(
child: DropdownButton<T>(
value: value,
isExpanded: true,
items: items,
onChanged: onChanged,
dropdownColor: AppColors.backgroundCard,
style: AppTextStyles.body.copyWith(
color: AppColors.textSecondary,
fontSize: 14,
),
icon: Icon(
Icons.keyboard_arrow_down_rounded,
color: AppColors.primary,
),
),
),
],
),
),
],
),
);
}

Widget _buildCheckboxRow({
required String title,
required String subtitle,
required IconData icon,
required bool value,
required ValueChanged<bool> onChanged,
}) {
return InkWell(
borderRadius: BorderRadius.circular(12),
onTap: () => onChanged(!value),
child: Padding(
padding: const EdgeInsets.symmetric(vertical: 10),
child: Row(
children: [
_buildLeadingIcon(icon),
const SizedBox(width: 12),
Expanded(
child: Column(
crossAxisAlignment: CrossAxisAlignment.start,
children: [
Text(
title,
style: AppTextStyles.body.copyWith(
color: AppColors.textPrimary,
fontSize: 15,
),
),
const SizedBox(height: 4),
Text(
subtitle,
style: AppTextStyles.body.copyWith(
color: AppColors.textSecondary,
fontSize: 12,
fontWeight: FontWeight.normal,
),
),
],
),
),
const SizedBox(width: 8),
Checkbox(
value: value,
activeColor: AppColors.primary,
checkColor: AppColors.white,
onChanged: (newValue) {
if (newValue != null) {
onChanged(newValue);
}
},
),
],
),
),
);
}

Widget _buildLinkRow({
required IconData icon,
required String title,
required VoidCallback onTap,
}) {
return ListTile(
contentPadding: const EdgeInsets.symmetric(horizontal: 4),
leading: _buildLeadingIcon(icon),
title: Text(
title,
style: AppTextStyles.body.copyWith(
color: AppColors.textPrimary,
fontSize: 15,
),
),
trailing: Icon(
Icons.open_in_new_rounded,
color: AppColors.primary,
size: 20,
),
onTap: onTap,
);
}

Widget _buildLeadingIcon(IconData icon) {
return Container(
width: 40,
height: 40,
decoration: BoxDecoration(
color: AppColors.lightBlue,
borderRadius: BorderRadius.circular(12),
),
child: Icon(
icon,
color: AppColors.primary,
size: 21,
),
);
}

Widget _buildDivider() {
return Divider(
height: 1,
thickness: 1,
color: AppColors.divider,
);
}

void _goBack() {
Navigator.pop(context);

// Bestehende Automatik-Logik beibehalten.
if (isauto) {
iscomplete = false;
isaborted1 = false;
isaborted2 = false;

final now = DateTime.now();
final formattedDate =
'${now.day.toString().padLeft(2, '0')}-'
'${now.month.toString().padLeft(2, '0')}-'
'${now.year}';

if (!isSchrauben) {
_sendCommand('-STOP\$');
} else {
if (Automatik) {
_sendCommand(
'-AutomatikA $pwm $Projectnumber $formattedDate '
'$SOLLDRUCK $referenzzeitkal $vorreferenzzeit $akt_schraube\$',
);
} else {
_sendCommand(
'-AutomatikM $pwm $Projectnumber $formattedDate '
'$SOLLDRUCK $referenzzeitkal $vorreferenzzeit $akt_schraube\$',
);
}
}
}
}
}

