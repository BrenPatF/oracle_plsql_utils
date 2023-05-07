"use strict";
/***************************************************************************************************
Name: main-colgroup.js                 Author: Brendan Furey                       Date: 10-Jun-2018

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
| *main-colgroup*          |               | Simple file-reading/group-counting module, logging to |
|  test-colgroup           |  ColGroup     | file. Example of testing impure units, error display  |
|--------------------------|-----------------------------------------------------------------------|
|  format-external-file    |                 External formatting scripts                           |
|  format-external-folder  |-----------------------------------------------------------------------|
|  format-externals        |  Trapit       | Unit test formatting functions                        |
|--------------------------|  TrapitUtils  | Unit test entry points for scripts                    |
|                          |-----------------------------------------------------------------------|
|  test-getutresults       |                 Unit test script                                      |
====================================================================================================
This file contains a main script for a simple file-reading and group-counting module, with logging
to file.

To run from the root folder:

    $ node examples\colgroup\main-colgroup
***************************************************************************************************/
const ColGroup = require('./colgroup');
const [INPUT_FILE, 													                   DELIM, COL] = 
      [__dirname + '/fantasy_premier_league_player_stats.csv', ',',   6];

let grp = new ColGroup(INPUT_FILE, DELIM, COL);

grp.prList('(as is)', grp.listAsIs());
grp.prList('key', grp.sortByKey());
grp.prList('value', grp.sortByValue());