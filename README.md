# Utils
<img src="mountains.png">
Oracle PL/SQL general utilities module.

:hammer_and_wrench:

This module comprises a set of generic user-defined Oracle types and a PL/SQL package of functions and procedures of general utility. It includes functions and procedures for:
- 'pretty-printing'
- returning records from cursors or views/tables as lists of delimited strings
- joining lists of values into delimited strings, and the converse splitting operation

This module is a prerequisite for these other Oracle GitHub modules:
- [Trapit - Oracle PL/SQL unit testing module](https://github.com/BrenPatF/trapit_oracle_tester)
- [Log_Set - Oracle logging module](https://github.com/BrenPatF/log_set_oracle)
- [Timer_Set - Oracle PL/SQL code timing module](https://github.com/BrenPatF/timer_set_oracle)

The package is tested using the Math Function Unit Testing design pattern, with test results in HTML and text format included (see `test_data\test_output` for the unit test results folder).

The module also comes with usage examples.

## In this README...
- [Usage (extract from main_col_group.sql)](https://github.com/BrenPatF/oracle_plsql_utils#usage-extract-from-main_col_groupsql)
- [API - Utils](https://github.com/BrenPatF/oracle_plsql_utils#api---utils)
- [Installation](https://github.com/BrenPatF/oracle_plsql_utils#installation)
- [Unit Testing](https://github.com/BrenPatF/oracle_plsql_utils#unit-testing)
- [Operating System/Oracle Versions](https://github.com/BrenPatF/oracle_plsql_utils#operating-systemoracle-versions)

## Usage (extract from main_col_group.sql)
- [&uarr; In this README...](https://github.com/BrenPatF/oracle_plsql_utils#in-this-readme)

```sql
DECLARE
  l_res_arr              chr_int_arr;
BEGIN

  Col_Group.Load_File(p_file   => 'fantasy_premier_league_player_stats.csv', 
                      p_delim  => ',', 
                      p_colnum => 7);
  l_res_arr := Col_Group.List_Asis;
  Utils.W(p_line_lis => Utils.Heading(p_head => 'As Is'));

  Utils.W(p_line_lis => Utils.Col_Headers(p_value_lis => chr_int_arr(chr_int_rec('Team', 30), 
                                                                     chr_int_rec('Apps', -5)
  )));

  FOR i IN 1..l_res_arr.COUNT LOOP
    Utils.W(p_line => Utils.List_To_Line(
                          p_value_lis => chr_int_arr(chr_int_rec(p_res_arr(i).chr_value, 30), 
                                                     chr_int_rec(p_res_arr(i).int_value, -5)
    )));
  END LOOP;

END;
```

The main_col_group.sql script gives examples of usage for all the functions and procedures in the Utils package. In the extract above, an example package, Col_Group, is called to read and process a CSV file, with calls to Utils procedures and functions to 'pretty-print' a listing at the end:

```
As Is
=====
Team                             Apps
------------------------------  -----
team_name_2                         1
Blackburn                          33
...

```
To run the example script in a slqplus session from app subfolder (after installation):

```
SQL> @main_col_group
```

There is also a separate [module](https://github.com/BrenPatF/oracle_plsql_api_demos) demonstrating instrumentation and logging, code timing and unit testing of Oracle PL/SQL APIs, which also uses this module.

## API - Utils
- [&uarr; In this README...](https://github.com/BrenPatF/oracle_plsql_utils#in-this-readme)
- [Heading(p_head)](https://github.com/BrenPatF/oracle_plsql_utils#l_heading_lis-l1_chr_arr--utilsheadingp_head)
- [Utils.Col_Headers(p_value_lis)](https://github.com/BrenPatF/oracle_plsql_utils#l_headers_lis-l1_chr_arr--utilscol_headersp_value_lis)
- [List_To_Line(p_value_lis)](https://github.com/BrenPatF/oracle_plsql_utils#l_line-varchar24000--utilslist_to_linep_value_lis)
- [Join_Values(p_value_lis, optional parameters)](https://github.com/BrenPatF/oracle_plsql_utils#l_line-varchar24000--utilsjoin_valuesp_value_lis-optional-parameters)
- [Join_Values(p_value1, optional parameters)](https://github.com/BrenPatF/oracle_plsql_utils#l_line-varchar24000--utilsjoin_valuesp_value1-optional-parameters)
- [Split_Values(p_string, optional parameters)](https://github.com/BrenPatF/oracle_plsql_utils#l_value_lis-l1_chr_arr--utilssplit_valuesp_string-optional-parameters)
- [View_To_List(p_view_name, p_sel_value_lis, optional parameters)](https://github.com/BrenPatF/oracle_plsql_utils#l_row_lis-l1_chr_arr--utilsview_to_listp_view_name-p_sel_value_lis-optional-parameters)
- [Cursor_To_List(x_csr, optional parameters)](https://github.com/BrenPatF/oracle_plsql_utils#l_row_lis-l1_chr_arr--utilscursor_to_listx_csr-optional-parameters)
- [IntervalDS_To_Seconds(p_interval)](https://github.com/BrenPatF/oracle_plsql_utils#l_seconds-number--utilsintervalds_to_secondsp_interval)
- [Sleep(p_ela_seconds, optional parameters)](https://github.com/BrenPatF/oracle_plsql_utils#utilssleepp_ela_seconds-optional-parameters)
- [Raise_Error(p_message)](https://github.com/BrenPatF/oracle_plsql_utils#utilsraise_errorp_message)
- [W(p_line)](https://github.com/BrenPatF/oracle_plsql_utils#utilswp_line)
- [W(p_line_lis)](https://github.com/BrenPatF/oracle_plsql_utils#utilswp_line_lis)
- [Delete_File(p_file_name)](https://github.com/BrenPatF/oracle_plsql_utils#utilsdelete_filep_file_name)
- [Write_File(p_file_name, p_line_lis)](https://github.com/BrenPatF/oracle_plsql_utils#utilswrite_filep_file_name-p_line_lis)
- [Read_File(p_file_name)](https://github.com/BrenPatF/oracle_plsql_utils#l_lines_lis-l1_chr_arr--utilsread_filep_file_name)
- [Get_XPlan(p_sql_marker, optional parameters)](https://github.com/BrenPatF/oracle_plsql_utils#l_lines_lis-l1_chr_arr--utilsget_xplanp_sql_marker-optional-parameters)

This package runs with Invoker rights, not the default Definer rights, so that the dynamic SQL methods execute SQL using the rights of the calling schema, not the lib schema (if different).

### l_heading_lis L1_chr_arr := Utils.Heading(p_head)
Returns a 2-element string array consisting of the string passed in and a string of underlining '=' of the same length, with parameters as follows:

* `p_head`: string to be used as a heading

### l_headers_lis L1_chr_arr := Utils.Col_Headers(p_value_lis)
Returns a 2-element string array consisting of a string containing the column headers passed in, justified as specified, and a string of sets of underlining '-' of the same lengths as the justified column headers, with parameters as follows:

* `p_value_lis`: chr_int_arr type, array of objects of type chr_int_rec:
  * `chr_value`: column header text
  * `int_value`: field size for the column header, right-justify if < 0, else left-justify

### l_line VARCHAR2(4000) := Utils.List_To_Line(p_value_lis)
- [&uarr; API - Utils](https://github.com/BrenPatF/oracle_plsql_utils#api---utils)

Returns a string containing the values passed in as a list of tuples, justified as specified in the second element of the tuple, with parameters as follows:
* `p_value_lis`: chr_int_arr type, array of objects of type chr_int_rec:
  * `chr_value`: value text
  * `int_value`: field size for the value, right-justify if < 0, else left-justify

### l_line VARCHAR2(4000) := Utils.Join_Values(p_value_lis, `optional parameters`)
Returns a string containing the values passed in as a list of strings, delimited by the optional p_delim parameter that defaults to '|', with parameters as follows:
* `p_value_lis`: list of strings

Optional parameters:
* `p_delim`: delimiter string, defaults to '|'

### l_line VARCHAR2(4000) := Utils.Join_Values(p_value1, `optional parameters`)
- [&uarr; API - Utils](https://github.com/BrenPatF/oracle_plsql_utils#api---utils)

Returns a string containing the values passed in as distinct parameters, delimited by the optional p_delim parameter that defaults to '|', with parameters as follows:
* `p_value1`: mandatory first value

Optional parameters:
* `p_value2-p_value17`: 16 optional values, defaulting to the constant PRMS_END. The first defaulted value encountered acts as a list terminator
* `p_delim`: delimiter string, defaults to '|'

### l_value_lis L1_chr_arr := Utils.Split_Values(p_string, `optional parameters`)
Returns a list of string values obtained by splitting the input string on a given delimiter, with parameters as follows:

* `p_string`: string to split

Optional parameters:
* `p_delim`: delimiter string, defaults to '|'

### l_row_lis L1_chr_arr := Utils.View_To_List(p_view_name, p_sel_value_lis, `optional parameters`)
Returns a list of rows returned from the specified view/table, with specified column list and where clause, delimiting values with specified delimiter, with parameters as follows:

* `p_view_name`: name of table or view
* `p_sel_value_lis`: L1_chr_arr list of columns to select

Optional parameters:
* `p_where`: where clause, omitting WHERE key-word
* `p_delim`: delimiter string, defaults to '|'

### l_row_lis L1_chr_arr := Utils.Cursor_To_List(x_csr, `optional parameters`)
- [&uarr; API - Utils](https://github.com/BrenPatF/oracle_plsql_utils#api---utils)

Returns a list of rows returned from the ref cursor passed, delimiting values with specified delimiter, with filter clause applied via RegExp_Like to the delimited rows, with parameters as follows:

* `x_csr`: IN OUT SYS_REFCURSOR, passed as open, and closed in function after processing

Optional parameters:
* `p_filter`: filter clause, regex expression passed to RegExp_Like against output line
* `p_delim`: delimiter string, defaults to '|'

### l_seconds NUMBER := Utils.IntervalDS_To_Seconds(p_interval)
Returns the number of seconds in a day-to-second interval, with parameters as follows:

* `p_interval`: INTERVAL DAY TO SECOND

### Utils.Sleep(p_ela_seconds, `optional parameters`)
- [&uarr; API - Utils](https://github.com/BrenPatF/oracle_plsql_utils#api---utils)

Sleeps for a given number of seconds elapsed time, including a given proportion of CPU time, with both numbers approximate, with parameters as follows:

* `p_ela_seconds`: elapsed time to sleep

Optional parameters
* `p_fraction_CPU`: fraction of elapsed time to use CPU, default 0.5

### Utils.Raise_Error(p_message)
Raises an error using Raise_Application_Error with fixed error number of 20000, with parameters as follows:

* `p_message`: error message

### Utils.W(p_line)
Writes a line of text using DBMS_Output.Put_line, with parameters as follows:

* `p_line`: line of text to write

### Utils.W(p_line_lis)
- [&uarr; API - Utils](https://github.com/BrenPatF/oracle_plsql_utils#api---utils)

Writes a list of lines of text using DBMS_Output.Put_line, with parameters as follows:

* `p_line_lis`: L1_chr_arr list of lines of text to write

### Utils.Delete_File(p_file_name)
Deletes a file on database server, in `input_dir`, with parameters as follows:

* `p_file_name`: file name

### Utils.Write_File(p_file_name, p_line_lis)
Writes a list of lines to a file on database server, in `input_dir`, with parameters as follows:

* `p_file_name`: file name
* `p_line_lis`: list of lines to write

The file is opened and closed within the procedure.

### l_lines_lis L1_chr_arr := Utils.Read_File(p_file_name)
Returns contents of a file on database server, in `input_dir`, into a list of lines, with parameters as follows:

* `p_file_name`: file name

The file is opened and closed within the function.

### l_lines_lis L1_chr_arr := Utils.Get_XPlan(p_sql_marker, `optional parameters`)
- [&uarr; API - Utils](https://github.com/BrenPatF/oracle_plsql_utils#api---utils)

Returns execution plan for a recently excuted query, identified by a marker string, into a list of lines, with parameters as follows:

* `p_sql_marker`: marker string

Optional parameters:
* `p_add_outline`: boolean, if TRUE return plan outline after normal execution plan, defaults to FALSE

The executed query should contain a hint of the form /*+  gather_plan_statistics  `p_sql_marker` */. Check the  main_col_group.sql script for an example of usage.

## Installation
- [&uarr; In this README...](https://github.com/BrenPatF/oracle_plsql_utils#in-this-readme)
- [Install 1: Create lib and app schemas and Oracle directory (optional)](https://github.com/BrenPatF/oracle_plsql_utils#install-1-create-lib-and-app-schemas-and-oracle-directory-optional)
- [Install 2: Create Utils components](https://github.com/BrenPatF/oracle_plsql_utils#install-2-create-utils-components)
- [Install 3: Create components for example code](https://github.com/BrenPatF/oracle_plsql_utils#install-3-create-components-for-example-code)
- [Install 4: Install Trapit module](https://github.com/BrenPatF/oracle_plsql_utils#install-4-install-trapit-module)
- [Install 5: Install unit test code](https://github.com/BrenPatF/oracle_plsql_utils#install-5-install-unit-test-code)

You can install just the base module in an existing schema, or alternatively, install base module plus an example of usage, and unit testing code, in two new schemas, `lib` and `app`.

### Install 1: Create lib and app schemas and Oracle directory (optional)
- [&uarr; Installation](https://github.com/BrenPatF/oracle_plsql_utils#installation)
#### [Schema: sys; Folder: (module root)]
- install_sys.sql creates an Oracle directory, `input_dir`, pointing to 'c:\input'. Update this if necessary to a folder on the database server with read/write access for the Oracle OS user
- Run script from slqplus:
```
SQL> @install_sys
```

If you do not create new users, subsequent installs will be from whichever schemas are used instead of lib and app.

### Install 2: Create Utils components
- [&uarr; Installation](https://github.com/BrenPatF/oracle_plsql_utils#installation)
#### [Schema: lib; Folder: lib]
- Run script from slqplus:
```
SQL> @install_utils app
```

This creates the required components for the base install along with grants for them to the app schema (passing none instead of app will bypass the grants). This install is all that is required to use the package and object types within the lib schema and app (if passed). To grant privileges to any `schema`, run the grants script directly, passing `schema`:
```
SQL> @grant_utils_to_app schema
```

### Install 3: Create components for example code
- [&uarr; Installation](https://github.com/BrenPatF/oracle_plsql_utils#installation)
#### [Folder: (module root)] Copy example csv to input folder
- Copy the following file from the root folder to the server folder pointed to by the Oracle directory INPUT_DIR:
    - fantasy_premier_league_player_stats.csv

- There is also a bash script to do this (it also copies the unit test JSON file), assuming C:\input as INPUT_DIR:
```
$ ./cp_data_files_to_input.ksh
```

#### [Schema: app; Folder: app] Install example code
- Run script from slqplus:
```
SQL> @install_col_group lib
```

You can review the results from the example code in the `app` subfolder without doing this install. This install creates private synonyms to the lib schema. To create synonyms within another schema, run the synonyms script directly from that schema, passing lib schema:
```
SQL> @c_utils_syns lib
```

The remaining, optional, installs are for the unit testing code, and require a minimum Oracle database version of 12.2.

### Install 4: Install Trapit module
- [&uarr; Installation](https://github.com/BrenPatF/oracle_plsql_utils#installation)

The module can be installed from its own Github page: [Trapit on GitHub](https://github.com/BrenPatF/trapit_oracle_tester). Alternatively, it can be installed directly here as follows:

#### [Schema: lib; Folder: install_ut_prereq\lib] Create lib components
- Run script from slqplus:
```
SQL> @install_lib_all
```

#### [Schema: app; Folder: install_ut_prereq\app] Create app synonyms
- Run script from slqplus:
```
SQL> @c_syns_all
```

#### [Folder: (npm root)] Install npm trapit package
The npm trapit package is a nodejs package used to format unit test results as HTML pages.

Open a DOS or Powershell window in the folder where you want to install npm packages, and, with [nodejs](https://nodejs.org/en/download/) installed, run
```
$ npm install trapit
```
This should install the trapit nodejs package in a subfolder .\node_modules\trapit

### Install 5: Install unit test code
- [&uarr; Installation](https://github.com/BrenPatF/oracle_plsql_utils#installation)

This step requires the Trapit module option to have been installed via Install 4 above.

#### [Folder: (module root)] Copy unit test JSON file to input folder
- Copy the following file from the root folder to the server folder pointed to by the Oracle directory INPUT_DIR:
    - tt_utils.purely_wrap_utils_inp.json

- The bash script mentioned in Install 3 above also copies this file, assuming C:\input as INPUT_DIR (so if executed already, no need to repeat):
```
$ ./cp_data_files_to_input.ksh
```

#### [Schema: lib; Folder: lib] Install unit test code
- Run script from slqplus:
```
SQL> @install_utils_tt
```

## Unit Testing
- [&uarr; In this README...](https://github.com/BrenPatF/oracle_plsql_utils#in-this-readme)
- [Unit Testing Process](https://github.com/BrenPatF/oracle_plsql_utils#unit-testing-process)
- [Wrapper Function Signature Diagram](https://github.com/BrenPatF/oracle_plsql_utils#wrapper-function-signature-diagram)
- [Unit Test Scenarios](https://github.com/BrenPatF/oracle_plsql_utils#unit-test-scenarios)

### Unit Testing Process
- [&uarr; Unit Testing](https://github.com/BrenPatF/oracle_plsql_utils#unit-testing)

The package is tested using the Math Function Unit Testing design pattern, described here: [The Math Function Unit Testing design pattern, implemented in nodejs](https://github.com/BrenPatF/trapit_nodejs_tester#trapit). In this approach, a 'pure' wrapper function is constructed that takes input parameters and returns a value, and is tested within a loop over scenario records read from a JSON file.

In this case, where we have a set of small independent methods, the wrapper function is designed to test all of them in a single generalised transaction.

The program is data-driven from the input file tt_utils.purely_wrap_utils_inp.json and produces an output file, tt_utils.purely_wrap_utils_out.json (in the Oracle directory `INPUT_DIR`), that contains arrays of expected and actual records by group and scenario.

The unit test program may be run from the Oracle lib subfolder:

```
SQL> @r_tests
```

The output file is processed by a nodejs program that has to be installed separately from the `npm` nodejs repository, as described in the Trapit install in `Install 4` above. The nodejs program produces listings of the results in HTML and/or text format, and a sample set of listings is included in the subfolder test_output. To run the processor, open a powershell window in the npm trapit package folder after placing the output JSON file, tt_utils.purely_wrap_utils_out.json, in the subfolder ./examples/externals and run:

```
$ node ./examples/externals/test-externals
```

This creates, or updates, a subfolder, oracle-pl_sql-utilities, with the formatted results output files. The three testing steps can easily be automated in Powershell (or Unix bash).

[An easy way to generate a starting point for the input JSON file is to use a powershell utility [Powershell Utilites module](https://github.com/BrenPatF/powershell_utils) to generate a template file with a single scenario with placeholder records from simple .csv files. See the script purely_wrap_utils.ps1 in the `test_data` subfolder for an example]

### Wrapper Function Signature Diagram
- [&uarr; Unit Testing](https://github.com/BrenPatF/oracle_plsql_utils#unit-testing)

<img src="test_data\oracle_plsql_utils.png">

###  Unit Test Scenarios
- [&uarr; Unit Testing](https://github.com/BrenPatF/oracle_plsql_utils#unit-testing)
- [Input Data Category Sets](https://github.com/BrenPatF/oracle_plsql_utils#input-data-category-sets)
- [Scenario Results](https://github.com/BrenPatF/oracle_plsql_utils#scenario-results)

The art of unit testing lies in choosing a set of scenarios that will produce a high degree of confidence in the functioning of the unit under test across the often very large range of possible inputs.

A useful approach to this can be to think in terms of categories of inputs, where we reduce large ranges to representative categories. In our case we might consider the following category sets (applied to individual functions as applicable), and create scenarios accordingly:

#### Input Data Category Sets
- [&uarr; Unit Test Scenarios](https://github.com/BrenPatF/oracle_plsql_utils#unit-test-scenarios)
- [Value Size](https://github.com/BrenPatF/oracle_plsql_utils#value-size)
- [Multiplicity](https://github.com/BrenPatF/oracle_plsql_utils#multiplicity)
- [Exceptions](https://github.com/BrenPatF/oracle_plsql_utils#exceptions)

##### Value Size
Check that utiilities work with both small and large parameter values
- Small
- Large

##### Multiplicity
Check that utiilities work with both few and many parameters passed
- Few
- Many

##### Exceptions
Check that validations return exceptions correctly
- Exception
- No exception

#### Scenario Results
- [&uarr; Unit Test Scenarios](https://github.com/BrenPatF/oracle_plsql_utils#unit-test-scenarios)
- [Results Summary](https://github.com/BrenPatF/oracle_plsql_utils#results-summary)
- [Results for Scenario 1: Small](https://github.com/BrenPatF/oracle_plsql_utils#results-for-scenario-1-small)

##### Results Summary
- [&uarr; Scenario Results](https://github.com/BrenPatF/oracle_plsql_utils#scenario-results)

The summary report in text format shows the scenarios tested:

      #    Scenario  Fails (of 15)  Status 
      ---  --------  -------------  -------
      1    Small     0              SUCCESS
      2    Large     0              SUCCESS
      3    Many      0              SUCCESS
      4    Bad SQL   0              SUCCESS

##### Results for Scenario 1: Small
- [&uarr; Scenario Results](https://github.com/BrenPatF/oracle_plsql_utils#scenario-results)

<pre>
SCENARIO 1: Small {
===================

   INPUTS
   ======

      GROUP 1: Heading {
      ==================

            #  Text     #Blanks Pre  #Blanks Post
            -  -------  -----------  ------------
            1  heading  0            0           

      }
      =

      GROUP 2: Col Headers {
      ======================

            #  Text  Length
            -  ----  ------
            1  col1  6     

      }
      =

      GROUP 3: List To Line {
      =======================

            #  Text    Length
            -  ------  ------
            1  value1  8     

      }
      =

      GROUP 4: Join Values (list) {
      =============================

            #  Value
            -  -----
            1  value

      }
      =

      GROUP 5: Join Values (scalars) {
      ================================

            #  Value 1  Value 2  Value 3  Value 4  Value 5  Value 6  Value 7  Value 8  Value 9  Value 10  Value 11  Value 12  Value 13  Value 14  Value 15  Value 16  Value 17
            -  -------  -------  -------  -------  -------  -------  -------  -------  -------  --------  --------  --------  --------  --------  --------  --------  --------
            1  value1                                                                                                                                                         

      }
      =

      GROUP 6: Split Values {
      =======================

            #  Delimited String
            -  ----------------
            1  value1          

      }
      =

      GROUP 7: View To List {
      =======================

            #  Select Column Name
            -  ------------------
            1  type_name         

      }
      =

      GROUP 8: Cursor To List {
      =========================

            #  Cursor Text                                  Filter              
            -  -------------------------------------------  --------------------
            1  select type_name from user_types order by 1  (CHR|L\d).+(ARR|REC)

      }
      =

      GROUP 9: Interval To Seconds {
      ==============================

            #  Interval String
            -  ---------------
            1  0 00:00:00     

      }
      =

      GROUP 10: Sleep {
      =================

            #  Elapsed Seconds  Fraction CPU
            -  ---------------  ------------
            1  1                0.5         

      }
      =

      GROUP 11: Raise Error {
      =======================

            #  Message     
            -  ------------
            1  Test message

      }
      =

      GROUP 12: Scalars {
      ===================

            #  Delimiter  View Name   View Where                                      View Order By   W Line   
            -  ---------  ----------  ----------------------------------------------  --------------  ---------
            1  ,          user_types  regexp_like(type_name, '(CHR|L\d).+(ARR|REC)')  type_name DESC  text line

      }
      =

      GROUP 13: W (List) {
      ====================

            #  Line            
            -  ----------------
            1  1-line text list

      }
      =

      GROUP 14: File I/O {
      ====================

            #  File Name      #Lines  Line 1  Line 2
            -  -------------  ------  ------  ------
            1  test_file.tmp  0                     

      }
      =

      GROUP 15: XPlan Cursor {
      ========================

            #  Cursor Text                                                    Marker        Outline Y/N
            -  -------------------------------------------------------------  ------------  -----------
            1  SELECT /*+ gather_plan_statistics XPLAN_MARKER */ 1 FROM DUAL  XPLAN_MARKER             

      }
      =

   OUTPUTS
   =======

      GROUP 1: Heading {
      ==================

            #  Line   
            -  -------
            1  heading
            2  =======

      } 0 failed of 2: SUCCESS
      ========================

      GROUP 2: Col Headers {
      ======================

            #  Line  
            -  ------
            1  col1  
            2  ------

      } 0 failed of 2: SUCCESS
      ========================

      GROUP 3: List To Line {
      =======================

            #  Line    
            -  --------
            1  value1  

      } 0 failed of 1: SUCCESS
      ========================

      GROUP 4: Join Values (list) {
      =============================

            #  Delimited String
            -  ----------------
            1  value           

      } 0 failed of 1: SUCCESS
      ========================

      GROUP 5: Join Values (scalars) {
      ================================

            #  Delimited String
            -  ----------------
            1  value1          

      } 0 failed of 1: SUCCESS
      ========================

      GROUP 6: Split Values {
      =======================

            #  Value 
            -  ------
            1  value1

      } 0 failed of 1: SUCCESS
      ========================

      GROUP 7: View To List {
      =======================

            #  Delimited String
            -  ----------------
            1  L4_CHR_ARR      
            2  L3_CHR_ARR      
            3  L2_CHR_ARR      
            4  L1_NUM_ARR      
            5  L1_CHR_ARR      
            6  CHR_INT_REC     
            7  CHR_INT_ARR     

      } 0 failed of 7: SUCCESS
      ========================

      GROUP 8: Cursor To List {
      =========================

            #  Delimited String
            -  ----------------
            1  CHR_INT_ARR     
            2  CHR_INT_REC     
            3  L1_CHR_ARR      
            4  L1_NUM_ARR      
            5  L2_CHR_ARR      
            6  L3_CHR_ARR      
            7  L4_CHR_ARR      

      } 0 failed of 7: SUCCESS
      ========================

      GROUP 9: Interval To Seconds {
      ==============================

            #  Seconds
            -  -------
            1  0      

      } 0 failed of 1: SUCCESS
      ========================

      GROUP 10: Sleep {
      =================

            #  Elapsed Seconds     CPU Seconds     
            -  ------------------  ----------------
            1  IN [0.9,1.1]: .999  IN [0.4,0.6]: .5

      } 0 failed of 1: SUCCESS
      ========================

      GROUP 11: Exception {
      =====================

            #  Source       Message                
            -  -----------  -----------------------
            1  Raise_Error  ORA-20000: Test message

      } 0 failed of 1: SUCCESS
      ========================

      GROUP 12: W (Line) {
      ====================

            #  Line     
            -  ---------
            1  text line

      } 0 failed of 1: SUCCESS
      ========================

      GROUP 13: W (List) {
      ====================

            #  Line            
            -  ----------------
            1  1-line text list

      } 0 failed of 1: SUCCESS
      ========================

      GROUP 14: File I/O {
      ====================

            #  #Lines  Line 1  Line 2
            -  ------  ------  ------
            1  0                     

      } 0 failed of 1: SUCCESS
      ========================

      GROUP 15: XPlan List (keyword extract) {
      ========================================

            #  XPlan Line                                                            
            -  ----------------------------------------------------------------------
            1  LIKE /SQL_ID.+, child number.+/: SQL_ID  62unzfghvzfw4, child number 0
            2  SELECT /*+ gather_plan_statistics XPLAN_MARKER */ 1 FROM DUAL         
            3  LIKE /Plan hash value: .+/: Plan hash value: 1388734953               

      } 0 failed of 3: SUCCESS
      ========================

} 0 failed of 15: SUCCESS
=========================
</pre>

You can review the formatted unit test results here, [Unit Test Report: Oracle PL/SQL Utilities](http://htmlpreview.github.io/?https://github.com/BrenPatF/oracle_plsql_utils/blob/master/test_data/test_output/oracle-pl_sql-utilities/oracle-pl_sql-utilities.html), and the files are available in the `test_data\test_output\oracle-pl_sql-utilities` subfolder [oracle-pl_sql-utilities.html is the root page for the HTML version and oracle-pl_sql-utilities.txt has the results in text format].

## Operating System/Oracle Versions
- [&uarr; In this README...](https://github.com/BrenPatF/oracle_plsql_utils#in-this-readme)
### Windows
Tested on Windows 10, should be OS-independent
### Oracle
- Tested on Oracle Database Version 19.3.0.0.0
- Base code (and example) should work on earlier versions at least as far back as v11

## See also
- [Trapit - Oracle PL/SQL unit testing module](https://github.com/BrenPatF/trapit_oracle_tester)
- [Log_Set - Oracle logging module](https://github.com/BrenPatF/log_set_oracle)
- [Timer_Set - Oracle PL/SQL code timing module](https://github.com/BrenPatF/timer_set_oracle)
- [Trapit - nodejs unit test processing package](https://github.com/BrenPatF/trapit_nodejs_tester)
- [Oracle PL/SQL API Demos - demonstrating instrumentation and logging, code timing and unit testing of Oracle PL/SQL APIs](https://github.com/BrenPatF/oracle_plsql_api_demos)

## License
MIT