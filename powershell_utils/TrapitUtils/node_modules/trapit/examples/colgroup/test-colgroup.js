'use strict';
/***************************************************************************************************
Name: test-colgroup.js                 Author: Brendan Furey                       Date: 10-Jun-2018

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
| *test-colgroup*          |  ColGroup     | file. Example of testing impure units, error display  |
|--------------------------|-----------------------------------------------------------------------|
|  format-external-file    |                 External formatting scripts                           |
|  format-external-folder  |-----------------------------------------------------------------------|
|  format-externals        |  Trapit       | Unit test formatting functions                        |
|--------------------------|  TrapitUtils  | Unit test entry points for scripts                    |
|                          |-----------------------------------------------------------------------|
|  test-getutresults       |                 Unit test script                                      |
====================================================================================================
This file contains a unit test script for a simple file-reading and group-counting module, with
logging to file. Note that this example has two deliberate errors to show how these are displayed.

To run from the root folder:

    $ node examples\colgroup\test-colgroup
***************************************************************************************************/
const [ColGroup,               Trapit,            fs           ] =
      [require('./colgroup'),  require('trapit'), require('fs')],
      [DELIM,                  ROOT,                 ] = 
      ['|',                    __dirname + '/'];

const [INPUT_JSON,             INPUT_FILE,            LOG_FILE                 ] =
      [ROOT + 'colgroup.json', ROOT + 'ut_group.csv', ROOT + 'ut_group.csv.log'];

const [GRP_LOG,   GRP_SCA,   GRP_LIN, GRP_LAI,    GRP_SBK,     GRP_SBV      ]  =
      ['Log',     'Scalars', 'Lines', 'listAsIs', 'sortByKey', 'sortByValue'];

const DEFAULT_COLORS = {h1: '#FFFF00', h2: '#2AE6C1', h3: '#33F0FF', h4: '#7DFF33'};
let colors = DEFAULT_COLORS;
colors.h2 = '#FFFF00';

function fromCSV(csv, col) {return csv.split(DELIM)[col]};
function joinTuple(t) {return t.join(DELIM)}

function setup(inp) {
  fs.writeFileSync(INPUT_FILE, inp[GRP_LIN].join('\n'));
  if (inp[GRP_LOG].length > 0) {
    fs.writeFileSync(LOG_FILE, inp[GRP_LOG].join('\n') + '\n');
  }
  return new ColGroup(INPUT_FILE, fromCSV(inp[GRP_SCA][0], 0), fromCSV(inp[GRP_SCA][0], 1));
}
function teardown() {
  fs.unlinkSync(INPUT_FILE);
  fs.unlinkSync(LOG_FILE);
}
function sleep(time) { // sleep time in ms
  const stop = Date.now();
  while (Date.now() < stop + +time) {
    ;
  }
}
function purelyWrapUnit(inpGroups) {
  if (fromCSV(inpGroups[GRP_SCA][0], 2) == 'Y') {
    throw new Error('Error thrown');
  }
  const colGroup = setup(inpGroups);

  const linesArray = String(fs.readFileSync(LOG_FILE)).split('\n'),
        lastLine   = linesArray[linesArray.length - 2],
        text       = lastLine,
        date       = lastLine.substring(0, 24),
        logDate    = new Date(date),
        now        = new Date(),
        diffDate   = now.getTime() - logDate.getTime();

  teardown();
  sleep(100);
  return {
    [GRP_LOG] : [(linesArray.length - 1) + DELIM + diffDate + DELIM + text],
    [GRP_LAI] : [colGroup[GRP_LAI]().length.toString()],
    [GRP_SBK] : colGroup[GRP_SBK]().map(joinTuple),
    [GRP_SBV] : colGroup[GRP_SBV]().map(joinTuple)
  };
}
Trapit.fmtTestUnit(INPUT_JSON, ROOT, purelyWrapUnit, 'B', colors);