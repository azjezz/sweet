/*
 * This file is part of the Sweet package.
 *
 * (c) Saif Eddin Gmati <azjezz@protonmail.com>
 *
 * For the full copyright and license information, please view the LICENSE
 * file that was distributed with this source code.
 */

namespace Sweet;

function factory<T>(
  (function(ServiceContainerInterface): T) $factory,
): Factory<T> {
  return new _Private\CallableFactoryDecorator($factory);
}

function container(): ServiceContainer {
  return new ServiceContainer();
}

function locator<T>(
  Container<typename<T>> $services,
  ServiceContainerInterface $container,
): ServiceLocator {
  return new ServiceLocator($services, $container);
}
