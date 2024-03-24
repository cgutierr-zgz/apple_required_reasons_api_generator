// ignore_for_file: avoid_web_libraries_in_flutter

import 'dart:convert';
import 'dart:html' as html;
import 'dart:js' as js;

import 'package:apple_required_reasons_api_generator/privacy_info_generator.dart';
import 'package:apple_required_reasons_api_generator/required_apis.dart';
import 'package:flutter/material.dart';

void main() => runApp(const MyApp());

final class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) => const MaterialApp(home: HomePage());
}

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Apple Required Reasons API Generator'),
        actions: [
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
                builder: (context) {
                  return AlertDialog(
                    content: SingleChildScrollView(
                      child: SelectionArea(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                IconButton(
                                  icon: const Icon(Icons.link),
                                  onPressed: () => js.context.callMethod(
                                    'open',
                                    [reason.url],
                                  ),
                                ),
                                const SizedBox(width: 5),
                                Expanded(
                                  child: Text(
                                    categoryKey,
                                    style:
                                        Theme.of(context).textTheme.titleLarge,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 20),
                            Text(reason.description),
                            const SizedBox(height: 20),
                            Text(
                              'Relevant APIs:',
                              style: Theme.of(context)
                                  .textTheme
                                  .titleMedium
                                  ?.copyWith(
                                    fontWeight: FontWeight.w600,
                                  ),
                            ),
                            ...reason.relevantApis.map(Text.new),
                          ],
                        ),
                      ),
                    ),
                  );
                },
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
