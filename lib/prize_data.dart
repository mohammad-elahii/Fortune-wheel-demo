import 'package:flutter/material.dart';

// Data models for prizes and user profile, plus the hardcoded prize list

/// Represents a single prize option on the wheel.
class PrizeData {
  PrizeData({required this.name, required this.icon, required this.color});
  final String name;
  final IconData icon;
  final Color color;
}

/// Holds the current user's info and game state.
class ProfileData {
  final String name;
  final String phoneNumber;
  int tickets; // not final cause mutable
  final List<PrizeData> wonPrizes = [];

  ProfileData({
    this.name = 'Mohammad Elahi',
    this.phoneNumber = '+989155776012',
    this.tickets = 2, // 2 ta spin
  });
}

// list of prizes
final List<PrizeData> prizes = [
  PrizeData(
    name: '10 min free game',
    icon: Icons.timer,
    color: Color(0xFFE36559),
  ),
  PrizeData(
    name: ' Gift Card ',
    icon: Icons.card_giftcard,
    color: Color(0XFF23617E),
  ),
  PrizeData(
    name: '20 min free game',
    icon: Icons.watch,
    color: Color(0XFFC0B058),
  ),
  PrizeData(
    name: 'Try Again',
    icon: Icons.sentiment_dissatisfied,
    color: Color(0XFF94BEBB),
  ),
  PrizeData(
    name: 'free second ride',
    icon: Icons.person,
    color: Color(0xffe89c73),
  ),
  PrizeData(
    name: '30% food court off',
    icon: Icons.percent,
    color: Color(0xFFF4D892),
  ),
];


//note :  ina hame mock datas badan az server inaro migire