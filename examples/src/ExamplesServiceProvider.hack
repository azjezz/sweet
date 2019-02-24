/*
 * This file is part of the Sweet package.
 *
 * (c) Saif Eddin Gmati <azjezz@protonmail.com>
 *
 * For the full copyright and license information, please view the LICENSE
 * file that was distributed with this source code.
 */

namespace Sweet\Examples;

use namespace Sweet;

class ExamplesServiceProvider extends Sweet\ServiceProvider {
  protected Container<string> $provides = vec[
    Foo::class,
    Bar::class,
    Baz::class,
  ];

  public function register(Sweet\ServiceContainer $container): void {
    $container->share(Foo::class, new FooFactory());
    $container->share(Bar::class, new BarFactory());
    $container->share(Baz::class, new BazFactory());
  }
}
