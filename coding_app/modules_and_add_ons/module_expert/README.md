>[!IMPORTANT]
>The line numbers refer to the raw version of the app without any further modules and add-ons (except for the [socarea_others] add-on).

### Module: Expert status / Expertise

This module contains three variables that determine together with [socarea] and [scidepend] (if applicable [poladvice]) the so-called "expert status" regarding the subject of debate of an actor. It can be integrated in the core coding process as follows:

1. Download the Markdown file "module_expert.md" and save it in the folder "source_codebuch".
2. Include the module <a href="https://github.com/tablue99/content_analysis_scitech_discourses/tree/990931cc91410644578b796d3cafd4ad5b3cf7ec/coding_app/modules_and_add_ons/module_scidepend" target="_blank">[scidepend]</a> as described in the coding app.
3. Add the variable names "exp_call", "no_insider" and "exp_domain" to "variables" (line 24) and "actor_variables" (line 27). 
4. Define a vector to mark specific descriptions/words associated with experts and expertise by writing ```expert_calls <- "[Ee]xpert\\w*|[Ss]pezialist\\w*|Fachm[aä]nn\\w*|Fachfrau\\w*|Fachleute\\w*|[Ss]achkundige\\w*|Koryphäe\\w*"``` in line 31.
5. Adjust the "save_actors" function as follows:
	1. Add "exp_call", "no_insider" and "exp_domain" to "inputs" in line 52.
	2. Add two plausibility checks starting before the bracket in line 77. Include:
		```{r}
		if(!as.logical(inputs["relevant_quote"])){
		inputs[c("exp_call", "no_insider", "exp_domain")] <- NA
		}
		if(as.logical(inputs["relevant_quote"]) & !as.logical(inputs["exp_call"]) & !as.logical(inputs["no_insider"])){
		inputs["exp_domain"] <- NA
		}
		```
	3. Include the logical variables "exp_call" and "no_insider" in line 86.
	4. Generate the new variable "expert" that determines the expert status from the three indicators, [socarea] and [scidepend]. Include the following code from line 104 on:
		```{r}
		inputs["expert"] <- with(as.list(inputs), {case_when(
		relevant_quote == TRUE & (!socarea %in% c(100, 110, 120, 200, 210, 220, 230:237, 310:312, 330, 410, 460) & !(socarea %in% c(130, 140) & scidepend == 0)) & ((exp_call == TRUE | (exp_call == FALSE & no_insider == TRUE)) & exp_domain %in% c(1, 2, 6)) ~ 1,
		relevant_quote == TRUE & (socarea %in% c(100, 110, 120) | (socarea %in% c(130, 140) & scidepend == 0)) & ((exp_call == TRUE | (exp_call == FALSE & no_insider == TRUE)) & exp_domain %in% c(1, 2)) ~ 2,
		relevant_quote == TRUE & ((exp_call == TRUE | (exp_call == FALSE & no_insider == TRUE)) & exp_domain == 3) ~ 3,
		relevant_quote == TRUE & socarea %in% c(120, 220, 300, 310:312, 320:322) & ((exp_call == TRUE | (exp_call == FALSE & no_insider == TRUE)) & exp_domain == 4) ~ 4,
		relevant_quote == TRUE & socarea %in% c(200, 210, 220, 230:237) & ((exp_call == TRUE | (exp_call == FALSE & no_insider == TRUE)) & exp_domain == 5) ~ 5,
		relevant_quote == TRUE & (socarea %in% c(100, 110, 120, 310:312, 410, 460) | (socarea %in% c(130, 140) & scidepend == 0)) & ((exp_call == TRUE | (exp_call == FALSE & no_insider == TRUE)) & exp_domain %in% c(5, 6)) ~ 6,
		relevant_quote == TRUE & socarea %in% c(300, 310:312, 320:322, 330, 470) & ((exp_call == TRUE | (exp_call == FALSE & no_insider == TRUE)) & exp_domain == 7) ~ 7,
		.default = 8
		)})
		full_dataset[full_dataset$entity_id == actor$entity_id, "expert"] <<- as.numeric(inputs["expert"])
		``` 
		<i>Note</i>: If [poladvice] is also included add "220 + poladvice = TRUE" to value 6 by changing the line to ```relevant_quote == TRUE & (socarea %in% c(100, 110, 120, 310:312, 410, 460) | (socarea %in% c(130, 140) & scidepend == 0) | (socarea == 220 & poladvice == TRUE)) & ((exp_call == TRUE | (exp_call == FALSE & no_insider == TRUE)) & exp_domain %in% c(5, 6)) ~ 6,```.
6. Adjust the "set_to_last_actor_value" and "set_to_actor_values" functions by including "exp_call" and "no_insider" in line 361 and 394 as well as the following code in line 385 to 387 and 418 to 420:
	```{r}
	updateCheckboxInput(session = session, inputId = "exp_call", value = as.logical(actor_codes[["exp_call"]]))
	updateCheckboxInput(session = session, inputId = "no_insider", value = as.logical(actor_codes[["no_insider"]]))
	updateRadioButtons(session = session, inputId = "exp_domain", selected = actor_codes[["exp_domain"]][[1]])
	```
7. Adjust the "reset_inputs" function by including the following code in line 451 to 453:
	```{r}
	updateCheckboxInput(session = session, inputId = "exp_call", value = FALSE)
	updateCheckboxInput(session = session, inputId = "no_insider", value = FALSE)
	updateRadioButtons(session = session, inputId = "exp_domain", selected = character(0))
	```
8. Create a function to mark the words associated with experts in the shown text by including the following code in line 510:
	```{r}
	mark_expert_calls <- function(expert_call){
	paste0("<mark style=\"background-color: #f2ef00;\"><strong>", expert_call, "</strong></mark>")
	}
	```
9. Define the input elements for the added variables by including this code starting in line 646:
	```{r}
	exp_call_input <- checkboxInput("exp_call", label = "Akteur:in wird als Expert:in bezeichnet.",
                                value = FALSE)

	no_insider_input <- checkboxInput("no_insider", label = "Akteur:in ist KEIN:E Insider:in.",
                                  value = FALSE)

	exp_domain_input <- radioButtons("exp_domain", label = "Expertise / Domäne",
                                 choices = c("Entwicklung" = 1,
                                             "Erforschung" = 2,
                                             "Anwendung" = 3,
                                             "Management" = 4,
                                             "Regulation" = 5,
                                             "Folgen/Verortung" = 6,
                                             "Recherche" = 7,
                                             "nicht erkennbar/Sonstiges" = 99),
                                 selected = character(0))
	```
10. Insert the coding instruction in line 877:
	```{r}
	,
          tabPanel(
            title = "Expert:innenstatus",
            fluidRow(column(8, includeMarkdown("modules_and_add_ons/module_expert/module_expert.md")))
          )
	```
11. Include the new inputs in conditional panels that are dependent on [relevant_quote] = TRUE by adding a comma at the end of line 1153 (behind "relevant_quote_input") and typing copying the following code in the next line before the closing bracket:
	```{r}
	br(),
	conditionalPanel(
		condition = "input.relevant_quote == true",
			wellPanel(
				style = "background-color:#ffffff;",
				p("Expert:innenstatus"),
				exp_call_input,
				conditionalPanel(
					condition = "input.exp_call == false",
					p("ODER"),
					no_insider_input
					),
				conditionalPanel(
					condition = "input.exp_call == true || input.no_insider == true",
					exp_domain_input
					)
			)
		)
	```
12. Make sure that the coding of the variables is required when [relevant_quote] = TRUE before moving on by adding ``` | (empty_inputs(input$exp_domain) == "" & input$exp_call) | (empty_inputs(input$exp_domain) == "" & input$no_insider)``` before the closing brackets in line 1221 and line 1260.
13. Again: Include the inputs in conditional panels that are dependent on [relevant_quote] = TRUE by adding a comma at the end of line 1672 (behind "relevant_quote_input") and copying the following code in the next line before the closing bracket:
	```{r}
	br(),
	conditionalPanel(
		condition = "input.relevant_quote == true",
			wellPanel(
				style = "background-color:#ffffff;",
				p("Expert:innenstatus"),
				exp_call_input,
				conditionalPanel(
					condition = "input.exp_call == false",
					p("ODER"),
					no_insider_input
					),
				conditionalPanel(
					condition = "input.exp_call == true || input.no_insider == true",
					exp_domain_input
					)
			)
		)
	```	
	Repeat this step in line 1802.
14. Include the logical variables "exp_call" and "no_insider" in line 1868.
15. Include ``` |> str_replace_all(expert_calls, mark_expert_calls)``` in line 1965 before ```, "</p>")))```.
16. Repeat step 13 in line 2329.