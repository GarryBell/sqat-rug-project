module sqat::series1::A2_McCabe

import lang::java::jdt::m3::AST;
import IO;
import List;

/*

Construct a distribution of method cylcomatic complexity. 
(that is: a map[int, int] where the key is the McCabe complexity, and the value the frequency it occurs)
(10:0,7:4,1:160,3:20,13:2,9:3,2:23,4:9,11:0,6:6,12:0,0:0,5:5,8:6)

Questions:
- which method has the highest complexity (use the @src annotation to get a method's location)
|project://jpacman-framework/src/main/java/nl/tudelft/jpacman/npc/ghost/Inky.java|(3664,988,<96,29>,<131,17>), with a complexity of 13
- how does pacman fare w.r.t. the SIG maintainability McCabe thresholds?
Pretty well, with no hugely complex methods.
- is code size correlated with McCabe in this case (use functions in analysis::statistics::Correlation to find out)? 
  (Background: Davy Landman, Alexander Serebrenik, Eric Bouwers and Jurgen J. Vinju. Empirical analysis 
  of the relationship between CC and SLOC in a large corpus of Java methods 
  and C functions Journal of Software: Evolution and Process. 2016. 
  http://homepages.cwi.nl/~jurgenv/papers/JSEP-2015.pdf)
  
- what if you separate out the test sources?

Tips: 
- the AST data type can be found in module lang::java::m3::AST
- use visit to quickly find methods in Declaration ASTs
- compute McCabe by matching on AST nodes

Sanity checks
- write tests to check your implementation of McCabe

Bonus
- write visualization using vis::Figure and vis::Render to render a histogram.

*/

set[Declaration] jpacmanASTs() = createAstsFromEclipseProject(|project://jpacman-framework|, true); 
set[Declaration] jpacmanASTsNoTests() = createAstsFromEclipseProject(|project://jpacman-framework/src/main/|, true); 

alias CC = rel[loc method, int cc];


/*
* Returns the complexity of a statement
*/

int complexity(Statement state){
  int returnValue = 1;
  visit(state){
    case \while(_,_):          returnValue += 1;
    case \for(_,_,_):          returnValue += 1;
    case \for(_,_,_,_):        returnValue += 1;
    case \foreach(_,_,_):      returnValue += 1;
    case \do(_,_):             returnValue += 1;
    case \if(_,_):               returnValue += 1;
    case \if(_,_,_):               returnValue += 1;
    case \try(_,_):              returnValue += 1;
    case \catch(_,_):            returnValue += 1;
    case \infix(_,_,_):        returnValue += 1;
  }
  return returnValue;
}
CC cc(set[Declaration] decls) {
  CC cclist = {};
  for(Declaration dec <- decls){
  visit(dec){
     case \method(_,_,_,_,m): cclist += {<m.src, complexity(m)>};
    }
  }
  return cclist;
}

alias CCDist = map[int cc, int freq];

CCDist ccDist(CC cc) {
  CCDist out = ();
  list[int] comp =  [ x | <_,int x> <- cc];
  int length = max(comp);
  list[int] freq = [0 | x <- [0..(length + 1)]];
  for(int c <- comp) {
    freq[c] += 1;
  }
  for(i <- [0..(length+1)]){
    out += (i:freq[i]);
    
  }
  
  return out;
}

void Max(CC cc){
  int max = 0;
  loc maxMethod;
  for(c <- cc){
   if(c.cc > max){
       max = c.cc;
       maxMethod = c.method;
   }
  }
  println(maxMethod);
  println(max);
}


