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

class Bar {
  public function __construct(public Foo $foo) {}
}

class BarFactory implements Sweet\Factory<Bar> {
  public function create(Sweet\ServiceContainerInterface $container): Bar {
    $foo = $container->get(Foo::class);
    return new Bar($foo);
  }
}
