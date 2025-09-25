import 'package:application/enum/potability_enum.dart';
import 'package:application/helpers/user_session.dart';
import 'package:application/screens/components/minimal_notification.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:application/enum/report_type_enum.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class ReportFormBottomSheet extends StatefulWidget {
  final String fontanellaId;
  const ReportFormBottomSheet({Key? key, required this.fontanellaId})
    : super(key: key);

  @override
  State<ReportFormBottomSheet> createState() => _ReportFormBottomSheetState();
}

class _ReportFormBottomSheetState extends State<ReportFormBottomSheet>
    with SingleTickerProviderStateMixin {
  ReportType? selectedType;
  final _formKey = GlobalKey<FormState>();

  // Controllers
  final TextEditingController _infoController = TextEditingController();
  final TextEditingController _imageUrlController = TextEditingController();
  final userSession = UserSession();
  bool _isPotable = false;
  Potability potability = Potability.unknown;

  @override
  void dispose() {
    _infoController.dispose();
    _imageUrlController.dispose();
    super.dispose();
  }

  Widget _buildTypeButton(BuildContext context, ReportType type) {
    IconData icon;
    switch (type) {
      case ReportType.wrongInformation:
        icon = Icons.edit_note;
        break;
      case ReportType.wrongImage:
        icon = Icons.image_outlined;
        break;
      case ReportType.wrongPotability:
        icon = Icons.water_drop_outlined;
        break;
      case ReportType.nonExistentFontanella:
        icon = Icons.delete_forever_outlined;
        break;
    }

    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: () => setState(() => selectedType = type),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.grey.withOpacity(0.3), width: 1),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 6,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Row(
          children: [
            Icon(icon, color: Theme.of(context).primaryColor, size: 28),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                type.translationKey.tr(),
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ),
            const Icon(Icons.arrow_forward_ios, size: 18),
          ],
        ),
      ),
    );
  }

  Widget _buildSubForm(BuildContext context) {
    switch (selectedType!) {
      case ReportType.wrongInformation:
        return TextFormField(
          controller: _infoController,
          style: TextStyle(color: Theme.of(context).colorScheme.onSurface),
          decoration: const InputDecoration(
            labelText: "Nuovo nome/fontanella",
            border: OutlineInputBorder(),
          ),
          validator:
              (value) =>
                  value == null || value.isEmpty ? "Inserisci un valore" : null,
        );

      case ReportType.wrongImage:
        return TextFormField(
          controller: _imageUrlController,
          decoration: const InputDecoration(
            labelText: "URL nuova immagine",
            border: OutlineInputBorder(),
          ),
          validator:
              (value) =>
                  value == null || value.isEmpty
                      ? "Inserisci un URL valido"
                      : null,
        );

      case ReportType.wrongPotability:
        final theme = Theme.of(context);
        return Row(
          spacing: 15,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children:
              Potability.values.map((p) {
                Color color;
                IconData icon;
                String label;

                switch (p) {
                  case Potability.potable:
                    color = Colors.lightBlue;
                    icon = Icons.invert_colors;
                    label = 'drinking_fountain.potable'.tr();
                    break;
                  case Potability.notPotable:
                    color = Colors.orange;
                    icon = Icons.invert_colors_off;
                    label = 'drinking_fountain.not_potable'.tr();
                    break;
                  case Potability.unknown:
                    color = Colors.grey;
                    icon = Icons.invert_colors;
                    label = 'drinking_fountain.unknown'.tr();
                    break;
                }

                final bool selected = potability == p;

                return Expanded(
                  child: InkWell(
                    onTap: () {
                      setState(() => potability = p);
                    },
                    borderRadius: BorderRadius.circular(8),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 6),
                      decoration: BoxDecoration(
                        color:
                            selected
                                ? color.withOpacity(0.2)
                                : theme.inputDecorationTheme.fillColor ??
                                    Colors.white,
                        border: Border.all(
                          color:
                              theme
                                  .inputDecorationTheme
                                  .enabledBorder
                                  ?.borderSide
                                  .color ??
                              Colors.grey,
                        ),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Icon(icon, color: color),
                          const SizedBox(height: 4),
                          Text(
                            label,
                            softWrap: true,
                            overflow: TextOverflow.visible,
                            textAlign: TextAlign.center,
                            style: theme.textTheme.bodyMedium,
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              }).toList(),
        );

      case ReportType.nonExistentFontanella:
        return const Padding(
          padding: EdgeInsets.all(8.0),
          child: Text(
            "Segnalerai che questa fontanella non esiste più.",
            style: TextStyle(fontStyle: FontStyle.italic),
          ),
        );
    }
  }

  Future<void> _submit() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    final url = Uri.parse('${dotenv.env['API_URL']}/reports');

    String? description;
    String? imageUrl;
    String? value;

    switch (selectedType!) {
      case ReportType.wrongInformation:
        value = _infoController.text;
        break;

      case ReportType.wrongImage:
        imageUrl = _imageUrlController.text;
        break;

      case ReportType.wrongPotability:
        value = potability.index.toString();
        break;

      case ReportType.nonExistentFontanella:
        value = "Fontanella inesistente";
        break;
    }

    final body = {
      "fontanellaId": widget.fontanellaId,
      "type": selectedType!.index,
      "value": value,
      "imageUrl": imageUrl,
      "description": description,
    };

    try {
      final response = await http.post(
        url,
        headers: {
          'Authorization': 'Bearer ${userSession.token}',
          'Content-Type': 'application/json',
        },
        body: jsonEncode(body),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        if (!mounted) return;
        showMinimalNotification(
          context,
          message: 'report.correct_submit'.tr(),
          duration: 2500,
          position: 'bottom',
          backgroundColor: Colors.green,
        );
        Navigator.pop(context);
      } else {
        if (!mounted) return;
        showMinimalNotification(
          context,
          message: 'errors.save'.tr(),
          duration: 2500,
          position: 'bottom',
          backgroundColor: Colors.green,
        );
      }
    } catch (e) {
      if (!mounted) return;
      showMinimalNotification(
        context,
        message: 'errors.network_error'.tr(),
        duration: 2500,
        position: 'bottom',
        backgroundColor: Colors.green,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.7,
      minChildSize: 0.4,
      maxChildSize: 0.95,
      expand: false,
      builder: (context, scrollController) {
        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Theme.of(context).scaffoldBackgroundColor,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Form(
            key: _formKey,
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 250),
              transitionBuilder: (child, animation) {
                final offsetAnimation = Tween<Offset>(
                  begin: const Offset(1.0, 0.0),
                  end: Offset.zero,
                ).animate(animation);
                return SlideTransition(position: offsetAnimation, child: child);
              },
              child:
                  selectedType == null
                      ? ListView(
                        key: const ValueKey("typeList"),
                        controller: scrollController,
                        children: [
                          const Text(
                            "Seleziona il tipo di report",
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 12),
                          ...ReportType.values
                              .map(
                                (type) => Padding(
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 6,
                                  ),
                                  child: _buildTypeButton(context, type),
                                ),
                              )
                              .toList(),
                          const SizedBox(height: 8),
                          Text(
                            'report.info_message'.tr(),
                            style: TextStyle(
                              fontSize: 16,
                              fontStyle: FontStyle.italic,
                              color: Colors.grey,
                            ),
                          ),
                        ],
                      )
                      : ListView(
                        key: const ValueKey("subForm"),
                        controller: scrollController,
                        children: [
                          Row(
                            children: [
                              IconButton(
                                icon: const Icon(Icons.arrow_back),
                                onPressed: () {
                                  setState(() {
                                    selectedType = null;
                                  });
                                },
                              ),
                              Text(
                                selectedType!.translationKey.tr(),
                                style: Theme.of(context).textTheme.headlineSmall
                                    ?.copyWith(fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          _buildSubForm(context),
                          const SizedBox(height: 24),
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: _submit,
                              style: ElevatedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 16,
                                ),
                              ),
                              child: const Text("Invia Report"),
                            ),
                          ),
                        ],
                      ),
            ),
          ),
        );
      },
    );
  }
}
