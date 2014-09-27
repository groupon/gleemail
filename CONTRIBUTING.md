# Contribution Guide

You want to contribute to gleemail? That's great, thanks!
Please follow this guide when creating issues or pull requests so there are as few surprises as possible.

## Reporting a Bug

Before reporting a bug, make sure you are using the latest versions of gleemail, Node.js and Chrome.

When reporting a CLI/server-side bug with gleemail, please provide a minimal test case.
This can be a gist, inline in the description, or in the form of a pull request that includes a failing test.

When reporting a browser bug with gleemail, please provide a description of the steps taken to reproduce
the bug. A screenshot of the error state in the browser would also be appreciated.

If you are contributing a bug fix, make sure it has a passing test in your pull request.

## Adding a Feature

Adding support for integrations with additional email delivery services will always be considered.
Please follow the established patterns for these integrations so that all integration points in
the codebase will generally function in the same way.

All features should have tests.
