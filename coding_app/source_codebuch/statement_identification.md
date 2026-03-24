
### Formale Variablen und Filter - Aussagenebene

Nach Abschluss der Codierung auf Akteursebene werden die einzelnen Aussagen eines:einer Akteur:in im Artikel nacheinander erfasst und codiert.

###### **Identifikation** [statement]
Ehe einzelne Aussagen von Akteur:innen hinsichtlich ihrer Eigenschaften codiert werden können, müssen diese im Artikel identifiziert und dem:der Akteur:in, der:die sie getätigt hat, korrekt zugeordnet werden.\
In der Codier-App können hierfür nach abgeschlossener Akteurscodierung in einem Freitextfeld einzelne Aussagen des:der Akteur:in erfasst werden.
Eine Aussage ist dabei definiert als eine in sich geschlossene Informationseinheit, die einen abgrenzbaren, semantischen Sinn ergibt ("Sinneinheiten" oder "inhaltlich vollständige Gedanken") und sich eindeutig dem:der vorab als aktiv identifizierten Akteur:in zuordnen lässt. Sie besteht demnach immer aus **drei Bestandteilen**:

1. einem:einer **Urheber:in** der Aussage (= codierte:r Akteur:in),
2. einem **Aussagentyp** sowie
3. einer **Aussagentendenz**

Eine Aussage kann nur dann codiert werden, wenn alle drei Elemente erkennbar sind. **Ändert sich eines dieser drei Elemente, beginnt eine neue Aussage**. Das bedeutet auch:

- eine Aussage muss nicht identisch mit der grammatikalischen Einheit eines Satzes sein. Sie kann aus einzelnen Satzteilen, aber auch mehreren Sätzen bestehen.
- ein und dieselbe Äußerung eines:einer Akteur:in kann mehrere Aussagen enthalten. Dieselbe Äußerung muss dann mehrfach in das Freitextfeld eingetragen werden.
- eine Aussage kann auch in Form von **indirekter Rede** oder **Attribuierungen** (Journalist:in schreibt, dass der:die Akteur:in etwas gesagt hat) vorliegen. Daher können nicht nur doppelte Anführungszeichen oder ähnliche Markierungen direkter Zitierungen auf Aussagen hindeuten, sondern auch **Konjunktiv-Formulierungen** oder Einleitungen wie "x sagt, dass", "x meint, dass" usw.

Für die korrekte Identifikation von Aussagen muss somit bereits immer die weitere Codierung des Aussagentyps und der Aussagentendenz mitbedacht und geprüft werden, ob sich eines dieser beiden Elemente ändert. Ab diesem Punkt muss eine neue Aussage codiert und dem:der Akteur:in zugeordnet werden. 
Es werden ausschließlich **wörtliche oder indirekte Aussagen der Akteur:innen** codiert. Textstellen wie "Er hat sich seit den Weihnachtsferien intensiv mit Wissenschaft befasst", "Vom Potenzial der Methode zeigt sie sich beeindruckt" oder "In der Methode sieht x viel Potenzial" sind **alleinstehend NICHT als codierbare Aussagen zu betrachten**. Nur wenn sie mit klar zuzuordnender direkter oder indirekter Rede kombiniert sind, können sie als Aussage codiert werden, z. B. "In der Methode sieht x viel Potenzial. So könne beispielsweise ein komplettes Gen deaktiviert oder umstrukturiert werden." oder "Vom Potenzial der Methode zeigt sie sich beeindruckt. Ihr eigener Versuch, damit ein komplettes Gen zu deaktivieren, habe/hätte erstaunlich gut funktioniert."

*Hinweis*: Gegebenenfalls kann es hilfreich sein, die Aussage zu paraphrasieren und im Hinterkopf die Dreierstruktur aus Urheber:in, Aussagentyp und -tendenz mitzudenken. Auch Prädikate wie "x sagt y und fordert z" können hilfreich sein. Bei "sagt" beginnt hier beispielsweise die erste Aussage (Aussagetyp: Sachaussage) und bei "fordert" die zweite (Aussagetyp: Handlungsaufforderung).

**ACHTUNG**: Wird eine Aussage von mehreren Akteur:innen gemeinsam getätigt, wird sie für jede:n dieser Akteur:innen einmal codiert. Es wird also von unterschiedlichen Akteur:innen ausgehend mehrfach die gleiche Aussage codiert. Beispiel: "Sowohl x als auch y sind der Meinung, dass die inhaltsanalytische Erforschung von Wissenschafts- und Technologiediskursen nicht ausreichend theoretisch fundiert und dadurch chaotisch ist."

**ACHTUNG**: Eine Aussage kann nicht mehrere Absätze umfassen. Mit jedem neuen Absatz wird, falls vorhanden, eine neue Aussage codiert.

###### **Aussagen-ID** [statement_id]
Jede im Freitextfeld erfasste Aussage erhält automatisch eine einzigartige Aussagen-ID, die sich aus der [entity_id] des:der Expert:in und der Reihenfolge ihrer Identifikation ergibt (z. B. erste Aussage des:der Akteur:in 100401 = 100401**1**. Eine manuelle Codierung ist nicht erforderlich.

###### **FILTER: Bezug zum Diskursgegenstand** [relevant_statement]
Für die weitere Aussagencodierung sind nur Aussagen von Belang, die einen direkten Bezug zum a) Diskursgegenstand oder b) anderen relevanten Akteur:innen im Diskurs aufweisen.
Als andere relevante Akteur:innen im Diskurs gelten sowohl Akteur:innen, die im selben Artikel mit mindestens einer Aussage zum Diskursgegenstand ([relevant_quote] = 1) vorkommen als auch Akteur:innen, die im Kontext eines Diskurses allgemein bekannt sind, aber nicht selbst innerhalb des Artikels aktiv werden (z. B. Sam Altman im KI-Diskurs, Greta Thunberg im Klimawandel-Diskurs). 
In der Filtervariable wird entsprechend unterschieden zwischen:
<p><div style="margin-left:20px;"><b>0</b> Aussage hat keinen Bezug zum Diskurs(gegenstand) </br>
DIE CODIERUNG WIRD BEENDET.</br>
Sämtliche Aussagen, die sich weder direkt (explizite Nennung) oder indirekt (aus dem inhaltlichen Kontext) mit dem Diskursgegenstand befassen noch ein:e andere:n relevante:n Akteur:in im Diskurs erwähnen, z. B. im KI-Diskurs getätigte Aussagen, die sich auf den Zustand der Technologieentwicklung oder das Bildungsniveau im Allgemeinen beziehen ("Deutschland hängt bei der Entwicklung neuer Technologien hinterher.", "Die Leistungen der Jugendlichen werden immer besser."). Wird diese Ausprägung codiert, ist die Codierung der Aussage an dieser Stelle beendet.</div></p>
<p><div style="margin-left:20px;"><b>1</b> Aussage bezieht sich auf den Diskursgegenstand</br>
<i>Hinweis: Diese Ausprägung wird nicht direkt codiert, sondern automatisch festgelegt, wenn die beiden Filter "0 = Aussage hat keinen Bezug zum Diskurs(gegenstand)" und "2 = Aussage bezieht sich auf eine:n andere:n relevante:n Akteur:in" NICHT ausgewählt werden, entsprechend ist keine weitere manuelle Codierung erforderlich.</i></div></p>
<p><div style="margin-left:20px;"><b>2</b> Aussage bezieht sich auf eine:n andere:n relevante:n Akteur:in</br>
Sämtliche Aussagen, in denen eindeutig ein:e andere:r relevante:r Akteur:in durch eine explizite namentliche Nennung adressiert/angesprochen wird und keine weiteren inhaltlichen Bezüge zum Diskursgegenstand ("1 = Aussage bezieht sich auf Diskursgegenstand) oder anderen Themen ("0 = Aussage hat keinen Bezug zum Diskurs(gegenstand)") hergestellt werden.</div></p>