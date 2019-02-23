namespace Sweet;

interface ServiceContainerInterface {
  public function get<T>(classname<T> $id): T;

  public function has<T>(classname<T> $id): bool;
}
