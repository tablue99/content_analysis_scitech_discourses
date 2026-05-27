>[!IMPORTANT]
>The line numbers refer to the raw version of the app without any further modules and add-ons (except for the [socarea_others] add-on).

### Module: Scientific discipline

This module enables the identification of scientific disciplines for scientific actors ([socarea] = 100). It can be integrated to the core coding process and app as follows:

1. Download the Markdown file "module_discipline.md" and save it in the folder "source_codebuch".
2. Open the file "socarea" in the folder "source_codebuch" and delete the note "*Hinweis*: Um wissenschaftliche Akteur:innen gemäß ihrer Fachdisziplin zu verorten, steht das <a href="https://github.com/tablue99/content_analysis_scitech_discourses/tree/f090bad157c413a4a40ddf4113ea87d7be2d842e/coding_app/modules_and_add_ons/module_discipline" target="_blank"> Modul [discipline]</a> zur Verfügung." in line 24.
3. Add the variable name "discipline" to "variables" (line 24) and "actor_variables" (line 27). 
4. Adjust the "save_actors" function as follows:
	1. Add "discipline" to "inputs" in line 49.
	2. Add a plausibility check starting before the bracket in line 71. Include:
		```{r}
		if(inputs["socarea_oberkat"] != 100){
		  inputs["discipline"] <- NA
		}
		```
5. Adjust the "set_to_last_actor_value" and "set_to_actor_values" functions by including the following code in line 361 and 391:
	```{r}
	updateRadioButtons(session = session, inputId = "discipline", selected = actor_codes[["discipline"]][[1]])
	```
6. Adjust the "reset_inputs" function by including the following code in line 421:
	```{r}
	updateRadioButtons(session = session, inputId = "discipline", selected = character(0))
	```
7. Define the input element for the added variable by including this code starting in line 595:
	```{r}
	discipline_input <- radioButtons("discipline", label = "Wissenschaftliche Disziplin",
                                 choices = c("Geisteswissenschaften" = 1,
                                             "Sozial- und Verhaltenswissenschaften" = 2,
                                             "Biologie" = 3,
                                             "Medizin" = 4,
                                             "Agrar-, Forstwissenschaften & Tiermedizin" = 5,
                                             "Chemie" = 6,
                                             "Physik" = 7,
                                             "Mathematik" = 8,
                                             "Geowissenschaften" = 9,
                                             "Informatik, System- & Elektrotechnik" = 10,
                                             "Ingenieurwissenschaften" = 11,
                                             "Bauwesen & Architektur" = 12,
                                             "interdisziplinär" = 13,
                                             "kein:e Forscher:in" = 14,
                                             "nicht feststellbar" = 99),
                                 selected = character(0))
	```
8. Insert the coding instruction in line 830:
	```{r}
	tabPanel(
				title = "Wissenschaftliche Disziplin",
				fluidRow(column(8, includeMarkdown("source_codebuch/module_discipline.md")))
			  ),
	```
9. Include "discipline_input" in the conditional panel that is dependent on the selection of "100 = Wissenschaft" in [socarea_oberkat] by adding a comma at the end of line 1091 (behind "socarea_wiss_input") and typing "discipline_input" in the next line before the closing bracket.
10. Make sure that the coding of the variable is required when "100 = Wissenschaft" is selected before moving on by adding ```| (empty_inputs(input$discipline) == "" & input$socarea_oberkat == 100)``` before the closing brackets in line 1158 and line 1195.
11. Again: Include "discipline_input" in the conditional panel that is dependent on the selection of "100 = Wissenschaft" in [socarea_oberkat] by adding a comma at the end of line 1584 (behind "socarea_wiss_input") and typing "discipline_input" in the next line before the closing bracket. Repeat this step in line 1693 and 2197.