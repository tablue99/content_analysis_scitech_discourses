## Core: Shiny-App zur Codierung von strukturellen Merkmalen von medialen Wissenschafts- und Technologiediskursen (journalistische Texte)
## TODOs:
  # codierte Variablen mit IDs in Rds-Datensatz schreiben

library(shiny)
library(shinyjs)
library(shinyFiles)
library(shinyWidgets)
library(bslib)
library(tidyverse)

## Globale Variablen

## Dateipfade, Datensätze und ID-Listen werden als globale Variablen angelegt.

file_path <- ""
file_paths_new_datasets <- ""
full_dataset <- data.frame()
full_statement_dataset <- data.frame()
full_interaction_dataset <- data.frame()
ids <- list()
coder <- 0

## Listen mit Variablennamen, um Eingaben abzuspeichern und in Datensatz zu schreiben

variables <- c("coder_id", "opt_out_relevant", "affiliation", "gender", "socarea_oberkat", "socarea_wiss", "socarea_pol", "socarea_iv", "socarea_ivzo", "socarea_ivko", "socarea_sonst", "actlocal", "relevant_quote",
               "irrelevant_statement", "actor_statement", "statement_type_oberkat", "statement_type_actclaim", "valclaim", "obj_persp", "eval_subj_oberkat", "eval_subj_actor", "eval", "time_persp", "addressee", "statement_leaning",
               "dir_int", "dir_int_other", "indir_int", "false_int", "int_type")
actor_variables <- c("coder_id", "opt_out_relevant", "affiliation", "gender", "socarea_oberkat", "socarea_wiss", "socarea_pol", "socarea_iv", "socarea_ivzo", "socarea_ivko", "socarea_sonst", "actlocal", "relevant_quote")
statement_variables <- c("irrelevant_statement", "actor_statement", "statement_type_oberkat", "statement_type_actclaim", "valclaim", "obj_persp", "eval_subj_oberkat", "eval_subj_actor", "dir_int_eval", "dir_int_other_eval", "eval", "time_persp", "addressee", "dir_int_actclaim", "dir_int_other_actclaim", "dir_int", "dir_int_other", "dir_int_batch", "statement_leaning", "int_type")
interaction_variables <- c("false_int", "int_type")

## Funktionen

### Speicherfunktionen

#### Akteurseigenschaften
save_actors <- function(actor, inputs){
  # zunächst wird überprüft, ob die in der App codierten Variablen bereits als Spalten im Datensatz angelegt sind
  for(variable in actor_variables){
    if(!(variable %in% names(full_dataset))){
      # ist das nicht der Fall, werden entsprechende Spalten angelegt und vorläufig mit NA befüllt
      full_dataset[, variable] <<- NA
    }
  }
  # die coded_actor-Variable wird für den:die aktuelle:n Akteur:in (falls noch nicht vorhanden: angelegt und) auf TRUE gesetzt
  full_dataset[full_dataset$entity_id == actor$entity_id, "coded_actor"] <<- TRUE
  # Prüfung und Veränderung unlogischer bzw. unmöglicher Werte
  # Wenn opt_out_relevant = TRUE, müssen alle anderen Variablen NAs sein
  if(as.logical(inputs["opt_out_relevant"])){
    inputs[c("affiliation", "gender", "socarea_oberkat", "socarea_wiss", "socarea_pol", "socarea_iv", "socarea_ivzo", "socarea_ivko", "socarea_sonst", "actlocal", "relevant_quote")] <- NA
  }
  else {
    # leere Werte je nach gewählter Kategorie in socarea_oberkat
    if(inputs["socarea_oberkat"] == 100){
      inputs[c("socarea_pol", "socarea_iv", "socarea_ivzo", "socarea_ivko", "socarea_sonst")] <- NA
    }
    if(inputs["socarea_oberkat"] == 200){
      inputs[c("socarea_wiss", "socarea_iv", "socarea_ivzo", "socarea_ivko", "socarea_sonst")] <- NA
    }
    if(inputs["socarea_oberkat"] == 300 & !inputs["socarea_iv"] %in% c(310, 320)){
      inputs[c("socarea_pol", "socarea_wiss", "socarea_ivko", "socarea_ivzo", "socarea_sonst")] <- NA
    }
    if(inputs["socarea_oberkat"] == 300 & inputs["socarea_iv"] == 310){
      inputs[c("socarea_pol", "socarea_wiss", "socarea_ivko", "socarea_sonst")] <- NA
    }
    if(inputs["socarea_oberkat"] == 300 & inputs["socarea_iv"] == 320){
      inputs[c("socarea_pol", "socarea_wiss", "socarea_ivzo", "socarea_sonst")] <- NA
    }
    if(inputs["socarea_oberkat"] == 400){
      inputs[c("socarea_pol", "socarea_wiss", "socarea_iv", "socarea_ivko", "socarea_ivzo")] <- NA
    }
  }
  # nun werden die Werte aus dem Codebogen in den Datensatz geschrieben
  for(variable in actor_variables){
    if(variable %in% c("opt_out_relevant", "affiliation", "relevant_quote")){
      full_dataset[full_dataset$entity_id == actor$entity_id, variable] <<- inputs[variable]
    }
    else {
      full_dataset[full_dataset$entity_id == actor$entity_id, variable] <<- as.numeric(inputs[variable])
    }
  }
  # Zum Schluss werden die Einzel-Inputs für die socarea-Variable automatisch in socarea zusammengefasst
  inputs["socarea"] <- with(as.list(inputs), {case_when(
    !is.na(socarea_wiss) ~ socarea_wiss,
    !is.na(socarea_pol) ~ socarea_pol,
    (!is.na(socarea_iv) & (is.na(socarea_ivzo) & is.na(socarea_ivko))) ~ socarea_iv, 
    !is.na(socarea_ivzo) ~ socarea_ivzo,
    !is.na(socarea_ivko) ~ socarea_ivko,
    !is.na(socarea_sonst) ~ socarea_sonst
  )})
  full_dataset[full_dataset$entity_id == actor$entity_id, "socarea"] <<- as.numeric(inputs["socarea"])
  
  saveRDS(full_dataset, file_path)
}

#### Identifizierte Aussagen und deren Codierung
save_statements <- function(statement, inputs, statements_dataset){
  # zunächst wird überprüft, ob bereits eine RDS-Datei mit codierten Aussagen vorliegt
  if(file.exists(file.path(file_paths_new_datasets, "coded_statements.Rds"))){
    full_statement_dataset <- readRDS(file.path(file_paths_new_datasets, "coded_statements.Rds"))
  }
  # wenn noch kein Datensatz vorliegt, wird der reaktive Statements-Datensatz herangezogen, um diesen Datensatz erstmalig anzulegen
  else {
    full_statement_dataset <- statements_dataset 
  }
  # dann wird geprüft, ob die in der App codierten Variablen bereits als Spalten im Datensatz angelegt sind
  for(variable in statement_variables){
    if(!(variable %in% names(full_statement_dataset))){
      # ist das nicht der Fall, werden entsprechende Spalten angelegt und vorläufig mit NA befüllt
      full_statement_dataset[, variable] <- NA
    }
  }
  # für jede neue Aussage wird eine Zeile im neuen Datensatz angelegt
  current_statement <- which(full_statement_dataset$statement_id == statement$statement_id)
  if(length(current_statement) == 0){
    new_row <- tibble(
      entity_id = statement$entity_id,
      entity = statement$entity,
      document_id = statement$document_id,
      statement_id = statement$statement_id,
      statement = statement$statement,
      coded = TRUE
    )
    full_statement_dataset <- bind_rows(full_statement_dataset, new_row)
    current_statement <- nrow(full_statement_dataset)
  }
  # die coded-Variable wird für die aktuelle Aussage auf TRUE gesetzt
  full_statement_dataset[current_statement, "coded"] <- TRUE
  # Die kopierte Aussage wird bereinigt (nur einfache Wortlücken)
  full_statement_dataset <- full_statement_dataset |> 
    mutate(statement = str_replace_all(statement, "\\s{2,}", " "))
  # Prüfung und Veränderung unlogischer bzw. unmöglicher Werte
  # Wenn irrelevant_statement = TRUE, müssen alle anderen Variablen NAs sein
  if(isTRUE(as.logical(inputs["irrelevant_statement"]))){
    inputs[c("statement_type_oberkat", "statement_type_actclaim", "valclaim", "obj_persp", "eval_subj_oberkat", "eval_subj_actor", "dir_int_eval", "dir_int_other_eval", "eval", "time_persp", "addressee", "dir_int_actclaim", "dir_int_other_actclaim", "dir_int", "dir_int_other", "dir_int_batch", "statement_leaning", "int_type")] <- NA
  }
  else {
    # leere Werte je nach gewählter Kategorie in statement_type_oberkat
    if(inputs["statement_type_oberkat"] == 1){
      inputs[c("statement_type_actclaim", "obj_persp", "eval_subj_oberkat", "eval_subj_actor", "eval", "dir_int_eval", "dir_int_other_eval", "time_persp", "addressee", "dir_int_actclaim", "dir_int_other_actclaim")] <- NA
    }
    if(inputs["statement_type_oberkat"] == 2 & inputs["obj_persp"] == 21){
      inputs[c("statement_type_actclaim", "valclaim", "eval_subj_oberkat", "eval_subj_actor", "dir_int_eval", "dir_int_other_eval", "eval", "addressee", "dir_int_actclaim", "dir_int_other_actclaim", "dir_int", "dir_int_other", "int_type")] <- NA
    }
    if(inputs["statement_type_oberkat"] == 2 & inputs["obj_persp"] == 22 & inputs["eval_subj_oberkat"] != 2){
      inputs[c("statement_type_actclaim", "valclaim", "eval_subj_actor", "dir_int_eval", "dir_int_other_eval", "addressee", "dir_int_actclaim", "dir_int_other_actclaim", "dir_int", "dir_int_other", "int_type")] <- NA
    }
    if(inputs["statement_type_oberkat"] == 2 & inputs["obj_persp"] == 22 & inputs["eval_subj_oberkat"] == 2){
      inputs[c("statement_type_actclaim", "valclaim", "addressee", "dir_int_actclaim", "dir_int_other_actclaim", "dir_int", "dir_int_other", "int_type")] <- NA
    }
    if(inputs["statement_type_oberkat"] == 3){
      inputs[c("valclaim", "obj_persp", "eval_subj_oberkat", "eval_subj_actor", "dir_int_eval", "dir_int_other_eval", "eval", "time_persp", "dir_int", "dir_int_other", "int_type")] <- NA
    }
    if(inputs["statement_type_oberkat"] %in% c(4, 5, 99)){
      inputs[c("statement_type_actclaim", "valclaim", "obj_persp", "eval_subj_oberkat", "eval_subj_actor", "dir_int_eval", "dir_int_other_eval", "eval", "time_persp", "addressee", "dir_int_actclaim", "dir_int_other_actclaim")] <- NA
    }
    # statement_leaning muss immer 0 sein, wenn valclaim = 13
    if(inputs["statement_type_oberkat"] == 1 & inputs["valclaim"] == 13){
      inputs["statement_leaning"] <- 0
    }
  }
  # nun werden die Werte aus dem Codebogen in den Datensatz geschrieben
  for(variable in statement_variables){
    if(is.null(inputs["dir_int_batch"])) {
      full_statement_dataset[current_statement, variable] <- NA
    }
    if(variable %in% c("irrelevant_statement", "actor_statement", "dir_int_eval", "dir_int_other_eval", "dir_int_actclaim", "dir_int_other_actclaim", "dir_int", "dir_int_other", "dir_int_batch")){
      full_statement_dataset[current_statement, variable] <- inputs[variable]
    }
    else {
      full_statement_dataset[current_statement, variable] <- as.numeric(inputs[variable])
    }
  }
  # Zum Schluss werden die Einzel-Inputs für die statement_type-Variable automatisch in statement_type zusammengefasst
  inputs["statement_type"] <- with(as.list(inputs), {case_when(
    statement_type_oberkat == 1 ~ valclaim,
    statement_type_oberkat == 2 ~ as.numeric(paste0(obj_persp, time_persp)),
    statement_type_oberkat == 3 ~ as.numeric(paste0(statement_type_actclaim, addressee)),
    .default = statement_type_oberkat
  )})
  full_statement_dataset[current_statement, "statement_type"] <- as.numeric(inputs["statement_type"])
  # Dasselbe wird für die Inputs, die für eval_subj relevant sind, umgesetzt
  inputs["eval_subj"] <- with(as.list(inputs), {if_else(
    eval_subj_oberkat == 2, eval_subj_actor, eval_subj_oberkat
  )})
  full_statement_dataset[current_statement, "eval_subj"] <- as.numeric(inputs["eval_subj"])
  # Ebenso werden die Filtervariablen zur Variable relevant_statement zusammengefasst
  inputs["relevant_statement"] <- with(as.list(inputs), {case_when(
    isTRUE(as.logical(irrelevant_statement)) ~ 0,
    isTRUE(as.logical(actor_statement)) ~ 2,
    .default = 1
  )})
  full_statement_dataset[current_statement, "relevant_statement"] <- as.numeric(inputs["relevant_statement"])
  # Außerdem wird der Interaktionstyp für direkte Interaktionen durch Bewertungen und Handlungsaufforderungen automatisch festgelegt
  inputs["int_type"] <- with(as.list(inputs), {case_when(
    (obj_persp == 22 & eval_subj_oberkat == 2 & eval == -1) ~ -1,
    (obj_persp == 22 & eval_subj_oberkat == 2 & eval == 1) ~ 1,
    statement_type_actclaim %in% c(31, 32) ~ 0,
    .default = int_type
  )})
  full_statement_dataset[current_statement, "int_type"] <- as.numeric(inputs["int_type"])
  # leere Zellen werden durch NA ersetzt
  full_statement_dataset[full_statement_dataset == ""] <- NA
  
  saveRDS(full_statement_dataset, file.path(file_paths_new_datasets, "coded_statements.Rds"))
}

#### Identifizierte indirekte Interaktionen und deren Codierung
save_interactions <- function(interaction, inputs, interactions_dataset, new_interactions){
  # zunächst wird überprüft, ob bereits eine RDS-Datei mit codierten Interaktionen vorliegt
  if(file.exists(file.path(file_paths_new_datasets, "coded_interactions.Rds"))){
    full_interaction_dataset <- readRDS(file.path(file_paths_new_datasets, "coded_interactions.Rds"))
  }
  # wenn noch kein Datensatz vorliegt, wird der reaktive Statements-Datensatz herangezogen, um diesen Datensatz erstmalig anzulegen
  else {
    full_interaction_dataset <- interactions_dataset 
  }
  # wenn in Freitextfeldern neue Interaktionen erfasst wurden, werden diese an den bestehenden Datensatz angehängt
  new_direct_interactions <- new_interactions
  if(nrow(new_direct_interactions) > 0){
    interactions_to_add <- new_direct_interactions[!new_direct_interactions$int_id %in% full_interaction_dataset$int_id, ]
    if(nrow(interactions_to_add) > 0){
      full_interaction_dataset <- bind_rows(full_interaction_dataset, interactions_to_add)
    }
  }
  # zunächst wird überprüft, ob die in der App codierten Variablen bereits als Spalten im Datensatz angelegt sind
  for(variable in interaction_variables){
    if(!(variable %in% names(full_interaction_dataset))){
      # ist das nicht der Fall, werden entsprechende Spalten angelegt und vorläufig mit NA befüllt
      full_interaction_dataset[, variable] <- NA
    }
  }
  # für jede (neue) Interaktion wird eine Zeile im neuen Datensatz angelegt
  current_interaction <- which(full_interaction_dataset$int_id == interaction$int_id)
  if(length(current_interaction) == 0){
    new_row <- tibble(
      entity_id = interaction$entity_id,
      entity = interaction$entity,
      entity_id_2 = interaction$entity_id_2,
      entity_2 = interaction$entity_2,
      document_id = interaction$document_id,
      int_id = interaction$int_id,
      coded = TRUE
    )
    full_interaction_dataset <- bind_rows(full_interaction_dataset, new_row)
    current_interaction <- nrow(full_interaction_dataset)
  }
  # die coded-Variable wird für die aktuelle Interaktion auf TRUE gesetzt
  full_interaction_dataset[full_interaction_dataset$int_id == interaction$int_id, "coded"] <- TRUE
  # Prüfung und Veränderung unlogischer bzw. unmöglicher Werte
  # Wenn false_int = TRUE darf kein Interaktionstyp codiert sein
  if(as.logical(inputs["false_int"])){
    inputs["int_type"] <- NA
  }
  # nun werden die Werte aus dem Codebogen in den Datensatz geschrieben
  for(variable in interaction_variables){
    if(variable == "false_int"){
      full_interaction_dataset[current_interaction, variable] <- inputs[variable]
    }
    else {
      full_interaction_dataset[current_interaction, variable] <- as.numeric(inputs[variable])
    }
  }
  # Vor dem Export wird der Datensatz noch mit den Codierungen der direkten Interaktionen ergänzt
  coded_statements <- readRDS(file.path(file_paths_new_datasets, "coded_statements.Rds"))
  full_interaction_dataset <- full_interaction_dataset |> 
    mutate(join_id = if_else(!is.na(batch_id), batch_id, int_id)) |> 
    left_join(coded_statements |> 
                select(dir_int, dir_int_eval, dir_int_actclaim, dir_int_batch, int_type) |> 
                pivot_longer(cols = c(dir_int:dir_int_batch),
                             names_to = "variable",
                             values_to = "join_id") |> 
                filter(!is.na(join_id)) |> 
                select(join_id, int_type) |> 
                mutate(join_id = as.character(join_id)), by = "join_id", suffix = c("", "_stat")) |> 
    mutate(int_type = if_else(is.na(int_type), int_type_stat, int_type)) |> 
    select(-c(join_id, int_type_stat))
  
  saveRDS(full_interaction_dataset, file.path(file_paths_new_datasets, "coded_interactions.Rds"))
}

#### Neue direkte Interaktionen bei Akteur:innen, die ausschließlich mit passiven Akteur:innen interagieren
save_new_direct_interactions <- function(interactions_dataset, new_interactions){
  # zunächst wird überprüft, ob bereits eine RDS-Datei mit codierten Interaktionen vorliegt
  if(file.exists(file.path(file_paths_new_datasets, "coded_interactions.Rds"))){
    full_interaction_dataset <- readRDS(file.path(file_paths_new_datasets, "coded_interactions.Rds"))
  }
  # wenn noch kein Datensatz vorliegt, wird der reaktive Statements-Datensatz herangezogen, um diesen Datensatz erstmalig anzulegen
  else {
    full_interaction_dataset <- interactions_dataset 
  }
  # wenn in Freitextfeldern neue Interaktionen erfasst wurden, werden diese an den bestehenden Datensatz angehängt
  new_direct_interactions <- new_interactions
  if(nrow(new_direct_interactions) > 0){
    interactions_to_add <- new_direct_interactions[!new_direct_interactions$int_id %in% full_interaction_dataset$int_id, ]
    if(nrow(interactions_to_add) > 0){
      full_interaction_dataset <- bind_rows(full_interaction_dataset, interactions_to_add)
    }
  }
  # zunächst wird überprüft, ob die in der App codierten Variablen bereits als Spalten im Datensatz angelegt sind
  for(variable in interaction_variables){
    if(!(variable %in% names(full_interaction_dataset))){
      # ist das nicht der Fall, werden entsprechende Spalten angelegt und vorläufig mit NA befüllt
      full_interaction_dataset[, variable] <- NA
    }
  }
  # Vor dem Export wird der Datensatz noch mit den Codierungen der direkten Interaktionen ergänzt
  coded_statements <- readRDS(file.path(file_paths_new_datasets, "coded_statements.Rds"))
  full_interaction_dataset <- full_interaction_dataset |> 
    mutate(join_id = if_else(!is.na(batch_id), batch_id, int_id)) |> 
    left_join(coded_statements |> 
                select(dir_int, dir_int_eval, dir_int_actclaim, dir_int_batch, int_type) |> 
                pivot_longer(cols = c(dir_int:dir_int_batch),
                             names_to = "variable",
                             values_to = "join_id") |> 
                filter(!is.na(join_id)) |> 
                select(join_id, int_type) |> 
                mutate(join_id = as.character(join_id)), by = "join_id", suffix = c("", "_stat")) |> 
    mutate(int_type = if_else(is.na(int_type), int_type_stat, int_type)) |> 
    select(-c(join_id, int_type_stat))
  
  saveRDS(full_interaction_dataset, file.path(file_paths_new_datasets, "coded_interactions.Rds"))
}

#### vollständig codierte Akteur:innen
save_complete_coding <- function(actor){
  # die coded-Variable wird für den:die aktuelle:n Akteur:in (falls noch nicht vorhanden: angelegt und) auf TRUE gesetzt
  full_dataset[full_dataset$entity_id == actor$entity_id, "coded"] <<- TRUE
  
  saveRDS(full_dataset, file_path)
}

# Zurücksetzen auf letzte Akteurs-Werte
set_to_last_actor_value <- function(session = shiny::getDefaultReactiveDomain(), ids, index){
  actor_codes <<- full_dataset[full_dataset$entity_id == ids[index],]
  for(variable in actor_variables){
    if(is.na(actor_codes[[variable]][[1]])){
      if(variable %in% c("opt_out_relevant", "relevant_quote")){
        actor_codes[[variable]][[1]] <- FALSE
      }
      else if(variable == "affiliation"){
        actor_codes[[variable]][[1]] <- ""
      }
      else {
        actor_codes[[variable]][[1]] <- as.character(0)
      }
    }
  }
  updateTextInput(session = session, inputId = "affiliation", value = actor_codes[["affiliation"]][[1]])
  updateRadioButtons(session = session, inputId = "gender", selected = actor_codes[["gender"]][[1]])
  updateSelectInput(session = session, inputId = "socarea_oberkat", selected = actor_codes[["socarea_oberkat"]][[1]])
  updateRadioButtons(session = session, inputId = "socarea_wiss", selected = actor_codes[["socarea_wiss"]][[1]])
  updateRadioButtons(session = session, inputId = "socarea_pol", selected = actor_codes[["socarea_pol"]][[1]])
  updateRadioButtons(session = session, inputId = "socarea_iv", selected = actor_codes[["socarea_iv"]][[1]])
  updateRadioButtons(session = session, inputId = "socarea_ivzo", selected = actor_codes[["socarea_ivzo"]][[1]])
  updateRadioButtons(session = session, inputId = "socarea_ivko", selected = actor_codes[["socarea_ivko"]][[1]])
  updateRadioButtons(session = session, inputId = "socarea_sonst", selected = actor_codes[["socarea_sonst"]][[1]])
  updateRadioButtons(session = session, inputId = "actlocal", selected = actor_codes[["actlocal"]][[1]])
  updateCheckboxInput(session = session, inputId = "opt_out_relevant", value = as.logical(actor_codes[["opt_out_relevant"]]))
  updateCheckboxInput(session = session, inputId = "relevant_quote", value = as.logical(actor_codes[["relevant_quote"]]))
}

set_to_actor_values <- function(session = shiny::getDefaultReactiveDomain(), actor_id){
  actor_codes <<- full_dataset[full_dataset$entity_id == actor_id,]
  for(variable in actor_variables){
    if(is.na(actor_codes[[variable]][[1]])){
      if(variable %in% c("opt_out_relevant", "relevant_quote")){
        actor_codes[[variable]][[1]] <- FALSE
      }
      else if(variable == "affiliation"){
        actor_codes[[variable]][[1]] <- ""
      }
      else {
        actor_codes[[variable]][[1]] <- as.character(0)
      }
    }
  }
  updateTextInput(session = session, inputId = "affiliation", value = actor_codes[["affiliation"]][[1]])
  updateRadioButtons(session = session, inputId = "gender", selected = actor_codes[["gender"]][[1]])
  updateSelectInput(session = session, inputId = "socarea_oberkat", selected = actor_codes[["socarea_oberkat"]][[1]])
  updateRadioButtons(session = session, inputId = "socarea_wiss", selected = actor_codes[["socarea_wiss"]][[1]])
  updateRadioButtons(session = session, inputId = "socarea_pol", selected = actor_codes[["socarea_pol"]][[1]])
  updateRadioButtons(session = session, inputId = "socarea_iv", selected = actor_codes[["socarea_iv"]][[1]])
  updateRadioButtons(session = session, inputId = "socarea_ivzo", selected = actor_codes[["socarea_ivzo"]][[1]])
  updateRadioButtons(session = session, inputId = "socarea_ivko", selected = actor_codes[["socarea_ivko"]][[1]])
  updateRadioButtons(session = session, inputId = "socarea_sonst", selected = actor_codes[["socarea_sonst"]][[1]])
  updateRadioButtons(session = session, inputId = "actlocal", selected = actor_codes[["actlocal"]][[1]])
  updateCheckboxInput(session = session, inputId = "opt_out_relevant", value = as.logical(actor_codes[["opt_out_relevant"]]))
  updateCheckboxInput(session = session, inputId = "relevant_quote", value = as.logical(actor_codes[["relevant_quote"]]))
}

## Funktion, um gespeicherte Aussagen/neue direkte Interaktionen aus den Datensätzen zu löschen, falls die Aussagen- und Interaktionscodierung durch einen Klick auf "back_to_actor" neu gestartet wird
reset_saved_text_inputs <- function(actor){
  coded_statements <- readRDS(file.path(file_paths_new_datasets, "coded_statements.Rds"))
  coded_statements <- coded_statements |> 
    filter(entity_id != actor)
  coded_interactions <- readRDS(file.path(file_paths_new_datasets, "coded_interactions.Rds"))
  coded_interactions <- coded_interactions |> 
    filter(entity_id != actor)
  
  saveRDS(coded_statements, file.path(file_paths_new_datasets, "coded_statements.Rds"))
  saveRDS(coded_interactions, file.path(file_paths_new_datasets, "coded_interactions.Rds"))
}

# Zurücksetzen der Inputs auf Standardwerte
reset_inputs <- function(session = shiny::getDefaultReactiveDomain()){
  updateTextInput(session = session, inputId = "affiliation", value = "")
  updateRadioButtons(session = session, inputId = "gender", selected = character(0))
  updateSelectInput(session = session, inputId = "socarea_oberkat", selected = character(0))
  updateRadioButtons(session = session, inputId = "socarea_wiss", selected = character(0))
  updateRadioButtons(session = session, inputId = "socarea_pol", selected = character(0))
  updateRadioButtons(session = session, inputId = "socarea_iv", selected = character(0))
  updateRadioButtons(session = session, inputId = "socarea_ivzo", selected = character(0))
  updateRadioButtons(session = session, inputId = "socarea_ivko", selected = character(0))
  updateRadioButtons(session = session, inputId = "socarea_sonst", selected = character(0))
  updateRadioButtons(session = session, inputId = "actlocal", selected = character(0))
  updateCheckboxInput(session = session, inputId = "opt_out_relevant", value = FALSE)
  updateCheckboxInput(session = session, inputId = "relevant_quote", value = FALSE)
  updateTextInput(session = session, inputId = "statement", value = "")
  updateCheckboxInput(session = session, inputId = "irrelevant_statement", value = FALSE)
  updateCheckboxInput(session = session, inputId = "actor_statement", value = FALSE)
  updateSelectInput(session = session, inputId = "statement_type_oberkat", selected = character(0))
  updateRadioButtons(session = session, inputId = "statement_type_actclaim", selected = character(0))
  updateRadioButtons(session = session, inputId = "valclaim", selected = character(0))
  updateRadioButtons(session = session, inputId = "obj_persp", selected = character(0))
  updateRadioButtons(session = session, inputId = "eval_subj_oberkat", selected = character(0))
  updateRadioButtons(session = session, inputId = "eval_subj_actor", selected = character(0))
  updateRadioButtons(session = session, inputId = "eval", selected = character(0))
  updateRadioButtons(session = session, inputId = "time_persp", selected = character(0))
  updateRadioButtons(session = session, inputId = "addressee", selected = character(0))
  updateRadioButtons(session = session, inputId = "statement_leaning", selected = character(0))
  updateCheckboxInput(session = session, inputId = "dir_int_identification", value = FALSE)
  updateRadioButtons(session = session, inputId = "dir_int_filter", selected = character(0))
  updateSelectInput(session = session, inputId = "dir_int_eval", selected = character(0))
  updateSelectInput(session = session, inputId = "dir_int_actclaim", selected = character(0))
  updateSelectInput(session = session, inputId = "dir_int", selected = character(0))
  updateTextInput(session = session, inputId = "dir_int_other", value = "")
  updateTextInput(session = session, inputId = "dir_int_other_eval", value = "")
  updateTextInput(session = session, inputId = "dir_int_other_actclaim", value = "")
  updateCheckboxInput(session = session, inputId = "false_int", value = FALSE)
  updateRadioButtons(session = session, inputId = "int_type", selected = character(0))
}

### Funktion, um bereits im Zuge der Aussagencodierung codierte (direkte) Interaktionen zwischen aktiven Akteur:innen aus dem Datensatz herauszufiltern
mark_direct_interactions <- function(interaction_dataset){
  if(file.exists(file.path(file_paths_new_datasets, "coded_statements.Rds"))){
    coded_statements <- readRDS(file.path(file_paths_new_datasets, "coded_statements.Rds"))
    interactions <- interaction_dataset
    coded_int_ids <- coded_statements |> 
      pivot_longer(cols = c(dir_int_eval, dir_int_actclaim, dir_int),
                   names_to = "variable",
                   values_to = "int_id") |> 
      filter(!is.na(int_id)) |> 
      pull(int_id)
    interactions <- interactions |> 
      mutate(coded = if_else(int_id %in% coded_int_ids, TRUE, coded))
    interactions
  }
  else {
    interactions <- interaction_dataset
    interactions
  }
}

### Markieren der Akteursnamen im Text
mark_actor_names <- function(actor_name){
  paste0("<mark style=\"background-color: #32cd32;\"><strong>", actor_name, "</strong></mark>")
}
mark_statements <- function(statement){
  paste0("<mark style=\"background-color: #32cd32;\">", statement, "</mark>")
}
mark_partner_names <- function(partner_name){
  paste0("<mark style=\"background-color: #29abe0;\"><strong>", partner_name, "</strong></mark>")
}

### Hilfsfunktion, um leere Inputs zu normalisieren und in logischen Abfragen zu verwenden
empty_inputs <- function(input, empty = ""){
  if(is.null(input) | length(input) == 0){
    empty
  }
  else {
    input
  }
}


## UI

# Oberfläche: Schriftart (Größe), Buttons ("gefährliche" Buttons, z. B. Abbruch & "Zurück"-Button) und Scroll-Box, um vertikales Scrollen zu aktivieren, wenn Inhalte die Maximalhöhe (100vh-142px) überschreitet
app_style <- 'p, label, ul{
  font-size: 16px;
}
.app-danger.btn-danger {
  color: #ffffff !important;
  margin-top: 20px;
  margin-bottom: 10px;
}
.app-back.btn-secondary{
  margin-top: 20px;
  margin-bottom: 10px;
}
.scrollbox{
  overflow-y: auto;
  max-height: calc(100vh - 142px);
}
.tab-content {
  padding-top: 20px;
}'

# Erzeugung der Input-Elemente

## Coder-ID
coder_input <- numericInput("coder_id", label = "Coder-ID:",
                            value = 1, min = 1, max = 20, step = 1)

## Besprechungsmodus
besprechung_input <- checkboxInput("besprechung", label = "Besprechungsmodus")

## Opt-Out Relevanz
opt_out_relevance_input <- wellPanel(style = "background-color:#ffffff;",
                                     p("Irrläufer"),
                                     checkboxInput("opt_out_relevant", "Es handelt sich nicht um eine:n aktive:n Akteur:in.", 
                                                   value = FALSE))

# Affiliation
affiliation_input <- textInput("affiliation", label = "Affiliation")

# Geschlecht
gender_input <- radioButtons("gender", label = "Geschlecht",
                             choices = c("männlich" = 0,
                                         "weiblich" = 1,
                                         "anderes/nicht eindeutig bestimmbar" = 99),
                             selected = character(0))

# Gesellschaftsbereich
socarea_oberkat_input <- selectInput("socarea_oberkat", label = "Gesellschaftsbereich",
                                     choices = c("Nichts ausgewählt" = "",
                                                 "Wissenschaft" = 100,
                                                 "Politik" = 200,
                                                 "Interessensvertretungen" = 300,
                                                 "sonstige Bereiche" = 400))
socarea_wiss_input <- radioButtons("socarea_wiss", label = "Wissenschaftlicher Bereich",
                                     choices = c("universitäre Forschung" = 110,
                                                 "wissenschaftliche Administration" = 120,
                                                 "außeruniversitäre Forschung" = 130,
                                                 "wissenschaftliche Verbände/Kollektive" = 140,
                                                 "Nicht spezifiziert" = 100),
                                   selected = character(0))

socarea_pol_input <- radioButtons("socarea_pol", label = "Politischer Bereich",
                                   choices = c("Exekutive" = 210,
                                               "politische Administration" = 220,
                                               "Legislative" = 230,
                                               "Nicht spezifiziert" = 200),
                                  selected = character(0))

socarea_iv_input <- radioButtons("socarea_iv", label = "Interessensvertretung",
                                   choices = c("zivilgesellschaftliche Organisationen" = 310,
                                               "kommerzielle Organisationen" = 320,
                                               "Privatpersonen" = 330,
                                               "Nicht spezifiziert" = 300),
                                 selected = character(0))

socarea_ivzo_input <- wellPanel(style = "background-color:#ffffff;",
                                radioButtons("socarea_ivzo", label = "Zivilgesellschaftliche Organisationen",
                                   choices = c("Kollektivgüter (Gemeinwohl)" = 311,
                                               "nicht-profitorientierte Partialinteressen" = 312,
                                               "Nicht spezifiziert" = 310),
                                   selected = character(0)))

socarea_ivko_input <- wellPanel(style = "background-color:#ffffff;",
                                radioButtons("socarea_ivko", label = "Kommerzielle Organisationen",
                                 choices = c("Unternehmen/Firmen" = 321,
                                             "profitorientierte Verbände/Kollektive" = 322,
                                             "Nicht spezifiziert" = 320),
                                 selected = character(0)))

socarea_sonst_input <- radioButtons("socarea_sonst", label = "Sonstiger Bereich",
                                 choices = c("Recht" = 410,
                                             "Finanz- und Versicherungswesen" = 420,
                                             "Gesundheit" = 430,
                                             "öffentliche Sicherheit" = 440,
                                             "Bildung" = 450,
                                             "Kultur" = 460,
                                             "Journalismus" = 470,
                                             "Nicht spezifiziert" = 400),
                                 selected = character(0))

# nationale Verortung
actlocal_input <- radioButtons("actlocal", label = "Nationale Verortung",
                               choices = c("national" = 1,
                                           "supra-/international" = 2,
                                           "global" = 3,
                                           "nicht feststellbar" = 99),
                               selected = character(0))

# Bezug zum Diskursgegenstand
relevant_quote_input <- wellPanel(style = "background-color:#ffffff;",
                                  p("Relevante Aussage(n)"),
                                  checkboxInput("relevant_quote", label = "Akteur:in äußert sich zum Diskursgegenstand.",
                                                value = FALSE))

# Aussagenidentifikation
statement_input <- textInput("statement", label = "Aussage des:der Akteur:in")

# Filtervariablen Aussage
relevant_statement_input <- wellPanel(style = "background-color:#ffffff;",
                                      p("Filter"),
                                      checkboxInput("irrelevant_statement", label = "Aussage hat keinen Bezug zum Diskurs(gegenstand).", value = FALSE),
                                      checkboxInput("actor_statement", label = "Aussage bezieht sich auf eine:n andere:n relevante:n Akteur:in.", value = FALSE))

# Aussagentyp
statement_type_oberkat_input <- selectInput("statement_type_oberkat", label = "Aussagentyp",
                                            choices = c("Nichts ausgewählt" = "",
                                                        "Sachaussage" = 1,
                                                        "Deutung" = 2,
                                                        "Handlungsaufforderung" = 3,
                                                        "Selbstverpflichtung" = 4,
                                                        "Sonstiges" = 5,
                                                        "nicht feststellbar/uneindeutig" = 99))

statement_type_actclaim_input <- radioButtons("statement_type_actclaim", label = "Handlungsaufforderung",
                                              choices = c("direkt" = 31,
                                                          "indirekt" = 32),
                                              selected = character(0))

valclaim_input <- radioButtons("valclaim", label = "Geltungsanspruch",
                               choices = c("Allgemeingültigkeit" = 11,
                                           "persönliche Wahrnehmung/Erfahrung" = 12,
                                           "formallogische Gültigkeit" = 13),
                               selected = character(0))

obj_persp_input <- radioButtons("obj_persp", label = "Perspektive (\"Objektivität\")",
                                choices = c("objektive Einordnung" = 21,
                                            "subjektive Einschätzung" = 22),
                                selected = character(0))

eval_subj_oberkat_input <- radioButtons("eval_subj_oberkat", label = "Bewertungssubjekt",
                                                  choices = c("Diskursgegenstand" = 1,
                                                              "Andere:r Akteur:in" = 2,
                                                              "nicht erkennbar" = 99),
                                                  selected = character(0))

eval_subj_actor_input <- radioButtons("eval_subj_actor", label = "Bewertete:r Akeur:in",
                                      choices = c("Akteur:in im Text" = 21,
                                                  "individuelle:r Akteur:in" = 22,
                                                  "Wissenschaft" = 23,
                                                  "Politik" = 24,
                                                  "Judikative (Recht)" = 25,
                                                  "Wirtschaft" = 26,
                                                  "zivilgesellschaftliche Organisationen" = 27,
                                                  "Öffentlichkeit/Allgemeinheit" = 28,
                                                  "Sonstige" = 29),
                                      selected = character(0))

eval_input <- radioButtons("eval", label = "Bewertung",
                           choices = c("negativ" = -1,
                                       "ambivalent" = 0,
                                       "positiv" = 1),
                           selected = character(0))

time_persp_input <- radioButtons("time_persp", label = "Zeitlicher Bezug",
                                 choices = c("Vergangenheit" = 1,
                                             "Gegenwart" = 2,
                                             "Zukunft" = 3,
                                             "kein zeitlicher Bezug erkennbar" = 9),
                                 selected = character(0))

addressee_input <- radioButtons("addressee", label = "Adressat",
                                choices = c("Akteur:in im Text" = 1,
                                            "individuelle:r Akteur:in" = 2,
                                            "Wissenschaft" = 3,
                                            "Politik" = 4,
                                            "Judikative (Recht)" = 5,
                                            "Wirtschaft" = 6,
                                            "zivilgesellschaftliche Organisationen" = 7,
                                            "Öffentlichkeit/Allgemeinheit" = 8,
                                            "Sonstige" = 9),
                                selected = character(0))

# Aussagentendenz
statement_leaning_input <- radioButtons("statement_leaning", label = "Aussagentendenz",
                                        choices = c("negative Tendenz" = -1,
                                                    "neutral" = 0,
                                                    "positive Tendenz" = 1,
                                                    "ambivalent" = 99),
                                        selected = character(0))

# direkte Interaktion
dir_int_identification_input <- checkboxInput("dir_int_identification", label = "Es wird ein:e Akteur:in in der Aussage erwähnt.")

dir_int_filter_input <- radioButtons("dir_int_filter", label = "Direkte Interaktion",
                                     choices = c("Es wird ein:e aktive:r Akteur:in aus dem Text erwähnt." = 11,
                                                 "Es wird ein:e andere:r individuelle:r Akteur:in erwähnt." = 12),
                                     selected = character(0))

## 3 unterschiedliche Listen, um Auswahllisten in ConditionalPanels zu ermöglichen (sonst wird immer nur eine Liste geupdatet) -> Workaround
dir_int_eval_input <- selectInput("dir_int_eval", label = "angesprochene:r Akteur:in",
                             choices = c("Nichts ausgewählt" = ""))

dir_int_actclaim_input <- selectInput("dir_int_actclaim", label = "angesprochene:r Akteur:in",
                             choices = c("Nichts ausgewählt" = ""))

dir_int_input <- selectInput("dir_int", label = "angesprochene:r Akteur:in",
                             choices = c("Nichts ausgewählt" = ""))

## 3 unterschiedliche Textinputs, um klare Zuordnung der direkten Interaktion zu Aussagen zu ermöglichen
dir_int_other_eval_input <- textInput("dir_int_other_eval", label = "Name des:der angesprochenen Akteur:in")

dir_int_other_actclaim_input <- textInput("dir_int_other_actclaim", label = "Name des:der angesprochenen Akteur:in")

dir_int_other_input <- textInput("dir_int_other", label = "Name des:der angesprochenen Akteur:in")

# Interaktions-Filter
false_int_input <- wellPanel(style = "background-color:#ffffff;",
                            p("Filter"),
                            checkboxInput("false_int", label = "Es liegt keine Interaktion zwischen den Akteur:innen vor.",
                                          value = FALSE))

# Interaktionstyp
int_type_input <- radioButtons("int_type", label = "Interaktionstyp",
                               choices = c("negative Verbindung" = -1,
                                           "Leistungs-/Verantwortungsverbindung" = 0,
                                           "positive Verbindung" = 1),
                               selected = character(0))

# Aufbau der Nutzeroberfläche

ui <- fluidPage(
  theme = bs_theme(bootswatch = "sandstone"),
  tags$head(tags$style(app_style)),
  useShinyjs(),
  br(),
  h4(tags$b("Codierung struktureller Merkmale von Wissenschafts- und Technologiediskursen")),
  br(),
  # Seite, auf der man zwischen verschiedenen Tabs wechseln kann
  navset_card_underline(
    nav_panel(
      title = "Codebogen",
      sidebarLayout(
        mainPanel(
          width = 8,
          tags$div(
            id = "initialisierung",
            wellPanel(style = "
                      background-color:#ffffff;
                      ",
                      p("Vor Beginn der Codierung muss die Coder-ID eingetragen und der Datensatz ausgewählt werden: "),
                      coder_input,
                      shinyFilesButton("dataset", label = "Zu codierenden Datensatz auswählen",
                                       title = "Datensatz auswählen",
                                       multiple = FALSE,
                                       class = "btn-secondary btn-lg")),
            tags$div(id = "dataset_info", uiOutput("initialisierung_info"))
          )
        ),
        sidebarPanel(
          width = 4,
          style = "
                  background-color:#ffffff;
                  border-color:#ffffff;
                  ",
          tags$div(id = "coding_area")
        ),
        position = "left"
      )
    ),
    nav_menu(
      title = "Codebuch",
      nav_panel(
        title = "Einleitung",
        tabsetPanel(
          tabPanel(
            title = "Einleitung",
            fluidRow(column(8, includeMarkdown("source_codebuch/einleitung.md")))
          ),
          tabPanel(
            title = "Module und Add-Ons",
            fluidRow(column(8, includeMarkdown("source_codebuch/module_add_ons.md")))
          ),
          tabPanel(
            title = "Untersuchungsgegenstand & Methode",
            fluidRow(column(8, includeMarkdown("source_codebuch/methode.md")))
          ),
          tabPanel(
            title = "Formale Variablen",
            fluidRow(column(8, includeMarkdown("source_codebuch/formale_variablen.md")))
          )
        )
      ),
      nav_panel(
        title = "Akteursebene",
        tabsetPanel(
          tabPanel(
            title = "Formale Variablen & Filter",
            fluidRow(column(8, includeMarkdown("source_codebuch/formale_variablen_filter_akteursebene.md")))
          ),
          tabPanel(
            title = "Affiliation & Geschlecht",
            fluidRow(column(8, includeMarkdown("source_codebuch/affiliation_gender.md")))
          ),
          tabPanel(
            title = "Gesellschaftsbereich",
            fluidRow(column(8, includeMarkdown("source_codebuch/socarea.md")))
          ),
          tabPanel(
            title = "Nationale Verortung",
            fluidRow(column(8, includeMarkdown("source_codebuch/actlocal.md")))
          ),
          tabPanel(
            title = "Diskursbezug",
            fluidRow(column(8, includeMarkdown("source_codebuch/relevant_quote.md")))
          )
        )
      ),
      nav_panel(
        title = "Aussagenebene",
        tabsetPanel(
          tabPanel(
            title = "Einleitung",
            fluidRow(column(8, includeMarkdown("source_codebuch/statement_identification.md")))
          ),
          tabPanel(
            title = "Aussagentyp",
            fluidRow(column(8, includeMarkdown("source_codebuch/statement_type.md")))
          ),
          tabPanel(
            title = "Aussagentendenz",
            fluidRow(column(8, includeMarkdown("source_codebuch/statement_leaning.md")))
          ),
          tabPanel(
            title = "Erweiterungen",
            fluidRow(column(8, includeMarkdown("source_codebuch/statement_content.md")))
          ),
          tabPanel(
            title = "Direkte Interaktionen",
            fluidRow(column(8, includeMarkdown("source_codebuch/dir_int_filter.md")))
          )
        )
      ),
      nav_panel(
        title = "Interaktionsebene",
        tabsetPanel(
          tabPanel(
            title = "Indirekte Interaktionen & Filter",
            fluidRow(column(8, includeMarkdown("source_codebuch/interactions.md")))
          ),
          tabPanel(
            title = "Interaktionstyp",
            fluidRow(column(8, includeMarkdown("source_codebuch/int_type.md")))
          )
        )
      )
    )
  )
)

## Server

server <- function(input, output, session){
  
  # Angabe der Startzeit der Codierung
  start_time <- Sys.time()
  
  # Erzeugung von Reactive Values
  rv <- reactiveValues()
  
  # Zahl der codierten Akteur:innen
  rv$actors_coded <- 0
  # Index des:der aktuellen Akteur:in
  rv$index_actor <- 0
  # Index der aktuellen Aussage
  rv$index_statement <- 0
  # Index der aktuellen Interaktion
  rv$index_interaction <- 0
  
  # Speicher für identifizierte Aussagen
  statements <- reactiveVal(
    tibble(
      entity_id = integer(),
      entity = character(),
      document_id = integer(),
      statement_id = integer(),
      statement = character(),
      coded = FALSE
    )
  )
  
  # dynamische Liste der verfügbaren Aussagen-IDs
  rv$statement_ids <- list()
  statement_ids_by_actor <- reactive({
    req(statements())
    statements <- statements()
    if(input$besprechung) {
      statements <- statements[statements$coded,][["statement_id"]]
    }
    else {
      statements <- statements[!statements$coded,][["statement_id"]]
    }
  })
  
  # Speicher für manuell hinzugefügte direkte Interaktionen
  new_direct_interactions <- reactiveVal(
    tibble(
      entity_id = integer(),
      entity = character(),
      entity_id_2 = integer(),
      entity_2 = character(),
      document_id = integer(),
      int_id = character(),
      batch_id = character(),
      coded = TRUE
    )
  )
  
  # dynamische Liste der verfügbaren Interaktions-IDs
  rv$interaction_ids <- list()
  interaction_ids_by_actor <- reactive({
    req(interactions_dataset())
    interactions <- interactions_dataset()
    if(input$besprechung) {
      interactions <- interactions[interactions$coded,][["int_id"]]
    }
    else {
      interactions <- interactions[!interactions$coded,][["int_id"]]
    }
  })
  
  # Zwischenspeicher für batch-IDs der Texteingaben für neue direkte Interaktionen
  rv$batch_id <- NULL
  
  # Sidebar, in dem Informationen zur aktuellen Codier-Session angezeigt werden
  
  # Dauer der Session (Aktualisierung minütlich)
  output$duration_session <- renderText({
    invalidateLater(
      millis = 60000,
      session = session
    )
    dt <- difftime(
      time1 = Sys.time(),
      time2 = start_time,
      units = "secs"
    )
    paste0("<b>Dauer der Session: ", format(.POSIXct(dt, tz = "GMT"), "%H:%M</b>"))
  })
  
  # Zahl der codierten Akteur:innen
  output$coded_actors_session <- renderText({
    paste0("<b>Codierte Akteur:innen (Session): ", rv$actors_coded, "</b>")
  })
  
  # Insgesamt codierte Akteur:innen
  output$coded_actors_gesamt <- renderText({
    req(actors_dataset())
    rv$index_actor
    number_coded_actors <- ifelse(exists("full_dataset"), length(full_dataset[full_dataset$coded, "coded"]), 0)
    paste0("<b>Insgesamt codierte Akteur:innen: ", number_coded_actors, "</b>")
  })
  
  # Im Datensatz enthaltene Akteur:innen
  output$ausgangsdatensatz <- renderText({
    req(actors_dataset())
    paste0("<b>Enthaltene Akteur:innen: ", nrow(actors_dataset()), "</b>")
  })
  
  # Vorgaben zum Einlesen von Dateien
  ## max. Größe: 300 Mb
  options(shiny.maxRequestSize = 300*1024^2)
  ## Verzeichnis festlegen
  roots = c(wd = '.')
  shinyFileChoose(input, "dataset", roots = roots,
                  filetypes=c('', 'RDS', 'Rds'),
                  defaultPath = '', defaultRoot = 'wd')
  
  # Einlesen der Datei
  actors_dataset <- reactive({
    req(input$dataset)
    file <- parseFilePaths(roots = roots, input$dataset)
    ext <- tools::file_ext(file$datapath)
    # Überprüfung des richtigen Formats
    req(file)
    validate(need(ext %in% c("RDS", "Rds"), "Falsches Dateiformat. Bitte eine .Rds-Datei auswählen."))
    # Anlegen des Datensatzes: wenn noch nicht vorhanden (beim ersten Einlesen), wird die Variable "coded" erzeugt
    actors <- readRDS(file$datapath)
    if(!"coded" %in% names(actors)){actors$coded <- FALSE}
    if(!"coded_actor" %in% names(actors)){actors$coded_actor <- FALSE}
    full_dataset <<- actors
    actors
  })
  
  # Nach erfolgreichem Einlesen: Anzeige von Datensatz-Informationen
  output$initialisierung_info <- renderUI({
    req(actors_dataset())
    file <- parseFilePaths(roots = roots, input$dataset)
    dataset_name <- paste0("Datensatz ", file$name, " erfolgreich eingelesen.")
    actor_info <- paste0("Im Datensatz sind insgesamt ", length(actors_dataset()$entity), " Akteur:innen enthalten. Davon wurden bereits ", length(actors_dataset()[actors_dataset()$coded, ][["coded"]]), " Akteur:innen codiert.")
    tags$div(id = "infotext", br(), p(dataset_name), p(actor_info))
  })
  
  # Button, um Codierung zu beginnen
  observeEvent(actors_dataset(), {
    insertUI(selector = "#dataset_info", where = "afterEnd",
             ui = tags$div(id = "start",
                           besprechung_input,
                           actionButton("start_button", label = "Codieren beginnen", class = "btn-secondary btn-lg"),
                           br(),
                           br()))
  }, once = TRUE)
  
  observeEvent(input$start_button, {
    # zunächst wird geprüft, ob der Datensatz schon vollständig codiert wurde
    if(length(full_dataset[!full_dataset$coded,][["coded"]]) == 0 & !input$besprechung){
      show_alert(title = "Fehler", text = "Alle Akteur:innen aus dem Datensatz wurden bereits codiert.")
    }
    else{
      # Dateipfad zum Datensatz wird festgelegt
      file <- parseFilePaths(roots = roots, input$dataset)
      file_path <<- file$datapath
      file_paths_new_datasets <<- dirname(file$datapath)
      # die Coder-ID wird im Datensatz notiert
      coder <<- input$coder_id
      # UI-Elemente zur Anzeige der Datensatzinformationen
      insertUI(selector = "#coding_area", where = "beforeEnd",
               ui = tags$div(id = "coder_info",
                             htmlOutput("duration_session"),
                             br(),
                             htmlOutput("coded_actors_session"),
                             br(),
                             htmlOutput("coded_actors_gesamt"),
                             br(),
                             htmlOutput("ausgangsdatensatz"),
                             br(),
                             br()))
      # Textanzeige und Tabelle, die bereits codierte Akteur:innen enthält
      insertUI(selector = "#initialisierung", where = "afterEnd",
               ui = wellPanel(style = "background-color:#ffffff;",
                              tags$div(id = "text_area_actor",
                                       uiOutput("article_actor")),
                              tags$div(id = "actors_article",
                                       br(),
                                       hr(),
                                       h4(tags$b("Im Artikel codierte Akteur:innen")),
                                       tableOutput("actors_table"))))
      # Codier-Elemente auf der Akteursebene einfügen
      insertUI(selector = "#coder_info", where = "afterEnd",
               ui = tags$div(id = "actor_inputs",
                             # der:die zu codierende Akteur:in wird über dem Codierbereich angezeigt
                             wellPanel(style = "border-color:#32cd32; background-color:#ffffff;",
                                       tags$div(id = "actor_to_code",
                                                uiOutput("actor"))),
                             opt_out_relevance_input,
                             br(),
                             # Codierelemente werden ausgeblendet, wenn Irrläufer erkannt wird
                             conditionalPanel(
                               condition = "input.opt_out_relevant == false",
                               affiliation_input,
                               gender_input,
                               socarea_oberkat_input,
                               # je nach gewählter Oberkategorie werden die Unterkategorien als Auswahlmöglichkeiten angezeigt
                               conditionalPanel(
                                 condition = "input.socarea_oberkat == 100",
                                 socarea_wiss_input),
                               conditionalPanel(
                                 condition = "input.socarea_oberkat == 200",
                                 socarea_pol_input),
                               conditionalPanel(
                                 condition = "input.socarea_oberkat == 300",
                                 socarea_iv_input,
                                 conditionalPanel(
                                   condition = "input.socarea_iv == 310",
                                   socarea_ivzo_input),
                                 conditionalPanel(
                                   condition = "input.socarea_iv == 320",
                                   socarea_ivko_input)
                               ),
                               conditionalPanel(
                                 condition = "input.socarea_oberkat == 400",
                                 socarea_sonst_input),
                               actlocal_input,
                               relevant_quote_input
                             ),
                             # abhängig von der Codierung in "relevant_quote" werden zwei Buttons eingefügt:
                             # Liegt keine inhaltlich relevante Aussage vor (relevant_quote = FALSE), kann über die Buttons entweder zum:zur letzten Akteur:in zurückgekehrt werden oder der:die aktuelle Akteur:in abgespeichert und die Codierung beendet werden.
                             conditionalPanel(
                               style = "background-color:#ffffff; border-color:#ffffff;",
                               condition = "input.relevant_quote == false",
                               hr(),
                               splitLayout(
                                 cellWidths = c("30%", "70%"),
                                 actionButton("last_actor", "Zurück", class = "btn-secondary btn-lg", width = "100%"),
                                 actionButton("end_coding", "Codierung beenden", class = "btn-danger btn-lg", width = "100%"))
                             ),
                             # Liegt min. 1 relevante Aussage vor (relevant_quote = TRUE), kann mit den Buttons entweder zum:zur letzten Akteur:in zurück navigiert werden oder der:die aktuelle Akteur:in abgespeichert und zur Aussagenidentifikation übergegangen werden.
                             conditionalPanel(
                               style = "background-color:#ffffff; border-color:#ffffff;",
                               condition = "input.relevant_quote == true",
                               hr(),
                               splitLayout(
                                 cellWidths = c("30%", "70%"),
                                 actionButton("last_actor", "Zurück", class = "btn-secondary btn-lg", width = "100%"),
                                 actionButton("submit_actor", "Zur Aussagenidentifikation", class = "btn-info btn-lg", width = "100%"))
                             ),
               )
      )
      # Die Elemente, um den Datensatz einzulesen, werden entfernt
      removeUI(selector = "#start")
      removeUI(selector = "#dataset_info")
      removeUI(selector = "#initialisierung")
      if(input$besprechung){
        ids <<- full_dataset[full_dataset$coded,][["entity_id"]]
      }
      else{
        ids <<- full_dataset[!full_dataset$coded,][["entity_id"]]
      }
      rv$index_actor <- rv$index_actor + 1
    }
  })
  
  # Wenn die Codierung der:der Akteur:in mit "end_coding" abgebrochen wird, werden die eingegebenen Daten im Akteursdatensatz gespeichert, der Akteurs-Index erhöht und ein:e neue:r Akteur:in aus dem Datensatz gezogen
  observeEvent(input$end_coding,{
    # zunächst wird geprüft, ob alle Felder ausgefüllt wurden
    if(("" %in% c(input$affiliation, empty_inputs(input$gender), input$socarea_oberkat, empty_inputs(input$actlocal)) & !input$opt_out_relevant) |
       (empty_inputs(input$socarea_wiss) == "" & input$socarea_oberkat == 100) |
       (empty_inputs(input$socarea_pol) == "" & input$socarea_oberkat == 200) |
       (empty_inputs(input$socarea_iv) == "" & input$socarea_oberkat == 300) |
       (empty_inputs(input$socarea_ivzo) == "" & empty_inputs(input$socarea_iv) == 310 & input$socarea_oberkat == 300) |
       (empty_inputs(input$socarea_ivko) == "" & empty_inputs(input$socarea_iv) == 320 & input$socarea_oberkat == 300) |
       (empty_inputs(input$socarea_sonst) == "" & input$socarea_oberkat == 400)){
      show_alert(title = "Fehler", text = "Bitte zuerst alle Felder ausfüllen, um mit dem:der nächsten Akteur:in fortzufahren.", type = "error")
    }
    # wenn alle Felder ausgefüllt wurden und der:die Akteur:in nicht bereits zuvor codiert war, wird die Zahl der codierten Akteur:innen um 1 erhöht (Anzeige in der Coder-Info)
    else{
      if(!full_dataset[full_dataset$entity_id == ids[rv$index_actor], "coded"]){
        rv$actors_coded <- rv$actors_coded + 1
      }
      # mit der save_actors-Funktion werden die Akteur:inneneigenschaften im Datensatz gespeichert
      withProgress(message = "Akteurseigenschaften werden gespeichert", value = 0.5, 
                   {save_actors(draw_actor(), codebogen_actors())
                     incProgress(amount = 0.5)})
      # da die Codierung abgebrochen wurde, wird an dieser Stelle auch die "save_complete_coding"-Funktion aufgerufen, um die "coded"-Variable des:der Akteur:in auf TRUE zu setzen
      save_complete_coding(draw_actor())
      # anschließend wird geprüft, ob noch uncodierte Akteur:innen im Datensatz vorhanden sind
      if(length(ids) == rv$index_actor){
        # ist das nicht der Fall, wird eine Fehlermeldung angezeigt -> die Codierung ist dann vollständig abgeschlossen
        show_alert(title = "Codierung vollständig",
                   text = "Alle Akteur:innen in diesem Datensatz wurden codiert.\nDie App kann nun geschlossen werden.")
      }
      # befinden sich noch uncodierte Akteur:innen im Datensatz wird der Akteursindex erhöht 
      else {
        rv$index_actor <- rv$index_actor + 1
        }
    }
  })
  
  # Wenn die Codierung der Akteur:inneneigenschaften über den "submit_actor"-Button beendet wird, werden die Akteurscodierungen im Datensatz gespeichert und die Codieroberfläche wird verändert, um mit der Aussagenidentifikation zu beginnen
  observeEvent(input$submit_actor, {
    # zuvor wird überprüft, ob alle relevanten Felder in der Akteurscodierung ausgefüllt wurden
    if(("" %in% c(input$affiliation, empty_inputs(input$gender), input$socarea_oberkat, empty_inputs(input$actlocal)) & !input$opt_out_relevant) |
       (empty_inputs(input$socarea_wiss) == "" & input$socarea_oberkat == 100) |
       (empty_inputs(input$socarea_pol) == "" & input$socarea_oberkat == 200) |
       (empty_inputs(input$socarea_iv) == "" & input$socarea_oberkat == 300) |
       (empty_inputs(input$socarea_ivzo) == "" & empty_inputs(input$socarea_iv) == 310 & input$socarea_oberkat == 300) |
       (empty_inputs(input$socarea_ivko) == "" & empty_inputs(input$socarea_iv) == 320 & input$socarea_oberkat == 300) |
       (empty_inputs(input$socarea_sonst) == "" & input$socarea_oberkat == 400)){
      show_alert(title = "Fehler", text = "Bitte zuerst alle Felder ausfüllen, um mit dem:der nächsten Akteur:in fortzufahren.", type = "error")
    }
    else {
      # die Akteur:inneneigenschaften werden gespeichert und die Anzahl der codierten Akteur:innen um 1 erhöht
      if(!full_dataset[full_dataset$entity_id == ids[rv$index_actor], "coded"]){
        rv$actors_coded <- rv$actors_coded + 1
      }
      # mit der save_actors-Funktion werden die Akteur:inneneigenschaften im Datensatz gespeichert
      withProgress(message = "Akteurseigenschaften werden gespeichert", value = 0.5, 
                   {save_actors(draw_actor(), codebogen_actors())
                     incProgress(amount = 0.5)})
    # anschließend werden die UI-Elemente für die Akteurscodierung ausgeblendet
    removeUI(selector = "#actor_inputs")
    removeUI(selector = "#actor_to_code")
    # dafür wird ein Freitextfeld eingeblendet, in dem die Aussagen erfasst werden können
    insertUI(selector = "#coder_info", where = "afterEnd",
             ui = tags$div(id = "statement_identification",
                           statement_input,
                           actionButton("submit_statement", "Ok", class = "btn-info btn-lg", width = "40%"),
                           hr(),
                           actionButton("back_to_actor", "Zurück zum:zur Akteur:in", class = "btn-secondary btn-lg", width = "100%")))
    }
  })
  
  # Wenn eine Aussage über den "submit_statement"-Button bestätigt wird, ändert sich die Codieroberfläche, um die Aussage zu codieren
  observeEvent(input$submit_statement, {
    # bevor sich die Oberfläche ändert, wird überprüft, ob eine Aussage in das Feld eingetragen wurde
    if(!nzchar(input$statement)){
      show_alert(title = "Fehler", text = "Bitte eine Aussage in das Freitextfeld eintragen.", type = "error")
    }
    else {
      # Wenn eine Aussage identifiziert wurde, wird der Statement-Index um 1 erhöht, wodurch die Aussage zur Codierung durch "draw_statement" freigegeben wird
      rv$index_statement <- rv$index_statement + 1
      # zuerst ändert sich der angezeigte Text, sodass die gerade zu codierenden Aussage markiert wird
      removeUI(selector = "#text_area_actor")
      insertUI(selector = "#actors_article", where = "beforeBegin",
               ui = tags$div(id = "text_area_statement",
                             uiOutput("article_actor_statement")))
      # Die Elemente zur Aussagenidentifikation werden ausgeblendet
      removeUI(selector = "#statement_identification")
      # Die Elemente für die Aussagencodierung werden eingeblendet
      insertUI(selector = "#coder_info", where = "afterEnd",
               ui = tags$div(id = "statement_inputs",
                             relevant_statement_input,
                             conditionalPanel(
                               condition = "input.irrelevant_statement == false",
                               statement_type_oberkat_input,
                               conditionalPanel(
                                 condition = "input.statement_type_oberkat == 1",
                                 valclaim_input
                                 ),
                               conditionalPanel(
                                 condition = "input.statement_type_oberkat == 2",
                                 obj_persp_input,
                                 conditionalPanel(
                                   condition = "input.obj_persp == 22",
                                   wellPanel(style = "background-color:#ffffff;",
                                             eval_subj_oberkat_input,
                                             conditionalPanel(
                                               condition = "input.eval_subj_oberkat == 2",
                                               eval_subj_actor_input,
                                               conditionalPanel(
                                                 condition = "input.eval_subj_actor == 21",
                                                 dir_int_eval_input
                                                 ),
                                               conditionalPanel(
                                                 condition = "input.eval_subj_actor == 22",
                                                 dir_int_other_eval_input
                                                 )
                                               ),
                                             eval_input
                                             )
                                   ),
                                 time_persp_input
                                 ),
                               conditionalPanel(
                                 condition = "input.statement_type_oberkat == 3",
                                 statement_type_actclaim_input,
                                 addressee_input,
                                 conditionalPanel(
                                   condition = "input.addressee == 1",
                                   dir_int_actclaim_input
                                   ),
                                 conditionalPanel(
                                   condition = "input.addressee == 2",
                                   dir_int_other_actclaim_input
                                   )
                                 ),
                               statement_leaning_input,
                               conditionalPanel(
                                 condition = "input.eval == 0",
                                 wellPanel(
                                   style = "background-color:#ffffff;",
                                   int_type_input
                               )),
                               conditionalPanel(
                                 condition = "input.statement_type_oberkat == 1 || input.statement_type_oberkat == 4 || input.statement_type_oberkat == 5 ||input.statement_type_oberkat == 99",
                                 wellPanel(
                                   style = "background-color:#ffffff;",
                                   p("Interaktionsfilter"),
                                   dir_int_identification_input,
                                   conditionalPanel(
                                     condition = "input.dir_int_identification == true",
                                     dir_int_filter_input,
                                     conditionalPanel(
                                       condition = "input.dir_int_filter == 11",
                                       dir_int_input
                                       ),
                                     conditionalPanel(
                                       condition = "input.dir_int_filter == 12",
                                       dir_int_other_input
                                       ),
                                     int_type_input
                                     )
                                   )
                                 )
                               ),
                             # Es werden drei Buttons eingefügt, mit denen man zurück zur letzten Aussage springen, die Aussage bestätigen oder zurück zur Akteur:innencodierung gelangen kann
                             hr(),
                             splitLayout(
                               cellWidths = c("40%", "60%"),
                               actionButton("back_to_actor", "Zum:zur Akteur:in", class = "btn-secondary btn-lg", width = "100%"),
                               actionButton("last_statement", "Letzte Aussage", class = "btn-secondary btn-lg", width = "100%")),
                             tags$div(style = "line-height: 0.5;",
                                      br(),
                                      actionButton("submit_statement_coding", "Weiter", class = "btn-info btn-lg", width = "100%")
                                      )
                             )
               )
      }
  })
  
  # Wenn irrelevant_statement = TRUE werden alle anderen Aussagencodierungen zurückgesetzt
  observeEvent(input$irrelevant_statement, {
    updateCheckboxInput(session = session, inputId = "actor_statement", value = FALSE)
    updateSelectInput(session = session, inputId = "statement_type_oberkat", selected = character(0))
    updateRadioButtons(session = session, inputId = "statement_type_actclaim", selected = character(0))
    updateRadioButtons(session = session, inputId = "valclaim", selected = character(0))
    updateRadioButtons(session = session, inputId = "obj_persp", selected = character(0))
    updateRadioButtons(session = session, inputId = "eval_subj_oberkat", selected = character(0))
    updateRadioButtons(session = session, inputId = "eval_subj_actor", selected = character(0))
    updateRadioButtons(session = session, inputId = "eval", selected = character(0))
    updateRadioButtons(session = session, inputId = "time_persp", selected = character(0))
    updateRadioButtons(session = session, inputId = "addressee", selected = character(0))
    updateRadioButtons(session = session, inputId = "statement_leaning", selected = character(0))
    updateCheckboxInput(session = session, inputId = "dir_int_identification", value = FALSE)
    updateRadioButtons(session = session, inputId = "dir_int_filter", selected = character(0))
    updateSelectInput(session = session, inputId = "dir_int_eval", selected = character(0))
    updateSelectInput(session = session, inputId = "dir_int_actclaim", selected = character(0))
    updateSelectInput(session = session, inputId = "dir_int", selected = character(0))
    updateTextInput(session = session, inputId = "dir_int_other", value = "")
    updateTextInput(session = session, inputId = "dir_int_other_eval", value = "")
    updateTextInput(session = session, inputId = "dir_int_other_actclaim", value = "")
    updateRadioButtons(session = session, inputId = "int_type", selected = character(0))
  })
  
  # Wenn die Codierung der Aussage über "submit_statement_coding" beendet wird, wird die Aussage und ihre Codierung gespeichert und es erscheint wieder die Oberfläche zur Aussagenidentifikation
  observeEvent(input$submit_statement_coding, {
    # Bevor die Aussage gespeichert wird, wird überprüft, ob alle benötigten Codierungen vorgenommen wurden
    if(("" %in% c(empty_inputs(input$statement_type_oberkat), empty_inputs(input$statement_leaning)) & !input$irrelevant_statement) |
       (empty_inputs(input$valclaim) == "" & input$statement_type_oberkat == 1) |
       ("" %in% c(empty_inputs(input$obj_persp), empty_inputs(input$time_persp)) & input$statement_type_oberkat == 2) |
       ("" %in% c(empty_inputs(input$eval_subj_oberkat), empty_inputs(input$eval)) & empty_inputs(input$obj_persp) == 22) |
       (empty_inputs(input$eval_subj_actor) == "" & empty_inputs(input$eval_subj_oberkat) == 2) |
       (input$dir_int_eval == "" & empty_inputs(input$eval_subj_actor) == 21) |
       (input$dir_int_other_eval == "" & empty_inputs(input$eval_subj_actor) == 22) |
       ("" %in% c(empty_inputs(input$statement_type_actclaim), empty_inputs(input$addressee)) & input$statement_type_oberkat == 3) |
       (input$dir_int_actclaim == "" & empty_inputs(input$addressee) == 1) |
       (input$dir_int_other_actclaim == "" & empty_inputs(input$addressee) == 2) |
       (empty_inputs(input$dir_int_filter) == "" & input$dir_int_identification) |
       (input$dir_int == "" & empty_inputs(input$dir_int_filter) == 11) |
       (input$dir_int_other == "" & empty_inputs(input$dir_int_filter) == 12) |
       (empty_inputs(input$int_type) == "" & input$dir_int_identification) |
       (empty_inputs(input$int_type) == "" & empty_inputs(input$eval) == 0)) {
      show_alert(title = "Fehler", text = "Bitte zuerst alle Felder ausfüllen, um mit der nächsten Aussage fortzufahren.", type = "error")
    }
    else {
      # Wenn bei der Codierung einer Aussage eine neue Interaktion identifiziert wurde, wird sie in den Interaktions-Hilfsdatensatz integriert und eine batch-ID erzeugt, mit der die Codierung des Inputs im Statement-Datensatz den extrahierten Interaktionspartner:innen zugeordnet werden kann
      if(nzchar(input$dir_int_other) ||
         nzchar(input$dir_int_other_eval) ||
         nzchar(input$dir_int_other_actclaim)) {
      # zunächst wird die Eingabe aus dem Freitextfeld identifiziert
        if(input$statement_type_oberkat == 2){
          raw_text <- input$dir_int_other_eval
        }
        else if(input$statement_type_oberkat == 3){
          raw_text <- input$dir_int_other_actclaim
        }
        else {
          raw_text <- input$dir_int_other
        }
        # anschließend wird geprüft, ob nur ein oder mehrere Namen nach der Codierregel mit "&"-Trennung in das Freitextfeld eingetragen wurden. Falls ja werden die Namen beim &-Zeichen getrennt und entsprechend als mehrere Interaktionen mit dem:der Ausgangsakteur:in verzeichnet.
        new_partners <- if(str_detect(raw_text, "&")) {
          str_split(raw_text, "\\s*&\\s*")[[1]]
        } 
        else {
          raw_text
        }
        # Informationen über den:die aktuell codierte:r Akteur:in werden mithilfe der "draw_actor"-Funktion aus dem Ursprungsdatensatz ermittelt
        current_actor_id <- draw_actor()[["entity_id"]]
        current_actor_name <- draw_actor()[["entity"]]
        current_document <- draw_actor()[["document_id"]]
        # gemeinsame batch_id, um gemeinsam eingegebene Partner dieser Eingabe zuzuordnen (zur Generierung der ID wird der Zeitpunkt der Eingabe verwendet). Diese wird in einem reactiveValue zwischengespeichert.
        batch_id <- paste0("batch_", as.integer(Sys.time()))
        rv$batch_id <- batch_id
        # Mit einer Hilfsfunktion wird sichergestellt, dass auch bei mehreren erfassten Namen (durch &-Zeichen getrennt) jede Zeile nur eine Interaktion enthält
        extract_one_on_one_interaction <- function(new_partner) {
          # nun wird geprüft, ob der eingegebene Name ggfs. schon als potenzielle:r Partner:in im Akteursdatensatz (z. B. aus einem anderen Artikel) oder Interaktionsdatensatz existiert. Wenn ja wird die entity_id des ersten Treffers als neue entity_id für den:die eingegebene Akteur:in genutzt
          existing <- actors_dataset() |> 
            filter(entity == new_partner) |> 
            select(entity_id) |> 
            slice_min(entity_id, n = 1) |> 
            pull()
          existing_partner <- interactions_dataset() |> 
            filter(entity_2 == new_partner) |> 
            select(entity_id_2) |> 
            slice_min(entity_id_2, n = 1) |> 
            pull()
          if (length(existing) > 0) {
            new_id <- existing
          }
          else if (length(existing_partner) > 0) {
            new_id <- existing_partner
          }
          else {
            # Wenn der Name noch nicht im Datensatz vorkommt, wird eine neue ID erzeugt (größte bisher im Artikel vergebene ID + Position im Vektor; stellt sicher, dass auch bei mehreren Akteur:innen in einer Eingabe verschiedene IDs vergeben werden)
            max_id <- interactions_dataset() |> 
              filter(document_id == current_document) |> 
              pull(entity_id_2) |> 
              max(na.rm = TRUE)
            # Falls keine Interaktionen im Datensatz enthalten sind, beginnt die Zählung bei document_id + 00001
            if(is.infinite(max_id)){
              max_id <- as.numeric(paste0(current_document, "00001"))
            }
            new_id <- max_id + match(new_partner, new_partners)
          }
          # Neue Interaktions-ID generieren
          new_int_id <- paste0(current_actor_id, "_", new_id)
          # Neue Zeile wird im Interaktions-Speicher (reactiveVal) angelegt
          new_row <- tibble(
            entity_id = current_actor_id,
            entity = current_actor_name,
            entity_id_2 = new_id,
            entity_2 = new_partner,
            document_id = current_document,
            int_id = new_int_id,
            batch_id = batch_id,
            coded = TRUE
          )
        }
        new_rows <- map_dfr(new_partners, extract_one_on_one_interaction)
        # nun wird geprüft, ob eine neu erfasste Paarung bereits innerhalb des Artikels erfasst wurde (z. B., wenn ein:e Akteur:in in mehreren Aussagen den:dieselbe andere:n Akteur:in anspricht)
        existing_interactions <- interactions_dataset() |> 
          pull(int_id)
        new_rows <- new_rows |> 
          filter(!int_id %in% existing_interactions)
        # Wenn danach noch neue Paarungen übrig bleiben, werden diese als neue Zeile(n) an den Datensatz angehängt
        if (nrow(new_rows) > 0){
          new_direct_interactions(bind_rows(new_direct_interactions(), new_rows))
          # Es wird eine kurze Benachrichtigung angezeigt, dass neue Interaktionen für den:die Akteur:in gespeichert wurden
          showNotification(
            sprintf("%s neue Interaktion(en) für %s gespeichert.", nrow(new_rows), current_actor_name),
            type = "message",
            duration = 3
          )
        }
        else {
          showNotification(
            sprintf("Keine neue Interaktion für %s erfasst - Duplikate verworfen.", current_actor_name),
            type = "message",
            duration = 3
          )
        }
      } 
      else {
        rv$batch_id <- NA_character_
      }
      # die Batch-ID wird auch in den Codebogen für die Aussagencodierung geschrieben, damit anhand dieser die darin enthaltene Codierung der direkten Interaktion(en) zugeordnet werden kann
      statement_inputs <- codebogen_statements()
      statement_inputs[["dir_int_batch"]] <- rv$batch_id
      # Nach vollständiger Eingabe wird die Aussage im statements-Datensatz mit der save_statements-Funktion gespeichert
      withProgress(message = "Aussagencodierung wird gespeichert", value = 0.5, 
                   {save_statements(draw_statement(), codebogen_statements(), statements())
                     incProgress(amount = 0.5)})
    # Die Elemente zur Aussagencodierung werden entfernt
    removeUI(selector = "#statement_inputs")
    # Der Text wird auf die Standardanzeige zurückgesetzt
    removeUI(selector = "#text_area_statement")
    insertUI(selector = "#actors_article", where = "beforeBegin",
             ui = tags$div(id = "text_area_actor",
                        uiOutput("article_actor")))
    # Element zur Aussagenidentifikation wird wieder eingeblendet
    insertUI(selector = "#coder_info", where = "afterEnd",
             ui = tags$div(id = "statement_identification",
                           statement_input,
                           actionButton("submit_statement", "Ok", class = "btn-info btn-lg", width = "40%"),
                           br(),
                           tags$div(style = "line-height: 0.5;",
                                    br(),
                                    splitLayout(
                                      cellWidths = c("40%", "60%"),
                                      actionButton("last_statement", "Letzte Aussage", class = "btn-secondary btn-lg", width = "100%"),
                                      actionButton("back_to_actor", "Zum:zur Akteur:in", class = "btn-secondary btn-lg", width = "100%"))),
                           hr(),
                           actionButton("end_statement_coding", "Keine weiteren Aussagen", class = "btn-danger btn-lg", width = "100%")))
    }
  })
  
  # Codierung auf Interaktionsebene
  observeEvent(input$end_statement_coding, {
    # der Text, in dem nur der:die Ausgangsakteur:in markiert ist, wird entfernt
    removeUI(selector = "#text_area_actor")
    # die Elemente zur Aussagenidentifikation werden ausgeblendet
    removeUI(selector = "#statement_identification")
    # nun wird überprüft, ob für den:die Akteur:in Interaktionen erfasst wurden, die noch nicht im Zuge der Aussagencodierung als direkte Interaktionen codiert wurden
    if(nrow(interactions_dataset() |> filter(coded == FALSE)) > 0 & draw_actor()[["entity_id"]] %in% interactions_dataset()[["entity_id"]] == TRUE){
      # ist das der Fall, wird eine Variante des Texts, in dem sowohl der:die Ausgangsakteur:in als auch der:die potenzielle Interaktionspartner:in markiert ist, angezeigt
    insertUI(selector = "#actors_article", where = "beforeBegin",
             ui = tags$div(id = "text_area_actor_interaction",
                        uiOutput("article_interaction")))
    # die zu codierende Interaktion wird angezeigt
    insertUI(selector = "#coder_info", where = "afterEnd",
             ui = tags$div(id = "interaction_inputs",
                           wellPanel(style = "border-color:#32cd32; background-color:#ffffff;",
                                     tags$div(id = "interaction_coding_area",
                                              uiOutput("interaction"))),
                           false_int_input,
                           conditionalPanel(
                             condition = "input.false_int == false",
                             int_type_input
                             ),
                           # es werden drei Buttons hinzugefügt, mit denen zur Akteursebene oder zur letzten Interaktion zurückgekehrt werden sowie die Codierung bestätigt werden kann
                           hr(),
                           splitLayout(
                             cellWidths = c("40%", "60%"),
                             actionButton("back_to_actor", "Zum:zur Akteur:in", class = "btn-secondary btn-lg", width = "100%"),
                             actionButton("last_interaction", "Letzte Interaktion", class = "btn-secondary btn-lg", width = "100%")),
                           if(length(interaction_ids_by_actor()) == 1){
                             tags$div(id = "end_interaction_coding",
                                      style = "line-height: 0.5;",
                                      br(),
                                      actionButton("submit_interaction", "Nächste:r Akteur:in", class = "btn-danger btn-lg", width = "100%"))
                           } else {
                             tags$div(id = "change_interaction",
                                      style = "line-height: 0.5;",
                                      br(),
                                      actionButton("submit_interaction", "Weiter", class = "btn-info btn-lg", width = "100%")
                                    )
                           }
                           )
             )
    # Der Interaktions-Index wird um 1 erhöht, um die Interaktionscodierung zu beginnen
    interaction_ids <- interaction_ids_by_actor()
    if(rv$index_interaction == 0){
      rv$index_interaction <- rv$index_interaction + 1
      }
    else {
      rv$index_interaction <- rv$index_interaction
      }
    }
    # Sind für den:die Akteur:in keine weiteren Interaktionen erfasst, so wird die Interaktionscodierung übersprungen und direkt in die nächste Akteurscodierung übergeleitet
    else {
      # Eine reduzierte Variante der save_interactions-Funktion wird aufgerufen, um ggfs. neu identifzierte direkte Interaktionen mit passiven Akteur:innen im Datensatz zu speichern
      save_new_direct_interactions(interactions_dataset(), new_direct_interactions())
      # Die save_complete_coding-Funktion wird aufgerufen, um den:die Akteur:in als vollständig codiert zu markieren
      save_complete_coding(draw_actor())
      # Die Elemente zur Akteurscodierung werden wieder eingeblendet
      insertUI(selector = "#actors_article", where = "beforeBegin",
               ui = tags$div(id = "text_area_actor",
                             uiOutput("article_actor")))
      insertUI(selector = "#coder_info", where = "afterEnd",
               ui = tags$div(id = "actor_inputs",
                             # der:die zu codierende Akteur:in wird über dem Codierbereich angezeigt
                             wellPanel(style = "border-color:#32cd32; background-color:#ffffff;",
                                       tags$div(id = "actor_to_code",
                                                uiOutput("actor"))),
                             opt_out_relevance_input,
                             br(),
                             # Codierelemente werden ausgeblendet, wenn Irrläufer erkannt wird
                             conditionalPanel(
                               condition = "input.opt_out_relevant == false",
                               affiliation_input,
                               gender_input,
                               socarea_oberkat_input,
                               # je nach gewählter Oberkategorie werden die Unterkategorien als Auswahlmöglichkeiten angezeigt
                               conditionalPanel(
                                 condition = "input.socarea_oberkat == 100",
                                 socarea_wiss_input),
                               conditionalPanel(
                                 condition = "input.socarea_oberkat == 200",
                                 socarea_pol_input),
                               conditionalPanel(
                                 condition = "input.socarea_oberkat == 300",
                                 socarea_iv_input,
                                 conditionalPanel(
                                   condition = "input.socarea_iv == 310",
                                   socarea_ivzo_input),
                                 conditionalPanel(
                                   condition = "input.socarea_iv == 320",
                                   socarea_ivko_input)
                               ),
                               conditionalPanel(
                                 condition = "input.socarea_oberkat == 400",
                                 socarea_sonst_input),
                               actlocal_input,
                               relevant_quote_input
                             ),
                             # abhängig von der Codierung in "relevant_quote" werden zwei Buttons eingefügt:
                             # Liegt keine inhaltlich relevante Aussage vor (relevant_quote = FALSE), kann über die Buttons entweder zum:zur letzten Akteur:in zurückgekehrt werden oder der:die aktuelle Akteur:in abgespeichert und die Codierung beendet werden.
                             conditionalPanel(
                               style = "background-color:#ffffff; border-color:#ffffff;",
                               condition = "input.relevant_quote == false",
                               hr(),
                               splitLayout(
                                 cellWidths = c("30%", "70%"),
                                 actionButton("last_actor", "Zurück", class = "btn-secondary btn-lg", width = "100%"),
                                 actionButton("end_coding", "Codierung beenden", class = "btn-danger btn-lg", width = "100%"))
                             ),
                             # Liegt min. 1 relevante Aussage vor (relevant_quote = TRUE), kann mit den Buttons entweder zum:zur letzten Akteur:in zurück navigiert werden oder der:die aktuelle Akteur:in abgespeichert und zur Aussagenidentifikation übergegangen werden.
                             conditionalPanel(
                               style = "background-color:#ffffff; border-color:#ffffff;",
                               condition = "input.relevant_quote == true",
                               hr(),
                               splitLayout(
                                 cellWidths = c("30%", "70%"),
                                 actionButton("last_actor", "Zurück", class = "btn-secondary btn-lg", width = "100%"),
                                 actionButton("submit_actor", "Zur Aussagenidentifikation", class = "btn-info btn-lg", width = "100%"))
                             ),
               )
      )
      if(length(ids) == rv$index_actor){
        # ist das nicht der Fall, wird eine Fehlermeldung angezeigt -> die Codierung ist dann vollständig abgeschlossen
        show_alert(title = "Codierung vollständig",
                   text = "Alle Akteur:innen in diesem Datensatz wurden codiert.\nDie App kann nun geschlossen werden.")
      }
      # befinden sich noch uncodierte Akteur:innen im Datensatz wird der Akteursindex erhöht 
      else {
        rv$index_actor <- rv$index_actor + 1
      }
    }
  })
  
  # Immer wenn eine Interaktion fertig codiert wurde ("submit_interaction"), wird der Interaktions-Index um 1 erhöht, wodurch eine neue Interaktion aus dem Hilfsdatensatz gezogen werden kann
  observeEvent(input$submit_interaction, {
    # zunächst wird überprüft, ob alle notwendigen Eingaben gemacht wurden
    if(("" %in% empty_inputs(input$int_type) & !input$false_int)){
      show_alert(title = "Fehler", text = "Bitte zuerst alle Felder ausfüllen, um mit der nächsten Interaktion fortzufahren.", type = "error")
    }
    else {
      # Nach vollständiger Eingabe wird die codierte Interaktion im interactions-Datensatz mit der save_interactions-Funktion gespeichert
      withProgress(message = "Interaktionscodierung wird gespeichert", value = 0.5, 
                   {save_interactions(draw_interaction(), codebogen_interactions(), interactions_dataset(), new_direct_interactions())
                     incProgress(amount = 0.5)})
    # dann wird der Index erhöht
      interaction_ids <- interaction_ids_by_actor()
      rv$index_interaction <- rv$index_interaction + 1
      # bei der letzten Interaktion wird das Aussehen des "submit_interaction"-Buttons verändert, um zu signalisieren, dass die nächste Codierung wieder auf Akteursebene beginnt
      if(length(interaction_ids_by_actor()) == rv$index_interaction){
        removeUI(selector = "#change_interaction")
        insertUI(selector = "#interaction_inputs", where = "afterEnd",
                 ui = tags$div(id = "end_interaction_coding",
                               style = "line-height: 0.5;",
                               br(),
                               actionButton("submit_interaction", "Nächste:r Akteur:in", class = "btn-danger btn-lg", width = "100%")))
      }
      # ist keine weitere Interaktion mehr im Hilfsdatensatz vorhanden, wird der Akteurs-Index um 1 erhöht und wieder die Codier-Elemente für die Akteurscodierung eingeblendet
      if(length(interaction_ids_by_actor()) < rv$index_interaction){
        # Die save_complete_coding-Funktion wird aufgerufen, um den:die aktuelle:n Akteur:in als vollständig codiert zu markieren
        save_complete_coding(draw_actor())
        # Der Interaktionsindex wird auf 1 zurückgesetzt
        rv$index_interaction <- 1
        # Die Elemente für die Interaktions-Codierung werden ausgeblendet und die Textvariante, in der der:die nächste Akteur:in markiert ist, wird eingeblendet
        removeUI(selector = "#text_area_actor_interaction")
        insertUI(selector = "#actors_article", where = "beforeBegin",
                 ui = tags$div(id = "text_area_actor",
                               uiOutput("article_actor")))
        removeUI(selector = "#interaction_inputs")
        removeUI(selector = "#end_interaction_coding")
        # Codier-Elemente auf der Akteursebene einfügen
        insertUI(selector = "#coder_info", where = "afterEnd",
                 ui = tags$div(id = "actor_inputs",
                               wellPanel(style = "border-color:#32cd32; background-color:#ffffff;",
                                         tags$div(id = "actor_to_code",
                                                  uiOutput("actor"))),
                               opt_out_relevance_input,
                               br(),
                               # Codierelemente werden ausgeblendet, wenn Irrläufer erkannt wird
                               conditionalPanel(
                                 condition = "input.opt_out_relevant == false",
                                 affiliation_input,
                                 gender_input,
                                 socarea_oberkat_input,
                                 # je nach gewählter Oberkategorie werden die Unterkategorien als Auswahlmöglichkeiten angezeigt
                                 conditionalPanel(
                                   condition = "input.socarea_oberkat == 100",
                                   socarea_wiss_input),
                                 conditionalPanel(
                                   condition = "input.socarea_oberkat == 200",
                                   socarea_pol_input),
                                 conditionalPanel(
                                   condition = "input.socarea_oberkat == 300",
                                   socarea_iv_input,
                                   conditionalPanel(
                                     condition = "input.socarea_iv == 310",
                                     socarea_ivzo_input),
                                   conditionalPanel(
                                     condition = "input.socarea_iv == 320",
                                     socarea_ivko_input)
                                   ),
                                 conditionalPanel(
                                   condition = "input.socarea_oberkat == 400",
                                   socarea_sonst_input),
                                 actlocal_input,
                                 relevant_quote_input
                                 ),
                               # abhängig von der Codierung in "relevant_quote" werden zwei Buttons eingefügt:
                               # Liegt keine inhaltlich relevante Aussage vor (relevant_quote = FALSE), kann über die Buttons entweder zum:zur letzten Akteur:in zurückgekehrt werden oder der:die aktuelle Akteur:in abgespeichert und die Codierung beendet werden.
                               conditionalPanel(
                                 style = "background-color:#ffffff; border-color:#ffffff;",
                                 condition = "input.relevant_quote == false",
                                 hr(),
                                 splitLayout(
                                   cellWidths = c("30%", "70%"),
                                   actionButton("last_actor", "Zurück", class = "btn-secondary btn-lg", width = "100%"),
                                   actionButton("end_coding", "Codierung beenden", class = "btn-danger btn-lg", width = "100%"))
                                 ),
                               # Liegt min. 1 relevante Aussage vor (relevant_quote = TRUE), kann mit den Buttons entweder zum:zur letzten Akteur:in zurück navigiert werden oder der:die aktuelle Akteur:in abgespeichert und zur Aussagenidentifikation übergegangen werden.
                               conditionalPanel(
                                 style = "background-color:#ffffff; border-color:#ffffff;",
                                 condition = "input.relevant_quote == true",
                                 hr(),
                                 splitLayout(
                                   cellWidths = c("30%", "70%"),
                                   actionButton("last_actor", "Zurück", class = "btn-secondary btn-lg", width = "100%"),
                                   actionButton("submit_actor", "Zur Aussagenidentifikation", class = "btn-info btn-lg", width = "100%"))
                                 ),
                               )
                 )
        if(length(ids) == rv$index_actor){
          # ist das nicht der Fall, wird eine Fehlermeldung angezeigt -> die Codierung ist dann vollständig abgeschlossen
          show_alert(title = "Codierung vollständig",
                     text = "Alle Akteur:innen in diesem Datensatz wurden codiert.\nDie App kann nun geschlossen werden.")
        }
        # befinden sich noch uncodierte Akteur:innen im Datensatz wird der Akteursindex erhöht 
        else {
          rv$index_actor <- rv$index_actor + 1
        }
      }
    }
  })
  
  # Die Eingaben für die unterschiedlichen Ebenen werden in Reactive-Expressions zwischengespeichert
  
  ## Akteurseigenschaften
  codebogen_actors <- reactive({
    rv$index_actor
    coded_data <- sapply(actor_variables, function(x){
      if(x == "affiliation"){
        input[[x]]
      }
      else if(x %in% c("opt_out_relevant", "relevant_quote")) {
        as.logical(input[[x]])
      }
      else{
        as.numeric(input[[x]])
      }
    })
    coded_data
  })
  
  ## Aussagen
  codebogen_statements <- reactive({
    rv$index_statement
    coded_data <- sapply(statement_variables, function(x){
      if(x %in% c("irrelevant_statement", "actor_statement")){
        as.logical(input[[x]])
      }
      else if (x == "dir_int_batch") {
        if(is.null(rv$batch_id)) {
          NA_character_
        }
        else {
          rv$batch_id
        }
      }
      else if (x %in% c("dir_int_eval", "dir_int_actclaim", "dir_int", "dir_int_other_eval", "dir_int_other_actclaim", "dir_int_other")){
        input[[x]]
      }
      else if (x == "int_type") {
        if(is.null(input[[x]])) {
          NA_integer_
        }
        else {
          as.numeric(input[[x]])
        }
      }
      else {
        as.numeric(input[[x]])
      }
    }, simplify = FALSE)
    coded_data
  })
  
  ## Interaktionen
  codebogen_interactions <- reactive({
    rv$index_interaction
    coded_data <- sapply(interaction_variables, function(x){
      if(x == "false_int"){
        as.logical(input[[x]])
      }
      else {
        as.numeric(input[[x]])
      }
    }, simplify = FALSE)
    coded_data
  })
  
  # Durch die Veränderung des Index, wird basierend auf der ID ein:e neue:r Akteur:in aus dem Datensatz gezogen
  draw_actor <- eventReactive(
    {rv$index_actor},
    {validate(need(length(ids) > 0, message = FALSE))
      actor <- full_dataset[full_dataset$entity_id == ids[rv$index_actor],]
      actor$sentences <- str_split(actor$sentences_joined, "<->")
      # Wenn der:die Akteur:in bereits codiert wurde, werden die Werte auf die bereits eingegebenen Werte gesetzt, ansonsten werden sie zurückgesetzt
      if(actor$coded){
        set_to_last_actor_value(session = session, ids = ids, index = rv$index_actor)
      }
      else{
        reset_inputs(session = session)
      }
      actor}
  )
  
  # Anzeige des:der zu codierenden Akteur:in
  output$actor <- renderUI({
    req(draw_actor())
    entity_id <- draw_actor()[["entity_id"]]
    entity <- draw_actor()[["entity"]]
    tags$div(id = "actor_info",
             p("Zu codierende:r Akteur:in:"),
             p(HTML(mark_actor_names(entity))))
  })
  
  # Angezeigter Text, abhängig vom:von der zu codierenden Akteur:in
  output$article_actor <- renderUI({
    req(draw_actor())
    sentence_id <- draw_actor()[["sentence_id"]]
    sentences <- draw_actor()[["sentences"]][[1]]
    entity_name <- draw_actor()[["entity"]]
    surname <- str_match(entity_name, "[^\\s]*\\s([\\s\\S]*)")[,2]
    entity_name_surname <- ifelse(is.na(surname), entity_name, paste(entity_name, surname, sep = "|"))
    tags$div(id = "actor_text",
             h4("Artikel ", draw_actor()[["document_id"]], ": ", str_match(draw_actor()[["article_title"]], "([^;\\n]*)[\\s\\S]*")[,2]),
             h5("Quelle: ", draw_actor()[["article_source"]]),
             h5("Veröffentlichungsdatum: ", draw_actor()[["article_pubdate"]]),
             h5("Autor:in: ", draw_actor()[["article_byline"]]),
             br(),
             HTML(c("<p>", str_replace_all(paste0(sentences, collapse = "</p><p>"), entity_name_surname, mark_actor_names), "</p>")))
  })
  
  # Akteurstabelle, die sämtliche codierte Akteur:innen im Artikel anzeigt
  output$actors_table <- renderTable({
    draw_actor()
    validate(need(all(c("entity_id", "entity", "affiliation", "gender", "socarea") %in% names(full_dataset)), message = FALSE))
    actors_table <- full_dataset[(full_dataset$document_id == draw_actor()[["document_id"]]) & full_dataset$coded, c("entity_id", "entity", "affiliation", "gender", "socarea")]
    actors_table
  })
  
  # Wenn die Identifikation einer Aussage mit "submit_statement" bestätigt wird, wird die Aussage als neue Zeile in den statements-Speicher aufgenommen
  observeEvent(input$submit_statement, {
    req(draw_actor())
    # zunächst wird die Eingabe aus dem Freitextfeld identifiziert
    new_statement <- input$statement
    if (!nzchar(new_statement)) return()
    # Informationen über den:die aktuell codierte:r Akteur:in werden mithilfe der "draw_actor"-Funktion aus dem Ursprungsdatensatz ermittelt
    current_actor_id <- draw_actor()[["entity_id"]]
    current_actor_name <- draw_actor()[["entity"]]
    current_document <- draw_actor()[["document_id"]]
    # Für jede identifizierte Aussage wird eine neue "statement_id" aus der ID des:der Akteur:in und der Nummer der identifizierten Aussage erzeugt
    max_id <- statements() |> 
      group_by(entity_id) |> 
      summarise(max_id = max(statement_id, na.rm = TRUE)) |> 
      ungroup() |> 
      filter(entity_id == current_actor_id) |> 
      pull(max_id)
    # Falls noch keine Aussage identifiziert wurde, wird die max_id auf 0 festgesetzt, sodass die erste identifizierte Aussage mit einer ID, die mit 1 endet, erfasst wird
    if(length(max_id) == 0){
      max_id <- as.numeric(paste0(current_actor_id, 0))
    } else {
      max_id <- max_id
    }
    new_id <- max_id + 1
    # Die neue Zeile im Aussagen-Speicher wird angelegt
    new_row <- tibble(
      entity_id = current_actor_id,
      entity = current_actor_name,
      document_id = current_document,
      statement_id = new_id,
      statement = new_statement,
      coded = FALSE
    )
    statements(bind_rows(statements(), new_row))
    # Es wird eine kurze Benachrichtigung angezeigt, dass eine neue Aussage für den:die Akteur:in gespeichert wurden
    showNotification(
      sprintf("Neue Aussage für %s gespeichert.", current_actor_name),
      type = "message",
      duration = 3
      )
  })
  
  # Funktion, mit der zu codierende Aussagen des:der zu codierenden Akteur:in aus dem Hilfsdatensatz gezogen werden
  draw_statement <- eventReactive(
    {rv$index_statement},
    {validate(need(length(statement_ids_by_actor()) > 0, message = FALSE))
      statement_ids <- statement_ids_by_actor()
      statement <- statements()
      statement <- statement[statement$statement_id == statement_ids[rv$index_statement],]
      # Wenn die Aussage bereits codiert wurde, werden die Werte auf die default-Werte zurückgesetzt
      reset_inputs(session = session)
      statement}
  )
  
  # Der ausgegebene Artikeltext wird angepasst, um die aktuell zu codierende Aussage zu markieren
  output$article_actor_statement <- renderUI({
    req(draw_actor(), draw_statement())
    sentence_id <- draw_actor()[["sentence_id"]]
    sentences_joined <- draw_actor()[["sentences_joined"]]
    entity_name <- draw_actor()[["entity"]]
    surname <- str_match(entity_name, "[^\\s]*\\s([\\s\\S]*)")[,2]
    entity_name_surname <- ifelse(is.na(surname), entity_name, paste(entity_name, surname, sep = "|"))
    statement <- draw_statement()[["statement"]]
    # im kopierten Statement werden alle mehrfachen Leerzeichen oder Zeilenumbrüche (inkl. Tabstopps) in das Trennungszeichen <->, das auch in sentences_joined verwendet wird, umgewandelt
    statement_clean <- str_replace_all(statement, "(?: {2,}|[\\t\\r\\n]+)", "<->")
    # Das gefundene Statement wird mit einem Platzhalter markiert
    marked_text <- str_replace_all(str_replace_all(sentences_joined, statement_clean, "<STATEMENT>"), entity_name_surname, mark_actor_names)
    # Der Text wird am Trennungszeichen <-> in einzelne Paragraphen/Sätze aufgesplittet (für eine übersichtlichere Anzeige)
    paragraphs <- str_split(marked_text, "<->", simplify = FALSE)[[1]]
    # Es wird ein flexibles Muster für jedes Leerzeichen festgelt, das sowohl Leerzeichen als auch Platzhalter <-> aktzeptiert 
    statement_pattern <- str_replace_all(statement, "\\s+", "(?:\\\\s+|<->)")
    # nur wird das Statement absatzbezogen markiert
    paragraphs <- lapply(paragraphs, function(p){
      # Wenn ein Statement in einem Absatz liegt, wird die Standardfunktion aufgerufen und der Platzhalter im markierten Text dadurch ersetzt
      p <- str_replace_all(p,
                           fixed("<STATEMENT>"),
                           mark_statements(statement))
      # Wenn ein Statement auf mehrere Absätze verteilt ist, wird das zuvor festgelegte flexible Muster verwendet, um den Statement-Platzhalter im markierten Text zu ersetzen
      p <- str_replace_all(p,
                           regex(statement_pattern, dotall = TRUE),
                           mark_statements(statement))
      p
    })
    # In der Anzeige werden Statements, auch wenn sie ursprünglich auf mehrere Sätze/Absätze verteilt sind, für die Dauer der Codierung zusammengezogen und markiert
    tags$div(id = "actor_text",
             h4("Artikel ", draw_actor()[["document_id"]], ": ", str_match(draw_actor()[["article_title"]], "([^;\\n]*)[\\s\\S]*")[,2]),
             h5("Quelle: ", draw_actor()[["article_source"]]),
             h5("Veröffentlichungsdatum: ", draw_actor()[["article_pubdate"]]),
             h5("Autor:in: ", draw_actor()[["article_byline"]]),
             br(),
             HTML(c("<p>", paste0(paragraphs, collapse = "</p><p>"), "</p>")))
  })
  
  # Hilfsdatensatz für Interaktionen
  interactions_dataset <- reactive({
    req(actors_dataset(), draw_actor())
    actors <- actors_dataset()
    interactions <- actors |> 
      select(entity_id, entity, document_id) |> 
      # Name wird beibehalten
      nest(data = entity) |> 
      group_by(document_id) |> 
      # eine Liste aller Namen pro Artikel wird erzeugt
      mutate(entity_id_2 = list(entity_id)) |> 
      unnest(entity_id_2) |> 
      # Selbstpaarungen werden entfernt
      filter(entity_id != entity_id_2) |> 
      left_join(actors |> 
                  select(entity_id, entity, document_id) |> 
                  nest(data = entity) |>
                  group_by(document_id) |>
                  mutate(entity_id_2 = list(entity_id)) |> 
                  unnest(entity_id_2) |> 
                  filter(entity_id != entity_id_2) |> 
                  select(entity_id, data_2 = data) |> 
                  distinct() |> 
                  ungroup(), by = c("entity_id_2" = "entity_id", "document_id")) |>
      unnest(c(data, data_2), names_sep = "_") |> 
      rename(entity = data_entity,
             entity_2 = data_2_entity) |> 
      mutate(int_id = paste0(entity_id, "_", entity_id_2),
             coded = FALSE,
             batch_id = NA_character_) |> 
      filter(entity_id == draw_actor()[["entity_id"]],
             entity_id_2 > draw_actor()[["entity_id"]])
    # hier werden die während des Codierens zusätzlich identifizierten Interaktionen an den Ausgangsdatensatz angehängt, zeitgleich werden Interaktionen, die bereits im Zuge der Aussagencodierung codiert wurden, markiert
    mark_direct_interactions(bind_rows(interactions, new_direct_interactions()))
  })
  
  # Hilfsdatensatz für Auswahllisten direkter Interaktionen mit aktiven Akteur:innen
  direct_interactions_dataset <- reactive({
    req(actors_dataset(), draw_actor())
    actors <- actors_dataset()
    interactions <- actors |> 
      select(entity_id, entity, document_id) |> 
      # Name wird beibehalten
      nest(data = entity) |> 
      group_by(document_id) |> 
      # eine Liste aller Namen pro Artikel wird erzeugt
      mutate(entity_id_2 = list(entity_id)) |> 
      unnest(entity_id_2) |> 
      # Selbstpaarungen werden entfernt
      filter(entity_id != entity_id_2) |> 
      left_join(actors |> 
                  select(entity_id, entity, document_id) |> 
                  nest(data = entity) |>
                  group_by(document_id) |>
                  mutate(entity_id_2 = list(entity_id)) |> 
                  unnest(entity_id_2) |> 
                  filter(entity_id != entity_id_2) |> 
                  select(entity_id, data_2 = data) |> 
                  distinct() |> 
                  ungroup(), by = c("entity_id_2" = "entity_id", "document_id")) |>
      unnest(c(data, data_2), names_sep = "_") |> 
      rename(entity = data_entity,
             entity_2 = data_2_entity) |> 
      mutate(int_id = paste0(entity_id, "_", entity_id_2)) |> 
      # es wird nur nach dem:der aktuell codierten Akteur:in gefiltert
      filter(entity_id == draw_actor()[["entity_id"]])
    # hier werden die während des Codierens zusätzlich identifizierten Interaktionen an den Ausgangsdatensatz angehängt
    bind_rows(interactions, new_direct_interactions())
  })
  
  # Auswahlliste für "dir_int": 
  # Hierfür werden zunächst ausgehend von der ID des:der aktuell codierten Akteur:in sämtliche weiteren aktiven Akteur:innen im Artikel ermittelt
  potential_partners <- reactive({
    req(direct_interactions_dataset(), draw_actor())
    current_entity <- draw_actor()[["entity_id"]]
    partners <- direct_interactions_dataset() |> 
      filter(entity_id == current_entity) |> 
      mutate(partner = entity_2) |> 
      pull(partner) |> 
      unique() |> 
      sort() |> 
      as.character()
    ids <- direct_interactions_dataset()$int_id[match(partners, direct_interactions_dataset()$entity_2)]
    setNames(ids, partners)
  })
  
  # mit einer Hilfsfunktion werden die Bedingungen für die ConditionalPanels in ein reactiveValue geschrieben
  is_equal <- function (variable, target_value){
    !is.null(variable) && !is.na(variable) && variable == target_value
  }
  dir_int_visible <- reactive({
    is_equal(input$eval_subj_actor, 21) || 
      is_equal(input$addressee, 1) || 
      is_equal(input$dir_int_filter, 11)
  })
  # anschließend werden die Auswahlmenüs in den ConditionalPanels entsprechend angepasst
  observe({
    req(dir_int_visible())
    partners <- potential_partners()
    choices_dir_int <- c("Nichts ausgewählt" = "",
                         partners)
    updateSelectInput(session = session, inputId = "dir_int_eval",
                      choices = choices_dir_int,
                      selected = "")
    updateSelectInput(session = session, inputId = "dir_int_actclaim",
                      choices = choices_dir_int,
                      selected = "")
    updateSelectInput(session = session, inputId = "dir_int",
                      choices = choices_dir_int,
                      selected = "")
  })
  
  # Funktion, mit der zu codierende Interaktionen des:der zu codierenden Akteur:in aus dem Hilfsdatensatz gezogen werden
  draw_interaction <- eventReactive(
    {rv$index_interaction},
    {validate(need(length(interaction_ids_by_actor()) > 0, message = FALSE))
      interaction_ids <- interaction_ids_by_actor()
      interaction <- interactions_dataset()
      interaction <- interaction[interaction$int_id == interaction_ids[rv$index_interaction],]
      # Wenn die Interaktion bereits codiert wurde, werden die Werte auf die default-Werte zurückgesetzt
      reset_inputs(session = session)
      interaction}
  )
  
  # Angezeigte Interaktion, abhängig vom:von der zu codierenden Akteur:in
  output$interaction <- renderUI({
    req(draw_interaction())
    interaction_id <- draw_interaction()[["int_id"]]
    entity_1 <- draw_interaction()[["entity"]]
    entity_2 <- draw_interaction()[["entity_2"]]
    tags$div(id = "interaction_info",
             p("Zu codierende Interaktion:"),
             p(entity_1, " und ", entity_2))
  })
  
  # Markierung des:der Interaktionspartner:in im Artikeltext
  output$article_interaction <- renderUI({
    req(draw_actor(), draw_interaction())
    sentence_id <- draw_actor()[["sentence_id"]]
    sentences <- draw_actor()[["sentences"]][[1]]
    entity_name <- draw_actor()[["entity"]]
    surname <- str_match(entity_name, "[^\\s]*\\s([\\s\\S]*)")[,2]
    entity_name_surname <- ifelse(is.na(surname), entity_name, paste(entity_name, surname, sep = "|"))
    partner_name <- draw_interaction()[["entity_2"]]
    partner_surname <- str_match(partner_name, "[^\\s]*\\s([\\s\\S]*)")[,2]
    partner_name_surname <- ifelse(is.na(partner_surname), partner_name, paste(partner_name, partner_surname, sep = "|"))
    tags$div(id = "actor_text",
             h4("Artikel ", draw_actor()[["document_id"]], ": ", str_match(draw_actor()[["article_title"]], "([^;\\n]*)[\\s\\S]*")[,2]),
             h5("Quelle: ", draw_actor()[["article_source"]]),
             h5("Veröffentlichungsdatum: ", draw_actor()[["article_pubdate"]]),
             h5("Autor:in: ", draw_actor()[["article_byline"]]),
             br(),
             HTML(c("<p>", str_replace_all(paste0(sentences, collapse = "</p><p>"), entity_name_surname, mark_actor_names) |> 
                      str_replace_all(partner_name_surname, mark_partner_names), "</p>")))
  })
  
  # Zurück-Knöpfe
  
  ## Zurück zum:zur letzten Akteur:in (Akteurscodierung)
  observeEvent(input$last_actor, {
    if(rv$index_actor > 1){
      # der Akteursindex wird um 1 verringert
      rv$index_actor <- rv$index_actor - 1
    }
    else {
      # Wenn bereits der:die erste Akteur:in angezeigt wird, erscheint eine Fehlermeldung
      show_alert(title = "Fehler",
                 text = "Es handelt sich bereits um den:die erste Akteur:in in dieser Session.",
                 type = "error")
    }
  })
  
  ## Zurück zur letzten Aussage (Aussagencodierung)
  observeEvent(input$last_statement, {
    if(rv$index_statement > 1){
      # der Aussagenindex wird um 1 verringert
      rv$index_statement <- rv$index_statement - 1
    }
    else {
      # Wenn bereits die erste Aussage eines:einer Akteur:in angezeigt wird, erscheint eine Fehlermeldung
      show_alert(title = "Fehler",
                 text = "Es handelt sich bereits um die erste Aussage des:der Akteur:in.",
                 type = "error")
    }
  })
  
  ## Zurück zur letzten Interaktion (Interaktionscodierung)
  observeEvent(input$last_interaction, {
    removeUI(selector = "#end_interaction_coding")
    insertUI(selector = "#interaction_inputs", where = "afterEnd",
             ui = tags$div(id = "change_interaction",
                           style = "line-height: 0.5;",
                           br(),
                           actionButton("submit_interaction", "Weiter", class = "btn-info btn-lg", width = "100%")))
    if(rv$index_interaction > 1){
      # der Interaktionsindex wird um 1 verringert
      rv$index_interaction <- rv$index_interaction - 1
    }
    else {
      # Wenn bereits die erste Interaktion eines:einer Akteur:in angezeigt wird, erscheint eine Fehlermeldung
      show_alert(title = "Fehler",
                 text = "Es handelt sich bereits um die erste potenzielle Interaktion des:der Akteur:in.",
                 type = "error")
    }
  })
  
  ## Zurück zur Akteurscodierung (Aussagen-/Interaktionscodierung -> Akteurscodierung)
  observeEvent(input$back_to_actor, {
    # Die UI-Elemente der Aussagen-/Interaktionscodierung werden entfernt
    removeUI(selector = "#statement_identification")
    removeUI(selector = "#statement_inputs")
    removeUI(selector = "#text_area_statement")
    removeUI(selector = "#interaction_inputs")
    removeUI(selector = "#text_area_actor_interaction")
    removeUI(selector = "#end_interaction_coding")
    removeUI(selector = "#text_area_actor")
    # Die UI für die Akteurscodierung wird wieder eingeblendet
    insertUI(selector = "#actors_article", where = "beforeBegin",
             ui = tags$div(id = "text_area_actor",
                           uiOutput("article_actor")))
    # Codier-Elemente auf der Akteursebene einfügen
    insertUI(selector = "#coder_info", where = "afterEnd",
             ui = tags$div(id = "actor_inputs",
                           wellPanel(style = "border-color:#32cd32; background-color:#ffffff;",
                                     tags$div(id = "actor_to_code",
                                              uiOutput("actor"))),
                           opt_out_relevance_input,
                           br(),
                           # Codierelemente werden ausgeblendet, wenn Irrläufer erkannt wird
                           conditionalPanel(
                             condition = "input.opt_out_relevant == false",
                             affiliation_input,
                             gender_input,
                             socarea_oberkat_input,
                             # je nach gewählter Oberkategorie werden die Unterkategorien als Auswahlmöglichkeiten angezeigt
                             conditionalPanel(
                               condition = "input.socarea_oberkat == 100",
                               socarea_wiss_input),
                             conditionalPanel(
                               condition = "input.socarea_oberkat == 200",
                               socarea_pol_input),
                             conditionalPanel(
                               condition = "input.socarea_oberkat == 300",
                               socarea_iv_input,
                               conditionalPanel(
                                 condition = "input.socarea_iv == 310",
                                 socarea_ivzo_input),
                               conditionalPanel(
                                 condition = "input.socarea_iv == 320",
                                 socarea_ivko_input)
                             ),
                             conditionalPanel(
                               condition = "input.socarea_oberkat == 400",
                               socarea_sonst_input),
                             actlocal_input,
                             relevant_quote_input
                           ),
                           # abhängig von der Codierung in "relevant_quote" werden zwei Buttons eingefügt:
                           # Liegt keine inhaltlich relevante Aussage vor (relevant_quote = FALSE), kann über die Buttons entweder zum:zur letzten Akteur:in zurückgekehrt werden oder der:die aktuelle Akteur:in abgespeichert und die Codierung beendet werden.
                           conditionalPanel(
                             style = "background-color:#ffffff; border-color:#ffffff;",
                             condition = "input.relevant_quote == false",
                             hr(),
                             splitLayout(
                               cellWidths = c("30%", "70%"),
                               actionButton("last_actor", "Zurück", class = "btn-secondary btn-lg", width = "100%"),
                               actionButton("end_coding", "Codierung beenden", class = "btn-danger btn-lg", width = "100%"))
                           ),
                           # Liegt min. 1 relevante Aussage vor (relevant_quote = TRUE), kann mit den Buttons entweder zum:zur letzten Akteur:in zurück navigiert werden oder der:die aktuelle Akteur:in abgespeichert und zur Aussagenidentifikation übergegangen werden.
                           conditionalPanel(
                             style = "background-color:#ffffff; border-color:#ffffff;",
                             condition = "input.relevant_quote == true",
                             hr(),
                             splitLayout(
                               cellWidths = c("30%", "70%"),
                               actionButton("last_actor", "Zurück", class = "btn-secondary btn-lg", width = "100%"),
                               actionButton("submit_actor", "Zur Aussagenidentifikation", class = "btn-info btn-lg", width = "100%"))
                           ),
             )
    )
    # Die Inputs der Akteurscodierung werden angezeigt
    actor_id <- draw_actor()[["entity_id"]]
    session$onFlushed(function() {
      set_to_actor_values(session = session, actor_id = actor_id)
    })
    # Die Zwischenspeicher für die Aussagen- und Interaktionsidentifizierung sowie die zugehörigen Indizes werden zurückgesetzt
    rv$index_statement <- 0
    statements(tibble(
      entity_id = integer(),
      entity = character(),
      document_id = integer(),
      statement_id = integer(),
      statement = character(),
      coded = FALSE
      )
    )
    rv$index_interaction <- 1
    new_direct_interactions(tibble(
      entity_id = integer(),
      entity = character(),
      entity_id_2 = integer(),
      entity_2 = character(),
      document_id = integer(),
      int_id = character(),
      batch_id = character(),
      coded = TRUE
      )
    )
    # bereits in den Datensätzen für den:die Akteur:in gespeicherte Aussagen und Interaktionen werden mit der reset_saved_text_inputs-Funktion gelöscht
    reset_saved_text_inputs(actor_id)
  })
  
}

shinyApp(ui = ui, server = server)