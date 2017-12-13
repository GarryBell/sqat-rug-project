module sqat::series1::A1_SLOC

import IO;
import ParseTree;
import String;
import util::FileSystem;
import sqat::series1::Comments;

/* 

Count Source Lines of Code (SLOC) per file:
- ignore comments
- ignore empty lines

Tips
- use locations with the project scheme: e.g. |project:///jpacman/...|
- functions to crawl directories can be found in util::FileSystem
- use the functions in IO to read source files

Answer the following questions:
- what is the biggest file in JPacman?
- what is the total size of JPacman?
- is JPacman large according to SIG maintainability?
- what is the ratio between actual code and test code size?

Sanity checks:
- write tests to ensure you are correctly skipping multi-line comments
- and to ensure that consecutive newlines are counted as one.
- compare you results to external tools sloc and/or cloc.pl

Bonus:
- write a hierarchical tree map visualization using vis::Figure and 
  vis::Render quickly see where the large files are. 
  (https://en.wikipedia.org/wiki/Treemapping) 

*/

alias SLOC = map[loc file, int sloc];



/*
* returns the number of commented lines in a file
*/
int commentedLines(str file){
  str file2 = file;
  int returnValue = 0;
  while(findFirst(file2, "/*") != -1){
    returnValue += (findFirst(file2, "*/") - findFirst(file2, "/*"));
    file2 = replaceFirst(file2, "/*", "");
    file2 = replaceFirst(file2, "*/", "");
  } 
  return returnValue;
}


SLOC sloc(loc project) {
  SLOC result = ();
  // implement here
  return result;
}             
             
int testE(int val) {
  val += 1;
  return val;
}     
            