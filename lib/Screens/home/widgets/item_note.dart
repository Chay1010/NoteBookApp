import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:notebook_projectf/Screens/add_note/add_note_screen.dart';
import 'package:notebook_projectf/models/note.dart';


class ItemNote extends StatelessWidget {
  final Note note;
  final String searchQuery;
  final VoidCallback onRefresh;
  const ItemNote({super.key, required this.note, required this.searchQuery,required this.onRefresh,});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () async {
        await Navigator.push(context, MaterialPageRoute(builder: (_) => AddNoteScreen(note: note)));
        onRefresh();
      },
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 10),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 5),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                color: Color(0xFFFFB778),
              ),
              child: Column(
                children: [
                  Text(
                      DateFormat(DateFormat.ABBR_MONTH).format(note.createdAt),
                      style: const TextStyle(color: Colors.white70),
                  ),
                  const SizedBox(height: 3,),
                  Text(
                    DateFormat(DateFormat.DAY).format(note.createdAt),
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.bold
                    ),
                  ),
                  const SizedBox(height: 3,),
                  Text(
                    note.createdAt.year.toString(),
                    style: TextStyle(color: Colors.white70),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 15,),
            Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: RichText(
                            text: TextSpan(
                              children: _getHighlightedSpans(
                                note.title,
                                searchQuery,
                                Theme.of(context).textTheme.titleMedium!,
                              ),
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        Text(
                          DateFormat(DateFormat.HOUR_MINUTE).format(note.createdAt),
                          style: Theme.of(context).textTheme.bodySmall,
                        )
                      ],
                    ),
                    RichText(
                      text: TextSpan(
                        children: _getHighlightedSpans(
                          note.description,
                          searchQuery,
                          const TextStyle(
                            fontWeight: FontWeight.w300,
                            height: 1.5,
                            color: Colors.black, // Assurez-vous de définir une couleur
                          ),
                        ),
                      ),
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ))
          ],
        ),
      ),
    );
  }
}

List<TextSpan> _getHighlightedSpans(String text, String query, TextStyle textStyle) {
  if (query.isEmpty) {
    return [TextSpan(text: text, style: textStyle)]; // Affiche le texte normal s'il n'y a pas de recherche
  }

  final queryLower = query.toLowerCase();
  final textLower = text.toLowerCase();
  final matches = <TextSpan>[];

  int start = 0;

  while (start < text.length) {
    final matchIndex = textLower.indexOf(queryLower, start);

    if (matchIndex == -1) {
      matches.add(TextSpan(text: text.substring(start), style: textStyle)); // Ajoute le reste du texte
      break;
    }

    if (start < matchIndex) {
      matches.add(TextSpan(text: text.substring(start, matchIndex), style: textStyle)); // Texte avant le match
    }

    matches.add(TextSpan(
      text: text.substring(matchIndex, matchIndex + query.length),
      style: textStyle.copyWith(backgroundColor: Colors.yellow), // Met en surbrillance
    ));

    start = matchIndex + query.length;
  }

  return matches;
}

