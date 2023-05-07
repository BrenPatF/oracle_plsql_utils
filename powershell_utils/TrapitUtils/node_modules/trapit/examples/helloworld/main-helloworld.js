"use strict";
/***************************************************************************************************
Name: main-helloworld.js               Author: Brendan Furey                       Date: 10-Jun-2018

Component script in the JavaScript repository 'Trapit - JavaScript Unit Tester/Formatter'.

    GitHub: https://github.com/BrenPatF/trapit_nodejs_tester

The table shows the driver scripts for the relevant modules: There are two examples of use, with
main and test scripts; three scripts for formatting results from external (i.e. non-JavaScript) unit
tests; and a test script for the Trapit.getUTResults function.
====================================================================================================
|  Main/Test               | Unit Module   | Notes                                                 |
|==================================================================================================|
| *main-helloworld*        |               | Hello World program implemented as pure function to   |
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
|  test-getutresults       |                 Unit test script                                      |
====================================================================================================
This file contains a main script for a simple Hello World program implemented as a pure function to
allow for unit testing as a simple edge case.

To run from the root folder:

    $	node examples\helloworld\main-helloworld
***************************************************************************************************/
const Hw = require('./helloworld');
console.log(Hw.helloWorld());