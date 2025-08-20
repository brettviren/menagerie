
// #include <memory>

namespace OtherNS {
  class YourClass {
    int x;
  public:
    int get_x() const { return x; }
    void set_x(int xx) { x = xx; }

  };
}
namespace NS1::NS2 {
  class MyClass {
    //std::unique_ptr<YouClass> mYC;
    OtherNS::YourClass mYC;
  public:
    int myVar;
    double anotherVar;

    MyClass() : myVar(0), anotherVar(0.0) {
      // Constructor
      myVar = 10; // Write
      callMe();
    }

    void setMyVar(int val) {
      myVar = val; // Write
      readAnotherVar();
    }

    int getMyVar() const {
      return myVar; // Read
    }

    void incrementMyVar() {
      myVar++; // Read and Write (access)
    }

    void readAnotherVar() const {
      double temp = anotherVar; // Read
      // No write here
    }

    void modifyAnotherVar(double val) {
      anotherVar = val; // Write
      myVar = mYC.get_x();
      mYC.set_x(val);
    }

    void callMe();

    void independentMethod() {
      // Does not interact with member variables
    }

    void touchPrivate() {
      ++privateVar;
    }


  private:
    int privateVar;
  };
} // NS2
void outsideFunction() {
  using namespace NS1::NS2;
  MyClass obj;
  auto x = obj.getMyVar();
  obj.setMyVar(x);
  obj.readAnotherVar();
}
void NS1::NS2::MyClass::callMe() {
  setMyVar(5); // Call
  int val = getMyVar(); // Call and Read
  incrementMyVar(); // Call and Read/Write
  modifyAnotherVar(10.5); // Call and Write
  myVar += 3; // Read and Write
}
