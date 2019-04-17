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

Nowdays most applications are (or should be):

* Deployed to a cloud provider's computing resources.
* Distributed, sometimes between data centers.
* Failure resilient and Fault Tolerant.
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

Martin Fowler defines a `Circuit Breaker`_ in the following fashion:

  | The basic idea behind the circuit breaker is very simple.
  | You wrap a protected function call in a circuit breaker object, which monitors
  | for failures.
  | Once the failures reach a certain threshold, the circuit breaker trips,
  | and all further calls to the circuit breaker return with an error,
  | without the protected call being made at all.
  | Usually you'll also want some kind of monitor alert if the circuit breaker
  | trips.

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

Observability
+++++++++++++

The publisher will collect the following metrics:

* Messages Delivered (Counter)
* Messages Delivered/s (Gauge)
* Messages Delivered per Message Identifier (Counter)
* Messages Delivered/s per Message Identifier (Gauge)
* Rejected Messages (Counter)
* Rejected Messages/s (Gauge)
* Rejected Messages per Message Identifier (Counter)
* Rejected Messages/s per Message Identifier (Gauge)
* Time To Delivery (Histogram)
* Number of Connections/Cluster (Counter)
* Failed Connection Attempts/Cluster (Counter)
* Successful Connection Attempts/Cluster (Counter)
* Time To Connection (Histogram)
* Time To Connection per Cluster (Histogram)
* Time Between Connection Attempts (Histogram)
* Time Between Connection Attempts per Cluster (Histogram)
* Health Check Failures per Health Check (Counter)
* Health Check Failures/s per Health Check (Gauge)
* Total Uptime (Histogram)

By default, all metrics will be published to a broker cluster configured
by the user.

Alternative reporting mechanisms may be implemented by the user.
As such, the design must ensure extensibility of the reporting mechanism.


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

Beat
++++

Concurrency Limitations
+++++++++++++++++++++++

Autoscaler
~~~~~~~~~~

Observability
+++++++++++++

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

Controller
----------

Observability
+++++++++++++

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
CC0 1.0 Universal license (http://creativecommons.org/publicdomain/zero/1.0/deed).

(All CEPs must include this exact copyright statement.)

.. _Enterprise Integration Patterns: https://www.enterpriseintegrationpatterns.com
.. _Command Message: https://www.enterpriseintegrationpatterns.com/patterns/messaging/CommandMessage.html
.. _Event Message: https://www.enterpriseintegrationpatterns.com/patterns/messaging/EventMessage.html
.. _Document Message: https://www.enterpriseintegrationpatterns.com/patterns/messaging/DocumentMessage.html
.. _ubiquitous language: https://martinfowler.com/bliki/UbiquitousLanguage.html
.. _Message Broker: https://www.enterpriseintegrationpatterns.com/patterns/messaging/MessageBroker.html
.. _Circuit Breaker: https://martinfowler.com/bliki/CircuitBreaker.html
