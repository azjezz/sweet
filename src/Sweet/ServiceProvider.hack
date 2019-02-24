namespace Sweet;

use namespace HH\Lib\C;

abstract class ServiceProvider {
  protected Container<string> $provides = vec[];

  /**
   * Returns a boolean if checking whether this provider provides a specific
   * service.
   */
  final public function provide<T>(typename<T> $service): bool {
    return C\contains($this->provides, $service);
  }

  /**
   * Use the register method to register items with the container via the
   * container instance.
   */
  abstract public function register(ServiceContainer $container): void;
}
