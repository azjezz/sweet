namespace Sweet\Examples;

use namespace Sweet;
use namespace Facebook;

require_once __DIR__.'/../vendor/autoload.hack';

newtype RequestHandlersLocator = Sweet\ServiceLocator;

<<__EntryPoint>>
async function invariant(): Awaitable<void> {
  Facebook\AutoloadMap\initialize();

  $container = new Sweet\ServiceContainer();
  $container->register(new ExamplesServiceProvider());

  $services = vec[Foo::class, Bar::class];
  $locator = new Sweet\ServiceLocator($services, $container);

  invariant($container->has(Foo::class), '1. Error');
  invariant($container->has(Bar::class), '2. Error');
  invariant($container->has(Baz::class), '3. Error');

  invariant($locator->has(Foo::class), '4. Error');
  invariant($locator->has(Bar::class), '5. Error');

  invariant($locator->has(Baz::class) === false, '6. Error');

  invariant(
    $container->get(Foo::class) === $container->get(Foo::class),
    '7. Error',
  );
  invariant(
    $container->get(Bar::class) === $container->get(Bar::class),
    '8. Error',
  );
  // baz is not shaerd
  invariant(
    $container->get(Baz::class) !== $container->get(Baz::class),
    '9. Error',
  );

  invariant(
    $locator->get(Foo::class) === $container->get(Foo::class),
    '10. Error',
  );
  invariant(
    $locator->get(Bar::class) === $container->get(Bar::class),
    '11. Error',
  );

  try {
    $baz = $locator->get(Baz::class);
    invariant_violation('12. Error');
  } catch (Sweet\Exception\ServiceNotFoundException $e) {
    // Sweet :)
    invariant(
      'Service (Examples\Baz) not found: even though it exists in the service container.' ===
        $e->getMessage(),
      '13. Error',
    );
  }

  echo "Success.\n";
}
