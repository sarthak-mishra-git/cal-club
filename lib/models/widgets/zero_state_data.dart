class ZeroStateData {
  final String image;
  final String text;

  ZeroStateData({
    required this.image,
    required this.text,
  });

  factory ZeroStateData.fromJson(Map<String, dynamic> json) => ZeroStateData(
        image: json['image'] ?? '',
        text: json['text'] ?? '',
      );
} 