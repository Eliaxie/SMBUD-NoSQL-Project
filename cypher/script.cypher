//load
CALL apoc.load.json("file:///articles2.json") YIELD value AS entry
MERGE (art:Article:Publication {doi:entry.id})
SET art.title = entry.title, art.year = entry.year
MERGE (v:Venue {name:entry.venue})
MERGE (art)-[:PUBLISHED_ON]->(v)
WITH art, entry
UNWIND entry.references AS reference
MERGE (rfd:Article {doi:reference})
MERGE (art)-[:REFERENCES]->(rfd)
WITH art, entry.authors AS authors
UNWIND authors as author
MERGE (auth:Author {name: author})
SET auth.orcid = randomUUID()
MERGE (auth)-[:WRITES]->(art);
