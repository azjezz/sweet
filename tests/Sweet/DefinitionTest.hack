namespace Sweet\Test;

use namespace Sweet;
use namespace Sweet\Examples;
use type Facebook\HackTest\HackTest;
use function Facebook\FBExpect\expect;

class DefinitionTest extends HackTest {
  public function testResolve(): void {
    $container = new Sweet\ServiceContainer();
    $definition = new Sweet\Definition(
      Examples\Foo::class,
      new Examples\FooFactory(),
      false,
    );

    expect($definition->resolve($container))->toBeInstanceOf(
      Examples\Foo::class,
    );
  }

  public function testSharedAndNonSharedResolve(): void {
    $container = new Sweet\ServiceContainer();
    $definition = new Sweet\Definition(
      Examples\Foo::class,
      new Examples\FooFactory(),
      true,
    );

    expect($definition->resolve($container))->toBeSame(
      $definition->resolve($container),
    );

    $definition->setShared(false);

    expect($definition->resolve($container))->toNotBeSame(
      $definition->resolve($container),
    );
  }

  public function testIsShared(): void {
    $definition = new Sweet\Definition(
      Examples\Foo::class,
      new Examples\FooFactory(),
      false,
    );

    expect($definition->isShared())->toBeFalse();
  }

  public function testSetShared(): void {
    $definition = new Sweet\Definition(
      Examples\Foo::class,
      new Examples\FooFactory(),
      false,
    );

    $definition->setShared();
    expect($definition->isShared())->toBeTrue();

    $definition->setShared(false);
    expect($definition->isShared())->toBeFalse();

    $definition->setShared(true);
    expect($definition->isShared())->toBeTrue();
  }

  public function testGetService(): void {
    $definition = new Sweet\Definition(
      Examples\Foo::class,
      new Examples\FooFactory(),
      false,
    );

    expect($definition->getService())
      ->toBeSame(Examples\Foo::class);
  }

  public function testGetFactory(): void {
    $factory = new Examples\FooFactory();
    $definition = new Sweet\Definition(Examples\Foo::class, $factory, false);

    expect($definition->getFactory())
      ->toBeSame($factory);
  }

  public function testSetFacotry(): void {
    $container = new Sweet\ServiceContainer();
    $definition = new Sweet\Definition(
      Examples\Foo::class,
      new Examples\FooFactory(),
      false,
    );

    $definition->setFactory(Sweet\factory(($container) ==> {
      return new Examples\Foo('bar');
    }));

    $resolved = $definition->resolve($container);

    expect($resolved->baz)->toBeSame('bar');
  }

  public function testSharedDefinitionResetsResolvedInstanceAfterChangingFactory(
  ): void {
    $container = new Sweet\ServiceContainer();
    $definition = new Sweet\Definition(
      Examples\Foo::class,
      new Examples\FooFactory(),
      true,
    );

    $foo = $definition->resolve($container);

    expect($foo->baz)->toBeSame('sweet');

    $definition->setFactory(Sweet\factory(($container) ==> {
      return new Examples\Foo('bar');
    }));

    $resolved = $definition->resolve($container);

    expect($resolved)->toNotBeSame($foo);
    expect($resolved->baz)->toBeSame('bar');
  }

  public function testInflect(): void {
    $container = new Sweet\ServiceContainer();
    $definition = new Sweet\Definition(
      Examples\Foo::class,
      new Examples\FooFactory(),
      false,
    );

    $definition->inflect((Examples\Foo $foo): Examples\Foo ==> {
      $foo->baz = 'hello';
      return $foo;
    });

    $foo = $definition->resolve($container);

    expect($foo->baz)
      ->toBeSame('hello');
  }
}
