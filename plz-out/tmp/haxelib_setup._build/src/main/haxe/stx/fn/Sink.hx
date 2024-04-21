package stx.fn;

@:using(stx.fn.Sink.SinkLift)
@:callable abstract Sink<P>(SinkDef<P>) from SinkDef<P> to SinkDef<P>{
  static public var _(default,never) = SinkLift;
  public inline function new(self:SinkDef<P>) this = self;

  static public inline function unit<P>():Sink<P>{
    return lift((p:P) -> {});
  }
  @:noUsing static public inline function lift<P>(fn:P->Void):Sink<P>{
    return new Sink(fn);
  }

  #if tink_core
    @:to public function toTinkCallback():tink.core.Callback<P>{
      return this;
    }
  #end
  public inline function stage(?before: P -> Void,?after: P->Void):Sink<P>{
    before  = before  == null ? (_:P) -> {} : before;
    after   = after   == null ? (_:P) -> {} : after;
    return (p:P) -> {
      before(p);
      this(p);
      after(p);
    }
  }
  public function prj():P->Void{
    return this;
  }
}
class SinkLift{
  static public inline function then<P>(self:Sink<P>,that:Sink<P>):Sink<P>{
    return Sink.lift((p:P) -> {
      self(p);
      that(p);
    });
  }
  static public inline function bind<P>(self:Sink<P>,p:P):Block{
    return Block.lift(
      self.bind(p)
    );
  }
  static public inline function returns<P,R>(self:Sink<P>,r:R):Unary<P,R>{
    return (p:P) -> {
      self(p);
      return r;
    }
  }
  static public inline function promote<P,R>(self:SinkDef<P>):Unary<P,P>{
    return (p:P) -> {
      self(p);
      return p;
    }
  }
  static public inline function compose<P,Pi>(self:Sink<P>,fn:Pi->P):Sink<Pi>{
    return (pI:Pi) -> {
      self(fn(pI));
    }
  }
}