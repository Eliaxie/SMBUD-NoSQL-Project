//upload_authors
CALL apoc.load.json("file:///articles.json") YIELD value AS entry
MERGE (p:Article:Publication {id:entry.id})
SET p.title = entry.title, p.year = entry.year
MERGE (pub:Publisher {name:entry.publisher})
MERGE (pub)-[:PUBLISHES]-(p)
MERGE (v:Venue {name:entry.venue.raw})
SET v.id = entry.venue.id
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
SET a.name = author.name, a.affiliation = author.org
MERGE (a)-[:WRITES]->(p);
