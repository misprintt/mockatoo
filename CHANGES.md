v1.1.1
- fixed bug where a custom stub call ('thenCall(f)') did not recieve arguments
- fixed bug caused by when() not casting instance to mock;

v1.1.0
- added spying (partial mocking)
- added compiler error if mocking final class on flash target

v1.0.1
- added mocking for typedef structures (no verify/stubbing though)
- changed mock param type in verify to Dynamic (avoids casting)
- added Mockatoo.reset(mock) to reset stubs/verifications
- fixed issue #6 - super class typed params inside of typed params not mapped correctly
