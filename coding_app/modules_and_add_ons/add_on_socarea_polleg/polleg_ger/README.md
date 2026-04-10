>[!IMPORTANT]
>The line numbers refer to the raw version of the app without any further modules and add-ons (except for the [socarea_others] add-on).

### Add-On: Further specification of political legislative (German parties)

This add-on enables to further describe the political orientation (party membership) of political legislative actors in Germany that would otherwise be coded with "230 = politische Legislative". It can be integrated in the core coding process as follows:

1. Open the markdown file "socarea" in the folder "source_codebuch" and exchange "Durch das Hinzufügen eines oder mehrere länderspezifischer Add-Ons (z. B. <a href="linkzusocarea_polleg_ger" target="_blank"> [socarea_polleg_ger]</a>, <a href="linkzusocarea_polleg_uk" target="_blank"> [socarea_polleg_uk]</a>) können sie, wenn möglich, hinsichtlich ihrer Zugehörigkeit zu einzelnen Parteien unterschieden werden. Ist eine verallgemeinerte, länderübergreifende Codierung der Parteien erwünscht, kann auf das <a href="https://github.com/tablue99/content_analysis_scitech_discourses/tree/d729974ca89922f0d636302e5bb5d77cebc89ef7/coding_app/modules_and_add_ons/add_on_socarea_polleg" target="_blank"> Add-On [socarea_polleg]</a> zurückgegriffen werden." with the text provided in the markdown file "add_on_socarea_polleg_ger". Then include the provided categories by copying and pasting them starting at line 35.
2. Include "socarea_polleg_ger" in line 24 and 27.
3. Adjust the "save_actors" function as follows:
	1. Include "socarea_polleg_ger" in line 49 and 54.
	2. Replace line 56 to 58 with:
		```{r}
		if(inputs["socarea_oberkat"] == 200 & !inputs["socarea_pol"] == 230){
		inputs[c("socarea_wiss", "socarea_polleg_ger", "socarea_iv", "socarea_ivzo", "socarea_ivko", "socarea_sonst")] <- NA
		}
		```
	3. Include the following code in line 59:
		```{r}
		if(inputs["socarea_oberkat"] == 200 & inputs["socarea_pol"] == 230){
		inputs[c("socarea_wiss", "socarea_iv", "socarea_ivzo", "socarea_ivko", "socarea_sonst")] <- NA
		}
		```
	4. Include "socarea_polleg_ger" in line 63, 66, 69 and 72.
	5. Exchange the code in line 87 with:
		```{r}
		(!is.na(socarea_pol)  & is.na(socarea_polleg_ger)) ~ socarea_pol,
		!is.na(socarea_polleg_ger) ~ socarea_polleg_ger,
		```
4. Include ```updateRadioButtons(session = session, inputId = "socarea_polleg_ger", selected = actor_codes[["socarea_polleg_ger"]][[1]])``` in line 357 and 387.
5. Include ```updateRadioButtons(session = session, inputId = "socarea_polleg_ger", selected = character(0))``` in line 417.
6. Define the new input element by including the following code starting in line 563:
	```{r}
	socarea_polleg_ger_input <- radioButtons("socarea_polleg_ger", label = "Partei",
                                     choices = c("CDU/CSU" = 2311,
                                                 "SPD" = 2321,
                                                 "Die Grünen" = 2331,
                                                 "FDP" = 2341,
                                                 "AfD" = 2351,
                                                 "Die Linke" = 2361,
                                                 "Sonstige Partei" = 237))
	```
7. Add a comma in line 1081 (behind "socarea_pol_input") and insert the follwing code before the closing bracket:
	```{r}
	conditionalPanel(
                                   condition = "input.socarea_pol == 230",
                                   socarea_polleg_ger_input
                                 )
	```
8. Include ```(empty_inputs(input$socarea_polleg_ger) == "" & empty_inputs(input$socarea_pol) == 230 & input$socarea_oberkat == 200) |``` in line 1145 and 1182.
9. Again: Add a comma in line 1157 (behind "socarea_pol_input") and insert the code before the closing bracket:
	```{r}
	conditionalPanel(
                                   condition = "input.socarea_pol == 230",
                                   socarea_polleg_ger_input
                                 )
	```
	Repeat this step in line 1689 and 2196.
	
**Note**: Since the categories are non-overlapping it is also possible to combine different country-specific parties and/or to use those as subcategories to [socarea_polleg]. If help is required for the latter option, please contact the author of the app/coding manual. To implement the first option, simply rename "socarea_polleg_ger" to something more general (e. g., "socarea_polleg", if it is not used as overarching category, or "socarea_polleg_parties"), paste the chosen categories on the same level (same parameter for margin-left) in the "socarea" markdown file and add them as choices to the defined input element. Make sure that you always use the correct name of this element throughout the whole script to avoid errors.