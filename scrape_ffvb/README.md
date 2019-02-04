# Scrape FFVB

## Aim

Create an ICS file to import all the matches of the season in any e-calendar by scraping ffvbbeach.org website.

## Pre-requisites

* [Web scraper](https://chrome.google.com/webstore/detail/web-scraper/jnhgnonknehpejjnehehllkliplmbmhn/related?hl=en).
* [NodeJS](https://nodejs.org/en/download/)

## Create ICS file

* Go on http://www.ffvbbeach.org and find your championship's schedule (full schedule of course)
* Update the URL in `./siteMap.json` with yours
* Open the said URL in Chrome
* Open the devtools (F12)
* In tab `Web scraper`, choose `Create new site map > Import site map`
* Copy-paste the contents of `./siteMap.json` in the field, name your site map and import
* In the tab `Site map <NAME>`, click on `Scrape > Start scraping`
* When scraping is done, in the same tab, click on `Export data as CSV`
* Save the file and remove the BOM header. The BOM header is the first character in the file, it is invisible but you can see it's there because it takes two ⇾ to go past it
* Clone [js2ics](https://github.com/quilicicf/js2ics) in the same folder as `Tooling`
* Install both js2ics and this package (`npm install`)
* Run the script with the command below:

```shell
node ./icsify.js \
  <your team's name as on ffvbbeach.org> \
  <scraped CSV file path> \
  <file path where to store the output ICS file>
```

## Import it

Open your e-calendar and search for the `Import ics file` option.
