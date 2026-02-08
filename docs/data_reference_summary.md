# Data Reference Summary

This document summarizes all data points from the source document (`docs/french_content.txt`) that must be accurately represented in the app's JSON data files. Use this as a checklist when validating `assets/data/` files.

## Chapter 1: Suffix Patterns (`suffix_patterns.json`)

**Expected count: 16 patterns**

Each pattern needs: englishEnding, frenchEnding, examples (list), notes

1. -tion -> -tion: nation, information, situation, education, revolution | "SAME spelling! Just say it French: nah-see-ON. Hundreds of words."
2. -sion -> -sion: television, decision, passion, version, mission | "Same spelling, French pronunciation."
3. -ment -> -ment: moment, apartment, document, government, department | "Often identical. French says -moh(n)."
4. -ous -> -eux/-euse: famous->fameux, dangerous->dangereux, curious->curieux | "-eux (masc), -euse (fem). Huge pattern."
5. -ty -> -te: university->universite, quality->qualite, city->cite, liberty->liberte | "Almost always works. Always feminine."
6. -al -> -al/-el: normal, final, national, international, animal, capital | "Usually identical spelling."
7. -ble -> -ble: possible, table, terrible, comfortable, flexible, visible | "Same spelling, French pronunciation."
8. -ary/-ery -> -aire: necessary->necessaire, ordinary->ordinaire, military->militaire | "Very reliable pattern."
9. -ence/-ance -> -ence/-ance: difference, silence, distance, importance, intelligence | "Same spelling. Always feminine in French."
10. -ic -> -ique: music->musique, public->publique, fantastic->fantastique | "Add -que. Huge number of words."
11. -ism -> -isme: tourism->tourisme, capitalism->capitalisme, optimism->optimisme | "Add -e. Always masculine."
12. -ist -> -iste: artist->artiste, tourist->touriste, dentist->dentiste | "Add -e. Same for masc & fem."
13. -ly -> -ment: normally->normalement, exactly->exactement, rapidly->rapidement | "English adverbs ending -ly = French -ment."
14. -ive -> -if/-ive: active->actif/active, positive->positif/positive | "-if (masc), -ive (fem)."
15. -ure -> -ure: nature, culture, structure, adventure, temperature | "Same spelling. Always feminine."
16. -age -> -age: garage, message, village, image, voyage | "Same spelling. Usually masculine."

---

## Chapter 2: Pronunciation (`pronunciation_rules.json`)

### Golden Rules (3 rules)
1. Silent final consonants (exception: CaReFuL)
2. Stress always on last syllable
3. Nasal vowels (vowel + N/M without following vowel)

### Vowel Sounds (10 entries)
| Letters | Sound | Examples |
|---------|-------|----------|
| ou | "oo" like boot | vous, nous, tout |
| u | no English equiv, "ee" with rounded lips | tu, rue, plus |
| eu/oeu | "uh" with rounded lips | deux, bleu, heure |
| oi | "wah" | moi, trois, boire |
| ai/ei | "eh" like bed | lait, maison, faire |
| au/eau | "oh" | eau, beau, restaurant |
| e (accent aigu) | "ay" like day | cafe, ete |
| e (grave/circumflex) | "eh" like bed | mere, fete, tres |
| e (no accent, end) | silent | table, France |
| e (no accent, mid) | "uh" (schwa) | le, petit, devenir |

### Nasal Vowels (3 categories)
| Spelling | Sound | Examples |
|----------|-------|----------|
| an/am/en/em | ah(n) | France, enfant, comment, temps, chanson |
| on/om | oh(n) | bon, nom, maison, onze, bonjour |
| in/im/ain/ein/un | a(n) | vin, pain, demain, important, lundi |

Plus the nasal vowel trick (vowel+N/M followed by another vowel or doubled = NOT nasal)

### Consonant Tricks (10 entries)
c, c-cedilla, g, gn, h, j, r, qu, ch, th

### CaReFuL Rule
C, R, F, L are usually pronounced at end of words. With examples for each.

---

## Chapter 3: Gender Rules (`gender_rules.json`)

### Feminine Endings (8)
| Ending | Accuracy | Examples |
|--------|----------|----------|
| -tion/-sion | ~99% | la nation, la television, la situation, la decision |
| -te | ~99% | la liberte, la qualite, la societe, l'universite |
| -ure | ~95% | la nature, la voiture, la culture, l'aventure |
| -ence/-ance | ~95% | la difference, la France, la science, l'importance |
| -ie | ~95% | la vie, la partie, la philosophie, l'energie |
| -ette/-elle | ~95% | la baguette, la fourchette, la nouvelle, la chapelle |
| -ise/-aise | ~95% | la surprise, la valise, la francaise, la mayonnaise |
| -ee | ~99% | la journee, l'idee, l'annee, l'arrivee |

### Masculine Endings (7)
| Ending | Accuracy | Examples | Exceptions |
|--------|----------|----------|------------|
| -age | ~90% | le garage, le voyage, le message, le fromage | la plage, la page, l'image |
| -ment | ~99% | le moment, le gouvernement, le mouvement, l'appartement | - |
| -isme | ~99% | le tourisme, le capitalisme, le journalisme | - |
| -eau | ~99% | le bateau, le gateau, le chapeau, le bureau | l'eau = fem! |
| -oir | ~95% | le miroir, le soir, le pouvoir, le devoir | - |
| -et | ~95% | le ticket, le billet, le secret, le sujet | - |
| consonant ending | ~65-70% | le sport, le restaurant, le chat, le film | less reliable |

---

## Chapter 4: Verbs (`verbs.json`)

### 27 Essential Verbs
| Verb | Meaning |
|------|---------|
| etre | to be |
| avoir | to have |
| faire | to do/make |
| aller | to go |
| venir | to come |
| pouvoir | can/to be able |
| vouloir | to want |
| devoir | must/to have to |
| savoir | to know (facts) |
| dire | to say/tell |
| parler | to speak |
| prendre | to take |
| voir | to see |
| mettre | to put |
| donner | to give |
| trouver | to find |
| manger | to eat |
| travailler | to work |
| habiter | to live |
| comprendre | to understand |
| aimer | to like/love |
| penser | to think |
| demander | to ask |
| croire | to believe |
| connaitre | to know (people) |
| attendre | to wait |
| acheter | to buy |

### -ER Verb Conjugation Pattern
je: -e, tu: -es, il/elle: -e, nous: -ons, vous: -ez, ils/elles: -ent

### DR MRS VANDERTRAMP Verbs (16 verbs using etre in passe compose)
Devenir, Revenir, Monter, Retourner, Sortir, Venir, Aller, Naitre, Descendre, Entrer, Rentrer, Tomber, Rester, Arriver, Mourir, Partir

---

## Chapter 5: Grammar (`grammar_rules.json`)

### Question Words (7)
| French | English | Example | Pronunciation |
|--------|---------|---------|---------------|
| Qui | Who | Qui est-ce? | kee |
| Quoi/Que | What | C'est quoi? / Qu'est-ce que c'est? | kwah/kuh |
| Ou | Where | Ou est la gare? | oo |
| Quand | When | Quand est-ce qu'on part? | kah(n) |
| Pourquoi | Why | Pourquoi pas? | poor-KWAH |
| Comment | How | Comment allez-vous? | ko-MAH(N) |
| Combien | How much/many | Combien ca coute? | kom-BEE-A(N) |

### Contractions (6 mandatory)
| Combination | Contraction | Example |
|-------------|-------------|---------|
| de + le | du | du pain |
| de + les | des | des enfants |
| a + le | au | au restaurant |
| a + les | aux | aux Etats-Unis |
| je + vowel | j' | j'ai, j'aime, j'habite |
| ne + vowel | n' | je n'ai pas |

---

## Chapter 6: Numbers (`numbers.json`)

### 0-19
0 zero, 1 un/une, 2 deux, 3 trois, 4 quatre, 5 cinq, 6 six, 7 sept, 8 huit, 9 neuf, 10 dix, 11 onze, 12 douze, 13 treize, 14 quatorze, 15 quinze, 16 seize, 17 dix-sept, 18 dix-huit, 19 dix-neuf

### Tens 20-60
20 vingt, 30 trente, 40 quarante, 50 cinquante, 60 soixante

### Compound examples
21 vingt et un, 22 vingt-deux, 31 trente et un, 32 trente-deux

### The 70-99 System
70 soixante-dix (60+10), 71 soixante et onze (60+11), 72 soixante-douze (60+12), ..., 79 soixante-dix-neuf (60+19)
80 quatre-vingts (4x20), 81 quatre-vingt-un (4x20+1)
90 quatre-vingt-dix (4x20+10), 91 quatre-vingt-onze (4x20+11), ..., 99 quatre-vingt-dix-neuf (4x20+19)
100 cent

### Belgian/Swiss variants
70 = septante, 80 = huitante/octante, 90 = nonante

---

## Chapter 7: False Friends (`false_friends.json`)

**Expected count: 11 entries**

| French | Looks Like | Actually Means | Danger | English Equivalent |
|--------|-----------|---------------|--------|-------------------|
| blesse | blessed | injured/wounded | HIGH | beni = blessed |
| actuellement | actually | currently/right now | HIGH | en fait = actually |
| assister | to assist | to attend/be present at | MEDIUM | aider = to assist |
| attendre | to attend | to wait for | HIGH | assister = to attend |
| bras | bra | arm | FUNNY | soutien-gorge = bra |
| coin | coin (money) | corner | LOW | piece = coin |
| excite | excited | sexually aroused (!) | VERY HIGH | enthousiaste = excited |
| librairie | library | bookstore | MEDIUM | bibliotheque = library |
| preservatif | preservative | condom (!) | VERY HIGH | conservateur = preservative |
| regarder | to regard | to watch/look at | LOW | considerer = to regard |
| rester | to rest | to stay/remain | MEDIUM | se reposer = to rest |

Additional from source but not in main table:
- sympa(thique) - looks like sympathetic, means nice/friendly - LOW - compatissant = sympathetic
- envie - looks like envy, means desire/want - MEDIUM - jalousie = envy

**Note: The source document lists 13 entries total in the false friends table (lines 640-709).**

---

## Chapter 8: Liaison Rules (`liaison_rules.json`)

### Mandatory Liaisons (4 categories)
1. Article + noun: les_amis, un_homme, des_etudiants
2. Subject pronoun + verb: nous_avons, vous_etes, ils_ont
3. Adjective + noun: petit_enfant, bon_ami
4. After prepositions: en_Italie, dans_un, chez_elle

### Sound Changes (4)
1. s/x -> Z: les amis = lay-ZA-mee, deux heures = duh-ZUHR
2. d -> T: grand homme = grah(n)-TOM
3. n -> N: un ami = uh-NA-mee, bon appetit = boh-NA-pay-tee
4. t -> T: petit enfant = puh-TEE-tah(n)-fah(n)

### Elision Examples (5)
le + ami = l'ami, je + ai = j'ai, ne + ai = n'ai, de + eau = d'eau, que + il = qu'il

---

## Chapter 9: Survival Phrases (`survival_phrases.json`)

### Basics (7 entries)
1. Bonjour / Bonsoir = Hello / Good evening
2. Comment allez-vous? / Ca va? = How are you? (formal / informal)
3. Je m'appelle... / Moi, c'est... = My name is... (formal / casual)
4. Enchante(e) = Nice to meet you
5. S'il vous plait / Merci / De rien = Please / Thank you / You're welcome
6. Excusez-moi / Pardon = Excuse me / Sorry
7. Au revoir / Bonne journee / A bientot = Goodbye / Have a nice day / See you soon

### Communication Lifelines (7 entries)
1. Je ne comprends pas = I don't understand
2. Pouvez-vous repeter, s'il vous plait? = Can you repeat, please?
3. Pouvez-vous parler plus lentement? = Can you speak more slowly?
4. Comment dit-on ___ en francais? = How do you say ___ in French?
5. Qu'est-ce que ca veut dire? = What does that mean?
6. Je pense que... / A mon avis... = I think that... / In my opinion...
7. C'est-a-dire que... = That is to say... / I mean...

### Daily Life & Work (7 entries)
1. Je travaille comme... / Je suis... = I work as... / I am... (profession)
2. J'habite a... / Je viens de... = I live in... / I come from...
3. Je voudrais... / J'aimerais... = I would like... (polite requests)
4. Est-ce que je peux...? / Puis-je...? = Can I...? / May I...?
5. Il faut + infinitive = It's necessary to... / One must...
6. Je suis d'accord / Je ne suis pas d'accord = I agree / I disagree
7. D'abord... Ensuite... Enfin... = First... Then... Finally...

---

## Chapter 10: TEF Tricks (quiz_questions.json / separate file)

### Filler Words (8)
Alors, Bon/Ben, En fait, C'est-a-dire, Comment dire, Euh/Hmm, Vous savez/Tu sais, Par exemple

### Opinion Structures (6)
1. Je pense que... parce que...
2. A mon avis, ...
3. D'un cote... de l'autre cote...
4. Il y a plusieurs raisons. Premierement... Deuxiemement...
5. Je suis pour / Je suis contre
6. En conclusion...

### Recovery Strategies (5)
1. Describe: "C'est une chose qui..." / "C'est comme..."
2. Self-correct: "Non, pardon, je veux dire..."
3. Ask to rephrase: "Excusez-moi, pouvez-vous reformuler la question?"
4. Add more: "Et aussi..."
5. Switch topic: "C'est interessant, mais je voudrais aussi parler de..."
