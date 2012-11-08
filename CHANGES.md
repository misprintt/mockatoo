v1.2.x
- Issue #9 optional method args without a `?` cause compilation error
- Added -D MOCKATOO_LOG to opt into generation of log file (performance optimisation)

v1.2.0
- added support for mocking property fields (with autowiring of getter/setters where applicable)
- added when().thenStub() for stubbing spy objects using default mock values
- added when().thenCallRealMethod() for suppressing mocks on specific methods

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
