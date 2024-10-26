@..\initspool utils_examples
/***************************************************************************************************
Name: utils_examples.sql               Author: Brendan Furey                       Date: 26-May-2019

Driver script component in the oracle_plsql_utils module. The module comprises a set of generic 
user-defined Oracle types and a PL/SQL package of functions and procedures of general utility.

    GitHub: https://github.com/BrenPatF/oracle_plsql_utils

There is an example main program and package showing how to use the Utils package, and a unit test
program, which is driven by a Powershell script, as described in the README.

This file has the driver script for the example code calling the Utils methods. The first block uses 
a package that reads delimited lines from a file, and counts values in a given column, with methods
to return the counts in various orderings. It is used as a simple example to illustrate usage of 
Utils and, elsewhere, of other utility packages.
***************************************************************************************************/
PROMPT Example of Utils.Heading, .Col_Headers, .List_To_Line, .W (VARCHAR2), .W (L1_chr_arr)
DECLARE
  l_res_arr              chr_int_arr;
BEGIN

  Col_Group.Load_File(p_file   => 'fantasy_premier_league_player_stats.csv', 
                      p_delim  => ',', 
                      p_colnum => 7);
  l_res_arr := Col_Group.Sort_By_Value;
  Utils.W(p_line_lis => Utils.Heading(p_head => 'Sort_By_Value'));

  Utils.W(p_line_lis => Utils.Col_Headers(p_value_lis => chr_int_arr(chr_int_rec('Team', 30), 
                                                                     chr_int_rec('Apps', -5)
  )));

  FOR i IN 1..l_res_arr.COUNT LOOP
    Utils.W(p_line => Utils.List_To_Line(
                          p_value_lis => chr_int_arr(chr_int_rec(l_res_arr(i).chr_value, 30), 
                                                     chr_int_rec(l_res_arr(i).int_value, -5)
    )));
  END LOOP;

END;
/
PROMPT Example of Utils.View_To_List
COLUMN csv FORMAT A60
SELECT COLUMN_VALUE csv
  FROM Utils.View_To_List(p_view_name     => 'user_objects', 
                          p_sel_value_lis => L1_chr_arr('object_name', 'object_id', 'created',
                                                        'timestamp'))
 ORDER BY 1
/
PROMPT Example of Utils.Cursor_To_List, .Split_Values, .Join_Values (list), .Join_Values (scalars)
DECLARE
  l_csr         SYS_REFCURSOR;
  l_res_lis     L1_chr_arr;
  l_line_1_lis  L1_chr_arr;
  l_cursor_rec  Utils.cursor_rec;
  PROCEDURE Heading(p_head VARCHAR2) IS
  BEGIN
    Utils.W(p_line => '.');
    Utils.W(p_line_lis => Utils.Heading(p_head));
  END Heading;
BEGIN

  Heading(p_head => 'Utils.Cursor_To_List on user_objects...');
  OPEN l_csr FOR 'SELECT object_name, object_id, created, timestamp FROM user_objects ORDER BY 1';
  l_res_lis := Utils.Cursor_To_List(x_csr => l_csr);
  Utils.W(p_line_lis => l_res_lis);

  Heading(p_head => 'Utils.Prep_Cursor, .Pipe_Cursor on user_objects...');
  OPEN l_csr FOR 'SELECT object_name, object_id, created, timestamp FROM user_objects ORDER BY 1';
  l_cursor_rec := Utils.Prep_Cursor(x_csr => l_csr);
  Utils.W('Cursor prepared, now fetch...');
  SELECT COLUMN_VALUE
    BULK COLLECT INTO l_res_lis
    FROM TABLE(Utils.Pipe_Cursor(p_cursor_rec => l_cursor_rec));
  DBMS_SQL.Close_Cursor(l_cursor_rec.csr_id);
  Utils.W(p_line_lis => l_res_lis);

  Heading(p_head => 'Utils.Split_Values on first line...');
  l_line_1_lis := Utils.Split_Values(l_res_lis(1));
  Utils.W(p_line_lis => l_line_1_lis);

  Heading(p_head => 'Utils.Join_Values on first line, passing list, with "," delimiter...');
  Utils.W(p_line => Utils.Join_Values(l_line_1_lis, ','));

  Heading(p_head => 'Utils.Join_Values on first line, passing first three values...');
  Utils.W(p_line => Utils.Join_Values(p_value1 => l_line_1_lis(1),
                                      p_value2 => l_line_1_lis(2),
                                      p_value3 => l_line_1_lis(3)
  ));

END;
/
PROMPT Example of Utils.Sleep, .IntervalDS_To_Seconds, sleeping for 1.2s of which 0.36s CPU
DECLARE
  l_cpu_start               INTEGER := DBMS_Utility.Get_CPU_Time;
  l_ela_start               TIMESTAMP := SYSTIMESTAMP;

BEGIN
  Utils.Sleep(p_ela_seconds   => 1.2,
              p_fraction_CPU  => 0.3);
  Utils.W(p_line => 'Elapsed time is ' || Utils.IntervalDS_To_Seconds(SYSTIMESTAMP - l_ela_start));
  Utils.W(p_line => 'CPU time is ' || 0.01*(DBMS_Utility.Get_CPU_Time - l_cpu_start));
  Utils.Raise_Error('Example of raising error via Raise_Error');
END;
/
PROMPT Example of Utils.Get_XPlan
DECLARE
  l_csr             SYS_REFCURSOR;
  l_csr_value_lis   L1_chr_arr;
BEGIN

  OPEN l_csr FOR 'SELECT /*+ gather_plan_statistics XPLAN_MARKER_CG */ 1 FROM DUAL';

  l_csr_value_lis := Utils.Cursor_To_List(x_csr => l_csr);
  Utils.W(Utils.Get_XPlan(p_sql_marker => 'XPLAN_MARKER_CG', p_add_outline => TRUE));

END;
/
PROMPT Example of Utils.Write_File, .Read_File, .Delete_File
DECLARE
  c_filename  CONSTANT VARCHAR2(30) := 'example_file.txt';
  l_line_lis           L1_chr_arr;
BEGIN

  Utils.W(p_line_lis => Utils.Heading('First, create and write lines to a file, example_file.txt...'));
  Utils.Write_File(p_file_name => c_filename,
                   p_line_lis  => L1_chr_arr('Line one', 'Line two'));

  Utils.W(p_line_lis => Utils.Heading('Next, read the contents of the file and write them to log...'));
  l_line_lis := Utils.Read_File(p_file_name => c_filename);
  Utils.W(p_line_lis => Utils.Heading('Lines read...'));
  Utils.W(p_line_lis => l_line_lis);

  Utils.W(p_line_lis => Utils.Heading('Finally, delete the file...'));
  Utils.Delete_File(p_file_name => c_filename);
END;
/
@..\endspool