namespace Sweet;

use namespace HH\Lib\C;
use namespace HH\Lib\Str;
use type Exception;

final class ServiceContainer implements ServiceContainerInterface {
  private dict<string, mixed> $entries = dict[];
  private vec<ServiceContainerInterface> $delegates = vec[];

  public function get<T>(classname<T> $service): T {
    if (C\contains_key($this->entries, $service)) {
      $entry = $this->entries[$service] as Entry<_>;
      try {
        // UNSAFE
        return $entry->resolve($this);
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

  public function has<T>(classname<T> $service): bool {
    if (C\contains_key($this->entries, $service)) {
      return true;
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
  public function share<T>(classname<T> $service, Factory<T> $factory): void {
    $this->add($service, $factory, true);
  }

  /**
   * Add a service entry to the container.
   */
  public function add<T>(
    classname<T> $service,
    Factory<T> $factory,
    bool $shared = false,
  ): Entry<T> {
    return $this->entries[$service] = new Entry($service, $factory, $shared);
  }

  /**
   * Get a service entry to extend.
   */
  public function extend<T>(classname<T> $service): Entry<T> {
    if (!C\contains_key($this->entries, $service)) {
      throw new Exception\ServiceNotFoundException(Str\format(
        'Service (%s) is not managed by the service container.',
        $service,
      ));
    }
    // UNSAFE
    return $this->entries[$service];
  }

  /**
   * Delegate a backup container to be checked for services if it
   * cannot be resolved via this container.
   */
  public function delegate(ServiceContainerInterface $container): this {
    $this->delegates[] = $container;
    return $this;
  }
}
