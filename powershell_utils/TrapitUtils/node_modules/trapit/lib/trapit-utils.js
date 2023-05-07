"use strict";
/***************************************************************************************************
Name: trapit-utils.js                  Author: Brendan Furey                       Date: 18-Apr-2021

Component module in: The Math Function Unit Testing design pattern, implemented in nodejs.

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
| *TrapitUtils* |  Entry point module for JavaScript unit testing and drivers for formatting the   |
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
|  HTML         |  Module of pure functions that format HTML report output and buffer using Pages  |
====================================================================================================

This file has the entry point module for testUnit, the main functipn called by unit test scripts

***************************************************************************************************/
const [Utils,              Trapit,              fs           ] =
      [require('./utils'), require('./trapit'), require('fs')];
const DEFAULT_COLORS = {h1: '#FFFF00', h2: '#2AE6C1', h3: '#33F0FF', h4: '#7DFF33'}
const [DELIM, EXCEPTION_GRP] = 
      ['|',   'Unhandled Exception'];
  /***************************************************************************************************
  
  getUTOutGroups: Takes input expected and actual objects and returns the out property of the  
                  scenario with groups containing both expected and actual result lists
  
  ***************************************************************************************************/
function getUTOutGroups(expObj, actObj) {

  let retObj = {};
  for (let o in expObj) {
    retObj[o] = {
      exp : expObj[o],
      act : actObj[o]
    }
  }
  return retObj;
}
/***************************************************************************************************
  
getUTData: Read the input test data from JSON file, returning as object
  
***************************************************************************************************/
function getUTData(dataFile) {

  return JSON.parse(fs.readFileSync(dataFile, 'utf8'));
}
/***************************************************************************************************
  
callPWU: 
  
***************************************************************************************************/
function callPWU(delimiter, inp, out, purelyWrapUnit) {

  let actObj = {};
  try {
    actObj = purelyWrapUnit(inp);
    actObj[EXCEPTION_GRP] = [];
  } catch(e) {
    for(let o in out) {
      actObj[o] = [];
    }
    actObj[EXCEPTION_GRP] = [e.message + delimiter + e.stack];
  }
  return actObj;
}

/***************************************************************************************************
  
mkUTResultsFolder: Format unit test results JSON file via call to Trapit.mkUTResultsFolder
  
***************************************************************************************************/
function mkUTResultsFolder(fileName, extFolder, formatType, colors) {

  const testData = getUTData(fileName),
        [meta,          scenarios         ] = 
        [testData.meta, testData.scenarios];
  meta.testedDate = fs.statSync(fileName).mtime;
  return Trapit.mkUTResultsFolder(meta, scenarios, formatType, extFolder, colors);
}

const self = module.exports = {
  /***************************************************************************************************
  
  mkUTResultsFolderFromFile:  Format unit test results .json file
  
  ***************************************************************************************************/
  mkUTResultsFolderFromFile: (inpFile, formatType = 'B', colors = DEFAULT_COLORS) => {

    const extFolder = inpFile.split("/").slice(0, -1).join("/") + "/";
    return mkUTResultsFolder(inpFile, extFolder, formatType, colors);

  },
  /***************************************************************************************************
  
  mkUTExternalResultsFolders:  Format unit test results .json files in a folder
  
  ***************************************************************************************************/
  mkUTExternalResultsFolders: (extFolder, formatType = 'B', colors = DEFAULT_COLORS) => {

    let fileResults = [];

    fs.readdirSync(extFolder).forEach(file => {

      if ( /.*\.json$/.test(file) ) {
        fileResults.push({file: file, ...mkUTResultsFolder(extFolder + file, extFolder, formatType, colors)});
      }

    });
    
    return fileResults;

  },
  /***************************************************************************************************
  
  tabMkUTExternalResultsFolders:  Format unit test results .json files in a folder
  
  ***************************************************************************************************/
  tabMkUTExternalResultsFolders: (extFolder, formatType = 'B', colors = DEFAULT_COLORS) => {

    let failFiles = [],
        fileResults = self.mkUTExternalResultsFolders(extFolder + '/', formatType, colors);
    let [fileLen, titleLen, resFolderLen] = [4, 5, 6];

    console.log(Utils.heading('Unit Test Results Summary for Folder ' + extFolder));
    for (let r of fileResults) {
      if ( r.nFail ) {
        failFiles.push(r.file);
      }
      if(r.file.length > fileLen) {fileLen = r.file.length}
      if(r.resFolder.length > resFolderLen) {resFolderLen = r.resFolder.length}
      if(r.title.length > titleLen) {titleLen = r.title.length}
    }
    Utils.colHeaders( [
                       {name: ' File',  len: -(fileLen+1)},
                       {name: 'Title',  len: -titleLen},
                       {name: 'Inp Groups', len: 10},
                       {name: 'Out Groups', len: 10},
                       {name: 'Tests',  len: 5},
                       {name: 'Fails',  len: 5},
                       {name: 'Folder', len: -resFolderLen}
                ]).map(s => console.log(s));

    fileResults.map(r => [(r.nFail > 0 ? '*' : ' ') + Utils.lJust(r.file,    fileLen), 
                                                      Utils.lJust(r.title,   titleLen),
                                                      Utils.rJust(r.nInpGroups, 10),
                                                      Utils.rJust(r.nOutGroups, 10),
                                                      Utils.rJust(r.nTest,   5),
                                                      Utils.rJust(r.nFail,   5),
                                                      Utils.lJust(r.resFolder, resFolderLen)
                         ].join('  ')).map(s => console.log(s));
    console.log('\n' + failFiles.length + ' externals failed, see ' + extFolder + ' for scenario listings');
    failFiles.map(file => console.log(file));
    

  },
  /***************************************************************************************************
  
  testUnit: Main unit testing function, called like this:

                Trapit.testUnit('.\utils.json', '.\utils_out.json', purelyWrapUnit}

            This function creates the output JSON file with the help of two functions:
 
            - purelyWrapUnit is a function passed in from the client unit tester that returns an 
            object with result output groups consisting of lists of delimited strings
            - getUTOutGroups is a local private function that takes input expected and actual objects
            and returns the out property of the scenario with groups containing both expected and 
            actual result lists
   
  ***************************************************************************************************/
  testUnit: (inpFile, root, purelyWrapUnit, formatType = 'B', colors = DEFAULT_COLORS) => {

    const testData = getUTData(inpFile),
          [meta,          callScenarios] =
          [testData.meta, testData.scenarios];
    let delimiter = Trapit.getDelimiter();
    if (meta.delimiter != undefined) {delimiter = meta.delimiter};

    let scenarios = {};
    for (let s in callScenarios) {

      if (callScenarios[s].active_yn != 'N') { // optional in input json
        let out = callScenarios[s].out;
        out[EXCEPTION_GRP] = [];
        scenarios[s] = {  category_set : callScenarios[s].category_set,
                          inp          : callScenarios[s].inp,
                          out          : getUTOutGroups(out, callPWU(delimiter, callScenarios[s].inp, callScenarios[s].out, purelyWrapUnit))
//                          out          : getUTOutGroups(callScenarios[s].out, purelyWrapUnit(callScenarios[s].inp))
                       }
      }
    }
    meta.out[EXCEPTION_GRP] = ['Message', 'Stack']
    return Trapit.mkUTResultsFolder(meta, scenarios, formatType, root, colors);
  },
  fmtTestUnit: (inpFile, root, purelyWrapUnit, formatType = 'B', colors = DEFAULT_COLORS) => {

    console.log(Utils.heading('Unit Test Results Summary for Folder ' + root.substring(0, root.length - 1)));
    const r = self.testUnit(inpFile, root, purelyWrapUnit, formatType, colors);

    [
      ['File',       inpFile.substring(inpFile.lastIndexOf('/') + 1)],
      ['Title',      r.title],
      ['Inp Groups', r.nInpGroups],
      ['Out Groups', r.nOutGroups],
      ['Tests',      r.nTest],
      ['Fails',      r.nFail],
      ['Folder',     r.resFolder]
    ].map(t => console.log(Utils.lJust(t[0] + ':', 15) + t[1]));

  }
}
