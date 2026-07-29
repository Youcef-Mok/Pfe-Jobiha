import 'package:flutter/material.dart';

class MapJobEntity {
  final String id;
  final String title;
  final String company;
  final String category;
  final String distance;
  final String hours;
  final double salary;
  final String? imageAsset;
  final String? recruiterAvatar;
  final double lat;
  final double lng;
  final IconData categoryIcon;
  final String contractType;
  final double rating;

  const MapJobEntity({
    required this.id,
    required this.title,
    required this.company,
    required this.category,
    required this.distance,
    required this.hours,
    required this.salary,
    this.imageAsset,
    this.recruiterAvatar,
    required this.lat,
    required this.lng,
    required this.categoryIcon,
    this.contractType = 'CDD',
    this.rating = 4.9,
  });
}
