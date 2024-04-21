package tink.concurrent;

class Synchronized {
  @:extern static inline public function block<Target, Result>(target:Target, block:Void->Result):Result {
    #if concurrent
      #if java
        return untyped __lock__(target, block());
      #elseif neko
      #elseif cpp
      #else
        #error
      #end
    #else
      return block();
    #end
  }
}