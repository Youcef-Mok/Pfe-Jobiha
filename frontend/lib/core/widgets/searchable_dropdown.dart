import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:job_app/core/utils/icon_utils.dart';

class SearchableDropdown extends StatefulWidget {
  final String? value;
  final String placeholder;
  final List<String> items;
  final ValueChanged<String?> onChanged;
  final String? label;
  final IconData? icon;
  final double? heightFactor;
  final bool isSelected; // Nouveau paramètre pour indiquer si une valeur est sélectionnée
  final bool showSectorIcon; // Afficher l'icône du secteur pour les sociétés
  final bool showGraduationIcon; // Afficher l'icône de graduation pour les établissements

  const SearchableDropdown({
    super.key,
    required this.value,
    required this.placeholder,
    required this.items,
    required this.onChanged,
    this.label,
    this.icon,
    this.heightFactor,
    this.isSelected = false,
    this.showSectorIcon = false,
    this.showGraduationIcon = false,
  });

  @override
  State<SearchableDropdown> createState() => _SearchableDropdownState();
}

// Fonction helper pour obtenir l'icône selon le secteur de l'entreprise
IconData _getCompanySectorIcon(String companyName) {
  // Mapping des entreprises algériennes par secteur
  const techCompanies = ['Condor Electronics', 'Iris', 'Algérie Télécom'];
  const energyCompanies = ['Sonatrach', 'Sonelgaz'];
  const foodCompanies = ['Cevital', 'Danone Djurdjura', 'Tchin-Tchin', 'Ifri', 'Hamoud Boualem', 'Laiterie Soummam'];
  const transportCompanies = ['Air Algérie'];
  const industrialCompanies = ['ENIEM', 'Cosider', 'Tonic Industrie'];
  const pharmaCompanies = ['Saidal'];
  const retailCompanies = ['Groupe Benamor', 'Groupe Sim', 'Groupe Benhamadi', 'Groupe Amor Benamor'];

  if (techCompanies.contains(companyName)) {
    return Icons.computer;
  } else if (energyCompanies.contains(companyName)) {
    return Icons.bolt;
  } else if (foodCompanies.contains(companyName)) {
    return Icons.restaurant;
  } else if (transportCompanies.contains(companyName)) {
    return Icons.flight;
  } else if (industrialCompanies.contains(companyName)) {
    return Icons.factory;
  } else if (pharmaCompanies.contains(companyName)) {
    return Icons.medical_services;
  } else if (retailCompanies.contains(companyName)) {
    return Icons.shopping_bag;
  }
  
  // Icône par défaut
  return Icons.business;
}

class _SearchableDropdownState extends State<SearchableDropdown> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _showDropdown() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _DropdownSheet(
        items: widget.items,
        onSelected: (value) {
          widget.onChanged(value);
          Navigator.pop(context);
        },
        placeholder: widget.placeholder,
        heightFactor: widget.heightFactor,
        showSectorIcon: widget.showSectorIcon,
        showGraduationIcon: widget.showGraduationIcon,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bool hasValue = widget.value != null && widget.value!.isNotEmpty;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (widget.label != null) ...[
          Padding(
            padding: const EdgeInsets.only(bottom: 8, left: 4),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  widget.label!,
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF6B7280),
                  ),
                ),
              ],
            ),
          ),
        ],
        GestureDetector(
          onTap: _showDropdown,
          child: Container(
            height: 48,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              color: const Color(0xFFF8FAFC),
              border: Border.all(
                color: hasValue ? const Color(0xFF401E66) : const Color(0xFFE2E8F0),
                width: hasValue ? 1 : 1, // Bordure plus fine
              ),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Row(
                    children: [
                      if (hasValue && (widget.showSectorIcon || widget.showGraduationIcon)) ...[
                        Container(
                          width: 20,
                          height: 20,
                          decoration: const BoxDecoration(
                            color: Color(0xFF401E66),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            widget.showGraduationIcon 
                                ? Icons.school 
                                : _getCompanySectorIcon(widget.value!),
                            size: 11,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(width: 8),
                      ] else if (hasValue && widget.icon != null) ...[
                        Container(
                          width: 20,
                          height: 20,
                          decoration: const BoxDecoration(
                            color: Color(0xFF401E66),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            IconUtils.getSmartIcon(widget.value!),
                            size: 11,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(width: 8),
                      ],
                      Expanded(
                        child: Text(
                          widget.value ?? widget.placeholder,
                          style: GoogleFonts.inter(
                            fontSize: 16,
                            color: hasValue ? const Color(0xFF401E66) : const Color(0xFF475569),
                            fontWeight: hasValue ? FontWeight.w500 : FontWeight.w400,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons.expand_more, 
                  color: hasValue ? const Color(0xFF401E66) : const Color(0xFF401E66),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _DropdownSheet extends StatefulWidget {
  final List<String> items;
  final ValueChanged<String> onSelected;
  final String placeholder;
  final double? heightFactor;
  final bool showSectorIcon;
  final bool showGraduationIcon;

  const _DropdownSheet({
    required this.items,
    required this.onSelected,
    required this.placeholder,
    this.heightFactor,
    this.showSectorIcon = false,
    this.showGraduationIcon = false,
  });

  @override
  State<_DropdownSheet> createState() => _DropdownSheetState();
}

class _DropdownSheetState extends State<_DropdownSheet> {
  final TextEditingController _searchController = TextEditingController();
  final TextEditingController _manualInputController = TextEditingController();
  List<String> _filteredItems = [];

  @override
  void initState() {
    super.initState();
    _filteredItems = widget.items;
    _searchController.addListener(_filterItems);
  }

  @override
  void dispose() {
    _searchController.dispose();
    _manualInputController.dispose();
    super.dispose();
  }

  void _filterItems() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      _filteredItems = widget.items
          .where((item) => item.toLowerCase().contains(query))
          .toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    final heightFactor = widget.heightFactor ?? 0.7;
    return Container(
      height: MediaQuery.of(context).size.height * heightFactor,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: [
          // Header avec barre de recherche
          Container(
            padding: const EdgeInsets.all(16),
            decoration: const BoxDecoration(
              border: Border(
                bottom: BorderSide(color: Color(0xFFE2E8F0), width: 1),
              ),
            ),
            child: Column(
              children: [
                // Handle bar et bouton fermer
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const SizedBox(width: 24), // Spacer pour centrer le handle
                    Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: const Color(0xFFCBD5E1),
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.close, size: 20),
                      color: const Color(0xFF94A3B8),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                // Search bar
                Container(
                  height: 44,
                  decoration: BoxDecoration(
                    color: const Color(0xFFF8FAFC),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0xFFE2E8F0)),
                  ),
                  child: TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      hintText: 'Rechercher...',
                      hintStyle: GoogleFonts.inter(
                        fontSize: 14,
                        color: const Color(0xFF94A3B8),
                      ),
                      prefixIcon: const Icon(
                        Icons.search,
                        size: 20,
                        color: Color(0xFF64748B),
                      ),
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                // Label pour saisie manuelle
                Padding(
                  padding: const EdgeInsets.only(left: 4, bottom: 8),
                  child: Text(
                    'Ou saisissez manuellement si non trouvé dans la liste',
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: const Color(0xFF6B7280),
                    ),
                  ),
                ),
                // Champ de saisie manuelle
                Container(
                  height: 44,
                  decoration: BoxDecoration(
                    color: const Color(0xFFF8FAFC),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0xFFE2E8F0)),
                  ),
                  child: TextField(
                    controller: _manualInputController,
                    decoration: InputDecoration(
                      hintText: widget.showSectorIcon 
                          ? 'Saisir le nom de la société...' 
                          : widget.showGraduationIcon
                              ? 'Saisir le nom de l\'établissement...'
                              : 'Saisir manuellement...',
                      hintStyle: GoogleFonts.inter(
                        fontSize: 14,
                        color: const Color(0xFF94A3B8),
                      ),
                      prefixIcon: Icon(
                        widget.showGraduationIcon ? Icons.school : Icons.edit,
                        size: 20,
                        color: const Color(0xFF64748B),
                      ),
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    onChanged: (value) {
                      setState(() {}); // Pour mettre à jour le bouton
                    },
                  ),
                ),
                if (_manualInputController.text.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  ElevatedButton(
                    onPressed: () {
                      if (_manualInputController.text.isNotEmpty) {
                        widget.onSelected(_manualInputController.text);
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF401E66),
                      foregroundColor: Colors.white,
                      minimumSize: const Size(double.infinity, 44),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 0,
                    ),
                    child: Text(
                      'Confirmer',
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
          // Liste des items
          Expanded(
            child: _filteredItems.isEmpty
                ? Center(
                    child: Text(
                      'Aucun résultat',
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        color: const Color(0xFF94A3B8),
                      ),
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    itemCount: _filteredItems.length,
                    itemBuilder: (context, index) {
                      final item = _filteredItems[index];
                      return InkWell(
                        onTap: () => widget.onSelected(item),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 14,
                          ),
                          child: Row(
                            children: [
                              if (widget.showSectorIcon || widget.showGraduationIcon) ...[
                                Container(
                                  width: 20,
                                  height: 20,
                                  decoration: const BoxDecoration(
                                    color: Color(0xFF401E66),
                                    shape: BoxShape.circle,
                                  ),
                                  child: Icon(
                                    widget.showGraduationIcon 
                                        ? Icons.school 
                                        : _getCompanySectorIcon(item),
                                    size: 11,
                                    color: Colors.white,
                                  ),
                                ),
                                const SizedBox(width: 12),
                              ],
                              Expanded(
                                child: Text(
                                  item,
                                  style: GoogleFonts.inter(
                                    fontSize: 15,
                                    color: const Color(0xFF0F172A),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
