package stx.fn;

typedef ArwOutDef<R,E>    = Outcome<R,Defect<E>>;
typedef ArwOut<R,E>       = ArwOutDef<R,E>; 
typedef ArwDef<P,R,E>     = P -> Sink<ArwOut<R,E>> -> Work;
//typedef ArwPairDef<Pi,Pii,Ri,Rii,E> = 

@:using(stx.fn.Arw.ArwLift)
@:callable abstract Arw<P,R,E>(ArwDef<P,R,E>) from ArwDef<P,R,E> to ArwDef<P,R,E>{
  public function new(self) this = self;
  @:from static public function fromUnary<P,R,E>(self:Unary<P,R>):Arw<P,R,E>{
    return fromFun(self);
  }
  @:from static public function fromBinary<Pi,Pii,R,E>(self:Binary<Pi,Pii,R>):Arw<Couple<Pi,Pii>,R,E>{
    return fromFun(self.encouple());
  }
  static public inline function lift<P,R,E>(self:ArwDef<P,R,E>):Arw<P,R,E> return new Arw(self);
  static public function unit<P,E>(){
    return lift((p:P,cont:Sink<ArwOut<P,E>>) -> {
      cont(__.success(p));
      return Work.unit();
    });
  }
  static public inline function fromFun<P,R,E>(fn:P->R):Arw<P,R,E>{
    return lift((p:P,cont:Sink<ArwOut<R,E>>) -> {
      var res = __.success(fn(p));
      cont(res);
      return Work.unit();
    });
  }
  public function prj():ArwDef<P,R,E> return this;
  private var self(get,never):Arw<P,R,E>;
  private function get_self():Arw<P,R,E> return lift(this);
}
class ArwLift{
  static public inline function lift<P,R,E>(self:ArwDef<P,R,E>):Arw<P,R,E> return Arw.lift(self);

  static public inline function then<P,R,Ri,E>(self:ArwDef<P,R,E>,that:Arw<R,Ri,E>):Arw<P,Ri,E>{
    return lift(
      (p:P,cont:Sink<ArwOut<Ri,E>>) -> { 
        var b = Work.wait();
        var a = self(
          p,
          (res:ArwOut<R,E>) -> res.fold(
            ok -> {
              var work = that(ok,cont);
              work.prj().fold(
                ok -> ok.handle(
                  (v:Cycle) -> {
                    b.fill(v);
                  }
                ),
                () -> {
                  b.done();
                  return () -> {}; 
                }
              );
            },
            no -> {
              cont(__.failure(no));
              return () -> {};
            }
          )
        );
        return a.seq(b);
      }
    );
  }
  static public function pair<Pi,Pii,Ri,Rii,E>(self:ArwDef<Pi,Ri,E>,that:Arw<Pii,Rii,E>):Arw<Couple<Pi,Pii>,Couple<Ri,Rii>,E>{
    return lift(
      (p:Couple<Pi,Pii>,cont:Sink<ArwOut<Couple<Ri,Rii>,E>>) -> {
        var fts   = [];
        var l   : Option<ArwOut<Ri,E>>    = None;
        var r   : Option<ArwOut<Rii,E>>   = None;
        var work                          = Work.wait();

        final completer = () -> {
          l.zip(r).fold(
            ok -> {
              ok.decouple(
                (l,r) -> cont(l.zip(r))
              );
              work.done();
            },
            () -> {}
          );
        }
        final lh = (o:ArwOut<Ri,E>) -> {
          l = Some(o);
          completer();
        }
        final rh = (o:ArwOut<Rii,E>) -> {
          r = Some(o);
          completer();
        }
        var l_work = lift(self)(p.fst(),lh);
        var r_work = that(p.snd(),rh);

        return l_work.par(r_work).seq(work);
      }
    );
  }
  static public function go_left<Pi,Pii,Ri,E>(self:ArwDef<Pi,Ri,E>):Arw<Either<Pi,Pii>,Either<Ri,Pii>,E>{
    return lift(
      (p:Either<Pi,Pii>,cont:ArwOut<Either<Ri,Pii>,E> -> Void) ->
        p.fold(
          lhs -> self(
            lhs,
            (res:ArwOut<Ri,E>) -> cont(res.map(Left))
          ),
          rhs -> cont.bind(__.success(Right(rhs))).fn().bung()()
        )
    );
  }
  static public function go_right<Pi,Pii,Rii,E>(self:ArwDef<Pii,Rii,E>):Arw<Either<Pi,Pii>,Either<Pi,Rii>,E>{
    return lift(
      (p:Either<Pi,Pii>,cont:ArwOut<Either<Pi,Rii>,E> -> Void) ->
        p.fold(
          lhs -> cont.bind(__.success(Left(lhs))).fn().bung()(),
          rhs -> self(
            rhs,
            (res:ArwOut<Rii,E>) -> cont(res.map(Right))
          )
        )
    );
  }
  static public function split<Pi,Ri,Rii,E>(self:ArwDef<Pi,Ri,E>,that:ArwDef<Pi,Rii,E>):Arw<Pi,Couple<Ri,Rii>,E>{
    return lift(
      (pi:Pi,cont) -> pair(self,that)(__.couple(pi,pi),cont)
    );
  }
  static public function fan<P,R,E>(self:ArwDef<P,R,E>):Arw<P,Couple<R,R>,E>{
    return then(self,(x -> __.couple(x,x)).fn());
  }
  static public function first<Pi,Pii,Ri,E>(self:ArwDef<Pi,Ri,E>):Arw<Couple<Pi,Pii>,Couple<Ri,Pii>,E>{
    return pair(self,Arw.unit()); 
  }
  static public function second<Pi,Pii,Rii,E>(self:ArwDef<Pii,Rii,E>):Arw<Couple<Pi,Pii>,Couple<Pi,Rii>,E>{
    return pair(Arw.unit(),self);
  }
  static public function joint<I,Oi,Oii,E>(lhs:ArwDef<I,Oi,E>,rhs:Arw<Oi,Oii,E>):Arw<I,Couple<Oi,Oii>,E>{
    return then(lhs,Arw.unit().split(rhs));
  }
  static public function bound<P,Oi,Oii,E>(self:ArwDef<P,Oi,E>,that:Arw<Couple<P,Oi>,Oii,E>):Arw<P,Oii,E>{
    return joint(Arw.unit(),self).then(that);
  }
}