def blah():
    print "in blah"

class Foo:
    def __init__(self):
#        print "new obj foo, arg:" + param
        self.instancevar = 77
        print "adsfsdasdfsdfs NEW OBJ"
        
    def bar(self, param):
        print "in bar, param: " + param

    def fff(self):
        print "was here plain method"

    def foo(self, range):
        return "foo"

    def count(self, range):
        return len(range)

    def functions_provided(self):
        "count foo".split()

if __name__ == "__main__":
    x = Foo("baz")
