
### Untersuchungsgegenstand

Die mit diesem Codebuch erfassbaren Untersuchungsgegenstände stellen journalistische Berichterstattungen über verschiedene Wissenschafts- und Technologiethemen dar, die sich 1) als **medialer Wissenschafts- und Technologiediskurs** beschreiben und 2) einem der fünf in diesem Projekt fokussierten bzw. entwickelten **Diskurstypen** zuordnen lassen. 

Als medialer Wissenschafts- und Technologiediskurs gilt dabei journalistische Berichterstattung, die folgende vier Bedingungen erfüllt:

1. **Kommunikationsprozess**: Es gibt einen kommunikativen Austausch von Aussagen zwischen sozialen Akteur:innen, die in bestimmten Macht- und Wissensgefügen angeordnet sind.
2. **öffentlich zugängliche Materialisierung**: Der kommunikative Austausch ist in einer öffentlich zugänglichen Form materialisiert (automatisch zutreffend für massenmediale Berichterstattung)
3. **Kontroverse**: Es gibt einen kommunikativen Wettbewerb um Aufmerksamkeit und Deutungsmacht zwischen verschiedenen Akteur:innen hinsichtlich eines gesamtgesellschaftlich oder für große Teile der Gesellschaft relevanten Subjekts (Thema, Ereignis, usw., in der Folge: Diskursgegenstand)
4. **Wissenschafts- und Technologiebezug**: Der Diskursgegenstand ist ein materielles oder immaterielles Produkt, das von Individuen oder Organisationen, die wissenschaftliche Methoden anwenden und wissenschaftliche Werte und Normen vertreten, hervorgebracht wurde. Das bedeutet konkret, ein Diskurs wird entweder\
	a. durch wissenschaftliche Akteur:innen oder Praktiken _veranlasst_ (z. B. Technologien, medizinische Erzeugnisse, (un)vorhergesehene Konsequenzen wie Unfälle, Transformationen...), oder\
	b. wissenschaftlichen Akteur:innen zur Problemlösung, Untersuchung oder anderweitigen Auseinandersetzung _zugewiesen_ (z. B. Krisen/Bedrohungen, (Natur-)Katastrophen...), oder\
	c. regelmäßig und intensiv durch wissenschaftliche Akteur:innen _begleitet_ (z. B. durch Überwachung oder Beratung).
		
Darunter werden folgende Diskurstypen unterschieden:

1. **Umweltkrisendiskurse**: [Definition]
2. **Innovationsdiskurse**: [Definition]
3. **Katastrophen- oder Bedrohungsdiskurse**: [Definition]
4. **(Individual-)Gesundheitsdiskurse**: [Definition]
5. **Sozialdiskurse**: [Definition]

### Mediensample, Suchstrings und Untersuchungszeiträume

In der ersten, explorativen Anwendung des Codebuchs wurden die folgenden Einzeldiskurse untersucht. Die relevante Berichterstattung wurde dabei mit den jeweils angegebenen Suchstrings in den genannten Zeiträumen ermittelt:

1. *Beispieldiskurs Umweltkrise* (Zeitraum): **Suchstring** (Accuracy = , Precision = , Recall = , F-Wert = )
2. *Beispieldiskurs Innovation* (Zeitraum): **Suchstring** (Accuracy = , Precision = , Recall = , F-Wert = )
3. *Beispieldiskurs Katastrophe/Bedrohung* (Zeitraum): **Suchstring** (Accuracy = , Precision = , Recall = , F-Wert = )
4. *Beispieldiskurs Gesundheit* (Zeitraum): **Suchstring** (Accuracy = , Precision = , Recall = , F-Wert = )
5. *Beispieldiskurs Sozial* (Zeitraum): **Suchstring** (Accuracy = , Precision = , Recall = , F-Wert = )

In der zweiten, hypothesengeleiteten Anwendung des Codebuchs wurden die folgenden Einzeldiskurse untersucht und die relevante Berichterstattung mit folgenden Suchstrings in den angegebenen Zeiträumen ermittelt:

1. *Beispieldiskurs Umweltkrise* (Zeitraum): **Suchstring** (Accuracy = , Precision = , Recall = , F-Wert = )
2. *Beispieldiskurs Innovation* (Zeitraum): **Suchstring** (Accuracy = , Precision = , Recall = , F-Wert = )
3. *Beispieldiskurs Katastrophe/Bedrohung* (Zeitraum): **Suchstring** (Accuracy = , Precision = , Recall = , F-Wert = )
4. *Beispieldiskurs Gesundheit* (Zeitraum): **Suchstring** (Accuracy = , Precision = , Recall = , F-Wert = )
5. *Beispieldiskurs Sozial* (Zeitraum): **Suchstring** (Accuracy = , Precision = , Recall = , F-Wert = )
	
Das dabei jeweils herangezogene Mediensample umfasst [xx] Printmedientitel, darunter sowohl überregionale Tageszeitungen, ausgewählte regionale und lokale Tageszeitungen und Wochenmagazine:
	
- *Wochenmagazine*:
- *überregionale Tageszeitungen*:
- *regionale Tageszeitungen*:
- *lokale Tageszeitungen*:
	
Abgerufen wurden die Beiträge aus den Datenbanken <a href="https://www.nexisuni.com" target="_blank"> LexisNexis/Nexis Uni</a> und <a href="https://www.wiso-net.de/" target="_blank"> wiso</a>.

### Methode

Für die Codierung werden automatisierte Verfahren mit einem computer- bzw. app-gestützten manuellen, inhaltsanalytischen Vorgehen kombiniert.

Zur Identifikation der in der Berichterstattung vorkommenden Akteur:innen kommt das *flairNER*-Verfahren (NER = Named Entity Recognition) für deutsche Texte zum Einsatz. Anschließend werden die identifizierten Akteur:innen an ein Python-Skript (*"identify_relevant_actors_ki_toolbox"*) übergeben, mit dem die Relevanz (siehe [relevant] im Kategoriensystem) mithilfe des lokalen Large Language Models (LLM) *kit.gpt-oss-120b* automatisiert bestimmt wird. Dieser vorcodierte Datensatz wird dann mithilfe einer Funktion zur Ermittlung des längsten gemeinsamen Teilstrings ("longest common substring") (*"common_string"*) sowie dreier eigener auf die NER-Datensätze angepasster R-Funktionen (*"prepare_duplicate_dataframe"*, *"find_duplicates"* und *"mark_relevant_actors"*) (alle vier Funktionen sind im Package *"actordupes"* gebündelt) auf mehrfach in einem Artikel erwähnte Akteur:innen (sogenannte Duplikate) gemäß ihrer (Nach-)Namensähnlichkeit (Schwellenwert: 0.8) überprüft, diese nachträglich als irrelevant markiert und herausgefiltert (**NERRD-Pipeline**).

In der dann folgenden app-gestützten manuellen Inhaltsanalyse werden die verbleibenden relevanten (= aktiven) Akteur:innen näher hinsichtlich der hier beschriebenen diskursübergreifenden (und optional über die Module hinzugefügten, spezifischeren) Eigenschaften unterschieden.