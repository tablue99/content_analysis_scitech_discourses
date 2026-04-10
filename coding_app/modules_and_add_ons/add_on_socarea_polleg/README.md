>[!IMPORTANT]
>The line numbers refer to the raw version of the app without any further modules and add-ons (except for the [socarea_others] add-on).

### Add-On: Further specification of other societal areas

This add-on enables to further describe the societal area of peripheral actors that would otherwise be coded with "400 = sonstiger Bereich". It is per default integrated in the core coding process and can be removed as follows:

1. Open the markdown file "socarea" in the folder "source_codebuch" and exchange "Durch das Hinzufügen eines oder mehrere länderspezifischer Add-Ons (z. B. <a href="linkzusocarea_polleg_ger" target="_blank"> [socarea_polleg_ger]</a>, <a href="linkzusocarea_polleg_uk" target="_blank"> [socarea_polleg_uk]</a>) können sie, wenn möglich, hinsichtlich ihrer Zugehörigkeit zu einzelnen Parteien unterschieden werden. Ist eine verallgemeinerte, länderübergreifende Codierung der Parteien erwünscht, kann auf das <a href="https://github.com/tablue99/content_analysis_scitech_discourses/tree/d729974ca89922f0d636302e5bb5d77cebc89ef7/coding_app/modules_and_add_ons/add_on_socarea_polleg" target="_blank"> Add-On [socarea_polleg]</a> zurückgegriffen werden." with the text provided in the markdown file "add_on_socarea_polleg". Then include the provided categories by copying and pasting them starting at line 35.
2. Include "socarea_polleg" in line 24 and 27.
3. Adjust the "save_actors" function as follows:
	1. Include "socarea_polleg" in line 49 and 54.
	2. Replace line 56 to 58 with:
		```{r}
		if(inputs["socarea_oberkat"] == 200 & !inputs["socarea_pol"] == 230){
		inputs[c("socarea_wiss", "socarea_polleg", "socarea_iv", "socarea_ivzo", "socarea_ivko", "socarea_sonst")] <- NA
		}
		```
	3. Include the following code in line 59:
		```{r}
		if(inputs["socarea_oberkat"] == 200 & inputs["socarea_pol"] == 230){
		inputs[c("socarea_wiss", "socarea_iv", "socarea_ivzo", "socarea_ivko", "socarea_sonst")] <- NA
		}
		```
	4. Include "socarea_polleg" in line 63, 66, 69 and 72.
	5. Exchange the code in line 87 with:
		```{r}
		(!is.na(socarea_pol)  & is.na(socarea_polleg)) ~ socarea_pol,
		!is.na(socarea_polleg) ~ socarea_polleg,
		```
4. Include ```updateRadioButtons(session = session, inputId = "socarea_polleg", selected = actor_codes[["socarea_polleg"]][[1]])``` in line 357 and 387.
5. Include ```updateRadioButtons(session = session, inputId = "socarea_polleg", selected = character(0))``` in line 417.
6. Define the new input element by including the following code starting in line 563:
	```{r}
	socarea_polleg_input <- radioButtons("socarea_polleg", label = "Parteiorientierung",
                                     choices = c("Konservative Partei" = 231,
                                                 "Sozialdemokratische Partei" = 232,
                                                 "Grüne Partei" = 233,
                                                 "Liberale Partei" = 234,
                                                 "Rechtspopulistische Partei" = 235,
                                                 "Linke Partei" = 236,
                                                 "Sonstige Partei" = 237))
	```
7. Add a comma in line 1081 (behind "socarea_pol_input") and insert the follwing code before the closing bracket:
	```{r}
	conditionalPanel(
                                   condition = "input.socarea_pol == 230",
                                   socarea_polleg_input
                                 )
	```
8. Include ```(empty_inputs(input$socarea_polleg) == "" & empty_inputs(input$socarea_pol) == 230 & input$socarea_oberkat == 200) |``` in line 1145 and 1182.
9. Again: Add a comma in line 1157 (behind "socarea_pol_input") and insert the code before the closing bracket:
	```{r}
	conditionalPanel(
                                   condition = "input.socarea_pol == 230",
                                   socarea_polleg_input
                                 )
	```
	Repeat this step in line 1689 and 2196.