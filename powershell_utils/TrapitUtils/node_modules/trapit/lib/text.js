"use strict";
/***************************************************************************************************
Name: text.js                          Author: Brendan Furey                       Date: 10-Jun-2018

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
| *Text*        |  Module of pure functions that format text report output and buffer using Pages  |
|---------------|----------------------------------------------------------------------------------|
|  HTML         |  Module of pure functions that format HTML report output and buffer using Pages  |
====================================================================================================

This file has a module of pure functions that format text report output, and buffer using Pages

***************************************************************************************************/
const [Utils,              Pgs] =
      [require('./utils'), require('./pages')];
var pg;

function prLine(line, ofile, indentLev = 0) { 
  pg.addLine(ofile, line, indentLev);
}
function lengthLis(nOutGroups, maxSce, maxCatSet) { 
  return (maxCatSet == 0) ? [3, maxSce, 11 + nOutGroups.toString().length, 7] :
                            [3, maxCatSet, maxSce, 11 + nOutGroups.toString().length, 7];
}
function hdrLis(nOutGroups, fields, maxCatSet) { 
  return (maxCatSet == 0) ? [fields[0], fields[2], fields[3].replace('X', nOutGroups.toString()), fields[4]] :
                            [fields[0], fields[1], fields[2], fields[3].replace('X', nOutGroups.toString()), fields[4]];
}
function prListsAsLine(fields, lengths, ofile, indent) {

  const strings = [...fields.keys()].map( (j) => { return Utils.lJust(fields[j], lengths[j]) });
  prLine(strings.join('  '), ofile, indent);
  return strings;
}

const self = module.exports = {

  prHeading: (text, ofile, indent = 0) => {
    prLine(text, ofile, indent);
    prLine('='.repeat(text.length), ofile, indent);
  },
  prRepHdr: (text, root, ofile, fields, nGroups, maxSce, maxCatSet) => {
    pg = new Pgs(ofile, root);
    self.prHeading(text, ofile, 0);
    self.prColHdrs(hdrLis(nGroups, fields, maxCatSet), lengthLis(nGroups, maxSce, maxCatSet), ofile, 2)
  },
  prRepFtr: (text, dates, ofile) => {
    prLine('', ofile);
    self.prHeading(text, ofile, 0);
    prLine(dates, ofile, 0);
    pg.printPagesRoot();
  },
  prRepLin: (sfile, sceLin, ofile, nGroups, maxSce, maxCatSet) => {
    const fields = (maxCatSet == 0) ? [sceLin.sceNum, sceLin.sce, sceLin.nFail, sceLin.status] :
                                      [sceLin.sceNum, sceLin.sceCatSet, sceLin.sce, sceLin.nFail, sceLin.status];
    self.prRec(fields, lengthLis(nGroups, maxSce, maxCatSet), ofile, 2);
  },
  prSceHdr: (text, ofile) => {
    prLine('', ofile);
    self.prHeading(text + ' {', ofile, 0);
  },
  prSceFtr: (text, ofile) => {
    prLine('', ofile);
    self.prHeading('} ' + text, ofile, 0);
  },
  prIOHdr: (text, ofile) => {
    prLine('', ofile);
    self.prHeading(text, ofile, 1);
  },
  prGrpHdr: (text, nonEmpty, ofile) => {
    const br = nonEmpty ? ' {' : '';
    prLine('', ofile);
    self.prHeading(text + br, ofile, 2);
  },
  prGrpFtr: (text, ofile) => {
    let br = '}';
    if (text != '') {
      br = br + ' ';
    }
    prLine('', ofile);
    self.prHeading(br + text, ofile, 2);
  },
  prColHdrs: (fields, lengths, ofile, indent = 4) => {
    prLine('', ofile);
    const strings = prListsAsLine(fields, lengths, ofile, indent);
    const unders = strings.map((s) => { return '-'.repeat(s.length) })
    prLine(unders.join('  '), ofile, indent);
  },
  prRec: (fields, lengths, ofile, indent = 4) => {
    prListsAsLine(fields, lengths, ofile, indent);
  }
}