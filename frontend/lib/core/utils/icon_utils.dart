import 'package:flutter/material.dart';

/// Utilitaires pour la gestion des icônes intelligentes
class IconUtils {
  /// Détermine l'icône appropriée selon le contenu (formation, poste, etc.)
  static IconData getSmartIcon(String value) {
    final lowerValue = value.toLowerCase();
    
    // Correspondance exacte pour les domaines de la page d'édition
    switch (lowerValue) {
      case 'restauration':
        return Icons.restaurant;
      case 'hôtellerie':
        return Icons.hotel;
      case 'événementiel':
        return Icons.event;
      case 'commerce':
        return Icons.shopping_cart;
      case 'services':
        return Icons.build;
      case 'santé':
        return Icons.local_hospital;
      case 'éducation':
        return Icons.school;
      case 'transport':
        return Icons.directions_car;
    }
    
    // Icônes pour l'informatique et technologie
    if (lowerValue.contains('informatique') || 
        lowerValue.contains('génie logiciel') || 
        lowerValue.contains('programmation') ||
        lowerValue.contains('développement') ||
        lowerValue.contains('software') ||
        lowerValue.contains('computer') ||
        lowerValue.contains('développeur') ||
        lowerValue.contains('analyste')) {
      return Icons.computer;
    }
    
    // Icônes pour la cuisine
    if (lowerValue.contains('cuisine') || 
        lowerValue.contains('cuisinier') ||
        lowerValue.contains('chef') ||
        lowerValue.contains('pâtissier') ||
        lowerValue.contains('commis')) {
      return Icons.restaurant;
    }
    
    // Icônes pour le service
    if (lowerValue.contains('serveur') || 
        lowerValue.contains('serveuse') ||
        lowerValue.contains('service') ||
        lowerValue.contains('accueil') ||
        lowerValue.contains('hôte') ||
        lowerValue.contains('hôtesse')) {
      return Icons.room_service;
    }
    
    // Icônes pour le bar
    if (lowerValue.contains('barman') || 
        lowerValue.contains('barmaid') ||
        lowerValue.contains('bar') ||
        lowerValue.contains('sommelier')) {
      return Icons.local_bar;
    }
    
    // Icônes pour le management
    if (lowerValue.contains('manager') || 
        lowerValue.contains('responsable') ||
        lowerValue.contains('management') ||
        lowerValue.contains('direction') ||
        lowerValue.contains('superviseur')) {
      return Icons.supervisor_account;
    }
    
    // Icônes pour l'hôtellerie
    if (lowerValue.contains('hôtellerie') || 
        lowerValue.contains('hôtel') ||
        lowerValue.contains('tourisme') ||
        lowerValue.contains('réception') ||
        lowerValue.contains('réceptionniste')) {
      return Icons.hotel;
    }
    
    // Icônes pour l'événementiel
    if (lowerValue.contains('événementiel') || 
        lowerValue.contains('event') ||
        lowerValue.contains('animation') ||
        lowerValue.contains('animateur')) {
      return Icons.event;
    }
    
    // Icônes pour le commerce
    if (lowerValue.contains('commerce') || 
        lowerValue.contains('vente') ||
        lowerValue.contains('commercial') ||
        lowerValue.contains('vendeur')) {
      return Icons.shopping_bag;
    }
    
    // Icônes pour le droit
    if (lowerValue.contains('droit') || 
        lowerValue.contains('juridique') ||
        lowerValue.contains('avocat') ||
        lowerValue.contains('juriste')) {
      return Icons.gavel;
    }
    
    // Icônes pour la finance
    if (lowerValue.contains('finance') || 
        lowerValue.contains('comptabilité') ||
        lowerValue.contains('économie') ||
        lowerValue.contains('comptable')) {
      return Icons.account_balance;
    }
    
    // Icônes pour le marketing
    if (lowerValue.contains('marketing') || 
        lowerValue.contains('communication') ||
        lowerValue.contains('publicité') ||
        lowerValue.contains('digital')) {
      return Icons.campaign;
    }
    
    // Icônes pour les sciences
    if (lowerValue.contains('sciences') || 
        lowerValue.contains('recherche') ||
        lowerValue.contains('laboratoire') ||
        lowerValue.contains('doctorat')) {
      return Icons.science;
    }
    
    // Icônes pour la médecine
    if (lowerValue.contains('médecine') || 
        lowerValue.contains('santé') ||
        lowerValue.contains('infirmier') ||
        lowerValue.contains('médical')) {
      return Icons.medical_services;
    }
    
    // Icônes pour l'éducation
    if (lowerValue.contains('éducation') || 
        lowerValue.contains('enseignement') ||
        lowerValue.contains('professeur') ||
        lowerValue.contains('formation') ||
        lowerValue.contains('licence') ||
        lowerValue.contains('master') ||
        lowerValue.contains('bts') ||
        lowerValue.contains('dut') ||
        lowerValue.contains('cap') ||
        lowerValue.contains('baccalauréat')) {
      return Icons.school;
    }
    
    // Icônes pour les ressources humaines
    if (lowerValue.contains('ressources humaines') || 
        lowerValue.contains('rh') ||
        lowerValue.contains('recrutement')) {
      return Icons.people;
    }
    
    // Icônes pour la logistique
    if (lowerValue.contains('logistique') || 
        lowerValue.contains('transport') ||
        lowerValue.contains('livraison')) {
      return Icons.local_shipping;
    }
    
    // Icône par défaut
    return Icons.work;
  }
}