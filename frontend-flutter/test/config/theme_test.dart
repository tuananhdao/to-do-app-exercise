import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:todo_flutter/config/app_theme.dart';

void main() {
  group('AppTheme Tests', () {
    test('Primary color should be Microsoft blue', () {
      expect(AppTheme.primary, const Color(0xFF2564CF));
    });

    test('Success color should be Microsoft green', () {
      expect(AppTheme.success, const Color(0xFF107C10));
    });

    test('Error color should be defined', () {
      expect(AppTheme.error, const Color(0xFFD13438));
    });

    test('Background color should be light', () {
      expect(AppTheme.background, const Color(0xFFFAFAFA));
    });

    test('Surface color should be white', () {
      expect(AppTheme.surface, const Color(0xFFFFFFFF));
    });

    test('Text colors should be defined', () {
      expect(AppTheme.textPrimary, const Color(0xFF323130));
      expect(AppTheme.textSecondary, const Color(0xFF605E5C));
      expect(AppTheme.textTertiary, const Color(0xFF8A8886));
    });

    test('Light theme should have correct primary color', () {
      final theme = AppTheme.lightTheme;
      
      expect(theme.colorScheme.primary, AppTheme.primary);
      expect(theme.colorScheme.secondary, AppTheme.secondary);
      expect(theme.colorScheme.error, AppTheme.error);
    });

    test('Light theme should use Material 3', () {
      final theme = AppTheme.lightTheme;
      
      expect(theme.useMaterial3, true);
    });

    test('Text styles should have correct properties', () {
      expect(AppTheme.h1.fontSize, 32);
      expect(AppTheme.h1.fontWeight, FontWeight.w800);
      
      expect(AppTheme.h2.fontSize, 24);
      expect(AppTheme.h2.fontWeight, FontWeight.w700);
      
      expect(AppTheme.h3.fontSize, 20);
      expect(AppTheme.h3.fontWeight, FontWeight.w600);
      
      expect(AppTheme.bodyLarge.fontSize, 16);
      expect(AppTheme.bodyMedium.fontSize, 14);
      expect(AppTheme.bodySmall.fontSize, 12);
    });

    test('Card theme should have correct radius', () {
      final theme = AppTheme.lightTheme;
      final cardShape = theme.cardTheme.shape as RoundedRectangleBorder;
      
      expect(cardShape.borderRadius, BorderRadius.circular(16));
    });

    test('FAB theme should be circular', () {
      final theme = AppTheme.lightTheme;
      
      expect(theme.floatingActionButtonTheme.shape, const CircleBorder());
      expect(theme.floatingActionButtonTheme.backgroundColor, AppTheme.primary);
      expect(theme.floatingActionButtonTheme.foregroundColor, Colors.white);
    });

    test('Input decoration should have correct border radius', () {
      final theme = AppTheme.lightTheme;
      final border = theme.inputDecorationTheme.border as OutlineInputBorder;
      
      expect(border.borderRadius, BorderRadius.circular(12));
    });

    test('Checkbox theme should use primary color when selected', () {
      final theme = AppTheme.lightTheme;
      final fillColor = theme.checkboxTheme.fillColor;
      
      final selectedColor = fillColor?.resolve({MaterialState.selected});
      expect(selectedColor, AppTheme.primary);
    });
  });
}
