>[!IMPORTANT]
>The line numbers refer to the raw version of the app without any further modules and add-ons (except for the [socarea_others] add-on).

### Module: Political Advice

This module enables to distinguish between administrative actors who are part of a political advisory board and other actors belonging to the political administration. It can be integrated to the core coding process and app as follows:

1. Download the Markdown file "module_poladvice.md" and save it in the folder "source_codebuch".
2. Open the file "socarea" in the folder "source_codebuch" and delete the sentence " Sollen diese Akteur:innen später noch unterscheidbar sein, kann das <a href="https://github.com/tablue99/content_analysis_scitech_discourses/tree/d4dd47349bb7f04654d2dd9045cfccc866355b17/coding_app/modules_and_add_ons/module_poladvice" target="_blank"> Modul [poladvice]</a> an dieser Stelle in den Kern integriert werden." in line 29.
3. Add the variable name "poladvice" to "variables" (line 24) and "actor_variables" (line 27). 
4. Adjust the "save_actors" function as follows:
	1. Add "poladvice" to "inputs" in line 49
	2. Make sure that the variable only contains values if [socarea] = 220 by including the following code from line 71 on:
		```{r}
		if(inputs["socarea_oberkat"] == 200 & inputs["socarea_pol"] != 220 | inputs["socarea_oberkat"] != 200){
		inputs["poladvice"] <- NA
		}
		```
	3. Include "poladvice" in line 77
5. Adjust the "set_to_last_actor_value" and "set_to_actor_values" functions:
	1. Add "poladvice" in line 340 and 370
	2. Include the following code in line 357 and 387:
		```{r}
		updateCheckboxInput(session = session, inputId = "poladvice", value = as.logical(actor_codes[["poladvice"]][[1]]))
		```
6. Adjust the "reset_inputs" function by including the following code in line 417:
	```{r}
	updateCheckboxInput(session = session, inputId = "poladvice", value = FALSE)
	```
7. Define the input element for the added variable by including this code starting in line 599:
	```{r}
	poladvice_input <- wellPanel(style = "background-color:#ffffff;",
								 p("Politische Beratung"),
								 checkboxInput("poladvice", label = "Akteur:in gehört zu einem Gremium, das politische Beratung betreibt.",
											   value = FALSE))
	```
8. Insert the coding instruction in line 813:
	```{r}
	tabPanel(
				title = "Politische Beratung",
				fluidRow(column(8, includeMarkdown("source_codebuch/module_poladvice.md")))
			  ),
	```
9. Include "poladvice_input" when 220 is chosen in [socarea] by adding a comma at the end of line 1077 (behind "socarea_pol_input") and including the following code in the next line before the closing bracket:
	```{r}
	conditionalPanel(
									   condition = "input.socarea_pol == 220",
									   poladvice_input
									 )
	```
10. Again: Include "poladvice_input" in the coding when 220 is selected as [socarea] by adding a comma at the end of line 1571 (behind "socarea_pol_input") and including the following code in the next line before the closing bracket:
	```{r}
	conditionalPanel(
									   condition = "input.socarea_pol == 220",
									   poladvice_input
									 )
	```
	Repeat this step in line 1683 and 2190.
11. Make sure that "poladvice" is batched as logical in the "codebogen" by adding "poladvice" in line 1749.