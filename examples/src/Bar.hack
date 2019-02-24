namespace Sweet\Examples;

use namespace Sweet;

class Bar {
  public function __construct(public Foo $foo) {}
}

class BarFactory implements Sweet\Factory<Bar> {
  public function create(Sweet\ServiceContainerInterface $container): Bar {
    $foo = $container->get(Foo::class);
    return new Bar($foo);
  }
}
