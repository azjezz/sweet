# Sweet

Sweet, a strict typed hack service container and locator !

<p align="center">
<a href="https://travis-ci.org/azjezz/sweet"><img src="https://travis-ci.org/azjezz/sweet.svg" alt="Build Status"></a>
<a href="https://packagist.org/packages/azjezz/sweet"><img src="https://poser.pugx.org/azjezz/sweet/d/total.svg" alt="Total Downloads"></a>
<a href="https://packagist.org/packages/azjezz/sweet"><img src="https://poser.pugx.org/azjezz/sweet/v/stable.svg" alt="Latest Stable Version"></a>
<a href="https://packagist.org/packages/azjezz/sweet"><img src="https://poser.pugx.org/azjezz/sweet/license.svg" alt="License"></a>
</p>

---

## Installation

This package can be install with Composer.

```console
$ composer install azjezz/sweet
```

## Usage

Creating a container is a matter of creating a `ServiceContainer` instance:

```hack

use namespace Sweet;

$container = new Sweet\ServiceContainer();

// or functionally

$container = Sweet\container();

```

### Defining Services

A service is an object that does something as part of a larger system. Examples of services: a database connection, a templating engine, or a mailer. Almost any *global* object can be a service.

Services are defined by factories that return an instance of an object:

```hack

use namespace Sweet;

class SessionStorageFactory implements Sweet\Factory<SessionStorage> {
  public function create(
    Sweet\ServiceContainerInterface $container
  ): SessionStorage {
    return new SessionStorage('SESSION_ID');
  }
}

class SessionFactory implements Sweet\Factory<Session> {
  public function create(
    Sweet\ServiceContainerInterface $container
  ): Session {
    return new Session(
      $container->get(SessionStorage::class)
    );
  }
}

// later :

$container = new Sweet\Container();
$container->add(
  Session::class,
  new SessionFactory(),
);
$container->add(
  SessionStorage::class,
  new SessionStorageFactory(),
);
```

Notice that the factory has access to the current container instance, allowing references to other services.

You can also create a factory from a function using the `Sweet\factory()` helper.

```hack
$container = new Sweet\Container();

// lambda
$container->add(Session::class, Sweet\factory(($container) ==>
  new Session(
    $container->get(SessionStorage::class)
  )
));

// anonymous function / closure
$container->add(Session::class, Sweet\factory(function($container) {
  return new Session(
    $container->get(SessionStorage::class)
  );
}));

// function
$container->add(Session::class, Sweet\factory(fun('session_factory')));

// static method
$container->add(Session::class, Sweet\factory(class_meth(Factory::class, 'createSession')));

// object method
$container->add(Session::class, Sweet\factory(inst_meth($factory, 'createSession')));
```

As objects are only created when you get them, the order of the definitions does not matter.

Using the defined services is also very easy:

```hack
// get the session object
$session = $container->get(Session::class);

// the above call is roughly equivalent to the following code:
// $storage = new SessionStorage('SESSION_ID');
// $session = new Session($storage);
```

### Shared Services

Each time you get a service, Sweet returns a new instance of it. If you want the same instance to be returned for all calls, set the `shared` argument to true or use the `->share()` proxy.

```hack
$container = new Sweet\Container();
$container->add(
  Session::class,
  new SessionFactory(),
  true, // shared
);

/**
 * Proxy to add with shared as true.
 */
$container->share(
  Session::class,
  new SessionFactory(),
);
```

Now each call to `$container->get(Session::class);` will return the same instance of the session.

### Defining Parameters

Defining a parameter allows to ease the configuration of your container from the outside and to store global values:

```hack

newtype SessionCookieName = string;

$container->share(SessionCookieName::class, Sweet\factory(($container) ==> {
  return 'SESSION_ID';
}));

$container->share(SessionStorage::class, Sweet\factory(($container) ==> {
  return new SessionStorage(
    $container->get(SessionCookieName::class)
  );
}));

$container->share(Session::class, Sweet\factory(($container) ==> {
  return new Session(
    $container->get(SessionStorage::class)
  );
}));

$session = $container->get(Session::class);

```

You can now easily change the cookie name by overriding the `SessionCookieName` parameter instead of redefining the service definition.

### Service Providers

Service providers give the benefit of organising your container definitions along with an increase in performance for larger applications as definitions registered within a service provider are lazily registered at the point where a service is retrieved.

To build a service provider it is as simple as implementing the service provider interface and defining what you would like to register.

```hack
namespace App;

use namespace Sweet;
use namespace HH\Lib\C;

final class SessionServiceProvider extends Sweet\ServiceProvider {
  /**
   * The provided container is a way to let the service
   * container know that a service is provided by this
   * service provider.
   * Every service that is registered via this service
   * provider must have an alias added to this vector
   * or it will be ignored.
   */
  protected Container<string> $provides = vec[
    SessionCookieName::class,
    SessionStorage::class,
    Session::class
  ];

  /**
   * This is where the magic happens, within the method you can
   * access the container and register or retrieve anything
   * that you need to, but remember, every alias registered
   * within this method must be declared in the `$provides` container.
   */
  public function register(
    Sweet\ServiceContainer $container
  ): void {
    $container->share(SessionCookieName::class, Sweet\factory(($container) ==> {
      return 'SESSION_ID';
    }));

    $container->share(SessionStorage::class, Sweet\factory(($container) ==> {
      return new SessionStorage(
        $container->get(SessionCookieName::class)
      );
    }));

    $container->share(Session::class, Sweet\factory(($container) ==> {
      return new Session(
        $container->get(SessionStorage::class)
      );
    }));
  }
}
```

To register this service provider with the container simply pass an instance of your provider to the `register` method.

```hack

$container = new Sweet\Container();
$container->register(new SessionServiceProvider());

```

The `register` method is not invoked until one of the aliases in the `$provides` container is requested by the service container, therefore, when we want to retrieve one of the items provided by the service provider, it will not actually be registered until it is needed, this improves performance for larger applications as your dependency map grows.

### Definitions

Definitions are how `ServiceContainer` describes your dependency map internally. Each definition contains information on how to build your service.

Generally, `ServiceContainer` will handle everything that is required to build a definition for you. When you invoke `add`, a `Definition` is built and returned meaning any further interaction is actually with the `Definition`, not `ServiceContainer`.

```hack
$definition = $container->add(Session::class, $factory);

assert($definition is Sweet\Definition);
```

You can also extend a definition if needed.

```hack
$container->add(Session::class, $factory);

$definition = $container->extend(Session::class);

$definition->inflect(($session) ==> {
  $session->setStorage(
    $container->get(RedisSessionStorage::class)
  );

  return $session;
});

```

> *Note*: you can't call `extend()` for services that are registered via a
> service provider.

Creating definitions manually and passing them to the container is also possible.

```hack
$definition = new Sweet\Definition($service, $factory, $shared);

$container->addDefinition($definition);

$definition = $container->extend($service);
```

We can tell a definition to only resolve once and return the same instance every time it is resolved.

```hack
$container->add($service, $factory)
  ->setShared();
```

In some cases you may want to modify a service definition after it has been defined. You can use the `inflect` method to define additional code to be run on your service just after it is created:

```hack
$definition->inflect(($service) ==> {
  // do something to the service
  return $service;
});
```

### Service Locators

Some Services need access to serveral other services.
The traditional solution in those cases was to inject the entire service container to get the services really needed.
However, this is not recommended because it gives services too broad access to the rest of the application and it hides the actual dependencies of the services.

[Service locators](https://en.wikipedia.org/wiki/Service_locator_pattern) are a design pattern that "encapsulate the processes involved in obtaining a service [...] using a central registry known as the service locator". This pattern is often discouraged, but it's useful in these cases and it's way better than injecting the entire service container.

Consider a `RouteDispatcher` class that maps routes and their handlers.
This class dispatches only one route handler at a time, so it's useless to instantiate all of them.

First, define a service locator service with a newtype and add all the request handler to it.

```hack
newtype RequestHandlersLocator = Sweet\ServiceLocator;

$container->add(RequestHandlersLocator::class, Sweet\factory(($container) ==> {
  $handlers = vec[
    HomeHandler::class,
    PostHandler::class,
    CommentHandler::class,
    LoginHandler::class,
    RegistrationHandler::class,
    ProfileHandler::class,
    SettingsHandler::class,
  ];
  return new Sweet\ServiceLocator($handlers, $container);
}));

```

Then, inject the service locator into the service definition for the route dispatcher:

```hack
$container->add(RouteDispatcher::class, Sweet\factory(($container) ==> {
  return new RouteDispatcher(
    $container->get(RequestHandlersLocator::class)
  );
}));
```

The injected service locator is an instance of `Sweet\ServiceLocator`. This class implements the `Sweet\ServiceContainerInterface`, which includes the `has()` and `get()` methods to check and get services from the locator:

```hack
use namespace HH\Lib\Str;
use type Sweet\ServiceContainerInterface;
use type Nuxed\Contract\Http\Message\ResponseInterface;
use type Nuxed\Contract\Http\Message\ServerRequestInterface;
use type Nuxed\Contract\Http\Server\RequestHandlerInterface;

final class RouteDispatcher {
  public function __construct(
    private ServiceContainerInterface $locator
  ) {}

  public function dispatch<T as RequestHandlerInterface>(
    classname<T> $handler,
    ServerRequestInterface $request,
  ): ResponseInterface {
    if (!$this->locator->has($handler)) {
      throw new NotFoundException(Str\format(
        'Handler (%s) is not registered in the container.'
      ), $handler);
    }

    $handler = $this->locator->get($handler);
    return $handler->handle($request);
  }
}
```

---

## Security Vulnerabilities

If you discover a security vulnerability within Sweet, please send an e-mail to Saif Eddin Gmati via azjezz@protonmail.com.

---

## License

The Sweet Project is open-sourced software licensed under the MIT-licensed.
