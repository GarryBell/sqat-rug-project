module sqat::series1::A2_McCabe

import lang::java::jdt::m3::AST;
import IO;
import List;

/*

Construct a distribution of method cylcomatic complexity. 
(that is: a map[int, int] where the key is the McCabe complexity, and the value the frequency it occurs)


Questions:
- which method has the highest complexity (use the @src annotation to get a method's location)

- how does pacman fare w.r.t. the SIG maintainability McCabe thresholds?

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
    case \do(_):               returnValue += 1;
    case \do(_,_):             returnValue += 1;
    case \if(_):               returnValue += 1;
    case \if(_,_):             returnValue += 1;
    case \try(_):              returnValue += 1;
    case \catch(_):            returnValue += 1;
    case \infix(_,_,_):        returnValue += 1;
  }
  return returnValue;
}
CC cc(set[Declaration] decls) {
  CC result = {};
  for(Declaration dec <- decls){
  visit(dec){
     case \method(_,_,_,_,m): result += {<m.src,complexity(m)>};
    }
  }
  return result;
}

alias CCDist = map[int cc, int freq];

CCDist ccDist(CC cc) {
  list[int] comp =  [ x | <_,int x> <- cc];  int i = 0;
  int length = max(comp);
  list[int] freq = [0 | int y <- [0..length]];
  for(int c <- comp) {
    freq[c] += 1;
  }
  return [<x,y> | int x <- comp, int y <- freq];
}



