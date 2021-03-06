#!/usr/bin/env node

const { homedir } = require('os');
const { resolve } = require('path')
const { readFileSync } = require('fs');

const MAX_ICONS_TO_DISPLAY = 50;

const main = () => {
  const [ iconsPath, searchTerm ] = process.argv.splice(2);
  const iconsContent = readFileSync(iconsPath, 'utf8');
  const { icons } = JSON.parse(iconsContent);

  const matchingIcons = icons
    .filter(({ id, filter }) => {
      return [ id, ...(filter || []) ].some(term => term.includes(searchTerm))
    });

  process.stdout.write(`Found ${matchingIcons.length} icons:\n`);
  if (matchingIcons.length > MAX_ICONS_TO_DISPLAY) {
    process.stdout.write(`More than ${MAX_ICONS_TO_DISPLAY} icons matched, please narrow down your search\n`);
    process.exit(1);
  }

  matchingIcons.forEach(({ unicode, name }) => {
    const character = String.fromCharCode(parseInt(unicode, 16));
    process.stdout.write(` ${character}\t${name}\n`);
  });
};

main();
