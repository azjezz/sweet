namespace Sweet\Examples;

use namespace Sweet;

class Foo {
  public function __construct(public string $baz) {}
}

class FooFactory implements Sweet\Factory<Foo> {
  public function create(Sweet\ServiceContainerInterface $container): Foo {
    return new Foo('sweet');
  }
}
