import 'package:flutter/material.dart';
import 'package:application/enum/report_type_enum.dart';

class ReportFormBottomSheet extends StatefulWidget {
  const ReportFormBottomSheet({Key? key}) : super(key: key);

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
  bool _isPotable = false;

  @override
  void dispose() {
    _infoController.dispose();
    _imageUrlController.dispose();
    super.dispose();
  }

  /// STEP 1 → lista bottoni tipi
  Widget _buildTypeButton(BuildContext context, ReportType type) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
      onPressed: () {
        setState(() {
          selectedType = type;
        });
      },
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(type.name, style: const TextStyle(fontSize: 16)),
          const Icon(Icons.arrow_forward_ios, size: 18),
        ],
      ),
    );
  }

  /// STEP 2 → form specifico in base al tipo scelto
  Widget _buildSubForm(BuildContext context) {
    switch (selectedType!) {
      case ReportType.wrongInformation:
        return TextFormField(
          controller: _infoController,
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
        return SwitchListTile(
          title: const Text("È potabile?"),
          value: _isPotable,
          onChanged: (val) => setState(() => _isPotable = val),
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

  void _submit() {
    if (_formKey.currentState?.validate() ?? false) {
      debugPrint("Tipo: $selectedType");
      debugPrint("Info: ${_infoController.text}");
      debugPrint("Image: ${_imageUrlController.text}");
      debugPrint("Potabile: $_isPotable");
      Navigator.pop(context);
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
                      // STEP 1 → lista bottoni
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
                        ],
                      )
                      // STEP 2 → form dettagliato
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
                                selectedType!.name,
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
