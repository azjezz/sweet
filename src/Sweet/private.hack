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
