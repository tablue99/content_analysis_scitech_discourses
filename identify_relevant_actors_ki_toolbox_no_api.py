import pandas as pd
import openai
from collections import defaultdict
import json
import os
import time

client = openai.OpenAI(api_key="insert_personal_api_key", base_url = "https://ki-toolbox.scc.kit.edu/api/v1") 

def ask_openai_tool(prompt, tool_name, tool_spec, entity=None):

    try:
        response = client.chat.completions.create(
            model="kit.gpt-oss-120b",
            messages=[
                {"role": "user", "content": prompt}
            ],
            tools=[
                {"type": "function", "function": tool_spec}
            ],
            tool_choice={
                "type": "function",
                "function": {"name": tool_name}
            },
            temperature=0.2
        )
        
        # ---- DEBUGGING: Anzeige vollständige 
        #print("🟢 Vollständige Antwort:", response)

        tool_call = response.choices[0].message.tool_calls[0]
        arguments = json.loads(tool_call.function.arguments)

        return arguments

    except Exception as e:
        print(f"❌ Fehler: {e}")

    finally:
      time.sleep(1)
      
# Hinweis: 
# Erkennt häufig fälschlicherweise Buchautoren oder Schriftsteller als Autoren des Artikels
# Erkennt Großschreibung teilweise fälschlicherweise als Autor (das Problem wird jedoch durch die spätere Prüfung auf reale Personennamen beseitigt)
def is_author(sentence, entity):
    prompt = (
        f"Du erhältst einen Satz aus einem Artikel. Entscheide, ob der Name '{entity}' höchstwahrscheinlich Autor, Interviewer, Fotograf, Illustrator oder Editor des Artikels ist.\n"
        "Sind mehrere Personen am Artikel beteiligt, sind sie oft nacheinander aufgelistet."
        "Die Namen von Autoren, Fotografen und Illustratoren sind oft in Großbuchstaben geschrieben.\n"
        "Interviewer ist die Personen, die ein Gespräch oder Interview geführt hat.\n"
        f"Satz: '{sentence}'\n"
        "Bitte gib das Ergebnis als Funktionsaufruf zurück."
    )
    tool_spec = {
        "name": "is_author",
        "description": "Prüfe, ob es sich bei der genannten Person höchstwahrscheinlich um den Autor, Interviewer, Fotografen, Illustrator oder Editor des Artikels handelt.",
        "parameters": {
            "type": "object",
            "properties": {
                "is_author": {"type": "boolean"}
            },
            "required": ["is_author"]
        }
    }
    result = ask_openai_tool(prompt, "is_author", tool_spec, entity)
    print(f"✍️  {result}")
    return result.get("is_author", False)

def is_person(entity, sentence):
    prompt = (
        f"Ist '{entity}' im folgenden Text der Name einer realen Person? "
        "Beachte: Es geht nicht um Berufsbezeichnungen oder Rollen, sondern nur um echte Personennamen.\n\n"
        f"Text: '{sentence}'\n"
        "Entscheide im Zweifelsfall immer, dass es sich um den Namen einer realen Person handelt.\n"
        "Bitte gib das Ergebnis als Funktionsaufruf zurück."
    )
    tool_spec = {
        "name": "is_person",
        "description": "Beurteile, ob es sich um einen Menschen und dessen Namen handelt (keine Berufsbezeichnung oder Funktion).",
        "parameters": {
            "type": "object",
            "properties": {
                "type": {
                    "type": "string",
                    "enum": ["Name einer Person", "Kein Name einer Person"]
                }
            },
            "required": ["type"]
        }
    }
    result = ask_openai_tool(prompt, "is_person", tool_spec, entity)
    print(f"👤  {result}")
    return result.get("type") == "Name einer Person"

def is_same_person(entity1, sentence1, entity2, sentence2):
    prompt = (
        f"Sind '{entity1}' "
        f"und '{entity2}' potenziell die gleiche Person?\n"
        f"Text 1: {sentence1}\n"
        f"Text 2: {sentence2}\n"
        "Gib eine strukturierte Antwort."
    )
    tool_spec = {
        "name": "is_same_person",
        "description": "Beurteile, ob zwei Entitäten dieselbe reale Person meinen.",
        "parameters": {
            "type": "object",
            "properties": {
                "same_person": {"type": "boolean"}
            },
            "required": ["same_person"]
        }
    }
    result = ask_openai_tool(prompt, "is_same_person", tool_spec, f"{entity1} <-> {entity2}")
    print(f"🟰  {result}")
    return result.get("same_person", False)

def is_passive_actor(entity, sentence):
 
    prompt = (
        f"Bewerte, ob die Person '{entity}' im folgenden Text eine aktive oder passive Rolle einnimmt.\n\n"
        f"Kontext: '{sentence}'\n\n"
        "Definitionen:\n"
        "Passiv heißt:\n"
        "- Es wird lediglich die Handlung der Person oder etwas, das ihr passiert ist, beschrieben\n"
        "- Die Person macht keine konkrete Aussage\n"
        "- Es handelt sich um eine historische Persönlichkeit (z. B. Robert Koch, Barbarossa)\n"
        "- Die Aussage der Person liegt mehrere Jahre zurück\n"
        "\n"
        "Aktiv heißt:\n"
        "- Die Person kommt direkt über ein Zitat zu Wort\n"
        "- Die Person wird indirekt zitiert (erkennbar an Konjunktiv und paraphrasierten Aussagen)\n"
        "- Es werden Studien erwähnt, die eine als Wissenschaftler arbeitende Person verfasst hat\n"
        "\n"
        "Antworte strukturiert mit \"aktiv\" oder \"passiv\".\n"
        "Wähle im Zweifelsfall immmer \"passiv\".\n"
        "Bitte gib das Ergebnis als Funktionsaufruf zurück."
    )
    tool_spec = {
        "name": "is_passive_actor",
        "description": (
            "Klassifiziere, ob die genannte Person im Text eine aktive oder passive Rolle einnimmt. "
            "Siehe Definition: aktiv = kommt zu Wort / eigene Studie; passiv = wird nur erwähnt, historische Figur."
        ),
        "parameters": {
            "type": "object",
            "properties": {
                "role": {
                  "type": "string",
                  "enum": ["aktiv", "passiv"]
                  }
            },
            "required": ["role"]
        }
    }

    result = ask_openai_tool(prompt, "is_passive_actor", tool_spec, entity)
    print(f"💬  {result}")
    return result.get("role") == "passiv"



if __name__ == "__main__":
    script_dir = os.path.dirname(os.path.abspath(__file__))
    dataset_name = input('Name of the file with the actors?')
    file_path = os.path.join(script_dir, "daten", dataset_name)
    
    df = pd.read_csv(file_path)
    pd.set_option('display.max_columns', None)
    print(df)
    
    grouped = df.groupby("document_id")
    for doc_id, group in grouped:
  
        # if doc_id < 5: # not in ["1"]:
          #  continue
        
        print("##############################")
        print(doc_id)
       
        #seen_entities = defaultdict(list)
        max_sentence_id = group['sentence_id'].max()

        for idx, row in group.iterrows():
            entity = row['entity']
            sentence = row['sentence']
            sentence_id = row['sentence_id']

            print("\n###")
            print(entity)
            print(sentence)

            # Ist die Entity ein Journalist? (Wir prüfen das nur für den Anfang und Ende eines Artikels, da hier am wahrscheinlichsten die Autoren stehen))
            if sentence_id == 1 or sentence_id == max_sentence_id:
                # Ignoriere diese Entität und springe zur nächsten Entität, wenn es sich um einen Journalisten handelt
                # Wenn die Entität in Byline des Artikels vorkommt, ist es automatisch ein Journalist und wir können uns die ChatGPT-Abfrage sparen
                if pd.notna(row.get('article_byline')) and entity in str(row['article_byline']):
                    df.at[idx, 'journalist'] = True
                    df.at[idx, 'relevant'] = False
                    continue 
                else:
                    author_check = is_author(sentence, entity)
                    if author_check:
                        df.at[idx, 'journalist'] = True
                        df.at[idx, 'relevant'] = False
                        continue 
                    else: 
                        df.at[idx, 'journalist'] = False

            # TODO: Duplikatscheck: Ganz am Ende, dann erste Schreibweise, die auftritt (niedrigste enitity_id)
            # TODO: Aus sentences joined: previous sentence_id, next sentence_id
            # Duplicate & Missclassification?
            
            #parts = entity.split()
            #found = False
            #for seen_entity, seen_idx in seen_entities[doc_id]:
            #    if seen_entity == entity and df.at[seen_idx, 'relevant']:
            #        df.at[idx, 'duplicate'] = True
            #        found = True
            #        break
            #    elif (entity in seen_entity or seen_entity in entity) and df.at[seen_idx, 'relevant']:
            #        if is_same_person(entity, sentence, seen_entity, df.at[seen_idx, 'sentence']):
            #            df.at[idx, 'duplicate'] = True
            #            found = True
            #            break
            #if found:
            #    continue

            # Springe zur nächsten Entität, wenn es sich um keine reale Person handelt
            if not is_person(entity, sentence):
                df.at[idx, 'misclassification'] = True
                df.at[idx, 'relevant'] = False
                continue

            # Ist die Entität ein aktiver oder passiver Akteur?
            if is_passive_actor(entity, sentence):
                df.at[idx, 'passive_actor'] = True
                df.at[idx, 'relevant'] = False
            else:
                df.at[idx, 'relevant'] = True

            # Save entity as seen
        #seen_entities[doc_id].append((entity, idx))

    output_csv_file = f"relevant_actors_from_{dataset_name[:-3]}csv"
    df.to_csv(os.path.join(script_dir, "daten", output_csv_file), index=False, encoding="UTF-8")
    print(f"Erstelle CSV-Datei {output_csv_file} mit codierten Akteuren.")
