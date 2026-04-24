>[!IMPORTANT]
>The line numbers refer to the raw version of the app without any further modules and add-ons (except for the [socarea_others] add-on).

### Add-On: Subcategories for other evaluated actors

This add-on enables to further specify other collective actors (institutions, organisations) that are addressed with a call to act. It can be integrated in the core coding process as follows:

1. Open the Markdown file "statement_type.md" in the folder "source_codebuch" and exchange "Falls eine Spezifizierung erwünscht ist, können an dieser Stelle weitere Unterausprägungen aus dem <a href="https://github.com/tablue99/content_analysis_scitech_discourses/tree/fe3fb7be0fc8b03b4884ad7437045d5eadeec858/coding_app/modules_and_add_ons/add_on_eval_subj_others" target="_blank"> Add-On [eval_subj_others]</a> hinzugefügt werden." in line 61 with "Dabei sind folgende Spezifikationen auswählbar:". Then copy the subcategories from the markdown file "add_on_eval_subj_others.md" and paste them to line 62. If applicable, change line 49 to "Wird nur der lehrende Bereich an Universitäten adressiert, ist "292 = Bildung" zu codieren.".
2. Add the variable "eval_subj_others" to "variables" (line 25) and "statement_variables" (line 28). 
3. Adjust the "save_statements" function as follows:
	1. Add "eval_subj_others" to "inputs" in line 134, 139, 142, 145, 151 and 154  of the "save_statements" function.
	2. Include the following plausibility check in line 160:
		```{r}
		if(inputs["statement_type_oberkat"] == 2 & inputs["obj_persp"] == 2 & inputs["eval_subj_oberkat"] == 2 & inputs["eval_subj_actor"] != 29){
		inputs["eval_subj_others"] <- NA
		}
		```
	3. Exchange line 185 to 187 for the following code:
		```{r}
		inputs["eval_subj"] <- with(as.list(inputs), {case_when(
		(eval_subj_oberkat == 2 & eval_subj_actor == 29) ~ eval_subj_others, 
		(eval_subj_oberkat == 2 & eval_subj_actor != 29) ~ eval_subj_actor,
		.default = eval_subj_oberkat
		)})
		```
4. Adjust the "reset_inputs" function by including the following code in line 432:
	```{r}
	updateRadioButtons(session = session, inputId = "eval_subj_others", selected = character(0))
	```
5. Define the input elements for the variable by including this code starting in line 661:
	```{r}
	eval_subj_others_input <- radioButtons("eval_subj_others", label = "Sonstige",
                                       choices = c("Gesundheit" = 291,
                                                   "Bildung" = 292,
                                                   "Kultur" = 293,
                                                   "Journalismus/Medien" = 294,
                                                   "öffentliche Sicherheit" = 295,
                                                   "Finanz-/Versicherungswesen" = 296),
                                       selected = character(0))
	```
6. Include the new inputs in the conditional panel for [statement_type_oberkat] = 2, [eval_subj_oberkat] = 2 and [eval_subj_actor] = 29 by adding a comma in line 1248 and including the following code before the closing bracket:
	```{r}
	conditionalPanel(
		condition = "input.eval_subj_actor == 29",
		eval_subj_others_input
	)
	```
7. Include ```updateRadioButtons(session = session, inputId = "eval_subj_others", selected = character(0))``` in line 1325 to reset the inputs if a statement is subsequently corrected to be irrelevant ([irrelevant_statement] = TRUE).
9. Make sure that the coding of the variables is required when [eval_subj_actor] = 29 before moving on by adding ```(empty_inputs(input$eval_subj_others) == "" & empty_inputs(input$eval_subj_actor) == 29) |``` in line 1351.