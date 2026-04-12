>[!IMPORTANT]
>The line numbers refer to the raw version of the app without any further modules and add-ons (except for the [socarea_others] add-on).

### Module: Geographical reference of statements

This module allows for the coding of the geographical scope and/or references of given statements. It can be integrated in the core coding process as follows:

1. Download the Markdown file "module_statement_local.md" and save it in the folder "source_codebuch".
2. Add the variable "statement_local" to "variables" (line 25) and "statement_variables" (line 28). 
3. Add "statement_local" to "inputs" in line 134 of the "save_statements" function.
4. Adjust the "reset_inputs" function by including the following code in line 430:
	```{r}
	updateRadioButtons(session = session, inputId = "statement_local", selected = character(0))
	```
5. Define the input elements for the variable by including this code starting in line 681:
	```{r}
	statement_local_input <- radioButtons("statement_local", label = "geographischer Bezug",
                                      choices = c("lokal" = 1,
                                                  "föderal" = 2,
                                                  "national" = 3,
                                                  "inter-/supranational" = 4,
                                                  "global" = 5,
                                                  "kein geographischer Bezug/nicht erkennbar" = 99),
                                      selected = character(0))
	```
6. Insert the coding instruction in line 836:
	```{r}
	tabPanel(
            title = "geographischer Bezug",
            fluidRow(column(8, includeMarkdown("modules_and_add_ons/module_statement_local/module_statement_local.md")))
          ),
	```
7. Include the new inputs in the conditional panel for relevant statements by including ```statement_local_input,``` in line 1267.
8. Include ```updateRadioButtons(session = session, inputId = "statement_local", selected = character(0))``` in line 1324 to reset the inputs if a statement is subsequently corrected to be irrelevant ([irrelevant_statement] = TRUE).
9. Make sure that the coding of the variables is required when [irrelevant_statement] = FALSE before moving on by adding ```empty_inputs(input$statement_local),``` between ```empty_inputs(input$statement_oberkat)``` and ```empty_inputs(input$statement_leaning)``` in line 1340.