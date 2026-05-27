>[!IMPORTANT]
>The line numbers refer to the raw version of the app without any further modules and add-ons (except for the [socarea_others] add-on).

### Module: Scientific (In)Dependence

This module enables to distinguish between scientific actors who are bound to certain partial interests in their research and scientists who are (more) independent in their scientific work. It can be integrated to the core coding process and app as follows:

1. Download the Markdown file "module_scidepend.md" and save it in the folder "source_codebuch".
2. Open the markdown file "socarea" in the folder "source_codebuch" and delete the sentence "Sollen diese weiterhin unterscheidbar bleiben von "klassischen" (unabhängigen) außeruniversitär Forschenden, sollte das <a href="https://github.com/tablue99/content_analysis_scitech_discourses/tree/d4dd47349bb7f04654d2dd9045cfccc866355b17/coding_app/modules_and_add_ons/module_scidepend" target="_blank"> Modul [scidepend]</a> diesem Kern-Codebuch hinzugefügt werden." in line 19.
3. Add the variable name "scidepend" to "variables" (line 24) and "actor_variables" (line 27). 
4. Adjust the "save_actors" function as follows:
	1. Add "scidepend" to "inputs" in line 49
	2. Make sure that the variable only contains values if [socarea] = 130 or 140 by including the following code from line 71 on:
		```{r}
		if(!inputs["socarea_wiss"] %in% c(130, 140)){
		  inputs["scidepend"] <- NA
		}
		```
5. Adjust the "set_to_last_actor_value" and "set_to_actor_values" functions by including the following code in line 360 and 390:
	```{r}
	updateRadioButtons(session = session, inputId = "scidepend", selected = actor_codes[["scidepend"]][[1]])
	```
6. Adjust the "reset_inputs" function by including the following code in line 420:
	```{r}
	updateRadioButtons(session = session, inputId = "scidepend", selected = character(0))
	```
7. Define the input element for the added variable by including this code starting in line 594:
	```{r}
	scidepend_input <- radioButtons("scidepend", label = "Wissenschaftliche (Un)Abhängigkeit",
									choices = c("unabhängige Forschung" = 0,
												"an Partialinteressen gebundene Forschung" = 1),
									selected = character(0))
	```
8. Insert the coding instruction in line 817:
	```{r}
	tabPanel(
				title = "Wissenschaftliche (Un)Abhängigkeit",
				fluidRow(column(8, includeMarkdown("source_codebuch/module_scidepend.md")))
			  ),
	```
9. Include "scidepend_input" when 130 or 140 are chosen in [socarea] by adding a comma at the end of line 1078 (behind "socarea_wiss_input") and including the following code in the next line before the closing bracket:
	```{r}
	conditionalPanel(
									   condition = "input.socarea_wiss == 130 || input.socarea_wiss == 140",
									   scidepend_input
									   )
	```
10. Make sure that the coding of the variable is required before moving on by adding ```|
       (empty_inputs(input$scidepend) == "" & empty_inputs(input$socarea_wiss) %in% c(130, 140))``` before the closing bracket in line 1149 and line 1186.
11. Again: Include "scidepend_input" in the coding when 130 or 140 is selected as [socarea] by adding a comma at the end of line 1574 (behind "socarea_wiss_input") and including the following code in the next line before the closing bracket:
	```{r}
	conditionalPanel(
									   condition = "input.socarea_wiss == 130 || input.socarea_wiss == 140",
									   scidepend_input
									 )
	```
	Repeat this step in line 1686 and 2193.