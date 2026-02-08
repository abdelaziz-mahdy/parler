class NumberItem {
  final int value;
  final String french;
  final String? formula; // e.g. "60 + 10" for 70
  final String? belgianSwiss; // e.g. "septante" for 70

  const NumberItem({
    required this.value,
    required this.french,
    this.formula,
    this.belgianSwiss,
  });

  factory NumberItem.fromJson(Map<String, dynamic> json) => NumberItem(
        value: json['value'] as int,
        french: json['french'] as String,
        formula: json['formula'] as String?,
        belgianSwiss: json['belgianSwiss'] as String?,
      );

  Map<String, dynamic> toJson() => {
        'value': value,
        'french': french,
        if (formula != null) 'formula': formula,
        if (belgianSwiss != null) 'belgianSwiss': belgianSwiss,
      };
}
