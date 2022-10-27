// FULL SCRIPT

// articles
CALL apoc.load.json("file:///articles_and_books.json") YIELD value AS 
entry
WHERE entry.doc_type <> "Book"
MERGE (p:Article:Publication {id:entry.id})
SET p.title = entry.title, p.year = entry.year, p.citations = 
entry.n_citation, p.pages = toInteger(entry.page_end) - 
toInteger(entry.page_start)
MERGE (pub:Publisher {name:entry.publisher})
MERGE (pub)-[:PUBLISHES]-(p)
MERGE (v:Venue {name:entry.venue.raw})
MERGE (p)-[:PUBLISHED_IN]->(v)
WITH p, entry
UNWIND entry.fos AS field
MERGE (f:FieldOfStudy {name:field.name})
MERGE (p)-[:COVERS_FIELD]->(f)
WITH p, entry
UNWIND entry.references AS reference
MERGE (ref:Publication {id:reference})
MERGE (p)-[:REFERENCES]->(ref)
WITH p, entry.authors AS authors
UNWIND authors AS author
MERGE (a:Author {id:author.id})
SET a.name = author.name
MERGE (a)-[:WRITES]->(p);

// books
CALL apoc.load.json("file:///articles_and_books.json") YIELD value AS 
entry
WHERE entry.doc_type = "Book"
MERGE (p:Book:Publication {id:entry.id})
SET p.title = entry.title, p.year = entry.year, p.citations = 
entry.n_citation, p.pages = toInteger(entry.page_end) - 
toInteger(entry.page_start)
MERGE (pub:Publisher {name:entry.publisher})
MERGE (pub)-[:PUBLISHES]-(p)
WITH p, entry
UNWIND entry.fos AS field
MERGE (f:FieldOfStudy {name:field.name})
MERGE (p)-[:COVERS_FIELD]->(f)
WITH p, entry
UNWIND entry.references AS reference
MERGE (ref:Publication {id:reference})
MERGE (p)-[:REFERENCES]->(ref)
WITH p, entry.authors AS authors
UNWIND authors AS author
MERGE (a:Author {id:author.id})
SET a.name = author.name
MERGE (a)-[:WRITES]->(p);

// affiliations
CALL apoc.load.json("file:///articles_and_books.json") YIELD value AS 
entry
WITH entry.authors AS authors
UNWIND authors AS author
MATCH (a:Author {id:author.id})
WHERE author.org IS NOT NULL
MERGE (aff:Organization {name:author.org})
MERGE (a)-[:AFFILIATED_TO]->(aff);

//journals
CALL apoc.load.json("file:///articles_and_books.json") YIELD value AS 
entry
WHERE entry.doc_type <> "Book"
MATCH (v:Venue {name:entry.venue.raw})
WITH v,entry.venue as venue
WHERE venue.type = 'J'
SET v:Journal;

//conferences
CALL apoc.load.json("file:///articles_and_books.json") YIELD value AS 
entry
WHERE entry.doc_type <> "Book"
MATCH (v:Venue {name:entry.venue.raw})
WITH v
WHERE not "Journal" in labels(v)
SET v:Conference;

// clearing scrap data
MATCH (p:Publication)
WHERE p.pages = 0
REMOVE p.pages;

MATCH (p:Publisher {name:""})
DETACH DELETE p;

MATCH (p:Publication {id:""})
DETACH DELETE p;

MATCH (a:Author {id:""})
DETACH DELETE a;
