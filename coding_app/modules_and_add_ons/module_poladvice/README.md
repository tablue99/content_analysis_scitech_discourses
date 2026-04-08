>[!IMPORTANT]
>The line numbers refer to the raw version of the app without any further modules and add-ons (except for the [socarea_others] add-on).

### Module: Political Advice

This module enables to distinguish between administrative actors who are part of a political advisory board and other actors belonging to the political administration. It can be integrated to the core coding process and app as follows:

1. Download the Markdown file "module_poladvice.md" and save it in the folder "source_codebuch".
2. Add the variable name "poladvice" to "variables" (line 24) and "actor_variables" (line 27). 
3. Adjust the "save_actors" function as follows:
	1. Add "poladvice" to "inputs" in line 49
	2. Make sure that the variable only contains values if [socarea] = 220 by including the following code from line 71 on:
	```{r}
	if(inputs["socarea_oberkat"] == 200 & inputs["socarea_pol"] != 220){
      inputs["poladvice"] <- NA
    }
    }
	```
	3. Include "poladvice" in line 77
4. Adjust the "set_to_last_actor_value" and "set_to_actor_values" functions:
	1. Add "poladvice" in line 340 and 371
	2. Include the following code in line 356 and 387:
```{r}
updateCheckboxInput(session = session, inputId = "poladvice", value = as.logical(actor_codes[["poladvice"]][[1]]))
```
5. Adjust the "reset_inputs" function by including the following code in line 418:
```{r}
updateCheckboxInput(session = session, inputId = "poladvice", value = FALSE)
```
6. Define the input element for the added variable by including this code starting in line 597:
```{r}
# politische Beratung
poladvice_input <- wellPanel(style = "background-color:#ffffff;",
                             p("Politische Beratung"),
                             checkboxInput("poladvice", label = "Akteur:in gehört zu einem Gremium, das politische Beratung betreibt.",
                                           value = FALSE))
```
7. Insert the coding instruction in line 820:
```{r}
tabPanel(
            title = "Politische Beratung",
            fluidRow(column(8, includeMarkdown("modules_and_add_ons/module_poladvice/module_poladvice.md")))
          ),
```
8. Include "poladvice_input" when 220 chosen in [socarea] by adding a comma at the end of line 1084 (behind "socarea_pol_input") and including the following code in the next line before the closing bracket:
```{r}
conditionalPanel(
                                   condition = "input.socarea_pol == 220",
                                   poladvice_input
                                 )
```
9. Again: Include "poladvice_input" in the coding when 220 is selected as [socarea] by adding a comma at the end of line 1580 (behind "socarea_pol_input") and including the following code in the next line before the closing bracket:
```{r}
conditionalPanel(
                                   condition = "input.socarea_pol == 220",
                                   poladvice_input
                                 )
``` 
    Repeat this step in line 1692 and 2199.
10. Make sure that "poladvice" is batched as logical in the "codebogen" by adding "poladvice" in line 1758.