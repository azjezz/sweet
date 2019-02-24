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
