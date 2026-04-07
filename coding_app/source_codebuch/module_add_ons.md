
### Module

Module ermöglichen eine spezifischere Erfassung verschiedener, oftmals themenspezifischer Diskurselemente. Es handelt sich hierbei um vollständige Kategorien mit Codieranweisungen und Unterkategorien, die je nach Bedarf in den bisherigen Codierprozess und somit auch in die Codier-App eingebaut werden können. Wie genau und an welcher Stelle die einzelnen Module integriert werden müssen, um einen reibungslosen appgestützten Codierablauf zu gewährleisten, ist in der Anleitung, die über den Klick auf den Link zum jeweiligen Modul in einem neuen Tab geöffnet wird, beschrieben.

Aktuell stehen folgende Module bereit:

*1. Diskursübergreifende Module:*
- <a href="https://github.com/tablue99/content_analysis_scitech_discourses/tree/1718e5391812b44355f224aa0b79b2827b4d0158/coding_app/modules_and_add_ons/module_discipline" target="_blank"> Wissenschaftliche Disziplin</a> <b>[discpline]</b>: Variable, die eine Unterscheidung von Akteur:innen der Kategorie "100 = Wissenschaft" in [socarea] hinsichtlich ihrer wissenschaftlichen Fachdisziplin ermöglicht.
- <a href="https://github.com/tablue99/content_analysis_scitech_discourses/tree/b5fdcf211f81a2b518a2433d81f9ee2e1ca0db0b/coding_app/modules_and_add_ons/module_scidepend" target="_blank"> Wissenschaftliche Abhängigkeit</a> <b>[scidepend]</b>: Variable, die Akteur:innen der Kategorien "130 = außeruniversitäre Forschung" und "140 = wissenschaftliche Verbände" auf Basis ihrer Affiliation mit Blick auf die Gebundenheit an bzw. Unabhängigkeit von Partialinteressen in ihrer Forschungstätigekeit unterscheidet.
- Nicht-wissenschaftliche politische Beratung **[poladvice]**: Variable, mit deren Hilfe Mitglieder in nicht-wissenschaftlichen, politischen Beratungsgremien von klassischeren, politisch administrativen Akteur:innen in Behörden, Ministerien usw. unterschieden werden können.
- Expert:innenstatus **[expert]**: mehrere Indikatorvariablen, mit denen in Kombination mit [socarea] ermittelt werden kann, ob und um welche Art von Expert:innen es sich bei einzelnen Akteur:innen handelt.
- <a href="https://github.com/tablue99/content_analysis_scitech_discourses/tree/76cbc7c8b9cc1639377d777ccade8cc996e7b51d/coding_app/modules_and_add_ons/module_intro" target="_blank"> Bezeichnung</a> <b>[intro]</b>: Variable, mit der festgehalten wird, wie ein:e Akteur:in in einen Artikel eingeführt, d. h. den Leser:innen vorgestellt wird.
- Geographischer Bezug von Aussagen **[statement_local]**: Variable, in der festgehalten werden kann, auf welche geographischen/räumlichen Kontexte sich eine Aussage bezieht (z. B. national, international).

*Ergänzung um diskurstypspezifische Module*


### Add-Ons	

Add-Ons sind Erweiterungen einzelner bereits bestehender (Unter-)Kategorien und ermöglichen somit eine spezifischere Erfassung einzelner Eigenschaften. In Klammern ist dabei jeweils angegeben, für welche Variable aus dem Kerncodebuch ein Add-On entwickelt wurde. Eine Anleitung zur Integration sowie die genaue Auflistung der zusätzlichen Ausprägungen kann über einen Klick auf den angegebenen Link in einem neuen Tab aufgerufen werden.

Aktuell stehen folgende Add-Ons bereit:
	
*1. Diskursübergreifende Add-Ons:*
- Partei-Ergänzungen für die politische Legislative in **[socarea]**:\
*Hinweis*: Es können sowohl einzelne als auch alle Add-Ons integriert werden. Ist [socarea_polleg] integriert, werden die länderspezifischen Parteilisten als Unterkategorien der Kategorien in [socarea_polleg] geführt (erste drei Ziffern des länderspezifischen Codes definieren Überkategorie). 
	- Partei-Orientierungen (länderübergreifend) für **[socarea]** [socarea_polleg]: Eine Liste von politischen Orientierungen einzelner Parteien (z. B. konservativ, liberal, grün), die zu einer länderunspezifischen Differenzierung politisch legislativer Akteur:innen herangezogen werden kann.
	- Parteien Deutschland für **[socarea]** [socarea_polleg_ger]: Eine Liste deutscher Parteien zur Spezifizierung von Akteur:innen der deutschen politischen Legislative.
	- Parteien Großbritannien für **[socarea]** [socarea_polleg_uk]: Eine Liste von Parteien des Vereinigten Königreichs zur Spezifizierung von Akteur:innen der britischen politischen Legislative.
- Sonstiger Bereich-Spezifizierungen für **[socarea]** [socarea_others]: Zusatzausprägungen, mit denen sonstige Gesellschaftsbereiche weiter differenziert werden können (z. B. Recht, Gesundheit, öffentliche Sicherheit). Das Add-On ist standardmäßig in das Kerncodebuch integriert.
- Länder bzw. Kontinente für **[actlocal]** [actlocal_national_countries]: Eine Liste der souveränen (anerkannten) Staaten, sortiert nach Kontinenten, aus denen einzelne Nationen (oder Kontinente) sowie eine Residualkategorie ("Anderes Land") importiert werden können.
- weitere Differenzierung der Kategorie "National" in **[actlocal]** [actlocal_national]: zwei Zusatzausprägungen, mit denen Akteur:innen nicht nur national, sondern auch föderal (auf Länderebene) oder kommunal (auf Kreis-/Gemeindeebene) verortet werden können.
- Sonstige-Spezifizierungen für **[eval_subj]** [eval_subj_others]: Zusatzausprägungen, mit denen bewertete Kollektive aus dem sonstigen Bereich weiter differenziert werden können (z. B. Gesundheit, Banken, Medien).
- Sonstige-Spezifizierungen für **[addressee]** [addressee_others]: Zusatzausprägungen, mit denen kollektive Adressat:innen von Handlungsaufforderungen aus dem sonstigen Bereich weiter differenziert werden können (z. B. Gesundheit, Bildung, Medien).