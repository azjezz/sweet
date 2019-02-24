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

class Foo {
  public function __construct(public string $baz) {}
}

class FooFactory implements Sweet\Factory<Foo> {
  public function create(Sweet\ServiceContainerInterface $container): Foo {
    return new Foo('sweet');
  }
}
