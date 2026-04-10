>[!IMPORTANT]
>The line numbers refer to the raw version of the app without any further modules and add-ons (except for the [socarea_others] add-on).

### Add-On: Continent and country codes for localisations on national level

This add-on enables to further localise national actors regarding their affiliated continent or country. It can be integrated to the core coding process and app as follows:

1. Open the Markdown file "actlocal.md" from the folder "source_codebuch" and make the following changes:
	1. Delete the sentence "Die auswählbaren Länder auf nationaler Ebene können einzeln oder auf Kontinentebene aus dem <a href="https://github.com/tablue99/content_analysis_scitech_discourses/tree/74fdcfcba8674fe5641ede3ec4ae34d2d7c0f77b/coding_app/modules_and_add_ons/add_on_actlocal_national_countries" target="_blank"> Add-On [actlocal_national_countries]</a> gewählt und nach Bedarf als Unterkategorie für "1 = National" gelistet werden." in line 4 and "<i>(es ist empfohlen, mindesten die Unterkategorie "100 = Anderes Land" aus dem <a href="https://github.com/tablue99/content_analysis_scitech_discourses/tree/74fdcfcba8674fe5641ede3ec4ae34d2d7c0f77b/coding_app/modules_and_add_ons/add_on_actlocal_national_countries" target="_blank"> Add-On [actlocal_national_countries]</a> zu integrieren, um Akteur:innen aus Ländern, die nicht dem Land der Berichterstattung entsprechen, zu verorten.)</i></br>" in line 8.
	2. Choose whether you would like to integrate "100 = Anderes Land" as equal contrary to "1 = national" (Option A) or collecting category for countries that haven't been specified/included (Option B). You can combine as much categories and subcategories as you want since the provided codes are non-overlapping.
	
**Option A: Distinguishing national actors (same country as media coverage) and actors from other countries**
1. Include "<p><div style="margin-left:20px;><b>100</b> Anderes Land</div></p>" in line 10 of the "actlocal.md" file.
2. Add ```"anderes Land" = 100,``` in line 589 of the coding app to enable a selection of "100 = Anderes Land" at the same level as the other values.

**Option B: Collecting specific continents and countries as subcategories
1. Insert the text from the markdown file "add_on_actlocal_national_countries" in line 10 of the "actlocal.md" file.
2. Decide whether you'd like to code continents or countries (of course you can combine both levels by defining further input elements and embed them in conditionalPanels. If you need help with that, don't hestitate to contact the author of this coding manual/app since, at the moment, there is no distinct manual provided for that.). In this example, the values "other country", "Germany" and "USA" shall be included in the coding procedure. Make sure that the subcategories are situated at the desired level by adjusting the "margin-left" parameter, e. g., in this case we want "100", "10108" and "10223" on the same level, so all have "margin-left" parameters have to be set to 40px. Copy the chosen categories to "actlocal" (starting in line 14).
2. Add the variable name "actlocal_national_countries" to "variables" (line 24) and "actor_variables" (line 27). 
3. Adjust the "save_actors" function as follows:
	1. Add "actlocal_national_countries" to "inputs" in line 49
	2. Make sure that the variable only contains values if [actlocal] = 1 by including the following code from line 71 on:
		```{r}
		if(inputs["actlocal"] != 1){
		inputs["actlocal_national_countries"] <- NA
		}
		```
4. Adjust the "set_to_last_actor_value" and "set_to_actor_values" functions by including the following code in line 361 and 391:
	```{r}
	updateRadioButtons(session = session, inputId = "actlocal_national_countries", selected = actor_codes[["actlocal_national_countries"]][[1]])
	```
5. Adjust the "reset_inputs" function by including the following code in line 421:
	```{r}
	updateRadioButtons(session = session, inputId = "actlocal_national_countries", selected = character(0))
	```
6. Define an input element for the added subcategories by including this code starting in line 602:
	```{r}
	actlocal_national_countries_input <- radioButtons("actlocal_national_countries", label = "Land",
                                                  choices = c("Deutschland" = 10108,
                                                              "USA" = 10223,
                                                              "anderes Land" = 100),
                                                  selected = character(0))
	```
7. Include "actlocal_national_countries_input" when 1 chosen in [actlocal] by including the following code in line 1092:
	```{r}
	conditionalPanel(
                                 condition = "input.actlocal == 1",
                                 actlocal_national_countries_input
                               ),
	```
8. Include ```| (empty_inputs(input$actlocal_national_countries) == "" & input$actlocal == 1)``` in line 1144 and 1181 before the closing bracket to make sure that the new subcategories have to be coded when 1 is selected in "actlocal".
9. Again: Include "actlocal_national_countries_input" in the coding when 1 is selected in [actlocal] by including the following code in line 1588:
	```{r}
	conditionalPanel(
                                 condition = "input.actlocal == 1",
                                 actlocal_national_countries_input
                               ),
	```
	Repeat this step in line 1700 and 2207.