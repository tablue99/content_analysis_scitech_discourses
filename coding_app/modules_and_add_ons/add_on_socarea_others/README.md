>[!IMPORTANT]
>The line numbers refer to the raw version of the app without any further modules and add-ons (except for the [socarea_others] add-on).

### Add-On: Further specification of other societal areas

This add-on enables to further describe the societal area of peripheral actors that would otherwise be coded with "400 = sonstiger Bereich". It is per default integrated in the core coding process and can be removed as follows:

1. Open the markdown file "socarea" in the folder "source_codebuch" and delete the lines 61 to 82 at first. Additionally, replace line 20 with the following text "Auch forschende Mitarbeiter:innen von Museen (z. B. Naturkundemuseum), Sammlungen oder botanischen Gärten werden in dieser Unterkategorie verortet. Nicht forschende Mitarbeiter:innen dieser Einrichtungen sind unter "400 = Sonstiges" zu erfassen." Then delete line 44 ("Hinweis") as well as 54 ("ACHTUNG").
2. Delete the variable "socarea_sonst" in line 24 and 27.
3. Adjust the "save_actors" function as follows:
	1. Remove "socarea_sonst" from line 49, 54, 57, 60, 63 and 66.
	2. Exchange the code in line 88 with ```socarea_oberkat == 400 ~ socarea_oberkat```
4. Delete line 356, 384 and 412.
5. Remove the input element by deleting line 574 to 583.
6. Remove the conditional Panel from line 1062 to 1064.
7. Delete ``` | (empty_inputs(input$socarea_sonst) == "" & input$socarea_oberkat == 400)``` from line 1111 and 1146.
8. Again: Remove the conditional Panel by deleting line 1547 to 1549 and repeat this step from line 1652 to 1654 and 2152 to 2154.