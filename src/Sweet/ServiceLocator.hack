/*
 * This file is part of the Sweet package.
 *
 * (c) Saif Eddin Gmati <azjezz@protonmail.com>
 *
 * For the full copyright and license information, please view the LICENSE
 * file that was distributed with this source code.
 */

namespace Sweet;

use namespace HH\Lib\C;
use namespace HH\Lib\Str;

class ServiceLocator implements ServiceContainerInterface {
  public function __construct(
    private Container<string> $services,
    private ServiceContainerInterface $container,
  ) {}

  final public function has<T>(typename<T> $service): bool {
    return
      $this->container->has($service) && C\contains($this->services, $service);
  }

  final public function get<T>(typename<T> $service): T {
    if (!$this->has($service)) {
      $message = Str\format('Service (%s) not found: ', $service);
      if ($this->container->has($service)) {
        $message .= 'even though it exists in the service container.';
      } else {
        $message .= 'the current service locator ';
        if (C\count($this->services) === 0) {
          $message .= 'is empty...';
        } else {
          $message .= Str\format(
            'only knows about the %s service%s.',
            Str\join($this->services, ', '),
            C\count($this->services) > 1 ? 's' : '',
          );
        }
      }
      throw new Exception\ServiceNotFoundException($message);
    }

    return $this->container->get($service);
  }
}
