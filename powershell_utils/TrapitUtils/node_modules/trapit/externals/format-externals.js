"use strict";
/***************************************************************************************************
Name: format-externals.js              Author: Brendan Furey                       Date: 05-Jul-2018

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
| *format-externals*       |  Trapit       | Unit test formatting functions                        |
|--------------------------|  TrapitUtils  | Unit test entry points for scripts                    |
|                          |-----------------------------------------------------------------------|
|  test-getutresults       |                 Unit test script                                      |
====================================================================================================
This file contains a unit test formatting driver program for JSON output files that are externally
sourced. The trapit package can be used to facilitate unit testing in *any* language, so long as the
same design pattern is followed, and the test driver program outputs a JSON file in the required
format.

This program loops over all .json files in a specified folder and creates results files formatted in
HTML and text in a subfolder named from the unit test title. The source JSON files contain a meta 
object and a scenarios object in a standard data model.

To run from the root folder:

    $ node externals\test-externals subFolder

where:

- subFolder = subfolder (of externals folder) for JSON files, and where the results output files are
              to be written, in subfolders with names based on the report titles
***************************************************************************************************/
const [subFolder,       Trapit           ] =
      [process.argv[2], require('trapit')];
const DEFAULT_COLORS = {h1: '#FFFF00', h2: '#2AE6C1', h3: '#33F0FF', h4: '#7DFF33'};
let colors = DEFAULT_COLORS;
//colors.h2 = '#a232a8';
Trapit.tabMkUTExternalResultsFolders(__dirname + (subFolder === undefined ? '' : '\\' + subFolder), 'B', colors); // H/T/B : Format in HTML/Text/Both