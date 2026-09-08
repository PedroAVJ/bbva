# Native design verification

The historical macOS allowance reference uses a fixed 420 by 598 point window,
a transparent title bar, and native traffic lights. Its source remains available
for visual comparison; private operator screenshots and their locations are
not part of this public repository.

For a new UI change, build with bounded resources and inspect the actual window
against `design/Allowance Mini.dc.html`. Verify typography, geometry, category
navigation, back navigation, recovery copy, and accessibility using synthetic
fixture data. A prior acceptance result does not verify a new candidate.

The iOS ledger is the current native product. Follow its own target and data
boundaries when validating changes; do not read a personal ledger for UI tests.
