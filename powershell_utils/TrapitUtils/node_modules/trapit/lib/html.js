"use strict";
/***************************************************************************************************
Name: html.js                          Author: Brendan Furey                       Date: 10-Jun-2018

Component module in: The Math Function Unit Testing design pattern, implemented in nodejs

GitHub: https://github.com/BrenPatF/trapit_nodejs_tester

See: 'Database API Viewed As A Mathematical Function: Insights into Testing'
    https://www.slideshare.net/brendanfurey7/database-api-viewed-as-a-mathematical-function-insights-into-testing
    Brendan Furey, March 2018

There is an entry point module, TrapitUtils, with two functions for JavaScript unit testing and two
driver functionss for formatting externally-sourced results read from JSON files. This module calls
the Trapit module to handle the results formatting.

There are also a helper class and three helper modules of pure functions, called by the Trapit
module
====================================================================================================
|  Module       |  Notes                                                                           |
|==================================================================================================|
|  TrapitUtils  |  Entry point module for JavaScript unit testing and drivers for formatting the   |
|               |  externally-sourced results read from JSON files                                 |
|---------------|----------------------------------------------------------------------------------|
|  Trapit       |  Module for the unit test formaatting functions, written with core pure          |
|               |  functions to facilitate unit testing and multiple reporters; called from        |
|               |  TrapitUtils                                                                     |
|---------------|----------------------------------------------------------------------------------|
|  Utils        |  General utility functions, called mainly by the Text module below               |
|---------------|----------------------------------------------------------------------------------|
|  Pages        |  Class used to buffer pages of text ahead of writing to file; used by Text, HTML |
|---------------|----------------------------------------------------------------------------------|
|  Text         |  Module of pure functions that format text report output and buffer using Pages  |
|---------------|----------------------------------------------------------------------------------|
| *HTML*        |  Module of pure functions that format HTML report output and buffer using Pages  |
====================================================================================================

This file has a module of pure functions that format HTML report output, and buffer using Pages
class

***************************************************************************************************/
const pgs = require('./pages');
var pg;

function prLine(line, ofile) { 
  pg.addLine(ofile, line);
}
function prField(line, ofile, indentLev = 0) { 
  pg.addLine(ofile, '<h' + indentLev + '>' + line + '</h' + indentLev + '>');
}
function prListsAsLine(fields, lengths, ofile, tag = 'td') {

  const [op, cl] = ['<' + tag + '>', '</' + tag + '>'];
  const strings = fields.map( (f) => {return op + f + cl});
  let addStyle = '';
  if (fields[0].includes('*')) {
    addStyle = ' style="background-color: #E62A3E"';
  }
  prLine('<tr' + addStyle + '>' + strings.join ('') + '</tr>', ofile);
}
function prHTMLHeader(ofile, colors, isRoot = false) {

  let td = `
    td {
      font-weight: bold;
      border: 1px solid #030303;
      text-align: left;
      padding: 8px;
      white-space: pre;
      font-family: "Courier New", Courier, monospace
    }`;
  if (isRoot) {
    td = `
          td {
            font-weight: bold;
            border: 1px solid #030303;
            text-align: left;
            padding: 8px;
            white-space: pre;
            font-family: arial, sans-serif;
            font-size: 100%;
          }`;
  }

  prLine (
`<html>
<head>
<style>
table {
  font-family: arial, sans-serif;
  border-collapse: collapse;
  width: 100%;
}

th {
  background-color: #dddddd;
  border: 1px solid #030303;
  text-align: left;
  padding: 8px;
}` + td + 
`
h1 {margin-top: 0em; margin-bottom: 0em;
  font-family: arial, sans-serif;
  width: 100%;
  font-size: 300%;
  background-color: ` + colors.h1 + `;
}
h2 {margin-top: 0em; margin-bottom: 0em;
  font-family: arial, sans-serif;
  width: 100%;
  font-size: 200%;
  background-color: ` + colors.h2 + `;
}
h3 {margin-top: 0em; margin-bottom: 0em;
  font-family: arial, sans-serif;
  width: 100%;
  font-size: 150%;
  background-color: ` + colors.h3 + `;
}
h4 {margin-top: 0em; margin-bottom: 0em;
  font-family: arial, sans-serif;
  width: 100%;
  font-size: 125%;
  background-color: ` + colors.h4 + `;
}
</style>
</head>
<body>`,
ofile
);
}
function prHTMLFooter(ofile) {
  prLine('</body></html>', ofile);
}
function hdrLis(nOutGroups, fields, maxCatSet) { 
  return (maxCatSet == 0) ? [fields[0], fields[2], fields[3].replace('X', nOutGroups.toString()), fields[4]] :
                            [fields[0], fields[1], fields[2], fields[3].replace('X', nOutGroups.toString()), fields[4]];
}

const self = module.exports = {

  prRepHdr: (text, root, ofile, fields, nOutGroups, maxSce, maxCatSet, colors) => {
    pg = new pgs(ofile, root);
    prHTMLHeader(ofile, colors, true);
    prField(text, ofile, 1);
    self.prColHdrs(hdrLis(nOutGroups, fields, maxCatSet), [], ofile)
  },
  prRepFtr: (text, dates, ofile) => {
    prLine('</table>', ofile);
    prField(text, ofile, 1);
    prField(dates, ofile, 4);
    prHTMLFooter(ofile);
    pg.printPages();
  },
  prRepLin: (sfile, sceLin, ofile, nGroups, maxSce, maxCatSet) => {
    const hLink = '<a href="' + sfile + '" target="_blank">' + sceLin.sce + '</a>';
    const fields = (maxCatSet == 0) ? [sceLin.sceNum, hLink, sceLin.nFail, sceLin.status] :
                                      [sceLin.sceNum, sceLin.sceCatSet, hLink, sceLin.nFail, sceLin.status];
    self.prRec(fields, [], ofile);
  },
  prSceHdr: (text, ofile, colors) => {
    prHTMLHeader(ofile, colors);
    prField(text, ofile, 2);
  },
  prSceFtr: (text, ofile) => {
    prField(text, ofile, 2);
    prHTMLFooter(ofile);
  },
  prIOHdr: (text, ofile) => {
    prField(text, ofile, 3);
  },
  prGrpHdr: (text, grpIsEmpty, ofile) => {
    prField(text, ofile, 4);
  },
  prGrpFtr: (text, ofile) => {
    prLine('</table>', ofile);
    prField(text, ofile, 4);
  },
  prColHdrs: (fields, lengths, ofile) => {
    prLine('<table>', ofile);
    prListsAsLine(fields, lengths, ofile, 'th');
  },
  prRec: (fields, lengths, ofile) => {
    prListsAsLine(fields, lengths, ofile, 'td')
  }
}