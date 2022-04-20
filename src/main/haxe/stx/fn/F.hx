package stx.fn;

enum FSum<Pi,R>{
  F0X(f:Void->Void);
  F1X(f:Pi->Void);
  F1R(f:Pi->R);
  //F2R(f:Pi->Pii->R);
}
abstract F<Pi,R>(FSum<Pi,R>) from FSum<Pi,R> to FSum<Pi,R>{
  public function new(self) this = self;
  @:noUsing static public function lift<Pi,R>(self:FSum<Pi,R>):F<Pi,R> return new F(self);

  static inline public function unit<P>():FSum<P,P>{
    return lift(F1X((x:P) -> x));
  }
  @:from static public function fromF0X<Pi:Noise,R:Noise>(fn:Void->Void):F<Noise,Noise>{
    return new F(F0X(fn));
  }
  @:from static public function fromF1X<Pi,R:Noise>(fn:Pi->Void):F<Pi,Noise>{
    return lift(F1X(fn));
  }
  @:from static public function fromF1R<Pi,R>(fn:Pi->R):F<Pi,R>{
    return lift(F1R(fn));
  }
  @:to public inline function toUnary():Unary<Pi,R>{
    return switch(this){
      case F0X(f) : (_:Pi) -> { f();  return cast Noise;};
      case F1X(f) : (x:Pi) -> { f(x); return cast Noise;};
      case F1R(f) : (x:Pi) -> f(x);
    }
  }
  public function prj():FSum<Pi,R> return this;
  private var self(get,never):F<Pi,R>;
  private function get_self():F<Pi,R> return lift(this);

  public function apply(pi:Pi):R{
    return toUnary()(pi);
  }
}