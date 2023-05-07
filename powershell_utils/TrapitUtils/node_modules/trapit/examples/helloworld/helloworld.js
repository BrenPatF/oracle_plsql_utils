"use strict";
/***************************************************************************************************
Name: helloworld.js                    Author: Brendan Furey                       Date: 10-Jun-2018

Component module in the JavaScript repository 'Trapit - JavaScript Unit Tester/Formatter'.

    GitHub: https://github.com/BrenPatF/trapit_nodejs_tester

The table shows the driver scripts for the relevant modules: There are two examples of use, with
main and test scripts; a main script for formatting results from external (i.e. non-JavaScript) unit
tests; and a test script for the Trapit.getUTResults function.
====================================================================================================
|  Main/Test          |  Unit Module | Notes                                                       |
|==================================================================================================|
|  main-helloworld    |              | Simple Hello World program implemented as a pure function   |
|  test-helloworld    | *helloWorld* | to allow for unit testing as a simple edge case             |
|---------------------|--------------|-------------------------------------------------------------|
|  main-colgroup      |              | Simple file-reading and group-counting module, with logging |
|  test-colgroup      |  ColGroup    | to file. Example of testing impure units, and error display |
|---------------------|--------------|-------------------------------------------------------------|
|  format-externals   |              |                                                             |
|---------------------|  Trapit      | Entry point module for the unit test formatting functions   |
|                     |--------------|-------------------------------------------------------------|
|  test-getutresults  |  TrapitUtils | Entry point module for testUnit, the main function called   |
|                     |              | by JavaScript unit test scripts                             |
====================================================================================================
This file contains a module for a simple Hello World program implemented as a pure function to allow
for unit testing as a simple edge case.
***************************************************************************************************/
module.exports = {
	helloWorld: () => {return 'Hello World!'}
}