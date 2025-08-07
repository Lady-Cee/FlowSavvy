import 'package:flutter/material.dart';

class MythsScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Menstrual Myths')),
      body: ListView.builder(
        itemCount: mythsAndFacts.length,
        padding: const EdgeInsets.all(16),
        itemBuilder: (context, i) => Card(
          child: ListTile(
            title: Text("Myth: ${mythsAndFacts[i]['myth']}"),
            subtitle: Text("Fact: ${mythsAndFacts[i]['fact']}"),
          ),
        ),
      ),
    );
  }
  final List<Map<String, String>> mythsAndFacts = [
    {
      'myth': 'You can’t get pregnant during your period.',
      'fact': 'While less likely, pregnancy can still occur during menstruation, especially with irregular cycles.'
    },
    {
      'myth': 'Menstrual blood is impure or dirty.',
      'fact': 'Menstrual blood is a natural bodily fluid composed of blood and uterine tissue. It\'s not impure.'
    },
    {
      'myth': 'Swimming during menstruation is unsafe.',
      'fact': 'Swimming is safe during menstruation when using appropriate products like tampons or menstrual cups.'
    },
    {
      'myth': 'Exercising during your period is harmful.',
      'fact': 'Exercise can alleviate menstrual cramps and improve mood.'
    },
    {
      'myth': 'Tampons can get lost inside the body.',
      'fact': 'Tampons cannot get lost; the vaginal canal has no pathway to other parts of the body.'
    },
    {
      'myth': 'Periods should last exactly 28 days.',
      'fact': 'Menstrual cycles vary between individuals, typically ranging from 21 to 35 days.'
    },
    {
      'myth': 'Menstrual cycles synchronize among women who live together.',
      'fact': 'There\'s no scientific evidence supporting menstrual synchronization.'
    },
    {
      'myth': 'Menstruation is a sign of impurity.',
      'fact': 'Menstruation is a natural biological process and not a reflection of cleanliness or purity.'
    },
    {
      'myth': 'You shouldn’t bathe during your period.',
      'fact': 'Bathing during menstruation is hygienic and can relieve cramps.'
    },
    {
      'myth': 'Using tampons can break the hymen and affect virginity.',
      'fact': 'Virginity is a social concept, and tampon use doesn’t determine it.'
    },
    {
      'myth': 'Menstrual blood attracts sharks.',
      'fact': 'There\'s no evidence that menstruation increases shark attacks.'
    },
    {
      'myth': 'You can’t have sex during menstruation.',
      'fact': 'Sex during menstruation is a personal choice and is safe with proper hygiene.'
    },
    {
      'myth': 'Menstruation should be kept secret.',
      'fact': 'Open discussions about menstruation promote health and reduce stigma.'
    },
    {
      'myth': 'Menstrual cramps are just minor discomforts.',
      'fact': 'Some individuals experience severe cramps, known as dysmenorrhea, which can be debilitating.'
    },
    {
      'myth': 'Menstruation is a punishment or curse.',
      'fact': 'Menstruation is a natural reproductive process, not a punishment.'
    },
    {
      'myth': 'Menstruating women should not enter religious places.',
      'fact': 'This belief is rooted in cultural myths; menstruation doesn’t affect one’s spiritual purity.'
    },
    {
      'myth': 'Menstruating women shouldn’t cook or touch food.',
      'fact': 'There’s no scientific basis for this; menstruation doesn’t contaminate food.'
    },
    {
      'myth': 'Menstruating women should avoid bathing.',
      'fact': 'Regular bathing during menstruation is hygienic and beneficial.'
    },
    {
      'myth': 'Menstruating women should be isolated.',
      'fact': 'Isolation practices are harmful and based on misconceptions.'
    },
    {
      'myth': 'Menstrual blood can be used in black magic.',
      'fact': 'Such beliefs are superstitions without scientific evidence.'
    },
    {
      'myth': 'Menstruating women shouldn’t touch plants.',
      'fact': 'There’s no evidence that menstruation affects plant health.'
    },
    {
      'myth': 'Menstruating women shouldn’t touch others.',
      'fact': 'Menstruation doesn’t make someone untouchable; this is a discriminatory belief.'
    },
    {
      'myth': 'Menstruating women shouldn’t participate in daily activities.',
      'fact': 'Menstruation doesn’t impede one’s ability to perform daily tasks.'
    },
    {
      'myth': 'Menstruating women shouldn’t attend school or work.',
      'fact': 'With proper menstrual hygiene, there’s no reason to miss school or work.'
    },
    {
      'myth': 'Menstruating women shouldn’t touch water sources.',
      'fact': 'This belief is unfounded; menstruation doesn’t contaminate water.'
    },
  ]; // Already
}
