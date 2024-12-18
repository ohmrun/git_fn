package stx.fn;

typedef PerhapsDef<P,R> = Option<P> -> Option<R>;

@:forward @:callable abstract Perhaps<P,R>(PerhapsDef<P,R>) from PerhapsDef<P,R>{
  public function new(self){
    this = self;
  }
}