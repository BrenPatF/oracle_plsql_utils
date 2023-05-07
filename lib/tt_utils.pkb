CREATE OR REPLACE PACKAGE BODY TT_Utils AS
/***************************************************************************************************
Name: tt_utils.pkb                     Author: Brendan Furey                       Date: 26-May-2019

Package body component in the oracle_plsql_utils module. The module comprises a set of generic 
user-defined Oracle types and a PL/SQL package of functions and procedures of general utility.

    GitHub: https://github.com/BrenPatF/oracle_plsql_utils

There is an example main program and package showing how to use the Utils package, and a unit test
program. Unit testing is optional and depends on the module trapit_oracle_tester.
====================================================================================================
|  Main/Test .sql  |  Package    |  Notes                                                          |
|==================================================================================================|
|  main_col_group  |  Col_Group  |  Example showing how to use the Utils package procedures and    |
|                  |             |  and functions. Col_Group is a simple file-reading and          |
|                  |             |  group-counting package also used as an example in other modules|
|------------------|-------------|-----------------------------------------------------------------|
|  r_tests         | *TT_Utils*  |  Unit testing the Utils package. Trapit is installed as a       |
|                  |  Trapit     |  separate module                                                |
====================================================================================================

This file has the TT_Utils unit test package body. Note that the test package is called by the unit
test driver package Trapit_Run, which reads the unit test details from a table, tt_units, populated
by the install scripts.

The test program follows 'The Math Function Unit Testing design pattern':

    GitHub: https://github.com/BrenPatF/trapit_nodejs_tester

Note that the unit test program generates an output file, tt_utils.purely_wrap_utils_out.json, that
is processed by a separate nodejs program, npm package trapit (see README for further details).

The output JSON file contains arrays of expected and actual records by group and scenario, in the
format expected by the nodejs program. This program produces listings of the results in HTML and/or
text format, and a sample set of listings is included in the folder test_data\test_output

***************************************************************************************************/
FUNCTION heading(
            p_value_2lis                   L2_chr_arr)
            RETURN                         L1_chr_arr IS
  l_ret_value_lis   L1_chr_arr;
BEGIN

  IF p_value_2lis.COUNT = 0 THEN
    RETURN l_ret_value_lis;
  END IF;

  l_ret_value_lis := Utils.heading(p_head            => p_value_2lis(1)(1),
                                   p_num_blanks_pre  => p_value_2lis(1)(2),
                                   p_num_blanks_post => p_value_2lis(1)(3));
  RETURN l_ret_value_lis;

END heading;

FUNCTION col_Headers(
            p_value_2lis                   L2_chr_arr)
            RETURN                         L1_chr_arr IS
  l_value_lis       chr_int_arr;
  l_ret_value_lis   L1_chr_arr;
BEGIN

  IF p_value_2lis.COUNT = 0 THEN
    RETURN l_ret_value_lis;
  END IF;

  l_value_lis := chr_int_arr();
  l_value_lis.EXTEND(p_value_2lis.COUNT);
  FOR i IN 1..p_value_2lis.COUNT LOOP

    l_value_lis(i) := chr_int_rec(p_value_2lis(i)(1), p_value_2lis(i)(2));

  END LOOP;
  l_ret_value_lis := Utils.col_Headers(p_value_lis => l_value_lis);

  RETURN l_ret_value_lis;

END col_Headers;

FUNCTION list_To_Line(
            p_value_2lis                   L2_chr_arr)
            RETURN                         L1_chr_arr IS
  l_value_lis       chr_int_arr;
  l_ret_value_lis   L1_chr_arr;
BEGIN

  IF p_value_2lis.COUNT = 0 THEN
    RETURN l_ret_value_lis;
  END IF;

  l_value_lis := chr_int_arr();
  l_value_lis.EXTEND(p_value_2lis.COUNT);
  FOR i IN 1..p_value_2lis.COUNT LOOP

    l_value_lis(i) := chr_int_rec(p_value_2lis(i)(1), p_value_2lis(i)(2));

  END LOOP;
  l_ret_value_lis := L1_chr_arr(Utils.list_To_Line(p_value_lis => l_value_lis));

  RETURN l_ret_value_lis;

END list_To_Line;

/***************************************************************************************************

extract_Lis_From_2Lis: Return a 1-list as the first column in a 2-list

***************************************************************************************************/
FUNCTION extract_Lis_From_2Lis(
            p_value_2lis                   L2_chr_arr,       -- 2-d array list
            p_column_no                    PLS_INTEGER := 1) -- column number
            RETURN                         L1_chr_arr IS     -- first column of 2-d array
  l_ret_value_lis   L1_chr_arr := L1_chr_arr();
BEGIN

  l_ret_value_lis.EXTEND(p_value_2lis.COUNT);
  FOR i IN 1..p_value_2lis.COUNT LOOP

    l_ret_value_lis(i) := p_value_2lis(i)(p_column_no);

  END LOOP;
  RETURN l_ret_value_lis;

END extract_Lis_From_2Lis;

/***************************************************************************************************

join_Values: Call Utils Join_Values function, passing list of values, and, optionally, delimiter, 
             and return the resulting delimited string.
             Input group array count zero means omit group


***************************************************************************************************/
FUNCTION join_Values(
            p_value_2lis                   L2_chr_arr,   -- 2-list with values
            p_delim                        VARCHAR2)     -- delimiter
            RETURN                         L1_chr_arr IS -- delimited string
  l_value_lis       L1_chr_arr;
  l_ret_value_lis   L1_chr_arr;
BEGIN

  IF p_value_2lis.COUNT = 0 THEN
    RETURN l_ret_value_lis;
  END IF;

  l_value_lis := extract_Lis_From_2Lis(p_value_2lis => p_value_2lis);
/*
  l_value_lis := L1_chr_arr();
  l_value_lis.EXTEND(p_value_2lis.COUNT);
  FOR i IN 1..p_value_2lis.COUNT LOOP

    l_value_lis(i) := p_value_2lis(i)(1);

  END LOOP;
*/
  IF p_delim IS NULL THEN
    l_ret_value_lis := L1_chr_arr(Utils.Join_Values(p_value_lis => l_value_lis));
  ELSE
    l_ret_value_lis := L1_chr_arr(Utils.Join_Values(p_value_lis => l_value_lis,
                                                    p_delim     => p_delim));
  END IF;

  RETURN l_ret_value_lis;

END join_Values;

/***************************************************************************************************

join_Values_S: Call Utils Join_Values function dynamically, passing as many value parameters as are 
               not null, and, optionally, delimiter, and return the resulting delimited string.
               Input group array count zero means omit group


***************************************************************************************************/
FUNCTION join_Values_S(
            p_value_2lis                   L2_chr_arr,   -- 2-list with values to pass in first row
            p_delim                        VARCHAR2)     -- delimiter
            RETURN                         L1_chr_arr IS -- delimited string
  l_values          VARCHAR2(4000);
  l_ret_value       VARCHAR2(4000);
  l_sql             VARCHAR2(4000);
  l_ret_value_lis   L1_chr_arr;
  l_value_lis       L1_chr_arr;
  l_par_name_spec   VARCHAR2(30);
BEGIN

  IF p_value_2lis.COUNT = 0 THEN
    RETURN l_ret_value_lis;
  END IF;

  l_par_name_spec := '';
  IF p_delim IS NOT NULL THEN
    l_par_name_spec := 'p_value1 => ';
  END IF;
  l_values := l_par_name_spec || '''' || p_value_2lis(1)(1) || '''';
  FOR i IN 2..p_value_2lis(1).COUNT LOOP

    IF p_value_2lis(1)(i) IS NULL THEN
      EXIT;
    END IF;
    l_par_name_spec := '';
    IF p_delim IS NOT NULL THEN
      l_par_name_spec := 'p_value' || i || ' => ';
    END IF;
    l_values := l_values || ',' || l_par_name_spec || '''' || p_value_2lis(1)(i) || '''';

  END LOOP;

  IF p_delim IS NOT NULL THEN
    l_values := l_values || ', p_delim => ' || ''''  || p_delim || '''';
  END IF;
  l_sql := 'BEGIN :1 := Utils.Join_Values(' || l_values || '); END;';
  EXECUTE IMMEDIATE l_sql
    USING OUT l_ret_value;

  RETURN L1_chr_arr(l_ret_value);

END join_Values_S;

/***************************************************************************************************

split_Values: Call Utils Split_Values function, passing a delimited string, and, optionally,
              delimiter, and return the resulting list of values.
              Input group array count zero means omit group


***************************************************************************************************/
FUNCTION split_Values(
            p_value_2lis                   L2_chr_arr,
            p_delim                        VARCHAR2)
            RETURN                         L1_chr_arr IS
  l_ret_value_lis   L1_chr_arr;
BEGIN

  IF p_value_2lis.COUNT = 0 THEN
    RETURN l_ret_value_lis;
  END IF;

  IF p_delim IS NULL THEN
    l_ret_value_lis := Utils.Split_Values(p_string => p_value_2lis(1)(1));
  ELSE
    l_ret_value_lis := Utils.Split_Values(p_string => p_value_2lis(1)(1),
                                          p_delim  => p_delim);
  END IF;

  RETURN l_ret_value_lis;

END split_Values;

/***************************************************************************************************

view_To_List: Call Utils View_To_List function, passing name of view/table, list of columns to 
              select and, optionally, where clause and delimiter and return the resulting list of 
              delimited records.
              Input view name null means omit group

***************************************************************************************************/
FUNCTION view_To_List(
            p_view_name                    VARCHAR2,
            p_sel_value_2lis               L2_chr_arr,
            p_where                        VARCHAR2,
            p_order_by                     VARCHAR2,
            p_delim                        VARCHAR2)
            RETURN                         L1_chr_arr IS
  l_ret_value_lis   L1_chr_arr;
  l_sel_value_lis   L1_chr_arr;
BEGIN

  IF p_view_name IS NULL THEN
    RETURN l_ret_value_lis;
  END IF;

  l_sel_value_lis := extract_Lis_From_2Lis(p_value_2lis     => p_sel_value_2lis);
  IF p_where IS  NULL THEN
    IF p_delim IS NULL THEN
      IF p_order_by IS NULL THEN
        l_ret_value_lis := Utils.View_To_List(p_view_name     => p_view_name,
                                              p_sel_value_lis => l_sel_value_lis);
      ELSE
        l_ret_value_lis := Utils.View_To_List(p_view_name     => p_view_name,
                                              p_sel_value_lis => l_sel_value_lis,
                                              p_order_by      => p_order_by);
      END IF;
    ELSE
      IF p_order_by IS NULL THEN
        l_ret_value_lis := Utils.View_To_List(p_view_name     => p_view_name,
                                              p_sel_value_lis => l_sel_value_lis,
                                              p_delim         => p_delim);
      ELSE
        l_ret_value_lis := Utils.View_To_List(p_view_name     => p_view_name,
                                              p_sel_value_lis => l_sel_value_lis,
                                              p_order_by      => p_order_by,
                                              p_delim         => p_delim);
      END IF;

    END IF;
  ELSE
    IF p_delim IS NULL THEN
      IF p_order_by IS NULL THEN
        l_ret_value_lis := Utils.View_To_List(p_view_name     => p_view_name,
                                              p_sel_value_lis => l_sel_value_lis,
                                              p_where         => p_where);
      ELSE
        l_ret_value_lis := Utils.View_To_List(p_view_name     => p_view_name,
                                              p_sel_value_lis => l_sel_value_lis,
                                              p_where         => p_where,
                                              p_order_by      => p_order_by);
      END IF;
    ELSE
      IF p_order_by IS NULL THEN
        l_ret_value_lis := Utils.View_To_List(p_view_name     => p_view_name,
                                              p_sel_value_lis => l_sel_value_lis,
                                              p_where         => p_where,
                                              p_delim         => p_delim);
      ELSE
        l_ret_value_lis := Utils.View_To_List(p_view_name     => p_view_name,
                                              p_sel_value_lis => l_sel_value_lis,
                                              p_where         => p_where,
                                              p_order_by      => p_order_by,
                                              p_delim         => p_delim);
      END IF;

    END IF;
  END IF;
  RETURN l_ret_value_lis;

END view_To_List;

/***************************************************************************************************

cursor_To_List: Call Utils Cursor_To_List function, passing an open cursor, regex filter, and,
                optionally, delimiter, and return the resulting list of delimited records.
                Input group array count zero means omit group

***************************************************************************************************/
FUNCTION cursor_To_List(
            p_cursor_text                  VARCHAR2,     -- cursor text
            p_filter                       VARCHAR2,     -- regex filter
            p_delim                        VARCHAR2)     -- delimiter
            RETURN                         L1_chr_arr IS -- list of delimited records
  l_csr             SYS_REFCURSOR;
  l_ret_value_lis   L1_chr_arr;
BEGIN

  IF p_cursor_text IS NULL THEN
    RETURN l_ret_value_lis;
  END IF;

  OPEN l_csr FOR p_cursor_text;

  IF p_filter IS NULL THEN
    IF p_delim IS NULL THEN
      l_ret_value_lis := Utils.Cursor_To_List(x_csr    => l_csr);
    ELSE
      l_ret_value_lis := Utils.Cursor_To_List(x_csr    => l_csr,
                                              p_delim  => p_delim);

    END IF;
  ELSE
    IF p_delim IS NULL THEN
      l_ret_value_lis := Utils.Cursor_To_List(x_csr    => l_csr,
                                              p_filter => p_filter);
    ELSE
      l_ret_value_lis := Utils.Cursor_To_List(x_csr    => l_csr,
                                              p_filter => p_filter,
                                              p_delim  => p_delim);

    END IF;
  END IF;
  RETURN l_ret_value_lis;

END cursor_To_List;
/***************************************************************************************************

cursor_To_Pipe: Call Utils Cursor_To_Pipe function, passing an open cursor, regex filter, and,
                optionally, delimiter, and return the resulting list of delimited records.
                Input group array count zero means omit group

***************************************************************************************************/
FUNCTION cursor_To_Pipe(
            p_cursor_text                  VARCHAR2,     -- cursor text
            p_filter                       VARCHAR2,     -- regex filter
            p_delim                        VARCHAR2)     -- delimiter
            RETURN                         L1_chr_arr IS -- list of delimited records
  l_csr             SYS_REFCURSOR;
  l_cursor_rec      Utils.cursor_rec;
  l_ret_value_lis   L1_chr_arr;
BEGIN

  IF p_cursor_text IS NULL THEN
    RETURN l_ret_value_lis;
  END IF;

  OPEN l_csr FOR p_cursor_text;
  l_cursor_rec := Utils.Prep_Cursor(x_csr => l_csr);

  IF p_filter IS NULL THEN
    IF p_delim IS NULL THEN
      SELECT COLUMN_VALUE
        BULK COLLECT INTO l_ret_value_lis
        FROM TABLE(Utils.Pipe_Cursor(p_cursor_rec => l_cursor_rec));
    ELSE
      SELECT COLUMN_VALUE
        BULK COLLECT INTO l_ret_value_lis
        FROM TABLE(Utils.Pipe_Cursor(p_cursor_rec => l_cursor_rec, p_delim  => p_delim));
    END IF;
  ELSE
    IF p_delim IS NULL THEN
      SELECT COLUMN_VALUE
        BULK COLLECT INTO l_ret_value_lis
        FROM TABLE(Utils.Pipe_Cursor(p_cursor_rec => l_cursor_rec, p_filter => p_filter));
    ELSE
      SELECT COLUMN_VALUE
        BULK COLLECT INTO l_ret_value_lis
        FROM TABLE(Utils.Pipe_Cursor(p_cursor_rec => l_cursor_rec, 
                                     p_filter     => p_filter,
                                     p_delim      => p_delim));
    END IF;
  END IF;
  DBMS_SQL.Close_Cursor(l_cursor_rec.csr_id);

  RETURN l_ret_value_lis;

END cursor_To_Pipe;

/***************************************************************************************************

intervalDS_To_Seconds: Call Utils IntervalDS_To_Seconds function, passing an interval, and return
                       the seconds as 1 element in list.
                       Input group array count zero means omit group

***************************************************************************************************/
FUNCTION intervalDS_To_Seconds(
            p_value_2lis                   L2_chr_arr)
            RETURN                         L1_chr_arr IS
  l_ret_value_lis   L1_chr_arr;
BEGIN

  IF p_value_2lis.COUNT = 0 THEN
    RETURN l_ret_value_lis;
  END IF;

  l_ret_value_lis := L1_chr_arr(
    Utils.IntervalDS_To_Seconds(p_interval => To_DSInterval(p_value_2lis(1)(1))));
  RETURN l_ret_value_lis;

END intervalDS_To_Seconds;

/***************************************************************************************************

Sleep: Call Utils Sleep procedure, passing elapsed time and CPU fraction, and return the resulting 
      elapsed and CPU times as 2 elements in list.
       Input group array count zero means omit group

***************************************************************************************************/
FUNCTION sleep(
            p_value_2lis                   L2_chr_arr,   -- input elapsed time and CPU fraction as 2 elements in list
            p_delim                        VARCHAR2)     -- delimiter
            RETURN                         L1_chr_arr IS -- actual elapsed and CPU times as 2 elements in list
  l_cpu_start       INTEGER := DBMS_Utility.Get_CPU_Time;
  l_ela_start       TIMESTAMP := SYSTIMESTAMP;
  l_interval        INTERVAL DAY(1) TO SECOND;
  l_ret_value_lis   L1_chr_arr;
BEGIN

  IF p_value_2lis.COUNT = 0 THEN
    RETURN l_ret_value_lis;
  END IF;

  Utils.Sleep(p_ela_seconds  => p_value_2lis(1)(1),
              p_fraction_CPU => p_value_2lis(1)(2));
  l_interval := SYSTIMESTAMP - l_ela_start;
  
  l_ret_value_lis := L1_chr_arr((       EXTRACT(SECOND FROM l_interval) + 
                                 60   * EXTRACT(MINUTE FROM l_interval) + 
                                 3600 * EXTRACT(HOUR   FROM l_interval)) || p_delim ||
                                 ((DBMS_Utility.Get_CPU_Time - l_cpu_start)*0.01));
  RETURN l_ret_value_lis;

END sleep;

/***************************************************************************************************

raise_Error: Raise an error with a given message via the Utils procedure, returning SQLERRM.
             Input group array count zero means omit group

***************************************************************************************************/
FUNCTION raise_Error(
            p_value_2lis                   L2_chr_arr)
            RETURN                         VARCHAR2 IS -- SQLERRM
  custom_error      EXCEPTION;
  PRAGMA            EXCEPTION_INIT(custom_error, -20000);
  l_ret_value       VARCHAR2(4000);
BEGIN

  IF p_value_2lis.COUNT = 0 THEN
    RETURN l_ret_value;
  END IF;

  BEGIN
    Utils.Raise_Error(p_message  => p_value_2lis(1)(1));
  EXCEPTION
    WHEN custom_error THEN
      l_ret_value := SQLERRM;
  END;
  RETURN l_ret_value;

END raise_Error;

/***************************************************************************************************

get_DBMS_Output_Buffer: Get lines from the DBMS_Output buffer, clearing buffer at same time

***************************************************************************************************/
FUNCTION get_DBMS_Output_Buffer
            RETURN                         L1_chr_arr IS -- lines from the DBMS_Output buffer
  l_numlines        PLS_INTEGER := 1000;
  l_lines           DBMSOUTPUT_LINESARRAY;
  l_ret_value_lis   L1_chr_arr := L1_chr_arr();
BEGIN

  DBMS_Output.Get_Lines(lines    => l_lines,
                        numlines => l_numlines);
  l_ret_value_lis.EXTEND(l_numlines);
  FOR i IN 1..l_numlines LOOP
    l_ret_value_lis(i) := l_lines(i);
  END LOOP;
  RETURN l_ret_value_lis;

END get_DBMS_Output_Buffer;

/***************************************************************************************************

W: Overloaded function to call Utils functions of same name to write line and return lines written
   as list
   Input line null means omit group

***************************************************************************************************/
FUNCTION w( p_line                         VARCHAR2)     -- line of text to write 
            RETURN                         L1_chr_arr IS -- lines of text from get_DBMS_Output_Buffer
  l_lines           DBMSOUTPUT_LINESARRAY;
  l_numlines        PLS_INTEGER;
  l_ret_value_lis   L1_chr_arr;
  l_save_buff_lis   L1_chr_arr;
BEGIN

  IF p_line IS NULL THEN
    RETURN l_ret_value_lis;
  END IF;

  l_save_buff_lis := get_DBMS_Output_Buffer;
  Utils.W(p_line => p_line);
  l_ret_value_lis := get_DBMS_Output_Buffer;
  Utils.W(p_line_lis => l_save_buff_lis);

  RETURN l_ret_value_lis;

END w;

/***************************************************************************************************

w: Overloaded function to call Utils functions of same name to write list of lines and return lines
   written as list
   Input line array null means omit group.

***************************************************************************************************/
FUNCTION w( p_line_2lis                    L2_chr_arr)   -- lines of text in first column of 2-lis to write 
            RETURN                         L1_chr_arr IS -- lines of text from get_DBMS_Output_Buffer
  l_lines           DBMSOUTPUT_LINESARRAY;
  l_numlines        PLS_INTEGER;
  l_line_lis        L1_chr_arr;
  l_save_buff_lis   L1_chr_arr;
  l_ret_value_lis   L1_chr_arr;
BEGIN

  IF p_line_2lis.COUNT = 0  THEN
    RETURN l_ret_value_lis;
  END IF;

  l_save_buff_lis := get_DBMS_Output_Buffer;
  l_line_lis := extract_Lis_From_2Lis(p_line_2lis);
  Utils.W(p_line_lis => l_line_lis);

  l_ret_value_lis := get_DBMS_Output_Buffer;
  Utils.W(p_line_lis => l_save_buff_lis);

  RETURN l_ret_value_lis;

END w;

/***************************************************************************************************

add_Exception: Add a record to the exceptions group array element

***************************************************************************************************/
FUNCTION add_Exception(
            p_source                       VARCHAR2,     -- source of exception
            p_message                      VARCHAR2,     -- error message
            p_act_lis                      L1_chr_arr,   -- input exceptions group list
            p_delim                        VARCHAR2)     -- delimiter
            RETURN                         L1_chr_arr IS -- output exceptions group list
  l_act_lis  L1_chr_arr := p_act_lis;
BEGIN

  l_act_lis.EXTEND;
  l_act_lis(l_act_lis.COUNT) := p_source || p_delim || p_message;
  RETURN l_act_lis;

END add_Exception;

/***************************************************************************************************

file_IO: Add a record to the exceptions group array element

***************************************************************************************************/
FUNCTION file_IO(
            p_value_2lis                   L2_chr_arr,   -- 1 row: file name, #lines, line 1, line 2
            p_delim                        VARCHAR2)     -- delimiter
            RETURN                         L1_chr_arr IS -- line list

  l_line_lis          L1_chr_arr;
  l_n_lines           PLS_INTEGER;
  l_filename          VARCHAR2(100);
  l_ret_value         VARCHAR2(4000);
  l_line_1            VARCHAR2(1000);
  l_line_2            VARCHAR2(1000);
  l_ret_value_lis     L1_chr_arr;
BEGIN

  IF p_value_2lis.COUNT = 0 THEN
    RETURN l_ret_value_lis;
  END IF;
  l_filename := p_value_2lis(1)(1);
  l_n_lines  := p_value_2lis(1)(2);
  l_line_1   := p_value_2lis(1)(3);
  l_line_2   := p_value_2lis(1)(4);

  IF l_n_lines > 0 THEN

    l_line_lis := L1_chr_arr();
    l_line_lis.EXTEND(l_n_lines);
    l_line_lis(1) := l_line_1;

    IF l_n_lines > 1 THEN
      l_line_lis(2) := l_line_2;
    END IF;

  END IF;

  Utils.Write_File(p_file_name => l_filename,
                   p_line_lis  => l_line_lis);

  l_line_lis := Utils.Read_File(p_file_name => l_filename);

  l_n_lines := l_line_lis.COUNT;

  IF l_n_lines > 0 THEN

    l_line_1 := l_line_lis(1);
    IF l_n_lines > 1 THEN
      l_line_2 := l_line_lis(2);
    END IF;

  END IF;

  l_ret_value := l_n_lines || p_delim || l_line_1 || p_delim  || l_line_2;
  Utils.Delete_File(p_file_name => l_filename);

  RETURN L1_chr_arr(l_ret_value);

END file_IO;

/***************************************************************************************************

xPlan: Call Utils Cursor_To_List function, passing an open cursor then calls Get_XPlan to get the 
       XPlan records, and returns the resulting list of  records.
       Input group array count zero means omit group

***************************************************************************************************/
FUNCTION xPlan(
            p_value_2lis                   L2_chr_arr)   -- cursor text, marker (row 1)
            RETURN                         L1_chr_arr IS -- list of delimited records
  l_csr             SYS_REFCURSOR;
  l_csr_value_lis   L1_chr_arr;
  l_xplan_lis       L1_chr_arr;
  l_ret_lis         L1_chr_arr := L1_chr_arr();
  l_searches        L1_chr_arr := L1_chr_arr('SQL_ID.+', 
                                             '.+gather_plan_statistics.+', 
                                             '.*Plan hash value:.+', 
                                             'SQL_ID.+',
                                             '.+gather_plan_statistics.+',
                                             '.*Plan hash value:.+',
                                             '.*BEGIN_OUTLINE_DATA.*',
                                             '.*END_OUTLINE_DATA.*');
  l_ind             PLS_INTEGER := 1;                                             
BEGIN

  IF p_value_2lis.COUNT = 0 THEN
    RETURN l_csr_value_lis;
  END IF;

  OPEN l_csr FOR p_value_2lis(1)(1);

  l_csr_value_lis := Utils.Cursor_To_List(x_csr    => l_csr);

  IF p_value_2lis(1)(3) = 'Y' THEN
    l_xplan_lis := Utils.Get_XPlan(p_sql_marker => p_value_2lis(1)(2), p_add_outline => TRUE);
  ELSE
    l_xplan_lis := Utils.Get_XPlan(p_sql_marker => p_value_2lis(1)(2));
  END IF;

  FOR i IN 1..l_xplan_lis.COUNT LOOP

    IF RegExp_Like(l_xplan_lis(i), l_searches(l_ind)) THEN

      EXIT WHEN RegExp_Like(l_xplan_lis(i), '.*child number [1-9]'); -- child cursors break test so ignore
      l_ret_lis.EXTEND;
      l_ret_lis(l_ret_lis.COUNT) := l_xplan_lis(i);
      l_ind := l_ind + 1;
      EXIT WHEN l_ind > l_searches.COUNT;

    END IF;

  END LOOP;

  RETURN l_ret_lis;

END xPlan;

/***************************************************************************************************

Purely_Wrap_Utils: Unit test wrapper function for Utils package procedures and functions

    Returns the 'actual' outputs, given the inputs for a scenario, with the signature expected for
    the Math Function Unit Testing design pattern, namely:

      Input parameter: 3-level list (type L3_chr_arr) with test inputs as group/record/field
      Return Value: 2-level list (type L2_chr_arr) with test outputs as group/record (with record as
                   delimited fields string)

***************************************************************************************************/
FUNCTION Purely_Wrap_Utils(
            p_inp_3lis                     L3_chr_arr)   -- input list of lists (group, record, field)
            RETURN                         L2_chr_arr IS -- output list of lists (group, record)

  c_delim                        VARCHAR2(1) := ';';
  l_act_2lis                     L2_chr_arr := L2_chr_arr();
  l_start_tmstp                  TIMESTAMP := SYSTIMESTAMP;
  l_start_cpu_cs                 PLS_INTEGER := DBMS_Utility.Get_CPU_Time;
  l_message                      VARCHAR2(4000);
BEGIN

  l_act_2lis.EXTEND(16);
  l_act_2lis(1) := heading(              p_value_2lis     => p_inp_3lis(1));
  l_act_2lis(2) := col_Headers(          p_value_2lis     => p_inp_3lis(2));
  l_act_2lis(3) := list_To_Line(         p_value_2lis     => p_inp_3lis(3));
  l_act_2lis(4) := join_Values(          p_value_2lis     => p_inp_3lis(4),
                                         p_delim          => p_inp_3lis(13)(1)(1));
  l_act_2lis(5) := join_Values_S(        p_value_2lis     => p_inp_3lis(5),
                                         p_delim          => p_inp_3lis(13)(1)(1));
  l_act_2lis(6) := Split_Values(         p_value_2lis     => p_inp_3lis(6),
                                         p_delim          => p_inp_3lis(13)(1)(1));
  l_act_2lis(12) := L1_chr_arr();
  BEGIN
    l_act_2lis(7) := view_To_List(       p_view_name      => p_inp_3lis(13)(1)(2),
                                         p_sel_value_2lis => p_inp_3lis(7),
                                         p_where          => p_inp_3lis(13)(1)(3),
                                         p_order_by       => p_inp_3lis(13)(1)(4),
                                         p_delim          => p_inp_3lis(13)(1)(1));
  EXCEPTION
    WHEN OTHERS THEN
      l_act_2lis(12) := add_Exception(   p_source         => 'view_To_List',
                                         p_message        => SQLERRM,
                                         p_act_lis        => l_act_2lis(12),
                                         p_delim          => c_delim);
  END;

  BEGIN
    l_act_2lis(8) := cursor_To_List(     p_cursor_text    => p_inp_3lis(8)(1)(1),
                                         p_filter         => p_inp_3lis(8)(1)(2),
                                         p_delim          => p_inp_3lis(13)(1)(1));
  EXCEPTION
    WHEN OTHERS THEN
      l_act_2lis(12) := add_Exception(   p_source         => 'cursor_To_List',
                                         p_message        => SQLERRM,
                                         p_act_lis        => l_act_2lis(12),
                                         p_delim          => c_delim);
  END;

  BEGIN
    l_act_2lis(9) := cursor_To_Pipe(     p_cursor_text    => p_inp_3lis(9)(1)(1),
                                         p_filter         => p_inp_3lis(9)(1)(2),
                                         p_delim          => p_inp_3lis(13)(1)(1));
  EXCEPTION
    WHEN OTHERS THEN
      l_act_2lis(12) := add_Exception(   p_source         => 'cursor_To_Pipe',
                                         p_message        => SQLERRM,
                                         p_act_lis        => l_act_2lis(12),
                                         p_delim          => c_delim);
  END;

  l_act_2lis(10) := intervalDS_To_Seconds(p_value_2lis     => p_inp_3lis(10));
  l_act_2lis(11) := sleep(               p_value_2lis     => p_inp_3lis(11),
                                         p_delim          => c_delim);
  l_message := raise_Error(              p_value_2lis     => p_inp_3lis(12));
  IF l_message IS NOT NULL THEN
    l_act_2lis(12) := add_Exception(     p_source         => 'Raise_Error',
                                         p_message        => l_message,
                                         p_act_lis        => l_act_2lis(12),
                                         p_delim          => c_delim);
  END IF;
  l_act_2lis(13) := w(                   p_line           => p_inp_3lis(13)(1)(5));
  l_act_2lis(14) := w(                   p_line_2lis      => p_inp_3lis(14));
  l_act_2lis(15) := file_IO(             p_value_2lis     => p_inp_3lis(15),
                                         p_delim          => c_delim);
  l_act_2lis(16) := xPlan(               p_value_2lis     => p_inp_3lis(16));
  RETURN l_act_2lis;

END Purely_Wrap_Utils;

END TT_Utils;
/
SHO ERR