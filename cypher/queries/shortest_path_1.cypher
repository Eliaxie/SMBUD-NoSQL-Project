//Find the shortest path (with general relations) between an author and a 
conference in which the author never wrote a publication for
MATCH 
(au:Author)-[:WRITES]->(ar:Article)-[:PUBLISHED_IN]->(cx:Conference),(cy:Conference),
p = shortestpath((au)-[*]-(cy))
WHERE cy <> cx
RETURN p LIMIT 1
