module sqat::series1::A3_CheckStyle

import Java17ish;
import Message;
import util::FileSystem;
import ParseTree;
import String;
import List;

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

set[Message] checkStyle(loc project) {
  set[Message] result = {};
  
  // to be done
  // implement each check in a separate function called here. 
  
  return result;
}

bool checkTabs(str file){
  list[str] splitFile = split("\t",file);
  return size(splitFile) == 1;
  
}

/*
* For this one, a desision on what should be counted as a "long line"needs to be made. 
* I decided on 120 characters, which is enough to just about fill the window on the eclipse IDE 
* (results will differ for other people with different screen sizes).
*/

bool checkLength(str file){
  list[str] splitFile = split("\n", file);
  return size(max(splitFile)) < 120;
}

bool checkSpace(str file){
  return indexOf("  ", file) == -1;
}




test bool testCheckSpace(){



}