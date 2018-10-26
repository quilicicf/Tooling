#!/usr/bin/env node

/*
* This is a bit of code I use to scrape the French volleyball's federation website to get the calendar of my matches.
* It then uses an nodeJS package I've written to create an iCal calendar with all the matches of the year in it.
* This is a WIP, the package is not published to NPM yet but already available at https://github.com/quilicicf/js2ics
* The scraping is done via http://webscraper.io/. If you are a french volleyball player you can import sitemap.json
* into web scraper and change it to match your division.
*
* $1: Team name
* $2: Input file path
* $3: Output file path
*/

const _ = require('lodash');
const fs = require('fs');
const csvtojson = require('csvtojson');
const moment = require('moment');

const ics = require('../../js2ics/index.js');

const reformatEntry = (teamName, entry) => {
  const reformatted = {};
  const enemyTeam = entry.teamA === teamName
    ? entry.teamB
    : entry.teamA;
  reformatted.eventName = `Match contre ${enemyTeam}`;

  const splitDate = _.split(entry.date, '/');
  const beginningHour = _.split(entry.time, ':')[ 0 ];
  const endHour = parseInt(beginningHour, 0) + 3;
  const minutes = _.split(entry.time, ':')[ 1 ];

  const beginningAsString = `20${splitDate[ 2 ]}${splitDate[ 1 ]}${splitDate[ 0 ]}T${beginningHour}${minutes}`;
  const endAsString = `20${splitDate[ 2 ]}${splitDate[ 1 ]}${splitDate[ 0 ]}T${endHour}${minutes}`;

  const beginningTime = moment(beginningAsString).format();
  const endTime = moment(endAsString).format();
  reformatted.dtstart = beginningTime;
  reformatted.dtend = endTime;
  reformatted.location = entry.gymnasium;
  return reformatted;
};

const icsify = async (teamName, inputFilePath, outputFilePath) => {
  const json = await csvtojson().fromFile(inputFilePath);
  const events = _(json)
    .filter(entry => [ entry.teamA, entry.teamB ].includes(teamName))
    .map(entry => reformatEntry(teamName, entry))
    .value();

  const calendar = ics.getCalendar({ events });
  fs.writeFileSync(outputFilePath, calendar, 'utf8');
};

icsify(process.argv[ 2 ], process.argv[ 3 ], process.argv[ 4 ]);
