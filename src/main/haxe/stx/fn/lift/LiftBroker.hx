package stx.fn.lift;

class LiftBroker{
  /**
   * Transform `identity` function and apply it to `v`. 
   * @param v `P`
   * @param fn `haxe.macro.Expr`
   * @return `haxe.macro.Expr`
   */
  static public function broker<P,R>(v:P,fn:(identity:Unary<P,P>) -> Unary<P,R>):R{
    return fn((x) -> x)(v);
  }
  /**
   * Macro version of `broker` that displays the supplied function types.
   * @param e0 `haxe.macro.Expr`
   * @param e1 `haxe.macro.Expr`
   * @return `haxe.macro.Expr`
   */
  static public macro function brokert<T,U>(e0:haxe.macro.Expr,e1:haxe.macro.Expr):haxe.macro.Expr{

    var str0 = haxe.macro.TypeTools.toString(haxe.macro.Context.typeof(e0));
    var str1 = haxe.macro.TypeTools.toString(haxe.macro.Context.typeof(e1));

    haxe.macro.Context.warning(str0,haxe.macro.Context.currentPos());
    haxe.macro.Context.warning(str1,haxe.macro.Context.currentPos());

    return macro {
      stx.core.Lift.broker($e0,$e1);
    }
  }
  //Ignores the input function, so you can see the types if there is an error in the function
  static public macro function brokeru<T,U>(e0:haxe.macro.Expr,e1:haxe.macro.Expr):haxe.macro.Expr{

    var str0 = haxe.macro.TypeTools.toString(haxe.macro.Context.typeof(e0));
    var str1 = haxe.macro.TypeTools.toString(haxe.macro.Context.typeof(e1));

    haxe.macro.Context.warning(str0,haxe.macro.Context.currentPos());
    haxe.macro.Context.warning(str1,haxe.macro.Context.currentPos());
    
    return macro {
      $e0;
    }
  }
}