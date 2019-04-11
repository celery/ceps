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
* Distributed, sometimes between datacenters.
* Failure resilient and Fault Tolerant.
* Observable.
* Built with scalibility in mind.
* Cloud Native - The application's lifecycle is managed using Kubernetes, Swarm or any other scheudler.

In addition, Celery lacks proper support for large scale deployments and some very useful messaging architectural patterns.

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

The API presented here is a draft to be determined by anohter CEP:

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
  ...   user_id: uuid.UUID
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
:ref:`Circuit Breakers <Circuit Breaker>` are tripped.

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

Scheduler
---------

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

Controller
----------

Worker
------

Motivation
==========

This section should explain *why* this CEP is needed. The motivation is critical
for CEPs that want to add substantial new features or materially refactor
existing ones.  It should clearly explain why the existing solutions are
inadequate to address the problem that the CEP solves.  CEP submissions without
sufficient motivation may be rejected outright.

Rationale
=========

This section should flesh out out the specification by describing what motivated
the specific design design and why particular design decisions were made.  It
should describe alternate designs that were considered and related work.

The rationale should provide evidence of consensus within the community and
discuss important objections or concerns raised during discussion.

Backwards Compatibility
=======================

If this CEP introduces backwards incompatibilities, you must must include this
section. It should describe these incompatibilities and their severity, and what
mitigation you plan to take to deal with these incompatibilities.

Reference Implementation
========================

If there's an implementation of the feature under discussion in this CEP,
this section should include or link to that implementation and provide any
notes about installing/using/trying out the implementation.

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
