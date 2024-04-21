package stx.fn;

typedef OtherDef<Pi,R> = Option<Pi> -> R;

@:forward @:callable abstract Other<Pi,R>(OtherDef<Pi,R>) from OtherDef<Pi,R> to Other<Pi,R>{
  public function new(self){
    this = self;
  }
  public function reply():R{
    return this(None);
  }
  public function apply(v:Pi):R{
    return this(Some(v));
  }
  public function close(v:Pi):Thunk<R>{
    return () -> apply(v);
  }
  @:from static public function fromUnaryT<Pi,R>(fn:UnaryDef<Option<Pi>,R>):Other<Pi,R>{
    return new Other(fn);
  }
  public function broker<Z>(fn:Other<Pi,R>->Z):Z{
    return fn(this);
  }
}