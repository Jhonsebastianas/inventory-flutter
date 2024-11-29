import 'package:flutter/material.dart';
import 'package:hola_mundo/modules/clients/models/register_client.dart';
import 'package:hola_mundo/shared/models/contact_dto.dart';
import 'package:hola_mundo/shared/models/identification_document_dto.dart';
import 'package:hola_mundo/shared/models/type_identification_dto.dart';
import 'package:hola_mundo/shared/services/client_service.dart';
import 'package:hola_mundo/shared/widgets/custom_dropdown.dart';
import 'package:hola_mundo/shared/widgets/forms/text_fields/custom_text_field.dart';

class AddClientForm extends StatefulWidget {
  final Function(RegisterClient)
      onClientUpdated; // Callback para devolver datos

  const AddClientForm({Key? key, required this.onClientUpdated})
      : super(key: key);

  @override
  _AddClientFormState createState() => _AddClientFormState();
}

class _AddClientFormState extends State<AddClientForm> {
  final _formKey = GlobalKey<FormState>();
  bool _isClientFound = false;
  bool _isLoading = false;

  RegisterClient? _currentClient; // Instancia del cliente actual

  String? selectedDocumentType = '1';

  TextEditingController _idNumberController = TextEditingController();
  TextEditingController _namesController = TextEditingController();
  TextEditingController _lastNamesController = TextEditingController();
  TextEditingController _emailController = TextEditingController();
  // Agregar otros controladores para más campos si es necesario

  @override
  void initState() {
    super.initState();
    _currentClient = RegisterClient();
    _currentClient!.identification = IdentificationDocumentDTO();
    _currentClient!.identification!.type = TypeIdentificationDTO();
    _currentClient!.contact = ContactDTO();
  }

  void _checkClient() async {
    final idType = selectedDocumentType ?? "";
    final idNumber = _idNumberController.text;
    print('Me mostrare');

    if (idType.isNotEmpty && idNumber.isNotEmpty) {
      setState(() => _isLoading = true);
      ClientService clientService = new ClientService();

      final clientData =
          await clientService.findClientByIdentification(idType, idNumber);

      setState(() => _isLoading = false);

      if (clientData != null) {
        setState(() {
          _isClientFound = true;
          _namesController.text = clientData.names ?? '';
          _lastNamesController.text = clientData.lastnames ?? '';
          _emailController.text = clientData.contact?.email ?? '';
          // Completa con más campos si es necesario
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

  // Método para actualizar el cliente actual y notificar al padre
  void _updateClientField(String field, String value) {
    print('Se acutalizo el: ${field} ${value}');
    print(_currentClient);
    setState(() {
      switch (field) {
        case 'numberIdentification':
          _currentClient!.identification?.value = value;
          break;
        case 'idType':
          _currentClient!.identification?.type?.id = value;
          break;
        case 'names':
          _currentClient!.names = value;
          break;
        case 'lastnames':
          _currentClient!.lastnames = value;
          break;
        case 'email':
          _currentClient!.contact?.email = value;
          break;
      }
    });
    print('Se acutalizo el: ${_currentClient}');
    widget.onClientUpdated(_currentClient!); // Notifica al widget padre
  }

  void _clearClientFields() {
    _namesController.clear();
    _lastNamesController.clear();
    _emailController.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
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
                    setState(() {
                      selectedDocumentType = value;
                    });
                    _updateClientField('idType', value ?? '1');
                  },
                  // Manejo del valor nulo
                  hint: 'Seleccione un tipo',
                ),
              ),
              const SizedBox(width: 3),
              Expanded(
                child: CustomTextField(
                  controller: _idNumberController,
                  label: 'Número de Identificación',
                  onChanged: (value) =>
                      _updateClientField('numberIdentification', value),
                  onEditingComplete:
                      _checkClient, // Verifica el cliente al finalizar la edición
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          if (_isLoading) CircularProgressIndicator(),
          Row(
            children: [
              Expanded(
                child: CustomTextField(
                  label: 'Nombres',
                  enabled: !_isClientFound, // Bloquear si el cliente existe
                  onChanged: (value) => _updateClientField('names', value),
                ),
              ),
              const SizedBox(width: 3),
              Expanded(
                child: CustomTextField(
                  controller: _lastNamesController,
                  label: 'Apellidos',
                  enabled: !_isClientFound,
                  onChanged: (value) => _updateClientField('lastnames', value),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          CustomTextField(
            controller: _emailController,
            label: 'Email',
            enabled: !_isClientFound,
            onChanged: (value) => _updateClientField('email', value),
          ),
          // ElevatedButton(
          //   onPressed: () {
          //     if (_formKey.currentState!.validate()) {
          //       // Procesar el formulario para enviar datos del cliente
          //     }
          //   },
          //   child: Text('Registrar Cliente'),
          // ),
        ],
      ),
    );
  }
}
