import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:provider/provider.dart';

import 'package:community_charts_flutter/community_charts_flutter.dart'
    as charts;

import 'package:waterflyiii/animations.dart';
import 'package:waterflyiii/auth.dart';
import 'package:waterflyiii/extensions.dart';
import 'package:waterflyiii/generated/swagger_fireflyiii_api/firefly_iii.swagger.dart';
import 'package:waterflyiii/widgets/charts.dart';

class CategoryChart extends StatelessWidget {
  const CategoryChart({
    super.key,
    required this.data,
  });

  final List<InsightGroupEntry> data;

  @override
  Widget build(BuildContext context) {
    List<LabelAmountChart> chartData = <LabelAmountChart>[];
    CurrencyRead defaultCurrency =
        context.read<FireflyService>().defaultCurrency;

    for (InsightGroupEntry e in data) {
      if ((e.name?.isEmpty ?? true) || e.differenceFloat == 0) {
        continue;
      }
      chartData.add(
        LabelAmountChart(
          e.name!,
          e.differenceFloat ?? 0,
        ),
      );
    }

    chartData.sort((LabelAmountChart a, LabelAmountChart b) =>
        a.amount.compareTo(b.amount));

    if (data.length > 5) {
      LabelAmountChart otherData = chartData.skip(5).reduce(
            (LabelAmountChart v, LabelAmountChart e) =>
                LabelAmountChart(S.of(context).catOther, v.amount + e.amount),
          );
      chartData = chartData.take(5).toList();

      if (otherData.amount != 0) {
        chartData.add(otherData);
      }
    }

    return Padding(
      padding: const EdgeInsets.only(left: 12),
      child: charts.PieChart<String>(
        <charts.Series<LabelAmountChart, String>>[
          charts.Series<LabelAmountChart, String>(
            id: 'Categories',
            domainFn: (LabelAmountChart entry, _) => entry.label,
            measureFn: (LabelAmountChart entry, _) => entry.amount.abs(),
            data: chartData,
            labelAccessorFn: (LabelAmountChart entry, _) =>
                entry.amount.abs().toStringAsFixed(0),
            /*defaultCurrency.fmt(
              entry.amount.abs(),
              locale: S.of(context).localeName,
              decimalDigits: 0,
            ),*/
            colorFn: (_, int? i) => possibleChartColors[i ?? 5],
          ),
        ],
        animate: true,
        animationDuration: animDurationEmphasized,
        defaultRenderer: charts.ArcRendererConfig<String>(
          arcRendererDecorators: <charts.ArcLabelDecorator<String>>[
            charts.ArcLabelDecorator<String>(
              insideLabelStyleSpec: charts.TextStyleSpec(
                fontSize:
                    Theme.of(context).textTheme.labelSmall!.fontSize!.round(),
              ),
              outsideLabelStyleSpec: charts.TextStyleSpec(
                fontSize:
                    Theme.of(context).textTheme.labelSmall!.fontSize!.round(),
                color: charts.ColorUtil.fromDartColor(
                  Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
              leaderLineStyleSpec: charts.ArcLabelLeaderLineStyleSpec(
                length: 10.0,
                thickness: 1.0,
                color: charts.ColorUtil.fromDartColor(
                  Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
            )
          ],
        ),
        behaviors: <charts.ChartBehavior<String>>[
          charts.DatumLegend<String>(
            position: charts.BehaviorPosition.end,
            horizontalFirst: false,
            cellPadding: const EdgeInsets.only(right: 4, bottom: 4),
            showMeasures: false, // Not formattable :(
            legendDefaultMeasure: charts.LegendDefaultMeasure.firstValue,
            desiredMaxRows: 6,
            measureFormatter: (num? value) {
              return value == null ? '-' : defaultCurrency.fmt(value);
            },
            entryTextStyle: charts.TextStyleSpec(
              fontSize:
                  Theme.of(context).textTheme.labelMedium!.fontSize!.round(),
            ),
          ),
        ],
        defaultInteractions: false,
      ),
    );
  }
}
