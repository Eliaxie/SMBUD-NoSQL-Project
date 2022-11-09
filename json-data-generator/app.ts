var fs = require("fs");
import axios, { AxiosRequestConfig, AxiosPromise } from 'axios';
/// https://baconipsum.com/api/?type=all-meat&paras=100
///
/// doc generalities: curl "https://api.mockaroo.com/api/f463f250?count=1000&key=0167ee30"
/// author: curl "https://api.mockaroo.com/api/5e6b06c0?count=1000&key=0167ee30"
/// pub details: curl "https://api.mockaroo.com/api/512c3fc0?count=1000&key=0167ee30"
/// title: curl "https://api.mockaroo.com/api/e2c22890?count=1000&key=0167ee30"
/// figures: curl "https://api.mockaroo.com/api/2cb545d0?count=1000&key=0167ee30"

generate(1000)

async function generate(howMany: number){
    if (howMany < 20){
        console.log(`minimum ${20} docs`)
    }
    console.log("Fetching...")
    var writeStream = fs.createWriteStream("documents.json");
    let documents: Article[] = [];
    let authors_data = (await axios({
        method: 'get',
        url: `https://api.mockaroo.com/api/5e6b06c0?count=${howMany}&key=0167ee30`,
        headers: {}
    })).data
    let doc_gen = (await axios({
        method: 'get',
        url: `https://api.mockaroo.com/api/f463f250?count=${howMany}&key=0167ee30`,
        headers: {}
    })).data
    let publishers_data = (await axios({
        method: 'get',
        url: `https://api.mockaroo.com/api/512c3fc0?count=${howMany}&key=0167ee30`,
        headers: {}
    })).data
    let figures = (await axios({
        method: 'get',
        url: `https://api.mockaroo.com/api/2cb545d0?count=${howMany}&key=0167ee30`,
        headers: {}
    })).data
    let text_raw: string[] = [];
    for (let index = 0; index < howMany / 100; index++) {
        text_raw = text_raw.concat(await (await axios({
            method: 'get',
            url: `https://baconipsum.com/api/?type=all-meat&paras=1000`,
            headers: {}
        })).data)
        await new Promise(r => setTimeout(r, 1000));
    }
    let titles = (await axios({
        method: 'get',
        url: `https://api.mockaroo.com/api/e2c22890?count=${howMany}&key=0167ee30`,
        headers: {}
    })).data

    console.log("Generating...")

    for (let index = 0; index < howMany; index++) {
        let authors: Author[] = []
        let num_authors = getRandomInt(10);
        for (let index = 0; index < num_authors; index++) {
            let range = Math.floor(howMany / num_authors)
            let low_bound = index * range;
            authors.push(authors_data[low_bound + getRandomInt(range)])
        }
        let publishers: Publisher[] = []
        let num_publisher = getRandomInt(20);
        for (let index = 0; index < num_publisher; index++) {
            let range = Math.floor(howMany / num_publisher)
            let low_bound = index * range;
            let pub = publishers_data[low_bound + getRandomInt(range)]
            let publisher: Publisher = {
                id: pub.id,
                journal: pub.journal,
                volume: pub.volume,
                number: pub.number,
                date: pub.date,
                pages: pub.pages
            }
            publishers.push(publisher)
        }
        
        let sections: Section[] = generateSection(figures, titles, howMany, text_raw);

        let doc: Article = {
            "id": doc_gen[index].id,
            "title": doc_gen[index].title,
            "abstract": doc_gen[index].abstract,
            "metadata": {
                "creation_date": doc_gen[index].creation_date,
            },
            "authors": authors,
            "publication_details": publishers,
            "sections": sections,
            "bibliography": []
        };
        documents.push(doc);
    }
    for (let index = 0; index < howMany; index++) {
        let references = getRandomInt(20);
        for (let e = 0; e < references; e++) {
            let range = Math.floor(howMany / 20)
            let low_bound = e * range;
            documents[index].bibliography.push(documents[low_bound + getRandomInt(range)].id);
        }
    }
    writeStream.write(JSON.stringify(documents));
    writeStream.end();
}

function getRandomInt(max: number) {
    return Math.floor(Math.random() * max);
}

function generateSubsectionRecursive(figures_data: any, titles: any, text_raw: string[], howMany: number, probability_to_continue: number): SectionBody[] | undefined {
    if( Math.random() > probability_to_continue ){
        return undefined
    } else {
        var section_bodies: SectionBody[] = []
        for (let index = 0; index < 10; index++) {
            let section_body: SectionBody = {
                "title": titles[getRandomInt(howMany)].title,
                "text": text_raw[getRandomInt(howMany)].split("  "),
                "sub_section": generateSubsectionRecursive(figures_data, titles, text_raw, howMany, probability_to_continue)
            }
            section_bodies.push(section_body);
        }
        return section_bodies;
    }
}
function generateSection(figures_data: any, titles: any, howMany: number, text_raw: string[]): Section[] {
    let sections: Section[] = []
    let figures: Figure[] = []
    let num_figures = getRandomInt(howMany / 10);
    for (let index = 0; index < num_figures; index++) {
        let figure: Figure = {
            "url": figures_data[index].url,
            "caption": figures_data[index].caption,
            "inserted_at": figures_data[index].inserted_at
        }
        figures.push(figure)
    }
    for (let index = 0; index < 10; index++) {
        let section: Section = {
            "body_text": {
                "title": titles[getRandomInt(howMany)],
                "text": text_raw[getRandomInt(howMany)].split("  "),
                "sub_section": generateSubsectionRecursive(figures_data, titles, text_raw, howMany, 0.05)
            },
            figures: figures
        }
        sections.push(section);
    }
    return sections
}

