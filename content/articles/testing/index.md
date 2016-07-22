+++
date = "2016-07-21T23:08:17+02:00"
draft = "true"
strap = ""
title = "Testing"

+++

A good suite of tests can be invaluable. However, a bad suite of tests can sometimes be more detrimental than no tests at all - lulling you into a false sense of security.

## Bad tests?

Yes, such a thing does exist. It's possible to achieve the grail of 100% test coverage, but then not actually test anything at all, and be able to make breaking changes while still remaining all green.

The opposite is also possible - when every small change causes the tests to break, frustration quickly sets in and corners quickly get cut. Deploying time-critical fixes becomes impossible with a failing test suite in your way. Best case scenario: new tests stop being written, as they're seen as an obstacle. In extreme cases, test cases can start getting skipped or commented out, or worse, are just ignored and allowed to gradually turn red across the board over time.

Either way, the net result is the same: the test suite stops being helpful. As with everything, the key is finding a balance: tests that are helpful when you genuinely have broken something, but get out of your way (or are trivially easy to modify) when the shit hits the fan.
