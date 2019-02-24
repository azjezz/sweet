namespace Sweet;

interface ServiceContainerInterface {
  public function get<T>(typename<T> $id): T;

  public function has<T>(typename<T> $id): bool;
}
