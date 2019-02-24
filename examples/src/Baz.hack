namespace Sweet\Examples;

use namespace Sweet;

class Baz {
  public function __construct(public Foo $foo, public Bar $bar) {}
}

class BazFactory implements Sweet\Factory<Baz> {
  public function create(Sweet\ServiceContainerInterface $container): Baz {
    $foo = $container->get(Foo::class);
    $bar = $container->get(Bar::class);
    return new Baz($foo, $bar);
  }
}
