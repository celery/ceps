==========================================
CEP XXXX: Celery 5 High Level Architecture
==========================================

:CEP: XXXX
:Author: Omer Katz
:Implementation Team: Omer Katz
:Shepherd: Omer Katz
:Status: Draft
:Type: Informational
:Created: 2019-04-08
:Last-Modified: 2019-04-08

.. contents:: Table of Contents
   :depth: 3
   :local:

Abstract
========

When Celery was conceived, production environments were radically different from today.

Nowadays most applications are (or should be):

* Deployed to a cloud provider's computing resources.
* Distributed (sometimes between data centers).
* Available or Consistent (We must pick one according to `CAP theorem`_).
* Network Partition Tolerant.
* Observable.
* Built with scalability in mind.
* Cloud Native - The application's lifecycle is managed using Kubernetes, Swarm or any other scheduler.

In addition, Celery lacks proper support for large scale deployments and some useful messaging architectural patterns.

Celery 5 is the next major version of Celery and so we are able to break backwards compatibility, even in major ways.

As such, our next major version should represent a paradigm shift in the way we implement our task execution platform.

Specification
=============

Message Types
-------------

`Enterprise Integration Patterns`_ defines multiple common message types:

* `Command Message`_ - A message which instructs a worker to execute a task.
* `Event Message`_ - A message which indicates that an event has occurred.
* `Document Message`_ - A message containing data from a data source.

In relation to Celery Command messages are the messages we publish whenever we delay a task.
Document messages are the messages we get as a result.

.. code-block:: pycon

  >>> from celery import task
  >>> @task
  ... def add(a, b):
  ...   return a + b
  >>> result = add.delay(1, 2)  # Publish a command message
  >>> result.get()  # Consume a Document message
  3

Event messages are a new concept for Celery. They describe that a domain event
occurred. Multiple tasks can be subscribed to an event.

The API presented here is a draft to be determined by another CEP:

.. code-block:: pycon

  >>> from uuid import UUID
  >>> from celery import task, event
  >>> from myapp.models import User, AccountManager
  >>> @task
  ... def send_welcome_email(user_id, email):
  ...   send_email(email=email, contents="hello, welcome", subject="welcome") # Send a welcome email to the user...
  ...   User.objects.filter(pk=user_id).update(welcome_email_sent=True)
  >>> @task
  ... def notify_account_manager(user_id, email):
  ...   account_manager = AccountManager.objects.assign_account_manager(user_id)
  ...   send_email(email=account_manager.email, contents="you have a new user to attend to", subject="Alert") # Send an email to the account manager...
  >>> @event
  ... class UserRegistered:
  ...   user_id: UUID
  ...   email: str
  >>> UserRegistered.subscribe(send_welcome_email)
  >>> UserRegistered.subscribe(notify_account_manager)
  >>> UserRegistered.delay(user_id=1, email='foo@bar.com')  # Calls both send_welcome_email and notify_account_manager with the provided arguments.

These architectural building blocks will aid us in creating a better messaging
system. To encourage `ubiquitous language`_, we will be using them in this document
and in Celery 5's codebase as well.

Message Broker
--------------

`Enterprise Integration Patterns`_ defines a `Message Broker`_ as an architectural
building block that can receive messages from
multiple destinations, determine the correct destination and route the message
to the correct channel.

Failure Resilience and Fault Tolerance
--------------------------------------

Celery 5 aims to be failure resilient and fault tolerant.
As an architectural guideline Celery must retry operations **by default**
and must avoid doing so **indefinitely and without proper limits**.

Any operation which cannot be executed either momentarily or permanently
as a result of a bug must not be retried beyond the the configured limits.
Instead, Celery must store the operation for further inspection
and if required, manual intervention.

Celery must track and automatically handle "poisonous messages" to ensure
the recovery of the Celery cluster.

Fault Tolerance
+++++++++++++++

Distributed Systems suffer from an inherent property:

  Any distributed system is unreliable.

  * The network may be unavailable or slow.
  * Some or all of the servers might suffer from a hardware failure.
  * A node in the system may arbitrarily crash
    due to lack of memory or a bug.
  * Any number of unaccounted failure modes.

Therefore, Celery must be fault tolerant and gracefully degrade it's operation
when failures occur.



Circuit Breaker
~~~~~~~~~~~~~~~

Martin Fowler defines a `Circuit Breaker`_ in the following fashion:

  | The basic idea behind the circuit breaker is very simple.
  | You wrap a protected function call in a circuit breaker object, which monitors
  | for failures.
  | Once the failures reach a certain threshold, the circuit breaker trips,
  | and all further calls to the circuit breaker return with an error,
  | without the protected call being made at all.
  | Usually you'll also want some kind of monitor alert if the circuit breaker
  | trips.

Worker
------

Protocol
++++++++

Introduction to AMQP 1.0 Terminology
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Health Checks
+++++++++++++

The Worker will perform health checks to ensure that it can execute
a task without errors.

A task may have more than one health check. However, that does not necessarily
means that if any of the health checks fail a configured number of times
it will trip a Circuit Breaker.

Task health checks have the following states:

* **Healthy** - The task will be executed without errors.
* **Degraded** - The task may fail, in which case it will be retried later.
* **Unhealthy** - The task will surely fail and thus is rejected.

A user can associate a health check with multiple Circuit Breakers.

The API for task health checks will be determined in another CEP.

Circuit Breaker
+++++++++++++++

Each task has it's own Circuit Breaker.

Whenever a circuit breaker trips, the worker will emit a warning log message.

The user will configure the following properties of the Circuit Breaker:

* How many times the health checks may fail before
  the circuit breaker trips.
* The period of time after which the circuit is yet
  again closed. That time period may grow linearly or exponentially.
* How many circuit breaker trips during a period of time should cause the worker
  to produce an error log message instead of a warning log message.
* The period of time after which the circuit breaker downgrades
  it's log level back to warning.

.. rubric:: Example

We allow 2 **Unhealthy** health checks
and/or 10 **Degraded** health checks in a period of 10 seconds.

If we cross that threshold, the circuit breaker trips.

The circuit will be closed again after 30 seconds. Afterwards, the task can
be executed again.

If 3 consequent circuit breaker trips occurred during a period of 5 minutes,
all circuit breaker trips will emit an error log message instead of a warning.

The circuit breaker will downgrade it's log level after 30 minutes.


Observability
+++++++++++++

One of Celery 5's goals is to be observable.

The Publisher will record statistics, provide trace points for application
monitoring tools and distributed tracing tools and emit log messages when
appropriate.

Metrics
~~~~~~~

Log Messages
~~~~~~~~~~~~

Log messages will be structured.
Structured logs provide context for our users which allows them to debug
problems more easily.

The Worker will be aware of it's execution platform and will format logs
accordingly.

For example, if the Worker is running using a SystemD service,
the Worker will detect that the `JOURNAL_STREAM`_ environment variable
was set and use it to transmit structured data into `journald`_.

Publisher
---------

The Publisher is responsible for publishing messages to a :ref:`message broker`.

It is responsible for publishing the message to the appropriate broker cluster
according to the configuration provided to the publisher.

The publisher must be able to run in-process inside a long-running thread
or a long running co-routine.

It can also be run using a separate daemon which can serve all the processes
publishing to the message brokers.

Health Checks
+++++++++++++

The Publisher will perform health checks to ensure that the message broker
the user is publishing to is available.

If a health check fails a configured number of times, the relevant
:ref:`Circuit Breaker` is tripped.

Each :ref:`message broker` Celery supports must provide an implementation for
the default health checks the Publisher will use for verifying its
availability for new messages.

Further health checks can be defined by the user.
These health checks allows the user to avoid publishing tasks if for example
a 3rd party API endpoint is not available or slow, if the database
the user stores the results in is available or any other check for that matter.

Circuit Breaker
+++++++++++++++

Each :ref:`health check <Health Checks>` has it's own Circuit Breaker.
Once a circuit breaker is tripped, the messages are stored
in the :ref:`messages backlog` until the health check recovers and the circuit
is once again closed.

Messages Backlog
++++++++++++++++

The messages backlog is a temporary queue of messages yet to be published to
the appropriate broker cluster.

In the event where messages cannot be published for any reason, the messages
are kept inside the queue.

By default, an in-memory queue will be used. The user may provide another
implementation which stores the messages on-disk or in a central database.

Publisher Daemon
++++++++++++++++

In sufficiently large deployments, one server runs multiple workloads which
may publish to a :ref:`message broker`.

Therefore, it is unnecessary to maintain a publisher for each process that
publishes to a :ref:`message broker`.

In such cases, a Publisher Daemon can be used. The publishing processes will
specify it as their target and communicate the messages to be published via
a socket.

If a disk based queue is used, the user may configure Celery to write to it
directly, provided that the queue can perform inserts and deletes concurrently.

Scheduler
---------

The scheduler is responsible for managing the scheduling of tasks for execution.

The scheduler is implemented as a worker which listens to messages directly
from other Celery components instead of using a broker.

The scheduler calculates the amount of tasks to be executed in any given time
in order to make cluster wide decisions when autoscaling workers or increasing
concurrency for an existing worker.
To do so it communicates with the Controller.

The scheduler is aware when tasks should no longer be executed due to manual
intervention or a circuit breaker trip. To do so, it orders the router to avoid
consuming the task or rejecting it.
To do so it communicates with the Router.

Suspend/Resume Tasks
++++++++++++++++++++

Whenever a Circuit Breaker trips, the Router must issue an event
to the scheduler. The exact payload of the suspension event will be determined
in another CEP.

This will notify the scheduler that it no longer has to take this task into
account when calculating the Celery workers cluster capacity.

The user may elect to send this event directly to the scheduler if suspension
of execution is required (E.g. The task interacts with a database which is
going under expected maintenance).

Once scheduling can be resumed, the Router another event to the scheduler.
The exact payload of the resumption event will be determined in another CEP.

Task Prioritization
+++++++++++++++++++

Resource Saturation
~~~~~~~~~~~~~~~~~~~

Rate Limiting
+++++++++++++

A user may impose a rate limit on the execution of a task.

For example, we only want to run 200 `send_welcome_email()` tasks per minute
in order to avoid decreasing our email reputation.

Tasks may define a global rate limit or a per worker rate limit.

Whenever a task reaches it's rate limit, an event is sent to the :ref:`Router`
to notify that is should not consume or reject these tasks.
The exact payload of the rate limiting event will be determined
in another CEP.

Beat
++++

Concurrency Limitations
+++++++++++++++++++++++

Autoscaler
~~~~~~~~~~

Observability
+++++++++++++

Metrics
~~~~~~~

Log Messages
~~~~~~~~~~~~

Log messages will be structured.
Structured logs provide context for our users which allows them to debug
problems more easily.

The Scheduler will be aware of it's execution platform and will format logs
accordingly.

For example, if the Scheduler is running using a SystemD service,
the Scheduler will detect that the `JOURNAL_STREAM`_ environment variable
was set and use it to transmit structured data into `journald`_.

Router
------

The Router is responsible for managing the connection to a message broker and
consuming messages from the broker.

The Router can maintain a connection to a cluster of message brokers or even
clusters of message brokers.

Data Source
+++++++++++

Ingress Only Data Sources
~~~~~~~~~~~~~~~~~~~~~~~~~

Ingress/Egress Data Sources
~~~~~~~~~~~~~~~~~~~~~~~~~~~

Observability
+++++++++++++

Metrics
~~~~~~~

Log Messages
~~~~~~~~~~~~

Log messages will be structured.
Structured logs provide context for our users which allows them to debug
problems more easily.

The Router will be aware of it's execution platform and will format logs
accordingly.

For example, if the Router is running using a SystemD service,
the Router will detect that the `JOURNAL_STREAM`_ environment variable
was set and use it to transmit structured data into `journald`_.

Controller
----------

The Controller is responsible for managing the lifecycle of all other Celery
components.

It spawns the :ref:`Workers <Worker>`, :ref:`Routers <Router>`,
:ref:`Schedulers <Scheduler>` and if configured and possible,
the :ref:`Message Brokers <Message Broker>` as well.

By default, the Controller creates sub-processes for
all the required components. This is suitable for small scale deployments
or for deployments where SystemD is unavailable.

SystemD Integration
+++++++++++++++++++

Unless it is explicitly overridden by the configuration, whenever the Controller
is run as a SystemD service, it will use SystemD to spawn all other Celery
components.

Celery will provide the required services for such a deployment.

The Controller will use the `sd_notify`_ protocol to announce when the cluster
is fully operational.

.. note::

  The Controller is meant to be run as a user service.
  If the Controller is run with root privileges, a log message with
  the warning level will be emitted.

Observability
+++++++++++++

Metrics
~~~~~~~

Log Messages
~~~~~~~~~~~~

Log messages will be structured.
Structured logs provide context for our users which allows them to debug
problems more easily.

The Controller will be aware of it's execution platform and will format logs
accordingly.

For example, if the Controller is running using a systemd service,
the Controller will detect that the `JOURNAL_STREAM`_ environment variable
was set and use it to transmit structured data into `journald`_.

Motivation
==========

Rationale
=========

Backwards Compatibility
=======================

Reference Implementation
========================

Copyright
=========

This document has been placed in the public domain per the Creative Commons
CC0 1.0 Universal license (https://creativecommons.org/publicdomain/zero/1.0/deed).

.. _CAP theorem: https://dzone.com/articles/understanding-the-cap-theorem
.. _Enterprise Integration Patterns: https://www.enterpriseintegrationpatterns.com
.. _Command Message: https://www.enterpriseintegrationpatterns.com/patterns/messaging/CommandMessage.html
.. _Event Message: https://www.enterpriseintegrationpatterns.com/patterns/messaging/EventMessage.html
.. _Document Message: https://www.enterpriseintegrationpatterns.com/patterns/messaging/DocumentMessage.html
.. _ubiquitous language: https://martinfowler.com/bliki/UbiquitousLanguage.html
.. _Message Broker: https://www.enterpriseintegrationpatterns.com/patterns/messaging/MessageBroker.html
.. _Circuit Breaker: https://martinfowler.com/bliki/CircuitBreaker.html
.. _JOURNAL_STREAM: https://www.freedesktop.org/software/systemd/man/systemd.exec.html#%24JOURNAL_STREAM
.. _journald: https://www.freedesktop.org/software/systemd/man/systemd-journald.service.html
.. _sd_notify: https://www.freedesktop.org/software/systemd/man/sd_notify.html
