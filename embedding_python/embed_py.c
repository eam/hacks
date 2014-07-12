#include <stdio.h>
#include <stdlib.h>
#include <Python.h>

void pp(PyObject *o) {
  /*
  static PyObject *pprint_pName;
  static PyObject *pprint_pModule;
  static PyObject *pprint_pFunc;
  PyObject *pprint_pValue;
  if (pprint_pName == NULL) {
    // happens once
    pprint_pName = PyString_FromString("pprint");
    pprint_pModule = PyImport_Import(pprint_pName);
    pprint_pFunc = PyObject_GetAttrString(pprint_pModule, "pprint");
  }
  
  pprint_pValue = PyObject_CallFunctionObjArgs(pprint_pFunc, o, NULL);
  */
  //PyObject *repr_string;
  //repr_string = PyObject_Repr(o);
  /* This replaces all the crap above */
  PyObject_Print(o, stdout, 0 );
  printf("\n");
  
}

int main(int argc, char ** argv) {
  PyObject *pName, *pModule, *pFunc;
  PyObject *pArgs, *pValue;
  PyObject *foo_instance;
  PyObject *foo_fffFunc;;


  if (argc < 3) {
    fprintf(stderr,"Usage: call pythonfile funcname [args]\n");
    exit(1);
  }

  Py_Initialize();
  PyRun_SimpleString("def foo():\n    print 'hello world foooooo'\n");
  pName = PyString_FromString(argv[1]);
  pModule = PyImport_Import(pName);
  if (pModule == NULL) {
    printf("pModule == NULL\n");
    exit(1);
  }
  // Py_DECREF(pName);
  

  PyRun_SimpleString("print 'I SEE:'\nmymod.functions_provided()");

  pFunc = PyObject_GetAttrString(pModule, argv[2]);
  printf("yyyyy\n");
  if (pFunc && PyCallable_Check(pFunc)) {
    printf("XXXXX\n");
    pArgs = PyTuple_New(0);
    /*
    pArgs = PyTuple_New(2);
    pValue = PyInt_FromLong(5);
    PyTuple_SetItem(pArgs, 0, pValue);
    pValue = PyInt_FromLong(6);
    PyTuple_SetItem(pArgs, 1, pValue);
    pValue = PyObject_CallObject(pFunc, pArgs);
    // works pValue = PyObject_CallObject(pFunc, pArgs);
    */
    foo_instance = PyObject_CallFunctionObjArgs(pFunc, NULL);
    if (foo_instance == NULL) {
      // if wrong number of args
      printf("calling %s.%s returned NULL\n", argv[1], argv[2]);
    } else {
      printf("calling  %s.%s worked, got..something\n", argv[1], argv[2]);
      pp(foo_instance);
      foo_fffFunc = PyObject_GetAttrString(foo_instance, "fff");
      if (foo_fffFunc && PyCallable_Check(foo_fffFunc)) {
        printf("fff() was callable\n");
        pValue = PyObject_CallFunctionObjArgs(foo_fffFunc, NULL);
        printf("fff returned: %p\n", pValue);
        
      }
    }
  } else {
    printf("pFunc not callable\n");
  }
    
  return 0;
}
