namespace Sweet;

use namespace HH\Lib\C;
use namespace HH\Lib\Str;

final class ServiceLocator<TE> implements ServiceContainerInterface {
  public function __construct(
    private Container<classname<TE>> $entries,
    private ServiceContainer $container,
  ) {}

  public function has<T>(classname<T> $service): bool {
    return
      $this->container->has($service) && C\contains($this->entries, $service);
  }

  public function get<T>(classname<T> $service): T {
    if (!$this->has($service)) {
      $message = Str\format('Service (%s) not found: ', $service);
      if ($this->container->has($service)) {
        $message .= 'even though it exists in the inner service container.';
      } else {
        $message .= 'the current service locator ';
        if (C\count($this->entries) === 0) {
          $message .= 'is empty...';
        } else {
          $message .= Str\format(
            'only knows about the %s service%s',
            Str\join($this->entries, ', '),
            C\count($this->entries) > 1 ? 's' : '',
          );
        }
      }
      throw new Exception\ServiceNotFoundException($message);
    }

    return $this->container->get($service);
  }
}
