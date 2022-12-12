const fs = require("fs");
const crypto = require('crypto');
import axios, { AxiosRequestConfig, AxiosPromise } from 'axios';
import { Console } from 'console';
/// https://baconipsum.com/api/?type=all-meat&paras=100
///
/// doc generalities: curl "https://api.mockaroo.com/api/f463f250?count=1000&key=0167ee30"
/// author: curl "https://api.mockaroo.com/api/5e6b06c0?count=1000&key=0167ee30"
/// pub details: curl "https://api.mockaroo.com/api/512c3fc0?count=1000&key=0167ee30"
/// title: curl "https://api.mockaroo.com/api/e2c22890?count=1000&key=0167ee30"
/// figures: curl "https://api.mockaroo.com/api/2cb545d0?count=1000&key=0167ee30"

const API_KEY= "0167ee30"

generate(1000)

async function generate(howMany: number){
    if (howMany < 20){
        console.log(`minimum ${20} docs`)
    }
    console.log("Fetching...")
    let documents: Article[] = [];
    let authors_data = (await axios({
        method: 'get',
        url: `https://api.mockaroo.com/api/5e6b06c0?count=${howMany}&key=${API_KEY}`,
        headers: {}
    })).data
    let doc_gen = (await axios({
        method: 'get',
        url: `https://api.mockaroo.com/api/f463f250?count=${howMany}&key=${API_KEY}`,
        headers: {}
    })).data
    let publishers_data = (await axios({
        method: 'get',
        url: `https://api.mockaroo.com/api/512c3fc0?count=${howMany}&key=${API_KEY}`,
        headers: {}
    })).data
    let figures = (await axios({
        method: 'get',
        url: `https://api.mockaroo.com/api/2cb545d0?count=${howMany}&key=${API_KEY}`,
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
        url: `https://api.mockaroo.com/api/e2c22890?count=${howMany}&key=${API_KEY}`,
        headers: {}
    })).data

    for (let index = 0; index < howMany; index++) {
        authors_data.id = index
        publishers_data.id = index
    }

    console.log("Generating...")

    for (let index = 0; index < howMany; index++) {
        let authors: Author[] = []
        let num_authors = getRandomInt(9) + 1;
        for (let index = 0; index < num_authors; index++) {
            let range = Math.floor(howMany / num_authors)
            let low_bound = index * range;
            authors.push(authors_data[low_bound + getRandomInt(range)])
        }
        let publishers: Publisher[] = []
        let num_publisher = getRandomInt(19) + 1;
        for (let index = 0; index < num_publisher; index++) {
            let range = Math.floor(howMany / num_publisher)
            let low_bound = index * range;
            let pub = publishers_data[low_bound + getRandomInt(range)]
            let publisher: Publisher = {
                id: pub.id,
                journal: pub.journal,
                volume: pub.volume,
                number: pub.number,
                date: pub.date != undefined ? { "$date": new Date().toISOString() } : undefined,
                pages: pub.pages
            }
            publishers.push(publisher)
        }
        
        let sections: Section[] = generateSection(figures, titles, howMany, text_raw);

        if( doc_gen[index].keywords.length == 0) {
            console.log("questo è vuoto")
        }

        var creation_date = doc_gen[index].creation_date != undefined ? { "$date": new Date(doc_gen[index].creation_date).toISOString() } : undefined;

        for (let e = 0; e < publishers.length; e++) {
            if(creation_date == undefined){
                publishers[e].date = publishers[e].date != undefined ? { "$date": getRandomDate(new Date(0), new Date()).toISOString() } : undefined
            } else {
                publishers[e].date = publishers[e].date != undefined ? { "$date": getRandomDate(new Date(creation_date.$date), new Date()).toISOString() } : undefined
            }
        }

        let doc: Article = {
            "id": index,
            "title": doc_gen[index].title,
            "abstract": doc_gen[index].abstract,
            "metadata": {
                "creation_date": creation_date,
                "keywords": (doc_gen[index].keywords ?? "" ).split(" ")
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
            const ref = documents[low_bound + getRandomInt(range)].id;
            if(ref != index)
                documents[index].bibliography.push(ref);
        }
    }
    var writeStream = fs.createWriteStream("documents.json");
    writeStream.write(JSON.stringify(documents));
    writeStream.end();
}

function getRandomInt(max: number) {
    const buf = crypto.randomInt(max);
    return buf
}

function getRandomDate(start: Date | undefined, end: Date | undefined){
    function randomValueBetween(min: number, max: number) {
      return getRandomInt(max - min) + min;
    }
    var start_date = new Date(start ?? 0)
    var end_date = new Date(end ?? new Date())
    if(start_date.getTime() > end_date.getTime()) {
        console.log("start cannot be > end", start, end)
        throw new Error();
    }
    return new Date(randomValueBetween(start_date.getTime(), end_date.getTime()))
}

function generateSubsectionRecursive(figures_data: any, titles: any, text_raw: string[], howMany: number, probability_to_continue: number, level: number): SectionBody[] | undefined {
    if( Math.random() > (Math.pow(probability_to_continue, Math.pow(level, 2))) ){
        return undefined
    } else {
        var section_bodies: SectionBody[] = []
        var num_section_bodies = getRandomInt(19) + 1;
        for (let index = 0; index < num_section_bodies; index++) {
            let section_body: SectionBody = {
                "title": titles[getRandomInt(howMany)].title,
                "text": text_raw[getRandomInt(howMany)].split("  "),
                "sub_section": generateSubsectionRecursive(figures_data, titles, text_raw, howMany, probability_to_continue, level + 1)
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
    let num_sections = getRandomInt(19) + 1
    for (let index = 0; index < num_sections; index++) {
        let section: Section = {
            "body_text": {
                "title": titles[getRandomInt(howMany)].title,
                "text": text_raw[getRandomInt(howMany)].split("  "),
                "sub_section": generateSubsectionRecursive(figures_data, titles, text_raw, howMany, 0.5, 1)
            },
            figures: figures
        }
        sections.push(section);
    }
    return sections
}

