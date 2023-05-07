"use strict";
/***************************************************************************************************
Name: colgroup.js                      Author: Brendan Furey                       Date: 10-Jun-2018

Component module in the JavaScript repository 'Trapit - JavaScript Unit Tester/Formatter'.

    GitHub: https://github.com/BrenPatF/trapit_nodejs_tester

The table shows the driver scripts for the relevant modules: There are two examples of use, with
main and test scripts; a main script for formatting results from external (i.e. non-JavaScript) unit
tests; and a test script for the Trapit.getUTResults function.
====================================================================================================
|  Main/Test          |  Unit Module | Notes                                                       |
|==================================================================================================|
|  main-helloworld    |              | Simple Hello World program implemented as a pure function   |
|  test-helloworld    |  helloWorld  | to allow for unit testing as a simple edge case             |
|---------------------|--------------|-------------------------------------------------------------|
|  main-colgroup      |              | Simple file-reading and group-counting module, with logging |
|  test-colgroup      | *ColGroup*   | to file. Example of testing impure units, and error display |
|---------------------|--------------|-------------------------------------------------------------|
|  format-externals   |              |                                                             |
|---------------------|  Trapit      | Entry point module for the unit test formatting functions   |
|                     |--------------|-------------------------------------------------------------|
|  test-getutresults  |  TrapitUtils | Entry point module for testUnit, the main function called   |
|                     |              | by JavaScript unit test scripts                             |
====================================================================================================
This file contains a simple file-reading and group-counting module, with logging to file. Example of 
testing impure units, and error display.
***************************************************************************************************/
const Utils = require ('../../lib/utils');
const fs = require('fs');
/***************************************************************************************************

_readList: Private function returns the key-value map of (string, count)

***************************************************************************************************/
function readList(file, delim, col) { // input file, field delimiter, 0-based column index
  const lines = fs.readFileSync(file).toString().trim().split("\n");//.shift()
  const firstLine = lines.shift();
  fs.appendFileSync(file + '.log', Date().substring(0, 24) + ": File " + file + ', delimiter \'' +
       delim + '\', column ' + col + "\n");
  var counter = new Map();
  for (const line of lines) {
    let val = line.split(delim)[col];
    let newVal = counter.get(val) + 1 || 1;
    if (val != undefined ) counter.set(val, newVal);
  }
  return counter;
}
class ColGroup {

  /***************************************************************************************************

  ColGroup: Constructor sets the key-value map of (string, count), and the maximum key length

  ***************************************************************************************************/
  constructor(file, delim, col) {
    this.file = file;
    this.delim = delim;
    this.col = col;
    this.counter = readList(file, delim, col);
    this.maxLen = this.counter.size ? Utils.maxLen (this.counter) : 0;
  }
  /***************************************************************************************************

  prList: Prints the key-value list of (string, count) sorted as specified

  ***************************************************************************************************/
  prList(sortBy, keyValues) { // sort by label, key-value list of (string, count)
  
    console.log(Utils.heading ('Counts sorted by '+sortBy));
    Utils.colHeaders([{name: 'Team', len : -this.maxLen}, {name : '#apps', len : 5}]).map(l => {console.log(l)});
    for (const kv of keyValues) {
      console.log((Utils.lJust(kv[0], this.maxLen) + '  ' + Utils.rJust(kv[1], 5))); 
    }
  };
  /***************************************************************************************************

  listAsIs: Returns the key-value list of (string, count) unsorted

  ***************************************************************************************************/
  listAsIs() {
    return [...this.counter];
  };
  /***************************************************************************************************

  sortByKey, sortByValue: Returns the key-value list of (string, count) sorted by key or value

  ***************************************************************************************************/
  sortByKey() {
    return Array.from(this.counter.entries()).sort(function(a, b) { return a[0] > b[0] ? 1 : -1; });
  };

  sortByValue() {
    return [...this.counter].sort(function(a, b) { return (a[1] - b[1]) || (a[0] > b[0] ? 1 : -1); });
  };
}
module.exports = ColGroup;