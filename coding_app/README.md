### Shiny app to code discourse structures in German technoscientific media coverage

This subdirectory contains an app as well as required materials (e. g., coding manual) to collect data on actors, their statements and the interactions between them in German textual media coverage on technoscientific topics by means of content analysis.
The coding manual and the corresponding app follow a modular principle that allows for comparative coding of basic structures and characteristics in its raw version and more nuanced and specific coding regarding particular research questions or topics by adding different modules and add-ons that are provided in the subfolder "modules_add_ons".

To include modules and add-ons, follow the instructions provided in the ReadMe-Files in each subfolder.

The following steps will help you set up the required coding environment to make use of the raw or core version of the app that enables the coding of **affiliation**, **gender**,**societal area**, **national localisation** and **discourse reference** on *actor level*, **statement type** and **leaning** as well as **direct interactions** on *statement level* and filtering out **true interactions** to identify an **interaction type** on *interaction level*.

1. Download the Shiny app (R file) as well as the folder "source_codebuch" and save them in the same local directory.
2. In the same local directory, create a subfolder called "daten" that contains the dataframes including all the NER-identified actors to be manually coded as RDS file.
3. Check the Markdown files in "source_codebuch" and change them, if necessary, acording to your needs (e. g., add new coders).
3. Open the app in R. If you have added for example additional coders, you have to search for the according definition of the variable in the R script and add the needed values. For instance, in terms of new coders, you have to navigate to line 514-515 and change the allowed values (per default, values from 1 to 20 can be inserted).
4. If you have made all the necessary changes on the app code, run the app by clicking on the "Run App" button in the top right corner of your file window in R. Make sure by clicking on the small arrow beneath the button that the app will be run externally to open it in your default web browser.
5. Start coding by inserting your coding id, selecting the file to be coded from the "daten" folder and clicking on "Codieren beginnnen".

Due to exclusive application by German coders, the app is currently only available in German language. However, if you are able to understand the German instructions/options, you can also code texts in other languages by using this app as the text output is dependent on the data that has been uploaded by you. Yet, if prior to using this app, you'd also like to use the provided Python script(s) for the NER identification of actors, you have to apply it to German texts or change the model from flair/ner-ger to an appropriate model for your textual data.