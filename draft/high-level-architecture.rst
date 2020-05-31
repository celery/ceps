================================================
CEP XXXX: Celery NextGen High Level Architecture
================================================

:CEP: XXXX
:Author: Omer Katz
:Implementation Team: Omer Katz
:Shepherd: Omer Katz
:Status: Draft
:Type: Informational
:Created: 2020-05-27
:Last-Modified: 2020-05-27

Abstract
========

When Celery was conceived, production environments were radically different from today.

Nowadays most applications are (or often should be):

* Deployed to a cloud provider's computing resources.
* Distributed (sometimes between data centers).
* :term:`Available <Availability>` or :term:`Consistent <Consistency>` (If we store state, we must pick one according to :term:`CAP Theorem`).
* :term:`Network Partition Tolerant <Partition Tolerant>`.
* :term:`Observable <Observability>`.
* Built with scalability in mind.
* Cloud Native - The application's lifecycle is managed using Kubernetes, Swarm, or any other scheduler.
* Heterogeneous - Microservices may be written in different languages.

Also, Celery lacks proper support for large scale deployments and some useful messaging architectural patterns.

Celery 5 is the next major version of Celery, and so we can break backward compatibility, even in significant ways.

As such, our next major version should represent the beginning of a paradigm shift
in the way we implement our task execution platform.
Future major versions will drastically change how Celery works.

This document provides a high-level overview of the new architecture for the next generation of Celery
major versions.

Specification
=============

.. note::
    From now on when we write Celery we refer to Celery NextGen.

    Whenever we refer to a previous major version of Celery we will specify the version number.

.. figure:: celery-5-architecture-figure01.png

  High Level Architecture Diagram

In Celery 4.x we had the following architectural building blocks:

- :term:`Message Broker`
- :term:`Result Backend`
- :term:`Celery Master`
- :term:`Celery Worker`

In addition we had a few optional architectural building blocks (some of them maintained by the community):

- :term:`Celery Multi`
- :term:`Flower`
- :term:`Cell`

The only architectural building block that remains in Celery is the :term:`Message Broker`.
The rest are replaced by new ones which provide more functionality and flexibility for our users.

Motivation
==========

We want to modernize Celery for the Cloud Native age.
We need to keep Celery relevant for our users and help them in new ways. Therefore, we must adjust and evolve to meet the unique challenges of the Cloud Native age.

Also, we want to modernize the code to support Python 3+, which will allow us to remove workarounds, backports, and compatibility shims.
Refactoring the codebase to support Python 3+ allows us to keep a slimmer, more maintainable codebase.

Furthermore, we'd like to resolve long-standing design bugs in our implementation.

Gradually evolving our codebase is currently not possible due to the many changes
in technology since Celery was conceived.
We need to move fast and break things until we match all our goals.

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
