/*
 * This file is part of the Sweet package.
 *
 * (c) Saif Eddin Gmati <azjezz@protonmail.com>
 *
 * For the full copyright and license information, please view the LICENSE
 * file that was distributed with this source code.
 */

namespace Sweet\_Private;

use type Sweet\Factory;
use type Sweet\ServiceContainerInterface;

final class CallableFactoryDecorator<T> implements Factory<T> {
  public function __construct(
    private (function(ServiceContainerInterface): T) $factory,
  ) {}

  public function create(ServiceContainerInterface $container): T {
    $fun = $this->factory;
    return $fun($container);
  }
}
