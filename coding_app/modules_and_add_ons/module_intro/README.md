>[!IMPORTANT]
>The line numbers refer to the raw version of the app without any further modules and add-ons (except for the [socarea_others] add-on).

### Module: Introduction

This module enables to code the attributes used to introduce/describe a specific actor at their first mention in a journalistic article. It can be integrated to the core coding process and app as follows:

1. Download the Markdown file "module_intro.md" and save it in the folder "source_codebuch".
2. Add the variable name "intro" to "variables" (line 24) and "actor_variables" (line 27). 
3. Adjust the "save_actors" function as follows:
	1. Add "intro" to "inputs" in line 49
	2. Make sure that multiple selected answers are saved in one column of the data frame by including the following code from line 77 on:
		```{r}
		else if(variable == "intro"){
		  full_dataset[full_dataset$entity_id == actor$entity_id, variable] <<- paste(inputs[[variable]], collapse = ", ")
		}
		```
4. Adjust the "set_to_last_actor_value" and "set_to_actor_values" functions by including the following code in line 352 and 382:
	```{r}
	updateCheckboxGroupInput(session = session, inputId = "intro", selected = actor_codes[["intro"]][[1]])
	```
5. Adjust the "reset_inputs" function by including the following code in line 412:
	```{r}
	updateCheckboxGroupInput(session = session, inputId = "intro", selected = character(0))
	```
6. Define the input element for the added variable by including this code starting in line 533:
	```{r}
	intro_input <- checkboxGroupInput("intro", label = "Bezeichnung (Mehrfachauswahl möglich)",
									  choices = c("Zuordnung zu Institution" = 1,
												  "Berufsbezeichnung" = 2,
												  "Tätigkeitsbeschreibung" = 3,
												  "Verweis auf Qualifikation" = 4,
												  "Titelnennung" = 5,
												  "sonstige Beschreibung/Bezeichnung" = 99,
												  "nur Name" = 0),
									  selected = character(0))
	```
7. Insert the coding instruction in line 814:
	```{r}
	tabPanel(
				title = "Bezeichnung",
				fluidRow(column(8, includeMarkdown("source_codebuch/module_intro.md")))
			  ),
	```
8. Include "intro_input" in the coding on actor level by adding a comma at the end of line 1077 (behind "affiliation_input") and typing "intro_input," in the next line.
9. Make sure that the coding of the variable is required before moving on by adding ```empty_inputs(input$intro),``` between "input$affiliation" and "empty_inputs(input$gender)" in line 1144 and line 1183 and include the following code starting from line 1153 and 1192:
	```{r}
	else if(length(input$intro) > 1 & 0 %in% input$intro){
		  show_alert(title = "Fehler", text = "Wenn bei der Bezeichnung \"nur Name\" ausgewählt wurde, darf keine weitere Ausprägung ausgewählt werden.", type = "error")
		}
	```
	
10. Again: Include "intro_input" in the coding on actor level by adding a comma at the end of line 1575 (behind "affiliation_input") and typing "intro_input," in the next line. Repeat this step in line 1684 and 2188.