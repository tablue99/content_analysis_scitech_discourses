>[!IMPORTANT]
>The line numbers refer to the raw version of the app without any further modules and add-ons (except for the [socarea_others] add-on).

### Add-On: Subcategories for other addressees of statements

This add-on enables to further specify other collective actors (institutions, organisations) that are addressed with a call to act. It can be integrated in the core coding process as follows:

1. Open the Markdown file "statement_type.md" in the folder "source_codebuch" and exchange "Falls eine Spezifizierung erwünscht ist, können an dieser Stelle weitere Unterausprägungen aus dem <a href="linkzuadressee_others" target="_blank"> Add-On [addressee_others]</a> hinzugefügt werden." in line 126 with "Dabei sind folgende Spezifikationen möglich:". Then copy the subcategories from the markdown file "add_on_addressee_others.md" and paste them to line 127. If applicable, change line 112 to "Wird nur der lehrende Bereich an Universitäten adressiert, ist "3192/3292 = Bildung" zu codieren.".
2. Add the variable "addressee_others" to "variables" (line 25) and "statement_variables" (line 28). 
3. Adjust the "save_statements" function as follows:
	1. Add "addressee_others" to "inputs" in line 134, 139, 142, 145, 148 and 154  of the "save_statements" function.
	2. Include the following plausibility check in line 160:
		```{r}
		if(inputs["statement_type_oberkat"] == 3 & inputs["addressee"] != 9){
		inputs["addressee_others"] <- NA
		}
		```
	3. Exchange line 180 for the following code:
		```{r}
		(statement_type_oberkat == 3 & addressee != 9) ~ as.numeric(paste0(statement_type_actclaim, addressee)),
		(statement_type_oberkat == 3 & addressee == 9) ~ as.numeric(paste0(statement_type_actclaim, addressee, addressee_others)),
		```
4. Adjust the "reset_inputs" function by including the following code in line 434:
	```{r}
	updateRadioButtons(session = session, inputId = "addressee_others", selected = character(0))
	```
5. Define the input elements for the variable by including this code starting in line 685:
	```{r}
	addressee_others_input <- radioButtons("addressee_others", label = "Sonstige",
                                       choices = c("Gesundheit" = 1,
                                                   "Bildung" = 2,
                                                   "Kultur" = 3,
                                                   "Journalismus/Medien" = 4,
                                                   "öffentliche Sicherheit" = 5,
                                                   "Finanz-/Versicherungswesen" = 6),
                                       selected = character(0))
	```
6. Include the new inputs in the conditional panel for [statement_type_oberkat] = 3 and [addressee] = 9 by adding a comma in line 1265 and including the following code before the closing bracket:
	```{r}
	conditionalPanel(
		condition = "input.addressee == 9",
		addressee_others_input
	)
	```
7. Include ```updateRadioButtons(session = session, inputId = "addressee_others", selected = character(0))``` in line 1327 to reset the inputs if a statement is subsequently corrected to be irrelevant ([irrelevant_statement] = TRUE).
9. Make sure that the coding of the variables is required when [addressee] = 9 before moving on by adding ```(empty_inputs(input$addressee_others) == "" & empty_inputs(input$addressee) == 9) |``` in line 1353.