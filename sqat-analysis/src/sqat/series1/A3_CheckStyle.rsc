module sqat::series1::A3_CheckStyle

import Java17ish;
import Message;
import util::FileSystem;
import ParseTree;
import String;
import List;
import Set;
import IO;

/*

Assignment: detect style violations in Java source code.
Select 3 checks out of this list:  http://checkstyle.sourceforge.net/checks.html
Compute a set[Message] (see module Message) containing 
check-style-warnings + location of  the offending source fragment. 

Plus: invent your own style violation or code smell and write a checker.

Note: since concrete matching in Rascal is "modulo Layout", you cannot
do checks of layout or comments (or, at least, this will be very hard).

JPacman has a list of enabled checks in checkstyle.xml.
If you're checking for those, introduce them first to see your implementation
finds them.

Questions
- for each violation: look at the code and describe what is going on? 
  Is it a "valid" violation, or a false positive?

Tips 

- use the grammar in lang::java::\syntax::Java15 to parse source files
  (using parse(#start[CompilationUnit], aLoc), in ParseTree)
  now you can use concrete syntax matching (as in Series 0)

- alternatively: some checks can be based on the M3 ASTs.

- use the functionality defined in util::ResourceMarkers to decorate Java 
  source editors with line decorations to indicate the smell/style violation
  (e.g., addMessageMarkers(set[Message]))

  
Bonus:
- write simple "refactorings" to fix one or more classes of violations 

My checks are FileTabCharacter, LineLength and SingleSpaceSeparator

*/

loc project = |project://jpacman-framework|;

set[Message] checkStyle(loc project) {
  set[Message] result = {};
  list[loc] files = toList(files(project));
  for(file <- files){
    if(!checkTabs(readFile(file))){
      result += warning("Tabs present in file",  file );
    }
    if(!checkLength(readFile(file))){
      result += warning("Very long line in file",  file );
    }
    if(!checkSpace(readFile(file))){
      result += warning("Double spacing in file",  file );
    }
  }
  return result;
}

bool checkTabs(str file){
  list[str] splitFile = split("\t",file);
  return size(splitFile) == 1;
}

/*
* For this one, a decision on what should be counted as a "long line" needs to be made. 
* I decided on 120 characters, which is enough to just about fill the window on the eclipse IDE 
* (results will differ for other people with different screen sizes).
*/

bool checkLength(str file){
  list[str] splitFile = split("\n", file);
  return size(max(splitFile)) < 120;
}

/*
*
*/

bool checkSpace(str file){
  return findAll(file, "  ") == [];
}




test bool testCheckSpace(){
  return checkSpace("assdasad  zsdzxczxc") == false;
}


test bool testCheckSpace2(){
  return checkSpace("assdasad zsdzxczxc") == true;
}

test bool testCheckSpace3(){
  return checkSpace("") == true;
}

test bool testCheckSpace4(){
  return checkSpace("   ") == false;
}

test bool testCheckSpace5(){
  return checkSpace(" 
 For this one, a decision on what should be counted as a long line needs to be made. 
 I decided on 120 characters, which is enough to just about fill the window on the eclipse IDE 
 (results will differ for other people with different screen sizes).This comment is used, in this case, as a large block of text.
 It is also useful for checking the behaviour of space, newline, space
 "
  ) == true;
}

test bool testCheckSpace6(){
  return checkSpace(" 
 For this one, a decision on what should be counted as a long line needs to be made. 
 I decided on 120 characters, which is enough to just about fill the window on the eclipse IDE 
 (results will differ for other people with different screen sizes).This comment is used, in this case, as a large block of text.
 It is also useful for checking the behaviour of space, newline, space. In this case, there is a double space.   
 "
  ) == false;
}