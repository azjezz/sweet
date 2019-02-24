namespace Sweet\Test;

use namespace Sweet;
use namespace Sweet\Examples;
use type Facebook\HackTest\HackTest;
use function Facebook\FBExpect\expect;

class ServiceLocatorTest extends HackTest {
  public function testHas(): void {
    $container = Sweet\container();
    $container->register(new Examples\ExamplesServiceProvider());
    $locator = new Sweet\ServiceLocator(
      vec[Examples\Foo::class, Examples\Bar::class],
      $container,
    );

    expect($locator->has(Examples\Foo::class))->toBeTrue();
    expect($locator->has(Examples\Bar::class))->toBeTrue();
    expect($locator->has(Examples\Baz::class))->toBeFalse();
  }

  public function testHasReturnsFalseWhenTheContainerDoesntContainTheService(
  ): void {
    $container = Sweet\container();
    $locator = new Sweet\ServiceLocator(
      vec[Examples\Foo::class, Examples\Bar::class],
      $container,
    );

    expect($locator->has(Examples\Foo::class))->toBeFalse();
    expect($locator->has(Examples\Bar::class))->toBeFalse();
  }

  public function testGet(): void {
    $container = Sweet\container();
    $container->register(new Examples\ExamplesServiceProvider());
    $locator = new Sweet\ServiceLocator(
      vec[Examples\Foo::class, Examples\Bar::class],
      $container,
    );
    $foo = $container->get(Examples\Foo::class);
    $bar = $container->get(Examples\Bar::class);

    expect($locator->get(Examples\Foo::class))->toBeSame($foo);
    expect($locator->get(Examples\Bar::class))->toBeSame($bar);
  }

  public function testGetThrowsWhenTheLocatorDoesntContainTheServiceButTheContainerDoes(
  ): void {
    $container = Sweet\container();
    $container->register(new Examples\ExamplesServiceProvider());
    $locator = new Sweet\ServiceLocator(
      vec[Examples\Foo::class, Examples\Bar::class],
      $container,
    );

    expect(() ==> {
      $locator->get(Examples\Baz::class);
    })->toThrow(
      Sweet\Exception\ServiceNotFoundException::class,
      'Service (Sweet\Examples\Baz) not found: even though it exists in the service container.',
    );
  }

  public function testGetThrowsWhentTheLocatorIsEmpty(): void {
    $container = Sweet\container();
    $locator = new Sweet\ServiceLocator(vec[], $container);

    expect(() ==> {
      $locator->get(Examples\Baz::class);
    })->toThrow(
      Sweet\Exception\ServiceNotFoundException::class,
      'Service (Sweet\Examples\Baz) not found: the current service locator is empty...',
    );
  }

  public function testGetThrowsWhenTheLocatorDoesntContainTheService(): void {
    $container = Sweet\container();
    $locator = new Sweet\ServiceLocator(
      vec[Examples\Foo::class, Examples\Bar::class],
      $container,
    );

    expect(() ==> {
      $locator->get(Examples\Baz::class);
    })->toThrow(
      Sweet\Exception\ServiceNotFoundException::class,
      'Service (Sweet\Examples\Baz) not found: the current service locator only knows about the '.
      'Sweet\Examples\Foo, Sweet\Examples\Bar services.',
    );
  }
}
