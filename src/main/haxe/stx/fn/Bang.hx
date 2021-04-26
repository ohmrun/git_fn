package stx.fn;

typedef BangDef = Future<Cycle>;

@:using(stx.fn.Bang.BangLift)
@:callable abstract Bang(BangDef) from BangDef to BangDef{
  @:noUsing static public function unit():Bang{
    return lift(Future.irreversible(
      (cb) -> cb(Cycle.ZERO)
    ));
  }
  static public function wait():BangBang{
    return new BangBang();
  }
  public function new(self) this = self;
  static public function lift(self:BangDef):Bang return new Bang(self);

  public function prj():BangDef return this;
  private var self(get,never):Bang;
  private function get_self():Bang return lift(this);
}
abstract BangBang(FutureTrigger<Cycle>){
  public function new(){
    this = Future.trigger();
  }
  public function fill(block:Cycle):Void{
    this.trigger(block);
  }
  public function done():Void{
    this.trigger(Cycle.ZERO);
  }
  public function pass(bang:Bang){
    (bang:Future<Cycle>).handle(
      (x) -> {
        this.trigger(x);
      }
    );
  }
  @:to public function toBang():Bang{
    return this.asFuture();
  }
}
class BangLift{
  static public function lift(self:BangDef):Bang return Bang.lift(self);

  static public function seq(self:Bang,that:Bang):Bang{
    return lift(
      Future.inSequence([self,that]).map(
        arr -> Cycle.lift(() -> __.option(arr[0]).defv(Cycle.ZERO).seq(__.option(arr[1]).defv(Cycle.ZERO)))
      )
    );
  }
  static public function par(self:Bang,that:Bang):Bang{
    return lift(
      Future.inParallel([self,that]).map(
        arr -> Cycle.lift(() -> __.option(arr[0]).defv(Cycle.ZERO).par(__.option(arr[1]).defv(Cycle.ZERO)()))
      )
    );
  }
}