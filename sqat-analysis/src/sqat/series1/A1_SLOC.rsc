module sqat::series1::A1_SLOC

import IO;
import ParseTree;
import String;
import util::FileSystem;
import sqat::series1::Comments;
import Set;

/* 

Count Source Lines of Code (SLOC) per file:
- ignore comments
- ignore empty lines

Tips
- use locations with the project scheme: e.g. |project:///jpacman/...|
- functions to crawl directories can be found in util::FileSystem
- use the functions in IO to read source files

Answer the following questions:
- what is the biggest file in JPacman? Level.java, at 212 lines
- what is the total size of JPacman? 2952 lines;
- is JPacman large according to SIG maintainability?  At an average of 52 lines per main files, it is not too large
- what is the ratio between actual code and test code size? Around 3.47 to one 

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

loc project = |project://jpacman-framework/src/main/java/nl/tudelft/jpacman/Launcher.java|;

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
  SLOC result = ();
  list[loc] files = toList(files(project));
  for(file <- files){
    result += (file:fileLOC(readFile(file)));
  }
  return result;
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

/*
* SLOC of non test code
*/
SLOC Main(){
  return sloc(|project://jpacman-framework/src/main/java/nl/tudelft/jpacman|);
}


/*
* SLoc of test code
*/
SLOC Test(){
  return sloc(|project://jpacman-framework/src/test/java/nl/tudelft/jpacman|);
}


/*
* Sums all the loc ints in a SLOC
*/
int Size(SLOC project){
  return sum([project[class] | class <- project]);
}

/*
* The average size of a file
*/
int Average(SLOC project){
  return sum([project[class] | class <- project])/size([x | x <- project]);
}
