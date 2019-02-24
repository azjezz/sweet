/*
 * This file is part of the Sweet package.
 *
 * (c) Saif Eddin Gmati <azjezz@protonmail.com>
 *
 * For the full copyright and license information, please view the LICENSE
 * file that was distributed with this source code.
 */

namespace Sweet\Test;

use namespace Sweet;
use namespace Sweet\Examples;
use type Facebook\HackTest\HackTest;
use function Facebook\FBExpect\expect;

class ServiceContainerTest extends HackTest {
  public function testAdd(): void {
    $container = new Sweet\ServiceContainer();
    $definition =
      $container->add(Examples\Foo::class, new Examples\FooFactory(), true);

    expect($definition->isShared())->toBeTrue();
    expect($container->has(Examples\Foo::class))->toBeTrue();

    $definition =
      $container->add(Examples\Bar::class, new Examples\BarFactory(), false);

    expect($definition->isShared())->toBeFalse();
    expect($container->has(Examples\Bar::class))->toBeTrue();

    $factory = new Examples\BazFactory();
    $definition = $container->add(Examples\Baz::class, $factory, false);

    expect($container->has(Examples\Baz::class))->toBeTrue();
    expect($definition->isShared())->toBeFalse();
    expect($definition->getService())->toBeSame(Examples\Baz::class);
    expect($definition->getFactory())->toBeSame($factory);
  }

  public function testShare(): void {
    $container = new Sweet\ServiceContainer();
    $factory = new Examples\BazFactory();
    $definition = $container->share(Examples\Baz::class, $factory);

    expect($definition->isShared())->toBeTrue();
    expect($definition->getService())->toBeSame(Examples\Baz::class);
    expect($definition->getFactory())->toBeSame($factory);
  }

  public function testAddDefinition(): void {
    $container = new Sweet\ServiceContainer();
    $definition = new Sweet\Definition(
      Examples\Baz::class,
      new Examples\BazFactory(),
      false,
    );
    $container->addDefinition($definition);

    expect($container->has(Examples\Baz::class))->toBeTrue();
  }

  public function testGet(): void {
    $container = new Sweet\ServiceContainer();
    $container->add(Examples\Foo::class, new Examples\FooFactory());

    $foo = $container->get(Examples\Foo::class);

    expect($foo->baz)->toBeSame('sweet');
  }

  public function testGetThrowsWhenServiceDoesntExist(): void {
    $container = new Sweet\ServiceContainer();
    expect(() ==> $container->get(Examples\Foo::class))
      ->toThrow(
        Sweet\Exception\ServiceNotFoundException::class,
        'Service (Sweet\Examples\Foo) is not managed by the service container or delegates.',
      );
  }

  public function testGetThrowsOnlyServiceContainerExceptions(): void {
    $container = new Sweet\ServiceContainer();
    $container->add(Examples\Foo::class, Sweet\factory(($container) ==> {
      throw new \Exception('foo');
    }));
    expect(() ==> $container->get(Examples\Foo::class))
      ->toThrow(
        Sweet\Exception\ServiceContainerException::class,
        'Exception thrown while trying to create service (Sweet\Examples\Foo) : foo',
      );
  }

  public function testHas(): void {
    $container = new Sweet\ServiceContainer();
    $container->add(Examples\Foo::class, new Examples\FooFactory());

    expect($container->has(Examples\Foo::class))->toBeTrue();
    expect($container->has(Examples\Bar::class))->toBeFalse();
  }

  public function testHasChecksDelegatedContainers(): void {
    $container = new Sweet\ServiceContainer();
    $container->add(Examples\Foo::class, new Examples\FooFactory());

    expect($container->has(Examples\Foo::class))->toBeTrue();
    expect($container->has(Examples\Bar::class))->toBeFalse();

    $delegate = new Sweet\ServiceContainer();
    $delegate->add(Examples\Bar::class, new Examples\BarFactory());
    $container->delegate($delegate);

    expect($container->has(Examples\Foo::class))->toBeTrue();
    expect($container->has(Examples\Bar::class))->toBeTrue();
  }

  public function testRegister(): void {
    $container = new Sweet\ServiceContainer();
    $container->register(new Examples\ExamplesServiceProvider());

    expect($container->has(Examples\Foo::class))->toBeTrue();
    expect($container->has(Examples\Bar::class))->toBeTrue();
    expect($container->has(Examples\Baz::class))->toBeTrue();
  }

  public function testExtend(): void {
    $container = new Sweet\ServiceContainer();
    $container->add(Examples\Foo::class, new Examples\FooFactory());
    $definition = $container->extend(Examples\Foo::class);
    expect($definition->getService())->toBeSame(Examples\Foo::class);
  }

  public function testCantExtendServiceRegisteredViaAServiceProvider(): void {
    $container = new Sweet\ServiceContainer();
    $container->register(new Examples\ExamplesServiceProvider());

    expect(() ==> {
      $container->extend(Examples\Foo::class);
    })->toThrow(
      Sweet\Exception\ServiceNotFoundException::class,
      'Service (Sweet\Examples\Foo) is not managed by the service container.',
    );
  }
}
