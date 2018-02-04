module sqat::series2::A2_CheckArch

import sqat::series2::Dicto;
import lang::java::jdt::m3::Core;
import Message;
import ParseTree;
import IO;
import Set;
import List;
import String;
import Set;

/*

This assignment has two parts:
- write a dicto file (see example.dicto for an example)
  containing 3 or more architectural rules for Pacman
  
- write an evaluator for the Dicto language that checks for
  violations of these rules. 

Part 1  

An example is: ensure that the game logic component does not 
depend on the GUI subsystem. Another example could relate to
the proper use of factories.   

Make sure that at least one of them is violated (perhaps by
first introducing the violation).

Explain why your rule encodes "good" design.
A: I added a rule such that randomMove could not e invoked by Ghost. The idea
behind was that therefore ranomMove could be implemented at the level of each
of the 4 ghosts, which would add more code, but would mean all the code to do
with the movement of each would be in the same plac.
  
Part 2:  
 
Complete the body of this function to check a Dicto rule
against the information on the M3 model (which will come
from the pacman project). 

A simple way to get started is to pattern match on variants
of the rules, like so:

switch (rule) {
  case (Rule)`<Entity e1> cannot depend <Entity e2>`: ...
  case (Rule)`<Entity e1> must invoke <Entity e2>`: ...
  ....
}

Implement each specific check for each case in a separate function.
If there's a violation, produce an error in the `msgs` set.  
Later on you can factor out commonality between rules if needed.

The messages you produce will be automatically marked in the Java
file editors of Eclipse (see Plugin.rsc for how it works).

Tip:
- for info on M3 see series2/A1a_StatCov.rsc.

Questions
- how would you test your evaluator of Dicto rules? (sketch a design)
A: A good way to test it would be in a fairly standard way of trying edge cases. 
For eah rule that is being interpreted, give it a range of different cases to try and
see if the rule is being enforced. For example, for inheritance, the evaluator could be given a 
case where the rule holds, where it doesn't hold, and cases were one or both of the arguments are empty,
since edge cases are often where errors develop
- come up with 3 rule types that are not currently supported by this version
  of Dicto (and explain why you'd need them). 
  1: A possible expansion for the relational rules would be to check if a certian variable, such as a string 
  or integer of a particular name is instantiated, instead of whether only classes are instantiated
  2: Another expansion would be to check whether classes that are instantiated are public or private,
  possibly in a format similar to <Entity e1> must instantiate public <Entity e2>.
  3:A further check would be specifying the types of class, i.e whether a class is abstract, or implements an interface of some form
*/

M3 m3 = createM3FromEclipseProject(|project://jpacman-framework|);

void main() {
  result = eval(parse(#start[Dicto], |project://sqat-analysis/src/sqat/series2/dictoFile.dicto|), m3);
  for(message <- result){
    println(message);
  }
}

set[Message] eval(start[Dicto] dicto, M3 m3) = eval(dicto.top, m3);

set[Message] eval((Dicto)`<Rule* rules>`, M3 m3) 
  = ( {} | it + eval(r, m3) | r <- rules );
  
set[Message] eval(Rule rule, M3 m3) {
  set[Message] msgs = {};
  switch(rule){
   case (Rule)`<Entity e1> cannot depend <Entity e2>`: {
    if(checkDepend(e1, e2, m3)){
        msgs += error("<e1> depends on <e2>", getLoc(e1)); 
      }
    }
    case (Rule)`<Entity e1> must inherit <Entity e2>`: {
    if(!checkInherit(e1, e2, m3)){
        msgs += error("<e1> must inherit <e2>", getLoc(e1) ); 
      }
    }
    case (Rule)`<Entity e1> cannot invoke <Entity e2>`: {
    if(checkInvoke(e1, e2, m3)){
        msgs += error("<e1> cannot invoke <e2>",  getLoc(e1) ); 
      }
    }
    case (Rule)`<Entity e1> must invoke <Entity e2>`: {
    if(!checkInvoke(e1, e2, m3)){
        msgs += error("<e1> must invoke <e2>",  getLoc(e1) ); 
      }
    }
    case (Rule)`<Entity e1> cannot inherit <Entity e2>`: {
    if(checkInherit(e1, e2, m3)){
        msgs += error("<e1> cannot inherit <e2>", getLoc(e1) ); 
      }
    }  
  
  }

  return msgs;
}
/*
* Checks if one entity inherits from another, by checking the paths in the type dependency of the M3
*/
bool checkInherit(Entity e1, Entity e2, M3 m3){
  inherit = [ m | m <- m3.typeDependency, contains("<m.from>", replaceAll(unparse(e1), ".", "/")), contains("<m.to>", replaceAll(unparse(e2), ".", "/"))]; 
  return !isEmpty(inherit);
}


/*
* Checks dependency for classes, basically inheritance as well as both entities being classes
*/
bool checkDepend(Entity e1, Entity e2, M3 m3){
  depend = [ m | m <- m3.typeDependency, isClass(m.from), isClass(m.to)];
  return !(isEmpty(depend) && checkInherit(e1,e2,m3));
}


/*
* Checks if a certain method is called by an entity, by checking the method invocation from the M3
*/
bool checkInvoke(Entity e1, Entity e2, M3 m3){
  invoke = [ m | m <- m3.methodInvocation, contains("<m.from.path>", replaceAll(unparse(e1), ".", "/")), contains("<m.from.path>", replaceAll(unparse(e2), ".", "/"))];
  return !isEmpty(invoke);
}

/*
* gets the location of where an entity is
*/
loc getLoc(Entity e){ m3 = createM3FromEclipseProject(|project://jpacman-framework|);
  for(dec <- m3.declarations){
    if(isClass(dec.name) && contains("<dec.name>", replaceAll(unparse(e), ".", "/")) ){
      return dec.name;
    }
  }
  return (|project://sqat-analysis/src/sqat/series2/A2_CheckArch.rsc|(0,0,<0,0>,<0,0>)); //This return value will never be called if the rules are formatted correctly, and basically serves to show that
}

/*
* Runs a special different test file, to check that the tests can both pass and fail. If any unexpected error messages come up, they are printed in terminal
*/
test bool testInherit(){
  M3 testm3 = createM3FromEclipseProject(|project://jpacman-framework/src/main/java/nl/tudelft/jpacman/ui/Boardpanel|);
  result = eval(parse(#start[Dicto], |project://sqat-analysis/src/sqat/series2/testFile.dicto|), m3);
  set[str] testErrors = {};
  testErrors += "nl.tudelft.jpacman.ui.BoardPanel cannot inherit JPanel";
  testErrors += "nl.tudelft.jpacman.level.Level cannot invoke registerPlayer";
  testErrors += "nl.tudelft.jpacman.npc.ghost.Clyde cannot inherit nl.tudelft.jpacman.npc.ghost.Ghost";
  if(testErrors != toSet([ x.msg | x <- result ])){
    for(mess <- result, mess.msg notin testErrors){
      println(mess);
    }
  }
  return (testErrors == toSet([ x.msg | x <- result ]));
}

