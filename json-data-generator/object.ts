interface Article
{
    "id": number,
    "title": string,
    "abstract": string
    "authors": Author[],
    "metadata": {
        "creation_date": Date | undefined
    },
    "publication_details": Publisher[],
    "sections": Section[],
    "bibliography": number[]
}

interface Author {
    "id": number,
    "first_name": string,
    "last_name": string,
    "affiliation": string | undefined,
    "mail": string,
    "bio": string | undefined
}

interface Publisher {
    "id": number,
    "journal": string,
    "volume": string | undefined,
    "number": number,
    "date": Date | undefined,
    "pages": number | undefined
}

interface Section {
    "body_text": SectionBody,
    "figures": Figure[]
}

interface SectionBody {
    "title": string,
    "text": string[],
    "sub_section": SectionBody[] | undefined
}

interface Figure 
{
    "url": URL,
    "caption": string | undefined
    "inserted_at": number
}