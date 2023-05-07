"use strict";
/***************************************************************************************************
Name: trapit.js                        Author: Brendan Furey                       Date: 10-Jun-2018

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
|  TrapitUtils  |  Entry point module for JavaScript unit testing and drivers for formatting the   |
|               |  externally-sourced results read from JSON files                                 |
|---------------|----------------------------------------------------------------------------------|
| *Trapit*      |  Module for the unit test formaatting functions, written with core pure          |
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

This file has the entry point module for the unit test formaatting functions, written with core pure
functions to enable unit testing, and easily allow for multiple reporters. See the examples in the
examples folder, and unit test in test folder

***************************************************************************************************/
const [Utils,              Text,              Html             ] = 
      [require('./utils'), require('./text'), require('./html')];

const [DELIM, UNTESTED] = 
      ['|',   'UNTESTED'];

const BOILER = {
        sceHdr         : 'SCENARIO $1: $2',
        sceHdrCatSet   : ' [Category Set: $1]',
        sceFtr         : '$1 failed of $2: $3',
        inputs         : 'INPUTS',
        outputs        : 'OUTPUTS',
        grpHdr         : 'GROUP $1: $2',
        emptyInpGrpHdr : 'GROUP $1: $2: Empty',
        emptyOutGrpHdr : 'GROUP $1: $2: Empty as expected: SUCCESS',
        inpGrpFtr      : '',
        outGrpFtr      : '$1 failed of $2: $3',
        errFlag        : '*',
        recNo          : '#',
        success        : 'SUCCESS',
        failure        : 'FAILURE',
        repHdr         : 'Unit Test Report: $1',
        repFtr         : 'Test scenarios: $1 failed of $2: $3',
        tstDate        : 'Tested: $1',
        fmtDate        : 'Formatted: $1'
};
const ROOT_HDRS = ['#', 'Category Set', 'Scenario', 'Fails (of X)', 'Status'];

/***************************************************************************************************

csvToLis: Returns array by splitting csv string on delimiter

***************************************************************************************************/
function csvToLis(delimiter, csv) {return csv.split(delimiter)}
/***************************************************************************************************

expRepRegex: Checks expected values for keywords, and processes accordingly, returning possibly
             updated expected and actual records

***************************************************************************************************/
function expRepRegex(delimiter, exp, act) {
  const [expLis,                   actLis                   ] = 
        [csvToLis(delimiter, exp), csvToLis(delimiter, act)];
  let [repExpLis, repActLis] = [[], []];
  for (const i in expLis) {
    repExpLis[i] = expLis[i];
    repActLis[i] = actLis[i];
    if (expLis[i].trim() === UNTESTED) { 
      repExpLis[i] = UNTESTED + ': ' + actLis[i];
      repActLis[i] = repExpLis[i];
    } else if (expLis[i].length > 7 && expLis[i].substring(0, 4) === 'IN [') {
      let rPair = expLis[i].substring(4, expLis[i].length - 1).split(',').map(s => s.trim());
      repExpLis[i] = repExpLis[i] + ': ' + actLis[i];
      if (actLis[i].length === 0 || actLis[i] < +rPair[0] || actLis[i] > +rPair[1]) {
        repActLis[i] = 'NOT ' + repExpLis[i];
      } else {
        repActLis[i] = repExpLis[i];
      }
    } else if (expLis[i].length > 8 && expLis[i].substring(0, 6).trim() === 'LIKE /') {
      let regex = new RegExp(expLis[i].substring(6, expLis[i].length - 1));
      repExpLis[i] = repExpLis[i] + ': ' + actLis[i];
      if (regex.test(actLis[i])) {
        repActLis[i] = repExpLis[i];
      } else {
        repActLis[i] =  'NOT ' + repExpLis[i];
      }
    }
  }
  return [repExpLis.join(delimiter), repActLis.join(delimiter)];
}
/***************************************************************************************************

mkOutObj: Returns the input object

***************************************************************************************************/
function mkInpObj(delimiter, inp, groups) {
  let inpGroups = {}, i = 0,
      csvToLisD = x => csvToLis(delimiter, x);
  for (let g in groups)  {
    let fields = groups[g].slice(); 
    fields.unshift(BOILER.recNo);
    let val2Lis = Object.keys(inp[g]).map( (i) => {return (+ i + 1) + delimiter + inp[g][i]})
        .map(csvToLisD);
    let lenLis = val2Lis.reduce( (a, b) => {
      return [...a.keys()].map(k => (a[k].length > b[k].length ? a[k] : b[k]));
    }, fields).map(s => s.length);
    val2Lis.unshift(fields);
    let grpHdr = (val2Lis.length === 1) ? BOILER.emptyInpGrpHdr : BOILER.grpHdr;
    inpGroups[g] = {
        grpHdr  : grpHdr.replace('$1', ++i).replace('$2', g),
        grpFtr  : BOILER.inpGrpFtr,
        val2Lis : val2Lis,
        lenLis  : lenLis
    };
  }
  return inpGroups;
}
/***************************************************************************************************

mkOutObj: Returns the output object

***************************************************************************************************/
function mkOutObj(delimiter, out, groups) {

  let sceResult = {nTest : Object.keys(out).length, nFail : 0, status : BOILER.success};
  let outGroups = {}, i = 0,
      csvToLisD = x => csvToLis(delimiter,x);
  for (let g in groups)  {

    let fields = groups[g].slice(); 
    fields.unshift(BOILER.recNo);
    let [exp, act] = [out[g].exp.slice(), out[g].act.slice()];
    let [lenLis, val2Lis, valLis, result] = [[], [[]], [], {}];
    let [nFail, nTest] = [0, 0];
    let status = BOILER.success;
    if (exp.length > 0 || act.length > 0) {

      let lenDif = exp.length - act.length;
      if (lenDif != 0) {

        let exRec = exp.length > act.length ? exp[0] : act[0];
        let padRec = '*NO RECORD*' + exRec.replace(new RegExp('[^\\' + delimiter + ']', 'g'), '');
        if (lenDif > 0) {
          for (let j = 0; j < lenDif; j++) {act.push(padRec)};
        } else {
          for (let j = 0; j < - lenDif; j++) {exp.push(padRec)};
        }
      }
      for (let j = 0; j < exp.length; j++) {
        const [expStr, actStr] = [...expRepRegex(delimiter, exp[j], act[j])];
        valLis.push(expStr);
        if (actStr != expStr) {
          valLis.push(actStr);
          valLis[valLis.length - 2] = (j + 1) +  delimiter + valLis[valLis.length - 2];
          valLis[valLis.length - 1] = (j + 1) + BOILER.errFlag + delimiter + valLis[valLis.length - 1];
          nFail++;
          status = BOILER.failure;
        } else {
          valLis[valLis.length - 1] = (j + 1) + delimiter + valLis[valLis.length - 1];
        };
      }
      if (nFail > 0) {
        sceResult.status = BOILER.failure;
        sceResult.nFail++;
      };
      nTest = Math.max(exp.length, act.length);
      val2Lis = valLis.map(csvToLisD);
      lenLis = val2Lis.reduce( (a, b) => {
        return [...a.keys()].map(k => (a[k].length > b[k].length ? a[k] : b[k]));
      }, fields).map(s => s.length);
    }
    let grpHdr = (nTest === 0) ? BOILER.emptyOutGrpHdr : BOILER.grpHdr;
    val2Lis.unshift(fields);
    outGroups[g] = {
        grpHdr  : grpHdr.replace('$1', ++i).replace('$2', g),
        grpFtr  : BOILER.outGrpFtr.replace('$1', nFail).replace('$2', nTest).replace('$3', status),
        val2Lis : val2Lis,
        lenLis  : lenLis,
        result  : {nTest : nTest, nFail : nFail, status : status}
    };
  }
  return {outGroups: outGroups, result: sceResult};
}
/***************************************************************************************************

getCallScenarios: Gets the call scenarios

***************************************************************************************************/
function getCallScenarios(scenarios) {
  let callScenarios = {};
  for (const s in scenarios) {
    callScenarios[s] = {inp: scenarios[s].inp, out: {}};
    for (const g in scenarios[s].out) {
      callScenarios[s].out[g] = scenarios[s].out[g].act.slice();
    }
  }
  return callScenarios;
}
/***************************************************************************************************

prInputs: Debugging method that prints the input objects

***************************************************************************************************/
function prInputs(meta, scenarios) {
  console.log('{ "meta": ' + JSON.stringify(meta, null, 4) + ',');
  const callScenarios = getCallScenarios(scenarios);
  console.log('"scenarios" : { ');
  const nSce = Object.keys(callScenarios).length;
  let n_s = 0;
  for (const s in callScenarios) {
    console.log('"' + s + '": ', 1);
    console.log(JSON.stringify(callScenarios[s], null, 4), 1);
    if (++n_s < nSce) {console.log(',')};
  }
  console.log('}}');
  console.log('"Full scenarios" : { ');
  n_s = 0;
  for (const s in scenarios) {
    let comma;
    console.log('"' + s + '": ' + JSON.stringify(scenarios[s], null, 4), 1);
    if (++n_s == nSce) {comma = '}'} else  {comma = ','};
    console.log('}}' + comma);
  }
  console.log('}}');
}
/***************************************************************************************************

chkRec: Checks records for numbers of fields

***************************************************************************************************/
function chkRec(delimiter, s, g, r, nFields, typ) {
//  console.log('chkRec, [s: ' + s + ', g: ' + g + ', r: ' + r + ', delimiter: ' + delimiter + ']');
  if (csvToLis(delimiter, r).length != nFields) {
    throw new Error('Error, ' + typ + ' #fields ' + csvToLis(delimiter, r).length + ', expected ' + nFields +
      ' [s: ' + s + ', g: ' + g + ', r: ' + r + ']');
  }
}
/***************************************************************************************************

chkGrpLen: Checks group lengths match metadata

***************************************************************************************************/
function chkGrpLen(expGrps, actGrps, s) {
  const [expLen, actLen] = [Object.keys(expGrps).length, Object.keys(actGrps).length];
  if (actLen != expLen) {
    throw new Error('Error, s: ' + s + ': expected #groups = ' + expLen + ', actual #groups = ' +
                    actLen);
  }
}
/***************************************************************************************************

chkOutGrp: Checks output groups

***************************************************************************************************/
function chkOutGrp(out, s, g) {

  if (out === undefined) {
    throw new Error('Error, ' + '*** s: g: ' + s + ': ' + g + ': output group undefined');
  }
  if (out.exp === undefined) {
    throw new Error('Error, ' + '*** s: g: ' + s + ': ' + g + ': exp object undefined');
  }
  if (out.act === undefined) {
    throw new Error('Error, ' + '*** s: g: ' + s + ': ' + g + ': act object undefined');
  }
}
/***************************************************************************************************

chkInputs: Validates the inputs, throwing errors when invalid via calls to:
           chkGrpLen - checks group lengths match metadata
           chkRec    - checks records for numbers of fields
           chkOutGrp - checks output groups

***************************************************************************************************/
function chkInputs(delimiter, meta, scenarios) {

  //prInputs(meta, scenarios); uncomment to get meta + actuals in json fmt sent to stdout
  for (const s in scenarios) {
    chkGrpLen(meta.inp, scenarios[s].inp, 'Inp: ' + s);
    chkGrpLen(meta.out, scenarios[s].out, 'Out: ' + s);
  }
  for (const g in meta.inp) {
    const nFields = meta.inp[g].length;
    for (const s in scenarios) {
      for (const r of scenarios[s].inp[g]) {
        chkRec(delimiter, s, g, r, nFields, 'inp');
      }
    }
  }
  for (const g in meta.out) {
    const nFields = meta.out[g].length;
    for (const s in scenarios) {
      chkOutGrp(scenarios[s].out[g], s, g);
      for (const r of scenarios[s].out[g].exp) {
        chkRec(delimiter, s, g, r, nFields, 'exp');
      }
      for (const r of scenarios[s].out[g].act) {
        chkRec(delimiter, s, g, r, nFields, 'act');
      }
    }
  }
}
/***************************************************************************************************

_mkUTResultsFolder: Private function called by the public methods to print results to files.Parameters:
              results - results object created by getUTResults
              ext     - file extensions
              p       - module containing functions used in printing in either text or html format

***************************************************************************************************/
function _mkUTResultsFolder(results, ext, p, rootFolder, colors) {
  const root = results.result.resFolder,
        ifile = root + ext;
  const maxSce = Math.max(ROOT_HDRS[2].length, Object.keys(results.sceLis).reduce( (a, b) => { return a.length > b.length ? a : b; }).length);
  const maxCatSetRows = Object.keys(results.sceLis).map(s => results.sceLis[s].sceLin.sceCatSet).reduce( (a, b) => { return a.length > b.length ? a : b; }).length;
  const maxCatSet = (maxCatSetRows == 0) ? 0 : Math.max(ROOT_HDRS[1].length, maxCatSetRows);
  p.prRepHdr(results.repHdr, rootFolder + root, ifile, ROOT_HDRS, results.nOutGroups, maxSce, maxCatSet, colors);
  for (const s in results.sceLis) {
    const sfile = Utils.repSpaces(s) + ext;
    const sceObj = results.sceLis[s];
    const [inpGroups, outGroups] = [sceObj.inpGroups, sceObj.outGroups];
    p.prSceHdr(sceObj.sceHdr, sfile, colors);
    p.prIOHdr(sceObj.inpHdr, sfile);
    for (const g in inpGroups) {
      const [val2Lis, lenLis] = [inpGroups[g].val2Lis, inpGroups[g].lenLis]
      p.prGrpHdr(inpGroups[g].grpHdr, val2Lis.length > 1, sfile);
      if (val2Lis.length > 1) {
        p.prColHdrs(val2Lis[0], lenLis, sfile);
        for (let k = 1; k < val2Lis.length; k++) {
          p.prRec(val2Lis[k], lenLis, sfile);
        }
        p.prGrpFtr(inpGroups[g].grpFtr, sfile);
      }
    }
    p.prIOHdr (sceObj.outHdr, sfile);
    for (const g in outGroups)  {
      const [val2Lis, lenLis] = [outGroups[g].val2Lis, outGroups[g].lenLis]
      p.prGrpHdr(outGroups[g].grpHdr, outGroups[g].result.nTest > 0, sfile);
      if (outGroups[g].result.nTest > 0) {
        p.prColHdrs(val2Lis[0], lenLis, sfile);
        for (let k = 1; k < val2Lis.length; k++) {
          p.prRec(val2Lis[k], lenLis, sfile);
        }
        p.prGrpFtr(outGroups[g].grpFtr, sfile);
      }
    }
    p.prRepLin(sfile, sceObj.sceLin, ifile, results.nOutGroups, maxSce, maxCatSet);
    p.prSceFtr(sceObj.sceFtr, sfile);
  }
  p.prRepFtr(results.repFtr, results.dates, ifile);
}
const self = module.exports = {
  getDelimiter: () => {return DELIM;},
  /*************************************************************************************************

  getUTResults: Get results, returning as object called by the mkUTResultsFolder* printing methods

  *************************************************************************************************/
  getUTResults: (meta, scenarios) => {
    let delimiter = self.getDelimiter();
    if (meta.delimiter != undefined) {delimiter = meta.delimiter};
    chkInputs(delimiter, meta, scenarios);
    const result = {nTest : Object.keys(scenarios).length, nFail : 0, status : BOILER.success, 
    	resFolder: Utils.repSpaces(meta.title)};
    let sceLis = {};
    let i = 0;
    let catSetCol = '';
    for (const s in scenarios) {
      sceLis[s] = {};
      sceLis[s].sceHdr = BOILER.sceHdr.replace('$1', ++i).replace('$2', s);
      if (scenarios[s].category_set) {
        sceLis[s].sceHdr += BOILER.sceHdrCatSet.replace('$1', scenarios[s].category_set);
        catSetCol = 'Category Set';
      } 
//                         (scenarios[s].category_set ? BOILER.sceHdrCatSet.replace('$1', scenarios[s].category_set) : '');
      sceLis[s].inpHdr = BOILER.inputs;
      sceLis[s].outHdr = BOILER.outputs;
      sceLis[s].inpGroups = mkInpObj(delimiter, scenarios[s].inp, meta.inp);

      const outObj = mkOutObj(delimiter, scenarios[s].out, meta.out);
      sceLis[s].outGroups = outObj.outGroups;
      sceLis[s].result = outObj.result;
      sceLis[s].sceFtr = BOILER.sceFtr.replace('$1', outObj.result.nFail)
                                      .replace('$2', outObj.result.nTest)
                                      .replace('$3', outObj.result.status);
      let sceNum = i.toString();
      if (outObj.result.nFail > 0) {
        sceNum += '*';
      }
      sceLis[s].sceLin = {
        sceNum    : sceNum,
        sceCatSet : scenarios[s].category_set || "",
        sce       : s,
        nFail     : outObj.result.nFail,
        nTest     : outObj.result.nTest,
        status    : outObj.result.status
      };
      if (outObj.result.nFail > 0) {
        result.status = BOILER.failure;
        result.nFail++;
      };
    }
    const dateObj = new Date();
    let dateStr = BOILER.fmtDate.replace('$1', dateObj.toISOString().replace('T', ' ').slice(0, -5));
    if (meta.testedDate != undefined) {
      dateStr = BOILER.tstDate.replace('$1', dateObj.toISOString().replace('T', ' ').slice(0, -5)) +
        ', ' + dateStr;
    }
    return {
        title      : meta.title,
        catSetCol  : catSetCol,
        sceLis     : sceLis,
        nInpGroups : Object.keys(meta.inp).length,
        nOutGroups : Object.keys(meta.out).length,
        result     : result,
        repHdr     : BOILER.repHdr.replace('$1', meta.title),
        repFtr     : BOILER.repFtr.replace('$1', result.nFail)
                               .replace('$2', result.nTest)
                               .replace('$3', result.status),
        dates      : dateStr
//                                 .replace('$2', Date().substring(0,24))
    };
  },
  /*************************************************************************************************

  mkUTResultsFolder: Print results in text or html format, or both

  *************************************************************************************************/
  mkUTResultsFolder: (meta, scenarios, formatType, rootFolder, colors) => {
    const results = self.getUTResults(meta, scenarios);

    if (formatType == 'H' || formatType == 'B') {_mkUTResultsFolder(results, '.html', Html, rootFolder, colors);}
    if (formatType == 'T' || formatType == 'B') {_mkUTResultsFolder(results, '.txt', Text, rootFolder);}

    return {
      nTest      : results.result.nTest,
      nFail      : results.result.nFail,
      status     : results.result.status,
      resFolder  : results.result.resFolder,
      nInpGroups : results.nInpGroups,
      nOutGroups : results.nOutGroups,
      title      : results.title
    };
  }
}