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
3. ...