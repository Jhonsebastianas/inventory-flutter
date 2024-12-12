import 'package:flutter/material.dart';
import 'package:hola_mundo/modules/clients/models/register_client.dart';
import 'package:hola_mundo/shared/models/contact_dto.dart';
import 'package:hola_mundo/shared/models/identification_document_dto.dart';
import 'package:hola_mundo/shared/models/type_identification_dto.dart';
import 'package:hola_mundo/shared/services/client_service.dart';
import 'package:hola_mundo/shared/widgets/custom_button.dart';
import 'package:hola_mundo/shared/widgets/custom_dropdown.dart';
import 'package:hola_mundo/shared/widgets/forms/text_fields/custom_text_field.dart';

class AddClientForm extends StatefulWidget {
  final Function(RegisterClient) onClientUpdated;

  const AddClientForm({Key? key, required this.onClientUpdated})
      : super(key: key);

  @override
  _AddClientFormState createState() => _AddClientFormState();
}

class _AddClientFormState extends State<AddClientForm> {
  final _formKey = GlobalKey<FormState>();
  bool _isClientFound = false;
  bool _isLoading = false;

  RegisterClient? _currentClient;

  String? selectedDocumentType = '1';
  TextEditingController _idNumberController = TextEditingController();
  TextEditingController _namesController = TextEditingController();
  TextEditingController _lastNamesController = TextEditingController();
  TextEditingController _emailController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _initializeClient();
  }

  void _initializeClient() {
    _currentClient = RegisterClient();
    _currentClient!.identification = IdentificationDocumentDTO();
    _currentClient!.identification!.type = TypeIdentificationDTO();
    _currentClient!.contact = ContactDTO();
  }

  void _checkClient() async {
    final idType = selectedDocumentType ?? "";
    final idNumber = _idNumberController.text;

    if (idType.isNotEmpty && idNumber.isNotEmpty) {
      setState(() => _isLoading = true);

      final clientService = ClientService();
      final clientData =
          await clientService.findClientByIdentification(idType, idNumber);

      setState(() => _isLoading = false);

      if (clientData != null) {
        setState(() {
          _isClientFound = true;
          _namesController.text = clientData.names ?? '';
          _lastNamesController.text = clientData.lastnames ?? '';
          _emailController.text = clientData.contact?.email ?? '';
          _currentClient = clientData;
        });
        widget.onClientUpdated(clientData);
      } else {
        setState(() {
          _isClientFound = false;
          _clearClientFields();
        });
      }
    }
  }

  void _saveClient() {
    if (_formKey.currentState!.validate()) {
      // Simulación de guardado en backend
      widget.onClientUpdated(_currentClient!);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Cliente guardado exitosamente')),
      );
    }
  }

  void _clearClientFields() {
    _namesController.clear();
    _lastNamesController.clear();
    _emailController.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 3,
      margin: const EdgeInsets.all(0),
      child: Padding(
        padding: const EdgeInsets.all(4),
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: CustomDropdown(
                        label: 'Tipo documento',
                        value: selectedDocumentType,
                        items: const [
                          DropdownMenuItem(
                            value: '1',
                            child: Text('CC - Cédula'),
                          ),
                        ],
                        onChanged: (value) {
                          setState(() => selectedDocumentType = value);
                        },
                        hint: 'Seleccione un tipo',
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: CustomTextField(
                        controller: _idNumberController,
                        label: 'Número de Identificación',
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                CustomButton(
                  text: 'Buscar',
                  type: ButtonType.outline,
                  onPressed: _isLoading ? null : _checkClient,
                  minimumSize: const Size(double.infinity, 48),
                ),
                const SizedBox(height: 20),
                if (_isClientFound || !_isClientFound) ...[
                  Row(
                    children: [
                      Expanded(
                        child: CustomTextField(
                          controller: _namesController,
                          label: 'Nombres',
                          enabled: !_isClientFound,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: CustomTextField(
                          controller: _lastNamesController,
                          label: 'Apellidos',
                          enabled: !_isClientFound,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  CustomTextField(
                    controller: _emailController,
                    label: 'Email',
                    enabled: !_isClientFound,
                  ),
                  const SizedBox(height: 20),
                  if (!_isClientFound)
                    ElevatedButton(
                      onPressed: _saveClient,
                      child: const Text('Guardar'),
                    ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
