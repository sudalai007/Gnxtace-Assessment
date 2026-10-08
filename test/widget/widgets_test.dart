import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gnxtace_assessment/features/gallery/presentation/widgets/category_filter_bar.dart';
import 'package:gnxtace_assessment/features/gallery/presentation/widgets/search_bar_widget.dart';

void main() {
  testWidgets('CategoryFilterBar renders category chips properly', (WidgetTester tester) async {
    String selected = 'all';

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: CategoryFilterBar(
            selectedCategory: selected,
            onCategorySelected: (cat) {
              selected = cat;
            },
          ),
        ),
      ),
    );

    // Verify chips render
    expect(find.text('ALL'), findsOneWidget);
    expect(find.text('NATURE'), findsOneWidget);

    // Tap nature chip
    await tester.tap(find.text('NATURE'));
    await tester.pumpAndSettle();

    expect(selected, equals('nature'));
  });

  testWidgets('SearchBarWidget accepts text input and triggers onChanged', (WidgetTester tester) async {
    String searchText = '';

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SearchBarWidget(
            onChanged: (val) {
              searchText = val;
            },
            onClear: () {
              searchText = '';
            },
          ),
        ),
      ),
    );

    expect(find.byType(TextField), findsOneWidget);

    // Enter text
    await tester.enterText(find.byType(TextField), 'mountains');
    await tester.pump(const Duration(milliseconds: 600));

    expect(searchText, equals('mountains'));
  });
}
