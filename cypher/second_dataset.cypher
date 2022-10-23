//author_writes
LOAD CSV WITH HEADERS FROM 'file:///for_smbud_2/written.csv' AS row FIELDTERMINATOR ';'
MERGE (p:Publication {id:row.work})
MERGE (a:Author {id:row.author})
MERGE (a)-[:WRITES]->(p)

// load journals
LOAD CSV WITH HEADERS FROM 'file:///for_smbud_2/journals.csv' AS row FIELDTERMINATOR ';'
MERGE (j:Journal {id:row.journalid})
ON CREATE SET j.name = row.name;

//load_articles_authors
LOAD CSV WITH HEADERS FROM 'file:///for_smbud_2/articles.csv' AS row FIELDTERMINATOR ';'
MERGE (art:Article:Publication {id:row.articleid})
ON CREATE SET art.title = row.title, art.doi = randomUUID(),
    art.date = row.date, art.month = row.month, art.note = row.note,
    art.pages = row.pages, art.ee = row.ee, art.year = row.year,
    art.dblpkey = row.key;
LOAD CSV WITH HEADERS FROM 'file:///for_smbud_2/author.csv' AS row FIELDTERMINATOR ';'
MERGE (auth:Author {id:row.orcid})
SET auth.name = row.author;

//load_books
LOAD CSV WITH HEADERS FROM 'file:///for_smbud_2/books.csv' AS row FIELDTERMINATOR ';'
MERGE (b:Book:Publication {id:row.bookid})
ON CREATE SET b.title = row.title, b.isbn = row.isbn, 
    b.ee = row.ee, b.year = row.year, b.mdate = row.mdate, b.note = row.note,
    b.volume = row.volume, b.pages = row.pages;     

//load_editor
LOAD CSV WITH HEADERS FROM 'file:///for_smbud_2/editors.csv' AS row FIELDTERMINATOR ';'
MATCH (a:Author)
WHERE a.id = row.id
SET a :Editor;

LOAD CSV WITH HEADERS FROM 'file:///for_smbud_2/editors.csv' AS row FIELDTERMINATOR ';'
MERGE (e:Editor {id:row.id})
ON CREATE SET e.name = row.name; 

// load_editor_relationship
LOAD CSV WITH HEADERS FROM 'file:///for_smbud_2/edited.csv' AS row FIELDTERMINATOR ';'
MERGE (p:Publication {id:row.work})
MERGE (e:Editor {id:row.editor})
MERGE (e)-[:EDITS]->(p);

// load_published_in
LOAD CSV WITH HEADERS FROM 'file:///for_smbud_2/published_in.csv' AS row FIELDTERMINATOR ';'
MERGE (p:Publication {id:row.work})
MERGE (j:Journal {id:row.journal})
MERGE (p)-[:PUBLISHED_IN]->(j)