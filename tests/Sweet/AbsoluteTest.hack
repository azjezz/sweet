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

class AbsoluteTest extends HackTest {
  public function testContainer(): void {
    $container = Sweet\container();

    expect($container)
      ->toBeInstanceOf(Sweet\ServiceContainer::class);
  }

  public function testFactory(): void {
    $container = Sweet\container();
    $factory = Sweet\factory(($container) ==> {
      return new Examples\Foo('herp');
    });
    $foo = $factory->create($container);

    expect($foo->baz)
      ->toBeSame('herp');
  }

  public function testLocator(): void {
    $container = Sweet\container();
    $container->add(Examples\Foo::class, new Examples\FooFactory());
    $container->add(Examples\Bar::class, new Examples\BarFactory());
    $container->add(Examples\Baz::class, new Examples\BazFactory());

    $services = vec[
      Examples\Foo::class,
      Examples\Bar::class,
    ];
    $locator = Sweet\locator($services, $container);

    expect($locator->has(Examples\Foo::class))->toBeTrue();
    expect($locator->has(Examples\Bar::class))->toBeTrue();
    expect($locator->has(Examples\Baz::class))->toBeFalse();
  }
}
