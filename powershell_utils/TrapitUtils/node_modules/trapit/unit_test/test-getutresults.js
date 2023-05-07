"use strict";
/***************************************************************************************************
Name: test-getutresults.js             Author: Brendan Furey                       Date: 10-Jun-2018

Component script in the JavaScript repository 'Trapit - JavaScript Unit Tester/Formatter'.

    GitHub: https://github.com/BrenPatF/trapit_nodejs_tester

The table shows the driver scripts for the relevant modules: There are two examples of use, with
main and test scripts; three scripts for formatting results from external (i.e. non-JavaScript) unit
tests; and a test script for the Trapit.getUTResults function.
====================================================================================================
|  Main/Test               | Unit Module   | Notes                                                 |
|==================================================================================================|
|  main-helloworld         |               | Hello World program implemented as pure function to   |
|  test-helloworld         |  helloWorld   | allow for unit testing as a simple edge case          |
|--------------------------|---------------|-------------------------------------------------------|
|  main-colgroup           |               | Simple file-reading/group-counting module, logging to |
|  test-colgroup           |  ColGroup     | file. Example of testing impure units, error display  |
|--------------------------|-----------------------------------------------------------------------|
|  format-external-file    |                 External formatting scripts                           |
|  format-external-folder  |-----------------------------------------------------------------------|
|  format-externals        |  Trapit       | Unit test formatting functions                        |
|--------------------------|  TrapitUtils  | Unit test entry points for scripts                    |
|                          |-----------------------------------------------------------------------|
| *test-getutresults*      |                 Unit test script                                      |
====================================================================================================
This file contains a unit test script for the getUTResults formatting function.

To run from the root folder:

    $ node unit_test\test-getutresults
***************************************************************************************************/
const Trapit = require('trapit');
const ROOT = __dirname + '/';
const [DELIM, SUB_DELIM, INPUT_JSON] = 
      ['|',   '~',       ROOT + 'getutresults.json'];
const [INP_TITLE,           INP_FIELDS,      OUT_FIELDS,       SCENARIOS,    INP_VALUES    ] = 
      ['Report',            'Input Fields',  'Output Fields',  'Scenarios',  'Input Values'],
      [EXP_VALUES,          ACT_VALUES,      OUT_VALUES,       SUMMARIES     ] = 
      ['Expected Values',   'Actual Values', 'Output Values',  'Summaries'   ],
      [EX_MESSAGE,          EX_STACK         ] = 
      ['Exception Message', 'Exception Stack'];

/***************************************************************************************************

setFldsRows: For each group, sets the group summary and the actuals fields and rows elements

***************************************************************************************************/
function setFldsRows(inpOrOut, // 'Input' or 'Output'
                     sce,      // scenario name
                     groups) { // groups object
  let [i_s, i_f, i_v] = [0, 0, 0];
  let [summaries, actFlds, actRows] = [[], [], []];
  let [nTest, nFail, status] = ['', '', ''];

  for (const g in groups) {
    const grp = groups[g];
    [nTest, nFail, status] = (inpOrOut == 'Input') ? ['', '', ''] : [grp.result.nTest, grp.result.nFail, grp.result.status];
    summaries[i_s++] = [
        inpOrOut + ' group', sce, g,
        grp.grpHdr, '', grp.grpFtr,
        nTest, nFail, status
    ].join(DELIM);

    for (const k in grp.val2Lis[0]) {
      actFlds[i_f++] = [sce, g, grp.val2Lis[0][k], grp.lenLis[k]].join(DELIM);
    }
    for (let k = 1; k < grp.val2Lis.length; k++) {
      actRows[i_v++] = [sce, g, grp.val2Lis[k].join(SUB_DELIM)].join(DELIM);
    }
  }
  return [summaries, actFlds, actRows];
}
/***************************************************************************************************

setOut: Returns output object of groups with arrays of actuals from the object returned by 
    Trapit.getUTResults, in the non-exception case

***************************************************************************************************/
function setOut(utOutput) { // object returned by Trapit.getUTResults
  let [summaries, actInpFlds, actOutFlds, actInpRows, actOutRows] = [[], [], [], [], []];
  let [summary, actFlds, actRows] = [[], [], []];

  summaries[0] = [
      'Report', '', '', 
      utOutput.repHdr, utOutput.catSetCol, utOutput.repFtr,
      utOutput.result.nTest, utOutput.result.nFail, utOutput.result.status
  ].join(DELIM);
  for (const s in utOutput.sceLis) {
    const sce = utOutput.sceLis[s];
    summaries[summaries.length] = [
        'Scenario', s, '',
        sce.sceHdr, sce.inpHdr + '-' + sce.outHdr, sce.sceFtr,
        sce.result.nTest, sce.result.nFail, sce.result.status
    ].join(DELIM);

    [summary, actFlds, actRows] = setFldsRows('Input', s, sce.inpGroups);
    summaries  =  summaries.concat(summary);
    actInpFlds = actInpFlds.concat(actFlds);
    actInpRows = actInpRows.concat(actRows);

    [summary, actFlds, actRows] = setFldsRows('Output', s, sce.outGroups);
    summaries  =  summaries.concat(summary);
    actOutFlds = actOutFlds.concat(actFlds);
    actOutRows = actOutRows.concat(actRows);
  }
  return {
      [SUMMARIES]  : summaries,
      [INP_FIELDS] : actInpFlds,
      [OUT_FIELDS] : actOutFlds,
      [INP_VALUES] : actInpRows,
      [OUT_VALUES] : actOutRows
  };
}
/***************************************************************************************************

setOutException: Returns output object of groups with arrays of actuals from the object returned by 
    Trapit.getUTResults, in the exception case

***************************************************************************************************/
function setOutException(s,            // scenario
                         exceptions) { // exception message and stack
  let actOutRows = [];
  actOutRows[0] = [s, EX_MESSAGE, exceptions[0]].join(DELIM);
  actOutRows[1] = [s, EX_STACK, exceptions[1]].join(DELIM);
  return {
      [SUMMARIES]  : [],
      [INP_FIELDS] : [],
      [OUT_FIELDS] : [],
      [INP_VALUES] : [],
      [OUT_VALUES] : actOutRows
  };
}
/***************************************************************************************************

addSce: Returns an object with a template scenario having empty arrays for each group

***************************************************************************************************/
function addSce(inpGroupNames,     // input group names
                outGroupNames,     // output group names
                lolSce,            // scenarios group list of lists (each row has name, active flag, category set)
                category_setInc) { // Include category set attribute Y/N
  let ret = {};
  for (const l of lolSce) {
    const s = l[0];
    ret[s] = {inp: {}, out: {}};
    if (category_setInc == 'Y') {
      ret[s].category_set = l[1];
    }
    for (const g of inpGroupNames) {
      ret[s].inp[g] = [];
    }
    for (const g of outGroupNames) {
      ret[s].out[g] = {exp: [], act: []};
    }
  }
  return ret;
}
/***************************************************************************************************

getGroups: Uses metadata groups with group name, field name pairs in delimited lists to return 
    object with group names and field lists

***************************************************************************************************/
function getGroups(fields) { // delimited group name, field name pairs

  const lol = fields.map((r) => r.split(DELIM));
  let ret = {};
  for (const r of lol) {
    const [g, f] = [r[0], r.slice(1)];
    if (g in ret) {
      ret[g] = ret[g].concat(f);
    } else {
      ret[g] = f;
    }
  }
  return ret;
}
/***************************************************************************************************

getInScenarios: Returns the input scenarios object

***************************************************************************************************/
function getInScenarios(inMeta,      // input metadata object, with inp and out properties
                        inpGroups,   // input groups object
                        repFields) { // report level fields: title, inclusion flags for active and category set
  function csvLisToLol(csvLis) { return csvLis.map((r) => r.split(DELIM)) };

  // Initialise arrays for inp/exp/act for meta groups for each sce
  let sce = addSce(Object.keys(inMeta.inp), Object.keys(inMeta.out), csvLisToLol(inpGroups[SCENARIOS]), repFields[1]);

  for (const r of csvLisToLol(inpGroups[INP_VALUES])) {
    const [s, g, v] = [r[0], r[1], r[2]];
    if (sce[s].inp[g] == undefined) sce[s].inp[g] = []; // edge-cases where group not in meta (exception)
    sce[s].inp[g].push(v.replace(SUB_DELIM, DELIM));
  }
  for (const r of csvLisToLol(inpGroups[EXP_VALUES])) {
    const [s, g, v] = [r[0], r[1], r[2]];
    if (sce[s].out[g] == undefined) sce[s].out[g] = {exp: [], act: []}; // ditto exp
    sce[s].out[g].exp.push(v.replace(SUB_DELIM, DELIM));
  }
  for (const r of csvLisToLol(inpGroups[ACT_VALUES])) {
    const [s, g, v] = [r[0], r[1], r[2]];
    if (sce[s].out[g] == undefined) sce[s].out[g] = {exp: [], act: []}; // ditto act
    sce[s].out[g].act.push(v.replace(SUB_DELIM, DELIM));
  }
  return sce;
}
/***************************************************************************************************

purelyWrapUnit: Wrapper function called by library function within a loop over scenarios to get the
    actuals from the inputs for that scenario. It returns an object with output groups as keys and
    actual values lists as values for a given scenario

***************************************************************************************************/
function purelyWrapUnit(inpGroups) { // input groups object

  let inMeta = {};
  let exceptions = [];
  let utOutput = {};
  const repFields = inpGroups[INP_TITLE][0].split(DELIM)
  inMeta.title = repFields[0];
  inMeta.inp = getGroups(inpGroups[INP_FIELDS]);
  inMeta.out = getGroups(inpGroups[OUT_FIELDS]);

  const inScenarios = getInScenarios(inMeta, inpGroups, repFields);
  try {
    utOutput = Trapit.getUTResults(inMeta, inScenarios);
  } catch(e) {
    return setOutException(inpGroups[EXP_VALUES][0].split(DELIM)[0], [e.message, e.stack]);
  }
  return setOut(utOutput);
}
Trapit.fmtTestUnit(INPUT_JSON, ROOT, purelyWrapUnit);