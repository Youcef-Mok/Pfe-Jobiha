import 'package:flutter/material.dart';

class MapJobEntity {
  final String id;
  final String title;
  final String company;
  final String category;
  final String distance;
  final String city;
  final String hours;
  final double salary;
  final String? imageAsset;
  final String? recruiterAvatar;
  final String? recruiterName;
  final String? recruiterRole;
  final String? description;
  final double lat;
  final double lng;
  final IconData categoryIcon;
  final String contractType;
  final double rating;
  final String status;
  final DateTime? postedAt;
  final int candidateCount;
  final int viewCount;

  const MapJobEntity({
    required this.id,
    required this.title,
    required this.company,
    required this.category,
    required this.distance,
    this.city = '',
    required this.hours,
    required this.salary,
    this.imageAsset,
    this.recruiterAvatar,
    this.recruiterName,
    this.recruiterRole,
    this.description,
    required this.lat,
    required this.lng,
    required this.categoryIcon,
    this.contractType = 'CDD',
    this.rating = 4.9,
    this.status = 'searching',
    this.postedAt,
    this.candidateCount = 0,
    this.viewCount = 0,
  });
}
