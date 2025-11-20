//here user defined classes are implementing the methods written in the
//predefined class named Exception class.
//UDC will implement the body of the methods in its own way seprately.


//login exceptions
class UserNotFoundException implements Exception {}
class WrongPasswordException implements Exception {}

//register exceptions
class WeakPasswordException implements Exception {}
class InvalidEmailException implements Exception {}
class EmailAlreadyUsedException implements Exception {}

//generic exceptions
class GenericException implements Exception {}
class UserNotLogInException implements Exception {}     