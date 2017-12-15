### Scone Ordering (Alt)

This project is meant to be used to compare two different Ordering builds in parallel on SAM.
For example, today we have suspicious memory consumption, but we aren't sure what is causing it.

So deploy two different images of the Ordering service to:
- sam/manifests/apps/team/Scone/ordering
- sam/manifests/apps/team/Scone/ordering-alt

and then we watch how the metrics change.
