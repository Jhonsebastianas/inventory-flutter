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
  RegisterClient? currentClient;

  AddClientForm({Key? key, required this.onClientUpdated, this.currentClient})
      : super(key: key);

  @override
  _AddClientFormState createState() => _AddClientFormState();
}

class _AddClientFormState extends State<AddClientForm> {
  final _formKey = GlobalKey<FormState>();
  bool _isClientFound = false;
  bool _isLoading = false;
  bool _existsSearch = false;

  late RegisterClient _currentClient;

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
    _currentClient = widget.currentClient ?? RegisterClient();
    _currentClient.identification ??= IdentificationDocumentDTO();
    _currentClient.identification!.type ??= TypeIdentificationDTO();
    _currentClient.contact ??= ContactDTO();

    // Actualizar campos con datos del cliente actual
    _idNumberController.text = _currentClient.identification?.value ?? '';
    _namesController.text = _currentClient.names ?? '';
    _lastNamesController.text = _currentClient.lastnames ?? '';
    _emailController.text = _currentClient.contact?.email ?? '';
  }

  void _checkClient() async {
    final idType = selectedDocumentType ?? "";
    final idNumber = _idNumberController.text;

    if (idType.isNotEmpty && idNumber.isNotEmpty) {
      setState(() => _isLoading = true);

      final clientService = ClientService();
      final clientData =
          await clientService.findClientByIdentification(idType, idNumber);

      setState(() {
        _isLoading = false;
        _existsSearch = true;
      });

      if (clientData != null) {
        setState(() {
          _isClientFound = true;
          // Actualizar los datos del cliente con los encontrados
          _namesController.text = clientData.names ?? '';
          _lastNamesController.text = clientData.lastnames ?? '';
          _emailController.text = clientData.contact?.email ?? '';
          _currentClient = clientData;
        });
        widget.onClientUpdated(
            clientData); // Actualiza el cliente en el widget principal
      } else {
        // Si no lo encontramos, lo consideramos como nuevo cliente
        setState(() {
          _isClientFound = false;
          _currentClient.identification?.value = _idNumberController.text;
          _clearClientFields();
        });
        widget.onClientUpdated(
            _currentClient); // Actualiza el cliente vacío en el widget principal
      }
    }
  }

  void _saveClient() {
    if (_formKey.currentState!.validate()) {
      // Actualizar datos del cliente antes de pasarlos al padre
      _currentClient.names = _namesController.text;
      _currentClient.lastnames = _lastNamesController.text;
      _currentClient.contact?.email = _emailController.text;
      _currentClient.identification?.value = _idNumberController.text;

      // Si el cliente no ha sido encontrado, es un nuevo cliente, lo agregamos al padre
      if (!_isClientFound) {
        widget.onClientUpdated(
            _currentClient); // Actualiza el cliente en el widget principal
      }

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

  void _updateParentClient() {
    _currentClient
      ..names = _namesController.text
      ..lastnames = _lastNamesController.text
      ..contact?.email = _emailController.text
      ..identification?.value = _idNumberController.text;

    widget.onClientUpdated(_currentClient);
  }

  String? _validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'El correo electrónico es obligatorio';
    }
    final emailRegex = RegExp(r'^[^@]+@[^@]+\.[^@]+$');
    if (!emailRegex.hasMatch(value)) {
      return 'Por favor, introduce un correo electrónico válido';
    }
    return null;
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
                      child: CustomDropdownOur(
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
                        onChanged: (value) => _updateParentClient(),
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
                          validator: (value) => value == null || value.isEmpty
                              ? 'Los nombres son obligatorios'
                              : null,
                          onChanged: (value) => _updateParentClient(),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: CustomTextField(
                          controller: _lastNamesController,
                          label: 'Apellidos',
                          validator: (value) => value == null || value.isEmpty
                              ? 'Los apellidos son obligatorios'
                              : null,
                          enabled: !_isClientFound,
                          onChanged: (value) => _updateParentClient(),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  CustomTextField(
                    controller: _emailController,
                    label: 'Email',
                    validator: _validateEmail,
                    enabled: !_isClientFound,
                    onChanged: (value) => _updateParentClient(),
                  ),
                  const SizedBox(height: 20),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
