module sqat::series2::A1a_StatCov
import String;
import lang::java::jdt::m3::Core;
import List;
import Set;
import IO;
import util::Math;
/*

Implement static code coverage metrics by Alves & Visser 
(https://www.sig.eu/en/about-sig/publications/static-estimation-test-coverage)


The relevant base data types provided by M3 can be found here:

- module analysis::m3::Core:

rel[loc name, loc src]        M3.declarations;            // maps declarations to where they are declared. contains any kind of data or type or code declaration (classes, fields, methods, variables, etc. etc.)
rel[loc name, TypeSymbol typ] M3.types;                   // assigns types to declared source code artifacts
rel[loc src, loc name]        M3.uses;                    // maps source locations of usages to the respective declarations
rel[loc from, loc to]         M3.containment;             // what is logically contained in what else (not necessarily physically, but usually also)
list[Message]                 M3.messages;                // error messages and warnings produced while constructing a single m3 model
rel[str simpleName, loc qualifiedName]  M3.names;         // convenience mapping from logical names to end-user readable (GUI) names, and vice versa
rel[loc definition, loc comments]       M3.documentation; // comments and javadoc attached to declared things
rel[loc definition, Modifier modifier] M3.modifiers;     // modifiers associated with declared things

- module  lang::java::m3::Core:

rel[loc from, loc to] M3.extends;            // classes extending classes and interfaces extending interfaces
rel[loc from, loc to] M3.implements;         // classes implementing interfaces
rel[loc from, loc to] M3.methodInvocation;   // methods calling each other (including constructors)
rel[loc from, loc to] M3.fieldAccess;        // code using data (like fields)
rel[loc from, loc to] M3.typeDependency;     // using a type literal in some code (types of variables, annotations)
rel[loc from, loc to] M3.methodOverrides;    // which method override which other methods
rel[loc declaration, loc annotation] M3.annotations;

Tips
- encode (labeled) graphs as ternary relations: rel[Node,Label,Node]
- define a data type for node types and edge types (labels) 
- use the solve statement to implement your own (custom) transitive closure for reachability.

Questions:
- what methods are not covered at all?
These methods are found through invocing Covered(jpacmanM3())-Methods(jpacmanM3()), and as a sample include:
|java+method:///nl/tudelft/jpacman/Launcher/getSinglePlayer(nl.tudelft.jpacman.game.Game)|,
  |java+method:///nl/tudelft/jpacman/level/Level/stopNPCs()|,
  |java+method:///nl/tudelft/jpacman/Launcher/getBoardFactory()|,
  |java+constructor:///nl/tudelft/jpacman/sprite/AnimatedSprite/AnimatedSprite(nl.tudelft.jpacman.sprite.Sprite%5B%5D,int,boolean)|,
  |java+method:///nl/tudelft/jpacman/board/Board/getHeight()|,
  |java+method:///nl/tudelft/jpacman/Launcher/getLevelMap()|,
  |java+method:///nl/tudelft/jpacman/level/Level/start()|,
  |java+method:///nl/tudelft/jpacman/level/Player/isAlive()|,
- how do your results compare to the jpacman results in the paper? Has jpacman improved?
- use a third-party coverage tool (e.g. Clover) to compare your results to (explain differences)


Results:
Total number of methods: 236
Total number of tests: 44
Total number of covered methods: 30
Leading to a coverage of 13%

This shows jpacman has grown, since at the time of the papers writing it had 181 methods

*/

//Some structures
alias CallGraph = rel[loc from, loc to];
alias Declaration = tuple[loc name, loc src];


M3 jpacmanM3() = createM3FromEclipseProject(|project://jpacman-framework|);
M3 empty =  emptyM3(|project://jpacman-framework|); //An empty set, used for tests

void main() {
  output(jpacmanM3());
}

/*
* As shown in the paper, this returns a call graph from the project
*/
CallGraph callGraphBuild(M3 m){
  CallGraph out = m.methodInvocation;
  return out;
}


/*
* All the non test methods
*/
list[Declaration] Methods(M3 m){
  list[Declaration] out = [ d |  d <- m.declarations, isMethod(d.name), !contains(d.src.path, "/test/") ];
  return out;
}

/*
* All the test methods
*/

list[Declaration] Tests(M3 m){
  list[Declaration] out = [ d |  d <- m.declarations, isMethod(d.name), contains(d.src.path, "/test/") ];
  return out;
}


/*
* All the covered methods
*/
set[loc] Covered(M3 m){
  list[Declaration] tests = Tests(m);
  methodSet = toSet(Methods(m));
  CallGraph graph = callGraphBuild(m);
  list[loc] testLocs = [ x.name | Declaration x <- tests ]; 
  set[loc] out = {};
  graph = graph+;
  for(loc l <- testLocs){
    out += graph[l] & methodSet.name;
  }
  return out;
}


/*
* Prints off an overview of the coverage
*/
void output(M3 m){
  print("Total number of methods: ");
  println(size(Methods(m)));
  print("Total number of tests: ");
  println(size(Tests(m)));
  print("Total number of covered methods: ");
  println(size(toList(Covered(m))));
  print("Leading to a coverage of ");
  int percentage = percent(size(toList(Covered(m))), size(Methods(m)));
  print(percentage);
  println("%");
}


test bool testMethods(){
  return (size(Methods(jpacmanM3())) == 236);
}


test bool testEmptyMethods(){
  return (size(Methods(empty)) == 0);
}

test bool testTests(){
  return (size(Tests(jpacmanM3())) == 44);
}

test bool testEmptyTests(){
  return (size(Tests(empty)) == 0);
}

test bool testCovered(){
  return (size(Covered(jpacmanM3())) == 129);
}

test bool testEmptyCovered(){
  return (size(Tests(empty)) == 0);
}

