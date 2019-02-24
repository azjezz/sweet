namespace Sweet;

use namespace HH\Lib\C;
use namespace HH\Lib\Str;
use type Exception;
use function get_class;

final class ServiceContainer implements ServiceContainerInterface {
  private dict<string, mixed> $definitions = dict[];
  private vec<ServiceContainerInterface> $delegates = vec[];
  private vec<ServiceProvider> $providers = vec[];

  public function get<T>(typename<T> $service): T {
    if (C\contains_key($this->definitions, $service)) {
      $def = $this->definitions[$service] as Definition<_>;
      try {
        // UNSAFE
        return $def->resolve($this);
      } catch (Exception $e) {
        throw new Exception\ServiceContainerException(
          Str\format(
            'Exception thrown while trying to create service (%s) : %s',
            $service,
            $e->getMessage(),
          ),
          $e->getCode(),
          $e,
        );
      }
    }

    foreach ($this->providers as $provider) {
      if ($provider->provide($service)) {
        $provider->register($this);
        // prevent stackoverflow
        if (!C\contains_key($this->definitions, $service)) {
          throw new Exception\ServiceContainerException(Str\format(
            'Service provider (%s) lied about providing (%s) service.',
            get_class($provider),
            $service,
          ));
        }

        return $this->get($service);
      }
    }

    foreach ($this->delegates as $container) {
      if ($container->has($service)) {
        return $container->get($service);
      }
    }

    throw new Exception\ServiceNotFoundException(Str\format(
      'Service (%s) is not managed by the service container or delegates.',
      $service,
    ));
  }

  public function has<T>(typename<T> $service): bool {
    if (C\contains_key($this->definitions, $service)) {
      return true;
    }

    foreach ($this->providers as $provider) {
      if ($provider->provide($service)) {
        return true;
      }
    }

    foreach ($this->delegates as $container) {
      if ($container->has($service)) {
        return true;
      }
    }

    return false;
  }

  /**
   * Proxy to add with shared as true.
   */
  public function share<T>(
    typename<T> $service,
    Factory<T> $factory,
  ): Definition<T> {
    return $this->add($service, $factory, true);
  }

  /**
   * Add a service entry to the container.
   */
  public function add<T>(
    typename<T> $service,
    Factory<T> $factory,
    bool $shared = false,
  ): Definition<T> {
    return $this->addDefinition(new Definition($service, $factory, $shared));
  }

  public function addDefinition<T>(Definition<T> $definition): Definition<T> {
    $this->definitions[$definition->getService()] = $definition;
    return $definition;
  }

  /**
   * Get a service entry to extend.
   */
  public function extend<T>(typename<T> $service): Definition<T> {
    if (!C\contains_key($this->definitions, $service)) {
      throw new Exception\ServiceNotFoundException(Str\format(
        'Service (%s) is not managed by the service container.',
        $service,
      ));
    }
    // UNSAFE
    return $this->definitions[$service];
  }

  /**
   * Delegate a backup container to be checked for services if it
   * cannot be resolved via this container.
   */
  public function delegate(ServiceContainerInterface $container): this {
    $this->delegates[] = $container;
    return $this;
  }

  public function register(ServiceProvider $provider): this {
    $this->providers[] = $provider;
    return $this;
  }
}
