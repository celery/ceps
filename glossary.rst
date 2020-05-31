========
Glossary
========

.. glossary::

  Message Broker
    `Enterprise Integration Patterns`_ defines a `Message Broker`_ as an architectural
    building block that can receive :term:`messages <Message>` from
    multiple destinations, determine the correct destination and route the message
    to the correct channel.

  Message
    `Enterprise Integration Patterns`_ defines a `Message`_ as  data record that
    the messaging system can transmit through a message channel.

  Command Message
    `Enterprise Integration Patterns`_ defines a `Command Message`_ as a
    :term:`Message` which instructs a worker to execute a task.

  Event Message
    `Enterprise Integration Patterns`_ defines an `Event Message`_ as a
    :term:`Message` which indicates that an event has occurred.

  Document Message
    `Enterprise Integration Patterns`_ defines a `Document Message`_ as a
    :term:`Message` containing data from a data source.

  Service Activator
    `Enterprise Integration Patterns`_ defines a `Service Activator`_ as a
    one-way (request only) or two-way (request-reply) adapter between the
    :term:`Message` and the service it invokes.
    The service can be a simple as a method call.
    The activator handles all of the messaging details and invokes the service
    like any other client, such that the service doesn’t even know it’s being
    invoked through messaging.

  Idempotent Receiver
    `Enterprise Integration Patterns`_ defines an `Idempotent Receiver`_ as a
    component that can safely receive the same message multiple times
    but will produce the same side effects when facing duplicated messages.

  Message Dispatcher

    `Enterprise Integration Patterns`_ defines a `Message Dispatcher`_ as a
    component that will consume messages from a channel and distribute them to
    performers.

  Circuit Breaker
    Martin Fowler defines a `Circuit Breaker`_ in the following fashion:

      The basic idea behind the circuit breaker is very simple.
      You wrap a protected function call in a circuit breaker object, which monitors
      for failures.
      Once the failures reach a certain threshold, the circuit breaker trips,
      and all further calls to the circuit breaker return with an error,
      without the protected call being made at all.
      Usually you'll also want some kind of monitor alert if the circuit breaker
      trips.

  CAP Theorem
    TODO

  Availability
    TODO

  Fault Tolerance
    TODO

  Network Resilience
    According to Wikipedia `Network Resilience`_ is:

      In computer networking: resilience is the ability to provide and maintain
      an acceptable level of service in the face of faults and challenges to
      normal operation.”
      Threats and challenges for services can range from simple misconfiguration
      over large scale natural disasters to targeted attacks.
      As such, network resilience touches a very wide range of topics.
      In order to increase the resilience of a given communication network,
      the probable challenges and risks have to be identified
      and appropriate resilience metrics have to be defined
      for the service to be protected.

  Consistency
    TODO

  Network Partition Tolerance
    TODO

  Monitoring
    According to `fastly`_ monitoring is:

      The activity of observing the state of a system over time.
      It uses instrumentation for problem detection, resolution,
      and continuous improvement.
      Monitoring alerts are reactive–they tell you when a known issue has
      already occurred
      (i.e. maybe your available memory is too low or you need more compute).
      Monitoring provides automated checks that you can execute against a
      distributed system to make sure that none of the things you predicted
      signify any trouble.
      While monitoring these known quantities is important,
      the practice also has limitations, including the fact that you are only
      looking for known issues. Which begs an important question,
      “what about the problems that you didn’t predict?”

  Observability
    According to Wikipedia in the context of control theory `Observability`_ is:

      In control theory, observability is a measure of how well internal states
      of a system can be inferred from knowledge of its external outputs.

    In the context of distributed systems observability is a super-set of
    :term:`Monitoring`.

    According to `fastly`_ the three pillars of observability are:

      Logs: Logs are a verbose representation of events that have happened.
      Logs tell a linear story about an event using string processing
      and regular expressions.
      A common challenge with logs is that if you haven’t properly indexed
      something, it will be difficult to find due to the sheer volume of
      log data.
      Traces: A trace captures a user’s journey through your application.
      Traces provide end-to-end visibility and are useful when you need to
      identify which components cause system errors, find performance
      bottlenecks, or monitor flow through modules.
      Metrics: Metrics can be either a point in time or monitored over
      intervals.
      These data points could be counters, gauges, etc.
      They typically represent data over intervals, but sometimes sacrifice
      details of an event in order to present data that is easier to assimilate.

  Structured Logging
    Structured Logging is a method to make log messages easy to process
    by machines.
    A usual log message is a timestamp, level and a message string.
    The context describing the logged event is embedded inside the message
    string.
    A structured log message store their context in a predetermined message
    format which allows machines to parse them more easily.

  JSON
    JSON stands for JavaScript Object Notation, which is a way to format data so
    that it can be transmitted from one place to another, most commonly between
    a server and a Web application.

  stdout
    Stdout, also known as standard output, is the default file descriptor
    where a process can write output.

  Service Locator
    Martin Fowler defines a `Service Locator`_ in the following fashion:

      The basic idea behind a service locator is to have an object that knows
      how to get hold of all of the services that an application might need.
      So a service locator for this application would have a method that returns
      a movie finder when one is needed.

  GIL
    The Global Interpreter Lock, abbreviated as the `GIL`_ is a mutex which
    prevents executing threads in parallel if both are about to execute a python
    bytecode.

    This is by design since Python has many atomic operations and maintaining
    individual locks on each object results in slower execution.

    Depending on the implementation, a thread may be forced to release the `GIL`_
    when a condition is met. In CPython's implementation of Python 3,
    a thread is forced to release the `GIL`_ after a it executes for a period of
    time.

    A thread may also release the `GIL`_ voluntarily when it uses a system call
    or when a C extension instructs to do so.

  IPC
    According to Wikipedia `Inter-process Communication`_:

      refers specifically to the mechanisms an operating system provides to allow
      the processes to manage shared data.
      Typically, applications can use IPC, categorized as clients and servers,
      where the client requests data and the server responds to client requests.
      Many applications are both clients and servers, as commonly seen in
      distributed computing.

      There are many `approaches <https://en.wikipedia.org/wiki/Inter-process_communication#Approaches>`_
      to IPC. Some of them are available in all operating systems, some are
      only available in specific operating systems.

  Task
    A task is a unit of business logic that is completely independent and can be
    executed regardless of the execution platform.

  Domain Model
    Martin Fowler defines a `Domain Model`_ in the following fashion:

      An object model of the domain that incorporates both behavior and data.

  Domain Event
    Martin Fowler defines a `Domain Event`_ in the following fashion:

      I go to Babur's for a meal on Tuesday, and pay by credit card.
      This might be modeled as an event, whose event type is 'make purchase',
      whose subject is my credit card, and whose occurred date is Tuesday.
      If Babur's uses an old manual system and doesn't transmit the transaction
      until Friday, the noticed date would be Friday.

      Things happen. Not all of them are interesting, some may be worth
      recording but don't provoke a reaction.
      The most interesting ones cause a reaction.
      Many systems need to react to interesting events.
      Often you need to know why a system reacts in the way it did.

      By funneling inputs to a system into streams of Domain Event you can keep
      a record of all the inputs to a system.
      This helps you organize your processing logic, and also allows you to keep
      an audit log of the inputs to the system.

  Ubiquitous Language
    TODO


Copyright
=========

This document has been placed in the public domain per the Creative Commons
CC0 1.0 Universal license (https://creativecommons.org/publicdomain/zero/1.0/deed).

.. _CAP theorem: https://dzone.com/articles/understanding-the-cap-theorem
.. _Enterprise Integration Patterns: https://www.enterpriseintegrationpatterns.com
.. _Message: https://www.enterpriseintegrationpatterns.com/patterns/messaging/Message.html
.. _Command Message: https://www.enterpriseintegrationpatterns.com/patterns/messaging/CommandMessage.html
.. _Event Message: https://www.enterpriseintegrationpatterns.com/patterns/messaging/EventMessage.html
.. _Document Message: https://www.enterpriseintegrationpatterns.com/patterns/messaging/DocumentMessage.html
.. _Message Dispatcher: https://www.enterpriseintegrationpatterns.com/patterns/messaging/MessageDispatcher.html
.. _ubiquitous language: https://martinfowler.com/bliki/UbiquitousLanguage.html
.. _Message Broker: https://www.enterpriseintegrationpatterns.com/patterns/messaging/MessageBroker.html
.. _Circuit Breaker: https://martinfowler.com/bliki/CircuitBreaker.html
.. _Network Resilience: https://en.wikipedia.org/wiki/Resilience_(network)
.. _Observability: https://en.wikipedia.org/wiki/Observability
.. _fastly: https://www.fastly.com/blog/monitoring-vs-observability
.. _Service Locator: https://martinfowler.com/articles/injection.html#UsingAServiceLocator
.. _Service Activator: https://www.enterpriseintegrationpatterns.com/patterns/messaging/MessagingAdapter.html
.. _Idempotent Receiver: https://www.enterpriseintegrationpatterns.com/patterns/messaging/IdempotentReceiver.html
.. _Inter-process Communication: https://en.wikipedia.org/wiki/Inter-process_communication
.. _Domain Event: https://martinfowler.com/eaaDev/DomainEvent.html
.. _Domain Model: https://martinfowler.com/eaaCatalog/domainModel.html
.. _GIL: https://realpython.com/python-gil/