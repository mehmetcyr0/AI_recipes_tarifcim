import 'dart:convert';
import 'package:http/http.dart' as http;

class GeminiService {
  // Gemini 1.5 Flash API doğrudan kullanım
  static const String _baseUrl =
      'https://generativelanguage.googleapis.com/v1beta/models/gemini-2.0-flash:generateContent';

  static const String _apiKey = 'AIzaSyCY2qDn0B26ZxwKNi4jbrivMcG9THoYfBA';

  Future<String> getResponse(String prompt, {String language = 'tr'}) async {
    try {
      final url = '$_baseUrl?key=$_apiKey';

      final systemPrompt = '''
      Tarifcim adlı bir yapay zeka asistanısın. Sadece yemek tarifleri ve mutfak konularında yardımcı olursun.
      Kullanıcıların verdiği malzemelerle yapılabilecek tarifleri detaylı olarak oluşturursun.
      Her tarif için şunları içermelisin:
      1. Tarifin adı ve kısa açıklaması
      2. Malzemeler listesi (SADECE kullanıcının verdiği malzemelere odaklanarak)
      3. Adım adım hazırlanışı
      4. Pişirme süresi ve porsiyon bilgisi
      5. Kalori değeri
      6. Gıda israfını azaltmak için ipuçları
      
      Yemek ve mutfak dışındaki konularda soru sorulursa, kibarca sadece yemek tarifleri konusunda yardımcı olabileceğini belirtirsin.
      Cevaplarını ${language == 'tr' ? 'Türkçe' : 'İngilizce'} olarak verirsin.
      
      ÖNEMLİ: Cevabını her zaman geçerli bir JSON formatında ver. Başka açıklama ekleme.
      ''';

      final requestBody = jsonEncode({
        'contents': [
          {
            'role': 'user',
            'parts': [
              {'text': systemPrompt},
              {'text': prompt}
            ]
          }
        ],
        'generationConfig': {
          'temperature': 0.7,
          'topK': 40,
          'topP': 0.95,
          'maxOutputTokens': 4096,
          'responseMimeType': 'application/json',
        }
      });

      final response = await http.post(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
        },
        body: requestBody,
      );

      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(response.body);
        if (jsonResponse['candidates'] != null &&
            jsonResponse['candidates'].isNotEmpty &&
            jsonResponse['candidates'][0]['content'] != null &&
            jsonResponse['candidates'][0]['content']['parts'] != null &&
            jsonResponse['candidates'][0]['content']['parts'].isNotEmpty) {
          final text =
              jsonResponse['candidates'][0]['content']['parts'][0]['text'];
          return text;
        } else {
          return language == 'tr'
              ? '[{"id":"1","title":"Basit Tarif","description":"API yanıt vermedi, basit bir tarif öneriyoruz.","cookingTime":15,"servings":2,"calories":200,"ingredients":["Malzeme 1","Malzeme 2"],"instructions":["Adım 1","Adım 2"],"wasteReductionTips":"Gıda israfını azaltmak için ipuçları."}]'
              : '[{"id":"1","title":"Simple Recipe","description":"API did not respond, suggesting a simple recipe.","cookingTime":15,"servings":2,"calories":200,"ingredients":["Ingredient 1","Ingredient 2"],"instructions":["Step 1","Step 2"],"wasteReductionTips":"Tips to reduce food waste."}]';
        }
      } else {
        // API hata durumunda fallback JSON döndür
        return language == 'tr'
            ? '[{"id":"1","title":"Basit Tarif","description":"API hatası oluştu, basit bir tarif öneriyoruz.","cookingTime":15,"servings":2,"calories":200,"ingredients":["Malzeme 1","Malzeme 2"],"instructions":["Adım 1","Adım 2"],"wasteReductionTips":"Gıda israfını azaltmak için ipuçları."}]'
            : '[{"id":"1","title":"Simple Recipe","description":"API error occurred, suggesting a simple recipe.","cookingTime":15,"servings":2,"calories":200,"ingredients":["Ingredient 1","Ingredient 2"],"instructions":["Step 1","Step 2"],"wasteReductionTips":"Tips to reduce food waste."}]';
      }
    } catch (e) {
      // Hata durumunda fallback JSON döndür
      return language == 'tr'
          ? '[{"id":"1","title":"Basit Tarif","description":"Bir hata oluştu, basit bir tarif öneriyoruz.","cookingTime":15,"servings":2,"calories":200,"ingredients":["Malzeme 1","Malzeme 2"],"instructions":["Adım 1","Adım 2"],"wasteReductionTips":"Gıda israfını azaltmak için ipuçları."}]'
          : '[{"id":"1","title":"Simple Recipe","description":"An error occurred, suggesting a simple recipe.","cookingTime":15,"servings":2,"calories":200,"ingredients":["Ingredient 1","Ingredient 2"],"instructions":["Step 1","Step 2"],"wasteReductionTips":"Tips to reduce food waste."}]';
    }
  }
}
