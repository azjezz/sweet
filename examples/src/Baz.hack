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
