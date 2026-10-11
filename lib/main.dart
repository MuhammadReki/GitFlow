import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'core/router/app_router.dart';
import 'core/theme/app_theme.dart';
import 'core/theme/theme_provider.dart';

void main() {
  runApp(const GitFlowApp());
}

class GitFlowApp extends StatelessWidget {
  const GitFlowApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => ThemeProvider(),
      child: Consumer<ThemeProvider>(
        builder: (context, themeProvider, _) {
          if (themeProvider.isLoading) {
            return const MaterialApp(
              debugShowCheckedModeBanner: false,
              home: Scaffold(
                backgroundColor: Color(0xFFF9FAFB),
                body: Center(
                  child: CircularProgressIndicator(
                    color: Color(0xFF6366F1),
                  ),
                ),
              ),
            );
          }

          return MaterialApp.router(
            title: 'GitFlow',
            debugShowCheckedModeBanner: false,
            themeMode: themeProvider.themeMode,
            theme: AppTheme.lightTheme.copyWith(
              textTheme: AppTheme.lightTheme.textTheme.apply(
                fontFamily: 'Inter',
              ),
              primaryTextTheme:
                  AppTheme.lightTheme.primaryTextTheme.apply(
                fontFamily: 'Inter',
              ),
            ),
            darkTheme: AppTheme.darkTheme.copyWith(
              textTheme: AppTheme.darkTheme.textTheme.apply(
                fontFamily: 'Inter',
              ),
              primaryTextTheme:
                  AppTheme.darkTheme.primaryTextTheme.apply(
                fontFamily: 'Inter',
              ),
            ),
            routerConfig: AppRouter.router,
          );
        },
      ),
    );
  }
}