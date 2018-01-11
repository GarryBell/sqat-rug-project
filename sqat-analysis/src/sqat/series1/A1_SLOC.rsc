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
int commentedSub(str file){
  str file2 = file;
  int returnValue = 0;
  while(findFirst(file2, "/*") != -1){
    returnValue += numberOfLines(substring(file2, findFirst(file2, "/*"), findFirst(file2, "*/")));
    file2 = replaceFirst(file2, "/*", "");
    file2 = replaceFirst(file2, "*/", "");
  } 
  return returnValue;
}

/*
*takes a string, and returns how many \n's there are in it
*/
int numberOfLines(str file){
  return size (findAll(file, "\n")); 
}


str testString = "
  /*
  *
  *
  
  
  
  
  
  zc
  */
  das
  asd
  
  asdsa
  as
  asd
  "
  ;
  

/*
*Returns the number of empty lines in a file
*/
int emptyLines(str file){
  list[str] file2 = split("\n", file);
  splitFile = [trim(x) | x <- file2 ];
  return size([ x | x <- splitFile, x == ""]);
}


list[str] emptyLines2(str file){
  return [trim(x) | x <- split("\n", file)];
}


int fileLOC(str file){
  return 1 + numberOfLines(file) - emptyLines(file) - commentedSub(file);
}

SLOC sloc(loc project) {
  SLOC result = [];
  list[loc] files = files(project);
  return [fileLOC(readfile(x)) | x <- files];
}             
             
/*
* Tests
*/

test bool testComments(){
  return commentedSub("
  /*
  *
  *
  
  
  
  
  
  zc
  */
  das
  asd
  
  asdsa
  as
  asd
  ") == 9;
}

test bool empty(){
  return (commentedSub("")== 0) && (fileLOC("") == 0) && (emptyLines("") == 1);
}

test bool emptyLinesTest(){
  return emptyLines("
  
  
  sdf
  
  dfs
  fdsf
  
  
  ") == 7;
}
int asd(){
  return emptyLines("
  
  
  sdf
  
  dfs
  fdsf
  
  
  ");
}
