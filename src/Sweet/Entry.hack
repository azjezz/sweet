namespace Sweet;

final class Entry<T> {
  private vec<(function(T): T)> $inflectors;
  private ?T $resolved;

  public function __construct(
    private classname<T> $service,
    private Factory<T> $factory,
    private bool $shared,
  ) {
    $this->inflectors = vec[];
  }

  public function resolve(ServiceContainerInterface $container): T {
    if ($this->isShared() && $this->resolved is nonnull) {
      return $this->resolved;
    }

    $instance = $this->getFactory()->create($container);
    foreach ($this->inflectors as $inflector) {
      $instance = $inflector($instance);
    }

    $this->resolved = $instance;
    return $instance;
  }

  public function isShared(): bool {
    return $this->shared;
  }

  public function setShared(bool $shared): this {
    $this->shared = $shared;
    return $this;
  }

  public function getId(): classname<T> {
    return $this->service;
  }

  public function getFactory(): Factory<T> {
    return $this->factory;
  }

  public function setFactory(Factory<T> $factory): this {
    $this->factory = $factory;
    return $this;
  }

  /**
   * Allows for manipulation of specific types on resolution.
   */
  public function inflect((function(T): T) $inflector): this {
    $this->inflectors[] = $inflector;
    return $this;
  }
}
