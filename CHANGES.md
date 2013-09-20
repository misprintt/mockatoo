v2.1.1
- hotfix for mocking getter/setters of type Void-Void (issue #17)

v2.1.0
- released to new haxelib (3.x)


v2.0.0
- Migrated to Haxe 3
- updated build files
- added @:isVar metadata to mocked interface getter setters (haxe3)
- added duplicate macro APIs when 'using' Mockatoo on methods that return Void (MacroVoid)


v1.3.2
- Issue #14 : setter for property defined in interface is missing
 

v1.3.1
- Issue #12 : added support for typed param contraints (class Test<T:(Foo,Bar)>{})

v1.3.0

- Added verification of full expression. eg - Mockatoo.verify(mock.someMethod("foo"));
- verification exceptions correctly reference position where verification was executed
- verifying null or invalid mock instances now throws VerificationExceptions
- compile time check that method being verified exists on mock object
- compile time check that method being stubbed exists on mock object
- support for raw integer verification count. e.g. - Mockatto.verify(mock.someMethod(), 2);
- added shorthand API for stubbing with using mixins - e.g. mock.someMethod().returns("foo"), mock.someMethod.throws("error")
- added static methods to mockatoo.Mockatoo to return untyped Matchers when using 'using'
- removed Matcher.isNull as it is the same as just specifying 'null'

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
