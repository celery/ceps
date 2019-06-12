.. vale off
=================================
CEP 1: CEP Purpose and Guidelines
=================================

:CEP: 1
:Author: Omer Katz
:Status: Final
:Type: Process
:Created: 2019-04-03
:Last-Modified: 2019-04-03

.. contents:: Table of Contents
   :depth: 3
   :local:

What is a CEP?
==============

CEP stands for Celery Enhancement Proposal. A CEP is a design document
providing information to the Celery community, or describing a new feature
or process for Celery. CEPs provide concise technical specifications of
features, along with rationales.

We intend CEPs to be the primary mechanisms for proposing major new features,
for collecting community input on issues, and for documenting design
decisions that have gone into Celery.

The concept and implementation of CEPs (and this document itself!) is a nearly
direct copy of `Python's PEP process <https://www.python.org/dev/peps/>`_ . If
you're already familiar with PEPs, you should be able to quickly grok CEPs by
reading the `differences between CEPs and PEPs`_.

CEP Types
=========

There are three kinds of CEPs:

1. A **Feature** CEP describes a new feature or implementation
   for Celery. Most CEPs will be Feature CEPs.

2. An **Informational** CEP describes a Celery design issue, or
   provides general guidelines or information to the Celery community
   but does not propose a new feature. Informational CEPs do not
   necessarily represent a community consensus or
   recommendation, so users and implementers are free to ignore
   Informational CEPs or follow their advice.

3. A **Process** CEP describes a process surrounding Celery, or
   proposes a change to (or an event in) a process.  Process CEPs are
   like Feature CEPs but apply to areas other than the Celery
   framework itself.  They may propose an implementation, but not to
   Celery's codebase; they often require community consensus; unlike
   Informational CEPs, they are more than recommendations, and users
   are typically not free to ignore them.  Examples include
   procedures, guidelines, changes to the decision-making process, and
   changes to the tools or environment used in Celery development.
   Any meta-CEP is also considered a Process CEP. (So this document
   is a Process CEP).

CEP submission workflow
=======================

So, you'd like to submit a CEP? Here's how it works, and what to expect.

There are a couple of terms you should be familiar with before reading the
rest of this document:

The Technical Board
    There are several reference in this CEP to the **Technical Board**
    (sometimes just "the Board"). This refers to Celery's Technical Board,
    the group of experienced and active committers who steer technical
    choices.

Core Developers
    Similarly, there are several references to **Core Developers** (sometimes
    "core devs"). This refers to the members of Celery's core team,
    and specifically those with commit access.

At a very high level, the CEP submission process looks like this:

1. `Pre-proposal`_ — someone has an idea and starts collecting early input and
   feedback to see if it's worth writing a CEP.

2. `Forming the team`_ — the CEP author rounds up the help they'll need to get
   the CEP considered.

3. `Submitting the draft`_ — the CEP author writes a rough draft of the CEP and
   submits it via pull request.

4. `Discussion, development, and updates`_ — the CEP and reference
   implementation are discussed, improved, and updated as feedback comes in.

5. `Review & Resolution`_ — the CEP is reviewed by the Technical Board and
   either accepted or rejected.

6. `Implementation`_ — the implementation of the proposed feature is completed
   by the CEP team.

For details on each step, read on.

Pre-proposal
------------

The CEP process begins with a new idea for Celery.  It is highly recommended
that a single CEP contain a single key proposal or new idea. Small enhancements
or patches usually don't need a CEP and follow Celery's normal `contribution
process <http://docs.celeryproject.org/en/latest/internals/guide.html>`_.

The more focused the CEP, the more successful it tends to be.  The Core
Developers reserve the right to reject CEP proposals if they appear too
unfocused or too broad.  If in doubt, split your CEP into several well-focused
ones.

The CEP Author (see below for the formal definition of an Author)
should first attempt to ascertain whether the idea is CEP-able.
Opening an issue on the `celery/ceps <https://github.com/celery/ceps>`_
repository is the best way to do so.

Vetting an idea publicly before going as far as writing a CEP is meant to save
the potential author time. Many ideas have been brought forward for changing
Celery that have been rejected for various reasons. Asking the Celery community
first if an idea is original helps prevent too much time being spent on
something that is guaranteed to be rejected based on prior discussions
(searching the Internet does not always do the trick). It also helps to make
sure the idea is applicable to the entire community and not just the author.
Just because an idea sounds good to the author does not mean it will work for
most people in most areas where Celery is used.

Forming the team
----------------

Once a CEP has been roughly validated, the author needs to fill out three vital
roles. These roles will be required to get a CEP read, approved, and the code
developed, so you need to identify up-front who will do what. These roles are:

Author
    The **Author** writes the CEP using the style and format described below
    (see `CEP format`_), shepherds the discussions in the appropriate forums,
    and attempts to build community consensus around the idea.

Implementation Team
    The **Implementation Team** are the people (or single person) who will
    actually implement the thing being proposed. A CEP may have multiple
    implementers (and the best CEPs probably will).

    Feature CEPs must have an implementation team to be submitted. Informational
    CEPs generally don't have implementers, and Process CEPs sometimes will.

Shepherd
    The **Shepherd** is the Core Developer who will be the primary reviewer
    of the CEP on behalf of the Celery team, will be the main point person
    who will help the Author assess the fitness of their proposal, and
    is the person who will finally submit the CEP for pronouncement by the
    Technical Board. When the implementation team doesn't contain someone
    who can commit to Celery, the Shepherd will be the one who actually merges
    the code into the project.

It's normal for a single person to fulfill multiple roles -- in most cases the
Author will be an/the Implementer, and it's not uncommon for the implementation
team to include the Shepherd as well. It's unusual but acceptable for a single
person to fulfill all roles, though this generally only happens when that person
is a long-time committer.

Submitting the draft
--------------------

Once the idea's been vetted and the roles are filled, a draft CEP should be
presented to Celery-developers. This gives the author a chance to flesh out the
draft CEP to make sure it's properly formatted, of high quality, and to address
initial concerns about the proposal.

Following the discussion on Celery-developers, the proposal should be sent as a
GitHub pull request to the `celery/ceps <https://github.com/celery/ceps>`_
repository.
This PR should add a CEP to the ``drafts/`` directory, written in the style
described below. The draft must be written in CEP style; if it isn't the pull
request may be rejected until proper formatting rules are followed.

At this point, a core dev will review the pull request. In most cases the
reviewer will be the Shepherd of the CEP, but if that's not possible for some
reason the author may want to ask on Celery-developers to ensure that this
review happens quickly. The reviewer will do the following:

* Read the CEP to check if it is ready: sound and complete.  The ideas
  must make technical sense, even if they don't seem likely to be
  accepted.

* Make sure the title accurately describes the content.

* Check the CEP for language (spelling, grammar, sentence structure,
  etc.), markup, and code style (examples should match PEP 8).

If the CEP isn't ready, the reviewer can leave comments on the pull request,
asking for further revisions. If the CEP's really in bad form, the reviewer
may reject the pull request outright and ask the author to submit a new one
once the problems have been fixed.

The reviewer doesn't pass judgment on CEPs.  They merely do the administrative &
editorial part (which is generally a low volume task).

Once the CEP is ready for the repository, the reviewer will:

* Merge the pull request.

* Assign a CEP number (almost always just the next available number), and rename
  the CEP file with the new number (e.g. rename ``dep-process.rst`` to
  ``0001-dep-process.rst``)

Developers with commit access to the CEPs repo may create drafts directly by
committing and pushing a new CEP. However, when doing so they need to take on
the tasks normally handled by the reviewer described above. This includes
ensuring the initial version meets the expected standards for submitting a CEP.
Of course, committers may still choose to submit CEPs as a pull request to
benefit from peer review.

Discussion, development, and updates
------------------------------------

At this point there will generally be more discussion, modifications to the
reference implementation, and of course updates to the CEP. It's rare for
a CEP to be judged on the first draft; far more common is several rounds
of feedback and updates.

Updates to a CEP can be submitted as pull requests; once again,
a core developer will merge those pull requests (typically they don't
require much if any review). In cases where the Author has commit access
(fairly common), the Author should just update the draft CEP directly.

Feature CEPs generally consist of two parts, a design document and a
reference implementation.  It is generally recommended that at least a
prototype implementation be co-developed with the CEP, as ideas that sound
good in principle sometimes turn out to be impractical when subjected to the
test of implementation.

CEP authors are responsible for collecting community feedback on a CEP
before submitting it for review. However, wherever possible, long
open-ended discussions on the relevant issue should be avoided.
Strategies to keep the discussions efficient include: setting up a
separate communication channel for the topic, having the CEP author accept
private comments in the early design phases, setting up a wiki page, etc.
CEP authors should use their discretion here.

Review & Resolution
-------------------

Once the author has completed a CEP, the shepherd will ask the Technical Board
for review and pronouncement. The final authority for deciding on a CEP rests
with the Technical Board. They may choose to rule on a CEP as a team, or they
may designate one or more board members to review and decide.

Having the shepherd (i.e. a core dev) rather than the author ask helps ensure
that the CEP meets the basic technical bar before it's called for review. It
also provides a fairly strong fitness test before the board is asked to rule on
it, making board rulings fairly easy. If the core developer shepherd is happy,
the board will likely be as well.

For a CEP to be accepted it must meet certain minimum criteria.  It must be a
clear and complete description of the proposed enhancement. The enhancement must
represent a net improvement. The proposed implementation, if applicable, must be
solid and must not complicate Celery unduly. Finally, a proposed enhancement
must "fit" with Celery's general philosophy and architecture. This last category
is the most imprecise and takes the most judgment, so if the Board rejects a
CEP for lack of "fit" they should provide a clear explanation for why.

At this point, the CEP will be considered "Accepted" and moved to the
``accepted`` directory in the CEPs repo.

A CEP can also be "Withdrawn".  The CEP author or a core developer can assign
the CEP this status when the author is no longer interested in the CEP, or if no
progress is being made on the CEP.  Once a CEP is withdrawn, it's moved
to the ``withdrawn`` directory for reference. Later, another author may
resurrect the CEP by opening a pull request, updating (at least) the author,
and moving it back to ``draft``.

Finally, a CEP can also be "Rejected".  Perhaps after all is said and done it
was not a good idea.  It is still important to have a record of this
fact. Rejected CEPs will be moved to the ``rejected`` directory, and
generally should be updated with a rationale for rejection.

CEPs can also be superseded by a different CEP, rendering the original
obsolete.  This is intended for Informational CEPs, where version 2 of
an API can replace version 1.

Implementation
--------------

Finally, once a CEP has been accepted, the implementation must be completed. In
many cases some (or all) implementation will actually happen during the CEP
process: Feature CEPs will often have fairly complete implementations before
being reviewed by the board. When the implementation is complete and
incorporated into the main source code repository, the status will be changed to
"Final" and the CEP moved to the ``final`` directory.

CEP format
==========

To save everyone time reading CEPs, they need to follow a common format
and outline; this section describes that format. In most cases, it's probably
easiest to start with copying the provided `CEP template <../template.rst>`_,
and filling it in as you go.

CEPs must be written in `reStructuredText <http://docutils.sourceforge.net/rst.html>`_
(the same format as Celery's documentation).

Each CEP should have the following parts:

#. A short descriptive title (e.g. "canvas-dsl"), which is also reflected
   in the CEP's filename (e.g. ``0181-canvas-dsl.rst``).

#. A preamble -- a rST `field list <http://docutils.sourceforge.net/docs/ref/rst/restructuredtext.html#field-lists>`_
   containing metadata about the CEP, including the CEP number, the names of the
   various members of the `CEP team <#forming- the-team>`_, and so forth. See
   `CEP Metadata`_ below for specific details.

#. Abstract -- a short (~200 word) description of the technical issue
   being addressed.

#. Specification -- The technical specification should describe the syntax and
   semantics of any new feature.  The specification should be detailed enough to
   allow implementation -- that is, developers other than the author should
   (given the right experience) be able to independently implement the feature,
   given only the CEP.

#. Motivation -- The motivation is critical for CEPs that want to add
   substantial new features or materially refactor existing ones.  It should
   clearly explain why the existing solutions are inadequate to address the
   problem that the CEP solves.  CEP submissions without sufficient motivation
   may be rejected outright.

#. Rationale -- The rationale fleshes out the specification by describing what
   motivated the design and why particular design decisions were made.  It
   should describe alternate designs that were considered and related work.

   The rationale should provide evidence of consensus within the community and
   discuss important objections or concerns raised during discussion.

#. Backwards Compatibility -- All CEPs that introduce backwards
   incompatibilities must include a section describing these incompatibilities
   and their severity.  The CEP must explain how the author proposes to deal
   with these incompatibilities.  CEP submissions without a sufficient backwards
   compatibility treatise may be rejected outright.

#. Reference Implementation -- The reference implementation must be completed
   before any CEP is given status "Final", but it need not be completed before
   the CEP is accepted.  While there is merit to the approach of reaching
   consensus on the specification and rationale before writing code, the
   principle of "rough consensus and running code" is still useful when it comes
   to resolving many discussions of API details.

   The final implementation must include tests and documentation, per Celery's
   `contribution guidelines <http://docs.celeryproject.org/en/latest/internals/guide.html>`_.

#. Copyright/public domain -- Each CEP must be explicitly licensed
   as `CC0 <https://creativecommons.org/publicdomain/zero/1.0/>`_.

CEP Metadata
------------

Each CEP must begin with some metadata given as an rST
`field list <http://docutils.sourceforge.net/docs/ref/rst/restructuredtext.html#field-lists>`_.
The headers must contain the following fields:

``CEP``
    The CEP number. In an initial pull request, this can be left out or given
    as ``XXXX``; the reviewer who merges the pull request will assign the CEP
    number.
``Type``
    ``Feature``, ``Informational``, or ``Process``
``Status``
    ``Draft``, ``Accepted``, ``Rejected``, ``Withdrawn``, ``Final``, or ``Superseded``
``Created``
    Original creation date of the CEP (in ``yyyy-mm-dd`` format)
``Last-Modified``
    Date the CEP was last modified (in ``yyyy-mm-dd`` format)
``Author``
    The CEP's author(s).
``Implementation-Team``
    The person/people who have committed to implementing this CEP
``Shepherd``
    The core developer "on point" for the CEP
``Requires``
    If this CEP depends on another CEP being implemented first,
    this should be a link to the required CEP.
``Celery-Version`` (optional)
    For Feature CEPs, the version of Celery (e.g. ``5.0``) that this
    feature will be released in.
``Replaces`` and ``Superseded-By`` (optional)
    These fields indicate that a CEP has been rendered obsolete. The newer CEP
    must have a ``Replaces`` header containing the number of the CEP that it
    rendered obsolete; the older CEP has a ``Superseded-By`` header pointing to
    the newer CEP.
``Resolution`` (optional)
    For CEPs that have been decided upon, this can be a link to the final
    rationale for acceptance/rejection. It's also reasonable to simply update
    the CEP with a "Resolution" section, in which case this header can be left
    out.

Auxiliary Files
---------------

CEPs may include auxiliary files such as diagrams.  Such files must be named
``XXXX-descriptive-title.ext``, where "XXXX" is the CEP number,
"descriptive-title" is a short slug indicating what the file contains, and
"ext" is replaced by the actual file extension (e.g. "png").

Reporting CEP Bugs, or Submitting CEP Updates
=============================================

How you report a bug, or submit a CEP update depends on several factors, such as
the maturity of the CEP, the preferences of the CEP author, and the nature of
your comments.  For the early draft stages of the CEP, it's probably best to
send your comments and changes directly to the CEP author.  For more mature, or
finished CEPs you can submit corrections as GitHub issues or pull requests
against the CEP repository.

When in doubt about where to send your changes, please check first with the CEP
author and/or a core developer.

CEP authors with git push privileges for the CEP repository can update the CEPs
themselves.

Transferring CEP Ownership
==========================

It occasionally becomes necessary to transfer ownership of CEPs to a new author.
In general, it is preferable to retain the original author as a co-author of the
transferred CEP, but that's really up to the original author.  A good reason to
transfer ownership is because the original author no longer has the time or
interest in updating it or following through with the CEP process, or has fallen
off the face of the 'net (i.e. is unreachable or not responding to email).  A
bad reason to transfer ownership is because the new author doesn't agree with
the direction of the CEP. One aim of the CEP process is to try to build
consensus around a CEP, but if that's not possible, an author can always submit
a competing CEP.

If you are interested in assuming ownership of a CEP, first try to contact the
original author and ask for permission. If they approve, ask them to open a pull
request transferring the CEP to you. If the original author doesn't respond to
email within a few weeks, contact Celery-developers.


Differences between CEPs and PEPs
=================================

As stated in the preamble, the CEP process is more or less a direct copy of
the PEP process (and this document is a modified version of
`PEP 1 <https://www.python.org/dev/peps/pep-0001/>`_).

Relative to the PEP process, we made the following changes in CEPs:

- The workflow is GitHub based (rather than email-based as in PEP 1).

  This is a simple enough change, but has a number of ramifications for the
  details of how CEPs work, including:

  - CEPs use pull requests (and direct commits) as the workflow process.
  - CEPs use rST-style headers rather than RFC822 (because rST-style headers
    render properly on GitHub without additional tooling).
  - CEPs have document titles rather than title fields in the metadata
    (again, because of GitHub rendering).
  - CEP are organized into directories based on statuses (e.g. ``draft/``,
    ``accepted/``, ``final/``, etc) so that additional tooling to create an
    index by status isn't needed.
  - CEP file names are more descriptive (e.g. ``0181-canvas-dsl.rst``),
    again to avoid the need for additional tooling.
  - CEPs are "edited" (e.g. pull request approved) by any core developer,
    rather than an explicit "editor" role like the PEP editors.

- CEPs are pronounced upon by the Technical Board, rather than a BDFL (because
  Celery has no BDFLs).

- CEPs explicitly require identifying a few roles (Author, Implementation Team,
  and Shepherd) before submission and throughout the process. With PEPs, most
  are authored and implemented by the same person, but the same doesn't seem to
  be true of CEPs (so far), hence the "implementer" role. As for the "shepherd":
  the BDFL or BDFL-delegate tends to be much more hands-on than the Technical
  Board, so the role of commenting and critiquing will be fulfilled by the
  shepherd, rather than the board. Further, we've observed that features are
  tremendously unlikely to make it into Celery without a committer on board to
  do the detail-work of merging a patch.

- CEPs simplify the metadata somewhat, removing a few fields ("Post-History",
  etc.) and dropping a couple of statuses ("Active" gets merged into "Final",
  and "Deferred" merged into "Withdrawn").

- CEPs have "Feature CEPs" rather than "Standards Track" CEPs.

- CEPs may only be reStructuredText (there is no plain text option).

Copyright
=========

This document has been placed in the public domain per the Creative Commons
CC0 1.0 Universal license (https://creativecommons.org/publicdomain/zero/1.0/deed).
