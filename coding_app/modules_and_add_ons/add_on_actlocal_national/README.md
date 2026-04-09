>[!IMPORTANT]
>The line numbers refer to the raw version of the app without any further modules and add-ons (except for the [socarea_others] add-on).

### Add-On: Specification of localisations on national level

This add-on enables to further specify whether national actors are active on national, Federal State or local level. It can be integrated to the core coding process and app as follows:

1. Open the Markdown file "actlocal.md" from the folder "source_codebuch" and make the following changes:
	1. Delete the sentence "Zusätzlich steht ein <a href="linkzuactlocal_national" target="_blank"> Add-On [actlocal_national]</a> bereit, mit dem die nationale Ebene weiter auf die föderale oder lokale/kommunale Ebene heruntergebrochen werden kann, um bspw. Lokalpolitiker:innen von Bundespolitiker:innen zu unterscheiden." in line 4.
	2. Exchange line 9 for the text from the markdown file "add_on_actlocal_national.md".
2. Add the variable name "actlocal_national" to "variables" (line 24) and "actor_variables" (line 27). 
3. Adjust the "save_actors" function as follows:
	1. Add "actlocal_national" to "inputs" in line 49
	2. Make sure that the variable only contains values if [actlocal] = 1 by including the following code from line 71 on:
		```{r}
		if(inputs["actlocal"] != 1){
		inputs["actlocal_national"] <- NA
		}
		```
	3. Write the subcategories to "actlocal" by including the following code in line 95:
		```{r}
		inputs["actlocal"] <- with(as.list(inputs), {case_when(
		!is.na(actlocal_national) ~ actlocal_national,
		is.na(actlocal_national) ~ actlocal
		)})
		full_dataset[full_dataset$entity_id == actor$entity_id, "actlocal"] <<- as.numeric(inputs["actlocal"])
		```
4. Adjust the "set_to_last_actor_value" and "set_to_actor_values" functions by including the following code in line 368 and 399:
	```{r}
	updateRadioButtons(session = session, inputId = "actlocal_national", selected = actor_codes[["actlocal_national"]][[1]])
	```
5. Adjust the "reset_inputs" function by including the following code in line 430:
	```{r}
	updateRadioButtons(session = session, inputId = "actlocal_national", selected = character(0))
	```
6. Define an input element for the added subcategories by including this code starting in line 611:
	```{r}
	actlocal_national_input <- radioButtons("actlocal_national", label = "Nationale Ebene",
                                        choices = c("Föderal" = 11,
                                                    "Kommunal" = 12,
                                                    "Nicht spezifiziert/national" = 1),
                                        selected = character(0))
	```
7. Include "actlocal_national_input" when 1 chosen in [actlocal] by including the following code in line 1101:
	```{r}
	conditionalPanel(
                                 condition = "input.actlocal == 1",
                                 actlocal_national_input
                               ),
	```
8. Include ``` | (empty_inputs(input$actlocal_national) == "" & input$actlocal == 1)``` in line 1154 and 1191 before the closing bracket to make sure that the new subcategories have to be coded when 1 is selected in "actlocal".
9. Again: Include "actlocal_national_input" in the coding when 1 is selected in [actlocal] by including the following code in line 1595:
	```{r}
	conditionalPanel(
                                 condition = "input.actlocal == 1",
                                 actlocal_national_input
                               ),
	```
	Repeat this step in line 1707 and 2214.