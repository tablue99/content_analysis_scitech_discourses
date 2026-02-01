import pandas as pd
import re
import flair
from datetime import datetime
import os


def create_log(filename):
    """
    Creates a logfile.
    :param filename: name of the logfile (Str)
    :return: None
    """
    with open(filename, 'w') as file:
        timestamp = datetime.now()
        file.write(str(timestamp) + ': Process started')


def write_log(msg, logfile):
    """
    appends the given message to the given logfile
    :param msg: message to append (Str)
    :param logfile: name of the logfile (Str)
    :return: None
    """
    if logfile is not None:
        with open(logfile, 'a') as file:
            file.write('\n')
            file.write(msg)


def print_progress_bar(iteration, total, prefix='', suffix='', decimals=1, length=50, fill='█', print_end=""):
    """
    Call in a loop to create terminal progress bar
    @params:
        iteration   - Required  : current iteration (Int)
        total       - Required  : total iterations (Int)
        prefix      - Optional  : prefix string (Str)
        suffix      - Optional  : suffix string (Str)
        decimals    - Optional  : positive number of decimals in percent complete (Int)
        length      - Optional  : character length of bar (Int)
        fill        - Optional  : bar fill character (Str)
        printEnd    - Optional  : end character (e.g. "\r", "\r\n") (Str)
    """
    percent = ("{0:." + str(decimals) + "f}").format(100 * (iteration / float(total)))
    filled_length = int(length * iteration // total)
    bar = fill * filled_length + '-' * (length - filled_length)
    print(f'\r{prefix} |{bar}| {percent}% {suffix}', end=print_end)
    # Print New Line on Complete
    if iteration == total:
        print()


def read_articles(filename, logfile):
    """
    Read text file with articles from GENIOS wiso, split them into single documents using document structure
    :param filename: name of the text file with the articles (Str)
    :param logfile:  name of the logfile created by the script (Str)
    :return: Pandas DataFrame with one column (content) containing the articles
    """
    try:
        with open(filename, "r", encoding="utf-8") as file:
            documents = file.read()
    except UnicodeDecodeError:
        with open(filename, "r", encoding="ANSI") as file:
            documents = file.read()
    documents = documents.split('GBI-Genios Deutsche Wirtschaftsdatenbank GmbH')[:-1]
    write_log(f"{datetime.now()}: Read file {filename}. Found {len(documents)} articles.", logfile)
    print(f"Found {len(documents)} articles.")
    documents_dataframe = pd.DataFrame(documents, columns=["content"])
    return documents_dataframe


def clean_articles(documents, logfile):
    """
    Clean articles from GENIOS wiso and extract headline, article body and complete text.
    Uses document structure to find body etc.
    :param documents: Pandas DataFrame with the articles. Must contain column "contents" (pandas.DataFrame)
    :param logfile: name of the logfile created by the script (Str)
    :return: Pandas DataFrame with new columns for the cleaned content ("content_clean"), title, source, pubdate, 
    article body ("body") and full text ("complete_text").
    """
    documents["content_clean"] = documents.content.apply(
        lambda x: re.sub("\xa0", " ", re.sub(r"\ufeff", " ", x)).strip())
    documents.content_clean = documents.content_clean.apply(
        lambda x: re.sub(r"\n{2,}", "\n", re.sub(r" \n", "\n", re.sub(r" {2,}", " ", x))))
    
    header_footer_pattern = re.compile(
      r"""^(?:Dokumente|Seite\s*\d+\s*von\s*\d+|Seite\s*\d+)$""",
      flags=re.IGNORECASE | re.MULTILINE | re.VERBOSE
    )
    documents.content_clean = documents.content_clean.apply(
      lambda x: header_footer_pattern.sub("", x)
    )
    documents.content_clean = documents.content_clean.apply(
      lambda x: re.sub(r"\n{2,}", "\n", x).strip()
    )
    
    """
    Find and extract source and article pubdate from header
    :param document: raw text of articles from GENIOS wiso (Str)
    :return: Part of the document that contains the source and pubdate mentioned in the header (Str)
    """
    pattern = re.compile(
      r'^(?P<source>.+?)\s+vom\s+(?P<pubdate>\d{2}\.\d{2}\.\d{4}),.*\n'
      r'(?P<title>.+?)\n',
      flags=re.MULTILINE
    )
    def extract_groups(document):
      m = pattern.search(document)
      if m:
        return m.group('title'), m.group('source'), m.group('pubdate')
      return "Nicht angegeben", "Nicht angegeben", "Nicht angegeben"
    documents[['title', 'source', 'pubdate']] = (
      documents.content_clean
      .apply(extract_groups)
      .apply(pd.Series)
    )

    """
    Find and extraxt author from article in GENIOS wiso
    :param document: raw text of articles from GENIOS wiso (Str)
    :return: Part of the text that contains the author of the article if mentioned at the end of the article (Str)
    """
    pattern_author_line = re.compile(
      r'''(?x)
          ^
          (?P<author>
            (?:[A-ZÄÖÜ][a-zäöüß]+
                (?:[--][A-ZÄÖÜ][\wäöüß]+)*
                (?:\s+[A-ZÄÖÜ][\wäöüß]+)*
            )
            (?:
              \s*
              (?:,|;|und)
              \s*
              (?:[A-ZÄÖÜ][a-zäöüß]+
                  (?:[--][A-ZÄÖÜ][\wäöüß]+)*
                  (?:\s+[A-ZÄÖÜ][\wäöüß]+)*
                  )
              )*
            )
            \s*$
            \n\s*Quelle:
      ''',
      flags=re.MULTILINE
    )  
    
    def extract_author(document):
      author = pattern_author_line.search(document)
      if author:
        return author.group('author').strip()
      else:
        return "Nicht angegeben"
      
    def read_body(document):
        """
        Find and extract article body in GENIOS wiso documents.
        :param document: raw text of article from GENIOS wiso (Str)
        :return: Part of the text that contains the article body (Str)
        """
        try:
            if re.search(r'\sQuelle:', document):
                end_body = re.search(r'\sQuelle:', document).start()
            else:
              return None
            header_pat = r'^.+?\n'
            title_pat = r'.+?\n'
            header_match = re.search(header_pat, document, re.MULTILINE)
            if header_match:
              after_header = header_match.end()
              title_match = re.search(title_pat, document[after_header:], re.MULTILINE)
              if title_match:
                start_body = after_header + title_match.end()
              else:
                start_body = after_header
            else:
              start_body = 0
            raw_body = document[start_body:end_body]
            """
            Delete the author line from the article body if found
            """
            author = extract_author(document)
            if author:
              author_line = re.compile(rf'^{re.escape(author)}\s*$\n?', flags=re.MULTILINE)
              raw_body = author_line.sub('', raw_body)
            document_body = re.sub(r"\s+", " ", raw_body).strip()
        except AttributeError:
            document_body = "Fehler beim Auslesen des Inhalts"
        return document_body

    def read_section(document):
        if re.search(r"\sRessort: ", document):
            return re.search(r"\sRessort:\s([^;\n]*)", document).group(1)
        else:
            return "Nicht angegeben"

    documents["body"] = documents.content_clean.apply(read_body)
    documents["byline"] = documents.content_clean.apply(extract_author)
    documents["section"] = documents.content_clean.apply(read_section)
    unsuccessful_cases = sum(documents['body'] == 'Fehler beim Auslesen des Inhalts')
    write_log(f"{datetime.now()}: Cleaned all articles. Was unsuccessful in {unsuccessful_cases} cases.", logfile)
    print("Cleaned articles.")
    documents["complete_text"] = documents["title"] + " " + documents["body"]
    return documents

if __name__ == '__main__':
    logfile = os.path.join('log', input('Name of the Logfile?'))
    create_log(logfile)
    dataset_name = input('Name of the file with the documents?')
    articles_dataframe = read_articles(os.path.join('daten', dataset_name), logfile)
    articles_dataframe = clean_articles(articles_dataframe, logfile)
    all_articles = pd.DataFrame(articles_dataframe)
    
    new_csv_file = f"documents_from_{dataset_name[:-3]}csv"
    all_articles[
        ["title",
         "source",
         "pubdate",
         "body",
         "byline",
         "section"]
    ].to_csv(os.path.join("daten", new_csv_file), sep=",", index=False, encoding="UTF-8")
    write_log(f"{datetime.now()}: Created file {new_csv_file} containing all identified documents", logfile)
    print(f"Created file {new_csv_file} containing all identified documents.")
    write_log(f"{datetime.now()}: Process terminated.", logfile)
    input('\nPress Enter to exit.')
