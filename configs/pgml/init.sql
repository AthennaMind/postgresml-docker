ALTER ROLE postgres SET search_path TO public,pgml;

CREATE EXTENSION IF NOT EXISTS pgml;

CREATE TEXT SEARCH CONFIGURATION bulgarian (COPY = simple);
CREATE TEXT SEARCH DICTIONARY bulgarian_ispell (
    TEMPLATE = ispell,
    DictFile = bulgarian, 
    AffFile = bulgarian, 
    StopWords = bulgarian
);
CREATE TEXT SEARCH DICTIONARY bulgarian_simple (
    TEMPLATE = pg_catalog.simple,
    STOPWORDS = bulgarian
);
ALTER TEXT SEARCH CONFIGURATION bulgarian 
    ALTER MAPPING FOR asciiword, asciihword, hword, hword_part, word 
    WITH bulgarian_ispell, bulgarian_simple;