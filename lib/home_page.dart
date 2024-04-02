import 'dart:convert';
import 'dart:html' as html;
import 'dart:js' as js;

import 'package:apple_required_reasons_api_generator/info_dialog.dart';
import 'package:apple_required_reasons_api_generator/privacy_info_generator.dart';
import 'package:apple_required_reasons_api_generator/required_apis.dart';
import 'package:flutter/material.dart';

final class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

final class _HomePageState extends State<HomePage> {
  List<RequiredReasonApi> reasons = [];
  Map<String, Set<String>> selectedReasons = {};

  Future<List<RequiredReasonApi>> loadRequiredApis() async {
    final jsonString = await DefaultAssetBundle.of(context)
        .loadString('assets/required_apis.json');
    final jsonData = json.decode(jsonString) as List<dynamic>;

    return jsonData
        .map((item) => RequiredReasonApi.fromJson(item as Map<String, dynamic>))
        .toList();
  }

  @override
  void initState() {
    super.initState();
    loadRequiredApis().then((value) => setState(() => reasons = value));
  }

  void toggleReason(String categoryKey, String reasonKey) {
    if (selectedReasons.containsKey(categoryKey)) {
      if (selectedReasons[categoryKey]!.contains(reasonKey)) {
        selectedReasons[categoryKey]!.remove(reasonKey);
      } else {
        selectedReasons[categoryKey]!.add(reasonKey);
      }
    } else {
      selectedReasons[categoryKey] = {reasonKey};
    }
    setState(() {});
  }

  void downloadPrivacyInfoFile() {
    final xmlContent =
        PrivacyInfoGenerator.generatePrivacyInfoXml(selectedReasons);
    final blob = html.Blob([xmlContent]);
    final url = html.Url.createObjectUrlFromBlob(blob);
    html.AnchorElement(href: url)
      ..setAttribute('download', 'PrivacyInfo.xcprivacy')
      ..click();
    html.Url.revokeObjectUrl(url);
  }

  int get totalAvailable {
    var totalCount = 0;
    for (final reason in reasons) {
      totalCount += reason.reasons.length;
    }
    return totalCount;
  }

  int get totalSelected {
    var totalCount = 0;
    selectedReasons.forEach((_, reasons) {
      totalCount += reasons.length;
    });
    return totalCount;
  }

  String get githubLogo => switch (Theme.of(context).brightness) {
        Brightness.dark => 'assets/github-mark-white.png',
        Brightness.light => 'assets/github-mark.png',
      };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Image.asset(
            githubLogo,
            width: kToolbarHeight / 2,
            height: kToolbarHeight / 2,
          ),
          onPressed: () => js.context.callMethod(
            'open',
            [
              'https://github.com/cgutierr-zgz/apple_required_reasons_api_generator',
            ],
          ),
        ),
        title: const Text('Apple Required Reasons API Generator'),
        centerTitle: false,
        actions: [
          Text('$totalSelected/$totalAvailable'),
          IconButton(
            icon: const Icon(Icons.download),
            onPressed: downloadPrivacyInfoFile,
          ),
        ],
      ),
      body: ListView.separated(
        itemCount: reasons.length,
        separatorBuilder: (_, __) => const Divider(),
        itemBuilder: (context, index) {
          final reason = reasons[index];
          final categoryKey = reason.key;
          final selectedCount = selectedReasons.containsKey(categoryKey)
              ? selectedReasons[categoryKey]!.length
              : 0;

          return ExpansionTile(
            shape: const Border(),
            title: Text(
              '${reason.requiredReasonApi} ($selectedCount/${reason.reasons.length})',
            ),
            leading: IconButton(
              icon: const Icon(Icons.info),
              onPressed: () => showDialog<void>(
                context: context,
                builder: (_) => InfoDialog(reason),
              ),
            ),
            children: reason.reasons.entries.map((entry) {
              final isSelected = selectedReasons.containsKey(categoryKey) &&
                  selectedReasons[categoryKey]!.contains(entry.key);

              return SelectionArea(
                child: CheckboxListTile(
                  title: ExpansionTile(
                    shape: const Border(),
                    title: Text(
                      entry.key,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    expandedAlignment: Alignment.centerLeft,
                    children: [Text(entry.value)],
                  ),
                  value: isSelected,
                  onChanged: (_) => toggleReason(categoryKey, entry.key),
                ),
              );
            }).toList(),
          );
        },
      ),
    );
  }
}
