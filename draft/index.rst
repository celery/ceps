.. include:: README.rst

.. toctree::
   :maxdepth: 2
   :caption: Contents:

   celery-5-high-level-architecture.rst
   features-release-schedule.rst
   high-level-architecture.rst
   controller.rst
   publisher.rst
   router.rst
   execution-platform.rst
   configuration.rst
   observability.rst

Glossary
--------

.. glossary::

  CAP Theorem
    The `CAP theorem`_ categorizes systems into three categories:

    * CP (:term:`Consistent <Consistency>` and :term:`Partition Tolerant`) — At first glance, the CP category is confusing, i.e., a system that is consistent and partition tolerant but never available. CP is referring to a category of systems where availability is sacrificed only in the case of a network partition.
    * CA (:term:`Consistent <Consistency>` and :term:`Available <Availability>`) — CA systems are consistent and available systems in the absence of any network partition. Often a single node's DB servers are categorized as CA systems. Single node DB servers do not need to deal with partition tolerance and are thus considered CA systems. The only hole in this theory is that single node DB systems are not a network of shared data systems and thus do not fall under the preview of CAP.
    * AP (:term:`Available <Availability>` and :term:`Partition Tolerant`) — These are systems that are available and partition tolerant but cannot guarantee consistency.

  Consistency
    A guarantee that every node in a distributed cluster returns the same, most recent, successful write.
    Consistency refers to every client having the same view of the data.
    There are various types of consistency models.
    Consistency in CAP (used to prove the theorem) refers to linearizability or sequential consistency, a very strong form of consistency.

  Availability
    Every non-failing node returns a response for all read and write requests in a reasonable amount of time.
    The key word here is every.
    To be available, every node on (either side of a network partition) must be able to respond in a reasonable
    amount of time.

  Partition Tolerant
    The system continues to function and upholds its consistency guarantees in spite of network partitions. Network partitions are a fact of life.
    Distributed systems guaranteeing partition tolerance can gracefully recover from partitions once the partition heals.

.. _CAP theorem: https://dzone.com/articles/understanding-the-cap-theorem