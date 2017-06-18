/*
* This is a bit of code I use to scrape the French volleyball's federation website to get the calendar of my matches.
* It then uses an nodeJS package I've written to create an iCal calendar with all the matches of the year in it.
* This is a WIP, the package is not published to NPM yet but already available at https://github.com/quilicicf/js2ics
* The scraping is done via http://webscraper.io/. If you are a french volleyball player you can import sitemap.json
* into web scraper and change it to match your division.
*/

module.exports = (function () {
  'use strict';

  var fs = require('fs');
  var ics = require('../../ics/index.js');
  var moment = require('moment');
  var _ = require('lodash');

  var asbTeamName = 'ASB REZE VOLLEY 2';
  var dateFormat = 'YYYYMMDDTHHmm';

  var icsify, dump, reformatEntry;

  reformatEntry = function (entry) {
    var reformatted = {};
    var ennemyTeam = entry.teamA === asbTeamName
    ? entry.teamB
    : entry.teamA;
    reformatted.eventName = 'Match contre ' + ennemyTeam;

    var splitDate = _.split(entry.date, '/');
    var beginingHour = _.split(entry.time, ':')[0];
    var endHour = parseInt(beginingHour) + 3;
    var minutes = _.split(entry.time, ':')[1];

    var beginingAsArray = ['20', splitDate[2], splitDate[1], splitDate[0], 'T', beginingHour, minutes];
    var beginingAsString = _.join(beginingAsArray, '');

    var endAsArray = ['20', splitDate[2], splitDate[1], splitDate[0], 'T', endHour, minutes];
    var endAsString = _.join(endAsArray, '');

    var beginingTime = moment(beginingAsString).format();
    var endTime = moment(endAsString).format();
    reformatted.dtstart = beginingTime;
    reformatted.dtend = endTime;

    reformatted.location = entry.gymnasium;
    return reformatted;
  };

  dump = function (entry) {
    icsContent += entry;
  };

  icsify = function (inputFilePath) {
    var fileContent = fs.readFileSync(inputFilePath, 'utf8');
    var entries = JSON.parse(fileContent);

    var events = _(entries)
    .filter(function (entry) {
      return entry.teamA === asbTeamName || entry.teamB === asbTeamName;
    })
    .map(reformatEntry)
    .value();

    var calendar = ics.getCalendar({ events: events });
    console.log(calendar);

    // .map(JSON.stringify)
    // .map(dump)
    // .value();
  };

  return {
    icsify: icsify,
  };

}());
