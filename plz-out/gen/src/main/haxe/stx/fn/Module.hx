package stx.fn;

class Module extends Clazz{
  public function _1R<P,R>(fn:P->R):Unary<P,R>{
    return fn;
  }
  public function sink<P>(fn:P->Void):Sink<P>{
    return Sink.lift(fn);
  }
}
