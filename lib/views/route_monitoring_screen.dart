import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:bitacora_busmen/core/services/route_service.dart';
import 'package:bitacora_busmen/core/services/auth_service.dart';
import 'package:bitacora_busmen/core/services/user_session.dart';
import 'package:bitacora_busmen/core/constants/api_config.dart';
import 'package:bitacora_busmen/models/route_monitoring_model.dart';
import 'package:bitacora_busmen/models/shift_model.dart';

class RouteMonitoringScreen extends StatefulWidget {
  const RouteMonitoringScreen({super.key});

  @override
  State<RouteMonitoringScreen> createState() => _RouteMonitoringScreenState();
}

class _RouteMonitoringScreenState extends State<RouteMonitoringScreen> {
  final RouteService _routeService = RouteService();
  late Future<List<RouteMonitoringModel>> _routesFuture;
  DateTime _selectedDate = DateTime.now();
  List<ShiftModel> _availableShifts = [];
  ShiftModel? _selectedShift;
  bool _isLoadingShifts = true;
  String _companyName = '';

  @override
  void initState() {
    super.initState();
    _companyName = UserSession().getCompanyData()?.nombre ?? '';
    _routesFuture = _loadData();
    _loadShifts().then((_) {
      _refreshData();
    });
  }

  Future<void> _loadShifts() async {
    setState(() => _isLoadingShifts = true);
    final shifts = await _routeService.fetchShifts(ApiConfig.empresa);
    setState(() {
      _availableShifts = shifts;
      _isLoadingShifts = false;
      if (_availableShifts.isNotEmpty) {
        _selectedShift = _getClosestShift(_availableShifts);
      }
    });
  }

  ShiftModel _getClosestShift(List<ShiftModel> shifts) {
    final now = DateTime.now();
    final currentMinutes = now.hour * 60 + now.minute;

    ShiftModel? closest;
    int minDiff = 1440; // Max minutes in a day

    for (final shift in shifts) {
      final parts = shift.turnoRuta.split(':');
      if (parts.length >= 2) {
        final shiftHour = int.tryParse(parts[0]) ?? 0;
        final shiftMin = int.tryParse(parts[1]) ?? 0;
        final shiftMinutes = shiftHour * 60 + shiftMin;

        int diff = (shiftMinutes - currentMinutes).abs();
        // Handle wraparound if necessary (though usually closest in absolute terms is fine)
        if (diff < minDiff) {
          minDiff = diff;
          closest = shift;
        }
      }
    }

    return closest ?? shifts.first;
  }

  void _refreshData() {
    setState(() {
      _routesFuture = _loadData();
    });
  }

  Future<List<RouteMonitoringModel>> _loadData() async {
    // 1. Fetch routes
    final routes = await _routeService.fetchRoutes(date: _selectedDate);

    // 2. Fetch population if shift is selected
    if (_selectedShift != null) {
      final fechaStr = DateFormat('yyyy-MM-dd').format(_selectedDate);
      final population = await _routeService.fetchPopulationData(
        ApiConfig.empresa,
        fechaStr,
        _selectedShift!.turnoRuta,
      );

      // 3. Sync data
      for (var route in routes) {
        final popData = population.firstWhere(
          (p) => 
            (p['clave_ruta']?.toString() == route.claveRuta && p['clave']?.toString() == route.unidad) ||
            (p['id']?.toString() == route.id.toString() && route.id != 0),
          orElse: () => <String, dynamic>{},
        );
        
        if (popData.isNotEmpty) {
          route.id = int.tryParse(popData['id']?.toString() ?? '0') ?? 0;
          route.poblacion = (popData['poblacion'] ?? popData['nom_col'] ?? '').toString();
          route.arriboPlanta = (popData['hora'] ?? popData['arribo_planta'] ?? '').toString();
        }
      }
    }

    return routes;
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2024),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: ThemeData.light().copyWith(
            primaryColor: const Color(0xFF1A237E),
            colorScheme: const ColorScheme.light(primary: Color(0xFF1A237E)),
            buttonTheme: const ButtonThemeData(textTheme: ButtonTextTheme.primary),
          ),
          child: child!,
        );
      },
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
        _refreshData();
      });
    }
  }

  String _formatDateInSpanish(DateTime date) {
    final days = ['Domingo', 'Lunes', 'Martes', 'Miércoles', 'Jueves', 'Viernes', 'Sábado'];
    final months = [
      'enero',
      'febrero',
      'marzo',
      'abril',
      'mayo',
      'junio',
      'julio',
      'agosto',
      'septiembre',
      'octubre',
      'noviembre',
      'diciembre'
    ];
    // weekday: 1 (Lunes) to 7 (Domingo)
    final dayName = days[date.weekday % 7];
    final monthName = months[date.month - 1];
    return '$dayName, ${date.day} de $monthName de ${date.year}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF0F2F5),
      appBar: AppBar(
        title: Column(
          children: [
            const Text(
              'Mis Rutas',
              style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white, fontSize: 18),
            ),
            if (_companyName.isNotEmpty)
              Text(
                _companyName,
                style: const TextStyle(fontSize: 12, color: Colors.white70, fontWeight: FontWeight.normal),
              ),
          ],
        ),
        centerTitle: true,
        backgroundColor: const Color(0xFF1A237E),
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white),
            onPressed: _refreshData,
          ),
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.white),
            onPressed: () async {
              await AuthService().logout();
              if (context.mounted) {
                Navigator.of(context).pushNamedAndRemoveUntil('/login', (route) => false);
              }
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            color: Colors.white,
            child: Column(
              children: [
                Text(
                  'Fecha seleccionada',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                    fontWeight: FontWeight.w500,
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  _formatDateInSpanish(_selectedDate),
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1A237E),
                  ),
                ),
                const SizedBox(height: 16),
                ElevatedButton.icon(
                  onPressed: () => _selectDate(context),
                  icon: const Icon(Icons.edit_calendar, size: 18),
                  label: const Text('CAMBIAR FECHA'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFE8EAF6),
                    foregroundColor: const Color(0xFF1A237E),
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ],
            ),
          ),
          if (_isLoadingShifts)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 10),
              child: LinearProgressIndicator(minHeight: 2),
            )
          else if (_availableShifts.isNotEmpty)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              color: Colors.white,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Turno / Horario',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 8),
                  DropdownButtonFormField<ShiftModel>(
                    value: _selectedShift,
                    decoration: InputDecoration(
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: Colors.grey[300]!),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: Colors.grey[300]!),
                      ),
                      prefixIcon: Icon(
                        _selectedShift?.isEntrada == true ? Icons.login : Icons.logout,
                        color: _selectedShift?.isEntrada == true ? Colors.green : Colors.orange,
                        size: 20,
                      ),
                    ),
                    items: _availableShifts.map((shift) {
                      return DropdownMenuItem(
                        value: shift,
                        child: Row(
                          children: [
                            Text(
                              shift.turnoRuta.substring(0, 5),
                              style: const TextStyle(fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                              decoration: BoxDecoration(
                                color: shift.isEntrada ? Colors.green.withValues(alpha: 0.1) : Colors.orange.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                shift.direccionRuta,
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                  color: shift.isEntrada ? Colors.green[700] : Colors.orange[700],
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                      onChanged: (val) {
                        setState(() {
                          _selectedShift = val;
                          _refreshData();
                        });
                      },
                      isExpanded: true,
                    ),
                  ],
                ),
              ),
            const Divider(height: 1, color: Color(0xFFEEEEEE)),
            Expanded(
              child: FutureBuilder<List<RouteMonitoringModel>>(
                future: _routesFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  } else if (snapshot.hasError) {
                    return _buildErrorState(snapshot.error.toString());
                  } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return _buildEmptyState();
                  }

                  return ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: snapshot.data!.length,
                    itemBuilder: (context, index) {
                      return RouteCard(
                        route: snapshot.data![index],
                        selectedDate: _selectedDate,
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.directions_bus_outlined, size: 64, color: Colors.grey[400]),
          const SizedBox(height: 16),
          Text(
            'No hay rutas asignadas',
            style: TextStyle(color: Colors.grey[600], fontSize: 18),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(String error) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 64, color: Colors.redAccent),
            const SizedBox(height: 16),
            Text(
              'Ocurrió un error',
              style: TextStyle(color: Colors.grey[800], fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              error,
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey[600]),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _refreshData,
              child: const Text('Reintentar'),
            ),
          ],
        ),
      ),
    );
  }
}

class RouteCard extends StatefulWidget {
  final RouteMonitoringModel route;
  final DateTime selectedDate;

  const RouteCard({
    super.key,
    required this.route,
    required this.selectedDate,
  });

  @override
  State<RouteCard> createState() => _RouteCardState();
}

class _RouteCardState extends State<RouteCard> {
  bool _hasError = false;
  bool _isSaving = false;
  final TextEditingController _poblacionController = TextEditingController();
  final TextEditingController _arriboController = TextEditingController();
  final RouteService _routeService = RouteService();

  @override
  void initState() {
    super.initState();
    _poblacionController.text = widget.route.poblacion;
    _arriboController.text = widget.route.arriboPlanta;
  }

  @override
  void didUpdateWidget(covariant RouteCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.route.poblacion != widget.route.poblacion) {
      _poblacionController.text = widget.route.poblacion;
    }
    if (oldWidget.route.arriboPlanta != widget.route.arriboPlanta) {
      _arriboController.text = widget.route.arriboPlanta;
    }
  }

  Future<void> _saveData() async {
    if (_isSaving) return;
    
    setState(() {
      _isSaving = true;
      _hasError = false;
    });

    try {
      final fechaStr = DateFormat('yyyy-MM-dd').format(widget.selectedDate);
      
      final data = {
        'unidad': widget.route.unidad,
        'clave_ruta': widget.route.claveRuta,
        'nom_col': _poblacionController.text, // Poblacion
        'hora': _arriboController.text, // Arrival Time
        'fecha_asignacion': fechaStr,
      };

      final success = await _routeService.savePopulationData(
        ApiConfig.empresa,
        widget.route.id,
        data,
      );

      if (mounted) {
        if (success) {
          setState(() {
            widget.route.poblacion = _poblacionController.text;
            widget.route.arriboPlanta = _arriboController.text;
            _hasError = false;
          });
        } else {
          setState(() => _hasError = true);
        }
      }
    } catch (e) {
      debugPrint('Error saving population: $e');
      if (mounted) {
        setState(() => _hasError = true);
      }
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: _hasError ? Colors.red[50] : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: _hasError ? Colors.red[300]! : Colors.transparent,
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: _hasError ? Colors.red[100] : const Color(0xFFE8EAF6),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                _hasError ? Icons.error_outline : Icons.directions_bus_filled_rounded,
                color: _hasError ? Colors.red[700] : const Color(0xFF1A237E),
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              flex: 3,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.route.ruta,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1A237E),
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'Unidad: ${widget.route.unidad}',
                    style: TextStyle(
                      fontSize: 11,
                      color: Colors.grey[600],
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            if (_isSaving)
              const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
            else if (_hasError)
              IconButton(
                icon: const Icon(Icons.refresh, color: Colors.red),
                onPressed: _saveData,
                constraints: const BoxConstraints(),
                padding: EdgeInsets.zero,
                iconSize: 24,
              ),
            const SizedBox(width: 8),
            SizedBox(
              width: 55,
              child: TextField(
                controller: _poblacionController,
                keyboardType: TextInputType.number,
                textAlign: TextAlign.center,
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                decoration: InputDecoration(
                  hintText: 'Pob',
                  contentPadding: const EdgeInsets.symmetric(vertical: 8),
                  isDense: true,
                  filled: true,
                  fillColor: Colors.grey[100],
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide.none,
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: const BorderSide(color: Color(0xFF1A237E), width: 1.5),
                  ),
                ),
                onSubmitted: (_) => _saveData(),
              ),
            ),
            const SizedBox(width: 4),
            SizedBox(
              width: 55,
              child: TextField(
                controller: _arriboController,
                keyboardType: TextInputType.datetime,
                textAlign: TextAlign.center,
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                decoration: InputDecoration(
                  hintText: 'Hora',
                  contentPadding: const EdgeInsets.symmetric(vertical: 8),
                  isDense: true,
                  filled: true,
                  fillColor: Colors.grey[100],
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide.none,
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: const BorderSide(color: Color(0xFF1A237E), width: 1.5),
                  ),
                ),
                onSubmitted: (_) => _saveData(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _poblacionController.dispose();
    _arriboController.dispose();
    super.dispose();
  }
}
