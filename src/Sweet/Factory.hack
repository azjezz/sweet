namespace Sweet;

interface Factory<T> {
  public function create(ServiceContainerInterface $container): T;
}
