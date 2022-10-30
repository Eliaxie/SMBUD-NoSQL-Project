// ALL QUERIES
// 1. Find affiliations of authors who have written articles published in a specific conference

MATCH (o:Organization) <-[:AFFILIATED_TO]-(:Author)-[:WRITES]->(:Article)-[:PUBLISHED_IN]->(c:Conference)
WHERE c.name = 'European Society for Fuzzy Logic and Technology Conference'
RETURN o

// 2. Find number of publications (convering a specific field and with at least 10 pages) published in conferences per year

MATCH (p:Publication)-[:COVERS_FIELD]->(:FieldOfStudy {name:'Computer science'})
WITH DISTINCT p.year AS years
UNWIND years AS y
MATCH (:FieldOfStudy {name:'Computer science'})<-[:COVERS_FIELD]-(p:Publication {year:y})-[:PUBLISHED_IN]->(:Conference)
WHERE p.pages >= 10
WITH COUNT(p) AS publications, y
ORDER BY y DESC
RETURN collect({number_of_publications:publications, year:y})

// 3. Find conference publications with at least one citation (reference) by a publication written within the next 5 years of the original publication year

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

// 5. Find the venue(s) with the most articles related to Artificial Intelligence, must include not only the name but the number of articles as well

MATCH (f:FieldOfStudy {name:'Artificial intelligence'})<-[:COVERS_FIELD]-(:Article)-[p:PUBLISHED_IN]->(v:Venue)
WITH COUNT(p) AS articles, v
WITH MAX(articles) AS max
MATCH (f:FieldOfStudy {name:'Artificial intelligence'})<-[:COVERS_FIELD]-(:Article)-[p:PUBLISHED_IN]->(v:Venue)
WITH COUNT(p) AS articles, v, max
WHERE articles = max
RETURN collect({venue:v.name, articles:articles})

// 6. Find the pair(s) of publications (written after 2005) that share the highest amount of fields covered

MATCH (p1:Publication)-[:COVERS_FIELD]->(f:FieldOfStudy)<-[:COVERS_FIELD]-(p2:Publication)
WHERE p1.year >= 2005 AND p2.year >= 2005
WITH COUNT(f) AS common_fields, p1, p2
WITH MAX(common_fields) AS max_fields
MATCH (p1:Publication)-[:COVERS_FIELD]->(f:FieldOfStudy)<-[:COVERS_FIELD]-(p2:Publication)
WHERE p1.year >= 2005 AND p2.year >= 2005
WITH COUNT(f) AS common_fields, p1, p2, max_fields
WHERE common_fields = max_fields
RETURN collect({common_fields:common_fields, p1:p1, p2:p2})

//7. Find the average number of references made by conference articles covering a specific field written by authors affiliated with a certain university

MATCH (o:Organization)<-[:AFFILIATED_TO]-(:Author)-[:WRITES]->(p:Publication)-[:PUBLISHED_IN]->(:Conference)
MATCH (p)-[:COVERS_FIELD]->(f:FieldOfStudy)
MATCH (p)-[r:REFERENCES]->(:Publication)
WHERE f.name = 'Computer science' AND o.name = 'Karadeniz Technical Univ.'
WITH COUNT(DISTINCT r) AS references, p
RETURN AVG(references) AS average_number_of_references

// 8. Find the top 3 publishers by number of published conference articles (who must reference at least 10 other publications) covering a specific field
MATCH (:Publication)<-[r:REFERENCES]-(a:Article)-[:COVERS_FIELD]->(:FieldOfStudy {name:'Computer science'})
MATCH (a)-[:PUBLISHED_IN]->(:Conference)
WITH COUNT(r) AS references, a
WHERE references >= 10
MATCH (publisher:Publisher)-[publishes:PUBLISHES]->(a)
WITH COUNT(publishes) AS articles, publisher
ORDER BY articles DESC LIMIT 3
RETURN collect({articles:articles, publisher:publisher.name})

// 9. Find the articles (with at least 12 pages) that cover the most fields by the publisher who has published the most articles

MATCH (publisher:Publisher)-[pub:PUBLISHES]->(:Article)
WITH COUNT(pub) AS publications, publisher
ORDER BY publications DESC LIMIT 1
WITH publisher
MATCH (publisher)-[:PUBLISHES]->(a:Article)-[c:COVERS_FIELD]->(:FieldOfStudy)
WHERE a.pages >= 12
WITH COUNT(c) AS fields, a, publisher
WITH MAX(fields) AS max_fields, publisher
MATCH (publisher)-[:PUBLISHES]->(a:Article)-[c:COVERS_FIELD]->(:FieldOfStudy)
WITH COUNT(c) AS fields, a, max_fields
WHERE fields = max_fields AND a.pages >= 12
RETURN a

// 10. Find the authors who have written the most cited journal publications in the field of Computer Science
MATCH (:Journal)<-[:PUBLISHED_IN]-(p:Publication)<-[r:REFERENCES]-(:Publication)
MATCH (p)-[:COVERS_FIELD]->(f:FieldOfStudy)
WHERE f.name = 'Computer science'
WITH COUNT(r) AS citations, p
WITH MAX(citations) AS max_citations
MATCH (:Journal)<-[:PUBLISHED_IN]-(p:Publication)<-[r:REFERENCES]-(:Publication)
WITH COUNT(r) AS citations, p, max_citations
MATCH (o:Organization)<-[:AFFILIATED_TO]-(a:Author)-[:WRITES]->(p)
WHERE citations = max_citations
RETURN DISTINCT o


// 11) Find the shortest path (with general relations) between an author and a conference in which the author never wrote a publication for
MATCH 
(au:Author)-[:WRITES]->(ar:Article)-[:PUBLISHED_IN]->(cx:Conference),(cy:Conference),
p = shortestpath((au)-[*]-(cy))
WHERE cy <> cx
RETURN p LIMIT 1


// 12) Find the best Organizations per field of study (based on # of articles)

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
