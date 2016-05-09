package stx.core;

import stx.data.Block;
/**
  Helpers for working with Blocks.
**/
class Blocks{
  public static var NIL(default,never) : Block = function(){}
  /**
    Compare function identity.
  **/
  public static function equals(a:Block,b:Block){
    return Reflect.compareMethods(a,b);
  }
  /**
    Produces a function that takes a parameter, ignores it, and calls `f`.
  **/
  public static function promote<A>(f: Block): A->Void {
    return function(a: A): Void {
      f();
    }
  }
  /**
    Produces a function that calls `f1` and `f2` in left to right order.*
  * @returns The composite function.
  **/
  public static function then(f1:Void->Void, f2:Void->Void):Void->Void {
    return function() {
      f1();
      f2();
    }
  }

  public static function upply(fn:Block){
    fn();
  }
  public static inline function and(fn0:Block,fn1:Block):Block{
    return function(){
      fn0();
      fn1();
    }
  }
}
