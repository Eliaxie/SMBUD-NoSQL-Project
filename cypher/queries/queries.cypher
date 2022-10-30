//ALL_QUERIES

// 1. Find affiliations of authors who have written articles published in a specific conference

MATCH (o:Organization) <-[:AFFILIATED_TO]-(:Author)-[:WRITES]->(:Article)-[:PUBLISHED_IN]->(c:Conference)
WHERE c.name = 'European Society for Fuzzy Logic and Technology Conference'
RETURN o

// 2. Find number of publications published in conferences per year

MATCH (p:Publication)
WITH DISTINCT p.year AS years
UNWIND years AS y
MATCH (q:Publication {year:y})-[:PUBLISHED_IN]->(:Conference)
WITH COUNT(q) AS publications, y
RETURN collect({number_of_publications:publications, year:y})

// 3. Find conference publications with at least one reference by a publication written within the next 5 years of the original publication year

MATCH (:Conference)<-[:PUBLISHED_IN]-(p:Publication)<-[r:REFERENCES]-(q:Publication)
WHERE (q.year - p.year) <= 5
WITH COUNT(r) AS citations, p
WHERE citations >= 1 
RETURN p 

// 4. Find the top 5 organizations whose authors have written the most articles (with at least 10 pages) in the field of Computer Science

MATCH (f:FieldOfStudy {name:'Computer science'})<-[c:COVERS_FIELD]-(a:Article)<-[:WRITES]-(:Author)-[:AFFILIATED_TO]->(o:Organization)
WHERE a.pages >= 10
WITH DISTINCT o, c
WITH COUNT(c) AS articles, o
ORDER BY articles DESC
LIMIT 5
RETURN collect({organization:o.name, articles:articles})

// 5. Find the venue with the most articles related to Artificial Intelligence, must include not only the name but the number of articles as well

MATCH (f:FieldOfStudy {name:'Artificial intelligence'})<-[c:COVERS_FIELD]-(:Article)-[:PUBLISHED_IN]->(v:Venue)
WITH DISTINCT v, c
WITH COUNT(c) AS articles, v
WITH MAX(articles) AS max
MATCH (f:FieldOfStudy {name:'Artificial intelligence'})<-[c:COVERS_FIELD]-(:Article)-[:PUBLISHED_IN]->(v:Venue)
WITH COUNT(c) AS articles, v, max
WHERE articles = max
RETURN collect({venue:v.name, articles:articles})

// 6) Find the shortest path (with general relations) between an author and a conference in which the author never wrote a publication for
MATCH 
(au:Author)-[:WRITES]->(ar:Article)-[:PUBLISHED_IN]->(cx:Conference),(cy:Conference),
p = shortestpath((au)-[*]-(cy))
WHERE cy <> cx
RETURN p LIMIT 1


// 7) Find the best Organizations per field of study (based on # of articles)

MATCH (f:FieldOfStudy)<-[:COVERS_FIELD]-(:Publication)<-[:WRITES]-(:Author)-[:AFFILIATED_TO]->(o:Organization)
WITH f,o,count(*) as c
WITH collect({Organization:o.name,Publications:c}) AS tuple,f
WITH collect({field:f.name,tuple:tuple}) as col
UNWIND col AS elem
WITH elem AS e
UNWIND e.tuple AS t
WITH max(t) AS m,e
RETURN e.field AS FieldOfStudy, m AS TOP_RESULT
ORDER BY FieldOfStudy ASC



