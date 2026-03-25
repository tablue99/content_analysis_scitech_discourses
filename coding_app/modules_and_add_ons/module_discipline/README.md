### Module: Scientific discipline

This module enables the identification of scientific disciplines for scientific actors ([socarea] = 100). It can be integrated to the core coding process and app as follows:

1. Add the variable name "discipline" to "variables" (line 24) and "actor_variables" (line 27) 
2. Adjust the "save_actors" function as follows:
	1. Add "discipline" to "inputs" in line 49
	2. Add a plausibility check starting before the bracket in line 71. Include:
	```{r}
	if(inputs["socarea_oberkat"] != 100){
      inputs["discipline"] <- NA
    }
	```
3. Adjust the "set_to_last_actor_value" and "set_to_actor_values" functions by including the following code in line 361 and 391:
```{r}
updateRadioButtons(session = session, inputId = "discipline", selected = actor_codes[["discipline"]][[1]])
```
4. Adjust the "reset_inputs" function by including the following code in line 421:
```{r}
updateRadioButtons(session = session, inputId = "discipline", selected = character(0))
```
5. Define the input element for the added variable by including this code starting in line 595:
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
                                             "nicht feststellbar" = 99))
```
6. 