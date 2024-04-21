package tink.core;

enum abstract Nada(Null<Dynamic>) {
  var Nada = null;
  @:from static function ofAny<T>(t:Null<T>):Nada
    return Nada;
}

#if (haxe_ver < 4.2)
typedef Never = Dynamic;
#else
abstract Never(Dynamic) to Dynamic  {
}
#end