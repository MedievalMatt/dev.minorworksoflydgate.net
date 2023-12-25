#ifndef PHP_SAXON_H
#define PHP_SAXON_H

#define PHP_SAXON_EXTNAME  "Saxon/C"
#define PHP_SAXON_EXTVER   "0.2"



#ifdef HAVE_CONFIG_H
#include "config.h"
#endif 


/*#ifdef ZTS
#include "TSRM.h"
#define COUNTER_G(v) TSRMG(counter_globals_id, zend_counter_globals *, v)
#else
#define COUNTER_G(v) (counter_globals.v)
#endif*/

extern "C" {
#ifdef __linux__
    #include "php.h"
#endif
	 #include "ext/standard/info.h"
#include "zend_exceptions.h"
}

/*ZEND_BEGIN_MODULE_GLOBALS(saxon)
    long counter;
ZEND_END_MODULE_GLOBALS(saxon)


ZEND_DECLARE_MODULE_GLOBALS(saxon)*/


extern zend_module_entry saxon_module_entry;
#define phpext_saxon_ptr &saxon_module_entry;

zend_object_handlers saxonProcessor_object_handlers;
zend_object_handlers xdmValue_object_handlers;
//int saxon_globals_id;

struct saxonProcessor_object {
    zend_object std;
    SaxonProcessor * saxonProcessor;
    XsltProcessor *xsltProcessor;
    XQueryProcessor *xqueryProcessor;
    XdmValue * xdmValue;
    char * sfilename;
    char * stylesheetFile;
    char * stylesheetStr;
    char * queryFile;
    char * queryStr;
};


struct xdmValue_object {
    zend_object std;
    XdmValue * xdmValue;
};



#endif /* PHP_SAXON_H */


zend_class_entry *saxonProcessor_ce;
zend_class_entry *xdmValue_ce;

void XsltProcessor_free_storage(void *object TSRMLS_DC)
{
    saxonProcessor_object *obj = (saxonProcessor_object *)object;
     if (obj->saxonProcessor != NULL) {
	obj->saxonProcessor->close();
    }
   // delete obj->saxonProcessor;
    //delete obj->xsltProcessor; 

    zend_hash_destroy(obj->std.properties);
    FREE_HASHTABLE(obj->std.properties);

    efree(obj);


}


zend_object_value saxonProcessor_create_handler(zend_class_entry *type TSRMLS_DC)
{
    zval *tmp;
    zend_object_value retval;

    saxonProcessor_object *obj = (saxonProcessor_object *)emalloc(sizeof(saxonProcessor_object));
    memset(obj, 0, sizeof(saxonProcessor_object));
    obj->std.ce = type;

    ALLOC_HASHTABLE(obj->std.properties);
    zend_hash_init(obj->std.properties, 0, NULL, ZVAL_PTR_DTOR, 0);
//#if PHP_VERSION_ID < 50399
  //  zend_hash_copy(obj->std.properties, &type->default_properties,
  //      (copy_ctor_func_t)zval_add_ref, (void *)&tmp, sizeof(zval *));
//#else
    object_properties_init(&obj->std, type);
//#endif
// zend_hash_copy(obj->std.properties, &type->default_properties,
  //      (copy_ctor_func_t)zval_add_ref, (void *)&tmp, sizeof(zval *));

    retval.handle = zend_objects_store_put(obj, NULL,
        XsltProcessor_free_storage, NULL TSRMLS_CC);
    retval.handlers = &saxonProcessor_object_handlers;

    return retval;
}






PHP_METHOD(SaxonProcessor, __construct)
{

	//php_error(E_WARNING,"XSLT2 PHP constructor");
	char cwd[256];
	getcwd(cwd, sizeof(cwd));
	if (getcwd(cwd, sizeof(cwd)) == NULL) {
		php_error(E_WARNING,"getcwd error");
	}
	if (ZEND_NUM_ARGS()>0)  {
		WRONG_PARAM_COUNT;
	}
	
    XsltProcessor *xsltProcessor = NULL;
    zval *object = getThis();
    SaxonProcessor * saxonProc;
    saxonProcessor_object * obj = (saxonProcessor_object *)zend_object_store_get_object(object TSRMLS_CC);
    saxonProc =  obj->saxonProcessor;
    if(saxonProc == NULL) {
//		php_error(E_WARNING,"saxonProc created");
	saxonProc = new SaxonProcessor(false);	
	obj->saxonProcessor = saxonProc;
    } 
	
    saxonProc->setcwd(cwd);
    
   
    obj->saxonProcessor = saxonProc;
    /*saxonProc = obj->saxonProcessor;
    if(saxonProc == NULL) {
	php_error(E_WARNING, "SaxonProcessor Construct - call to SAxonProcessor");
	    saxonProc = new SaxonProcessor(false);	
	    obj->saxonProcessor = saxonProc;
    } 
    saxonProc->setcwd(cwd);*/
    xsltProcessor = saxonProc->newTransformer(); 	
    obj->xsltProcessor = xsltProcessor;
    XQueryProcessor * queryProcessor = saxonProc->newXQueryProcessor(); 
    obj->xqueryProcessor = queryProcessor;
}


PHP_METHOD(SaxonProcessor, __destruct)
{
//php_error(E_WARNING,"check destruct");
  saxonProcessor_object *obj = (saxonProcessor_object *)zend_object_store_get_object(
        getThis() TSRMLS_CC);

    XsltProcessor *xsltProcessor =  obj->xsltProcessor;
    SaxonProcessor * saxonProc= obj->saxonProcessor;

    delete xsltProcessor;
    delete saxonProc;
}


PHP_METHOD(SaxonProcessor, transformToFile)
{
   XsltProcessor *xsltProcessor;
   char * outfileName;
   int len1;


   if (zend_parse_parameters(ZEND_NUM_ARGS() TSRMLS_CC, "s", &outfileName, &len1) == FAILURE) {
        RETURN_NULL();
    }
    saxonProcessor_object *obj = (saxonProcessor_object *)zend_object_store_get_object(
        getThis() TSRMLS_CC);
    xsltProcessor = obj->xsltProcessor;
    char * style = obj->stylesheetFile;
    if (xsltProcessor != NULL) {
	char * sfilename  = NULL;
	if(obj->sfilename != NULL) {	
		sfilename = obj->sfilename;
	}
     xsltProcessor->xsltSaveResultToFile(sfilename, style, outfileName);
     if(xsltProcessor->exceptionOccurred()) {
     	//throw exception
     } 	
    }

}

PHP_METHOD(SaxonProcessor, transformToString)
{

   XsltProcessor *xsltProcessor;
   char * stylesheet;
   int len1;
	if (ZEND_NUM_ARGS()>0)  {
		WRONG_PARAM_COUNT;
	}
	
    saxonProcessor_object *obj = (saxonProcessor_object *)zend_object_store_get_object(
        getThis() TSRMLS_CC);
    xsltProcessor = obj->xsltProcessor;
    char * style = obj->stylesheetFile;
    if (xsltProcessor != NULL) {
	char * sfilename  = NULL;
	if(obj->sfilename != NULL) {	
		sfilename = obj->sfilename;
	}
	const char * result = xsltProcessor->xsltApplyStylesheet(sfilename, style);
	if(result != NULL) {
   	  char *str = estrdup(result);
          RETURN_STRING(str, 0);
       } else {
	  xsltProcessor->checkException();
	  const char * errStr = xsltProcessor->getErrorMessage(0);
	  if(errStr != NULL) {
	//php_error(E_WARNING, errStr);
	      const char * errorCode = xsltProcessor->getErrorCode(0);	
	      if(errorCode!=NULL){
	//	php_error(E_WARNING, errorCode);
//		RETURN_STRING(estrdup(errorCode),0);	
	      }	
//	     RETURN_STRING(estrdup(errStr),0);
          } 	
	}
    }
   RETURN_NULL();
}

PHP_METHOD(SaxonProcessor, transformToValue)
{

   XsltProcessor *xsltProcessor;
    char * style;
	if (ZEND_NUM_ARGS()>0)  {
		WRONG_PARAM_COUNT;
	}

    saxonProcessor_object *obj = (saxonProcessor_object *)zend_object_store_get_object(
        getThis() TSRMLS_CC);
    xsltProcessor = obj->xsltProcessor;
    style = obj->stylesheetFile;
    if (xsltProcessor != NULL) {
	
	/*string failures = "xsltApplyStylesheet failures:="+string(xsltProcessor->checkFailures());
	php_error(E_WARNING,failures.c_str());*/
	char * sfilename  = NULL;
	if(obj->sfilename != NULL) {	
		sfilename = obj->sfilename;
	}
	XdmValue * node = xsltProcessor->xsltApplyStylesheetToValue(sfilename, style);
         if(node != NULL) {
	  if (object_init_ex(return_value, xdmValue_ce) != SUCCESS) {
		//php_error(E_WARNING,"parseString reported as null");
              	RETURN_NULL();
	  } else {
	    struct xdmValue_object* vobj = (struct xdmValue_object *)zend_object_store_get_object(return_value TSRMLS_CC);
            assert (vobj != NULL); 
            vobj->xdmValue = node;
	 }
      } else {
		xsltProcessor->checkException();
	}
    } else {
  	 RETURN_NULL();
  }
}



PHP_METHOD(SaxonProcessor, setStylesheetFile)
{

   XsltProcessor *xsltProcessor;
   char * name;
   int len1;

    if (zend_parse_parameters(ZEND_NUM_ARGS() TSRMLS_CC, "s", &name, &len1) == FAILURE) {
        RETURN_NULL();
    }
    saxonProcessor_object *obj = (saxonProcessor_object *)zend_object_store_get_object(
        getThis() TSRMLS_CC);
    xsltProcessor = obj->xsltProcessor;
    if (xsltProcessor != NULL) {
	obj->stylesheetFile = name;
	obj->stylesheetStr = NULL;
    }
    
}



PHP_METHOD(SaxonProcessor, setStylesheetContent)
{

   XsltProcessor *xsltProcessor;
   char * stylesheetStr;
   int len1, myint;	
    if (zend_parse_parameters(ZEND_NUM_ARGS() TSRMLS_CC, "s", &stylesheetStr, &len1) == FAILURE) {
        RETURN_NULL();
    }
    saxonProcessor_object *obj = (saxonProcessor_object *)zend_object_store_get_object(
        getThis() TSRMLS_CC);
    xsltProcessor = obj->xsltProcessor;
    if (xsltProcessor != NULL) {
	obj->stylesheetStr = stylesheetStr;
	obj->stylesheetFile = NULL;
	xsltProcessor->compileString(stylesheetStr);
    }
}


PHP_METHOD(SaxonProcessor, setQueryContent)
{

   char * queryStr;
   int len1;

    if (zend_parse_parameters(ZEND_NUM_ARGS() TSRMLS_CC, "s", &queryStr, &len1) == FAILURE) {
        RETURN_NULL();
    }
    saxonProcessor_object *obj = (saxonProcessor_object *)zend_object_store_get_object(
        getThis() TSRMLS_CC);
	obj->queryStr = queryStr;
	obj->queryFile = NULL;

}

PHP_METHOD(SaxonProcessor, setQueryFile)
{

   char * fileName;
   int len1;

    if (zend_parse_parameters(ZEND_NUM_ARGS() TSRMLS_CC, "s", &fileName, &len1) == FAILURE) {
        RETURN_NULL();
    }
    saxonProcessor_object *obj = (saxonProcessor_object *)zend_object_store_get_object(
        getThis() TSRMLS_CC);
	obj->queryStr = NULL;
	obj->queryFile = fileName;

}


PHP_METHOD(SaxonProcessor, setSourceValue)
{
   SaxonProcessor *saxonProcessor;
   zval* oth;

    if (zend_parse_parameters(ZEND_NUM_ARGS() TSRMLS_CC, "O", &oth, xdmValue_ce) == FAILURE) {
        RETURN_NULL();
    }
    saxonProcessor_object *obj = (saxonProcessor_object *)zend_object_store_get_object(getThis() TSRMLS_CC);

    saxonProcessor = obj->saxonProcessor;
    if (saxonProcessor != NULL) {
	xdmValue_object* ooth = (xdmValue_object*)zend_object_store_get_object(oth TSRMLS_CC);
	if(ooth != NULL){
	  XdmValue * value = ooth->xdmValue;
	  if(value != NULL)
	    saxonProcessor->setSourceValue(value);
	} 
    }
}




PHP_METHOD(SaxonProcessor, setSourceFile)
{

   SaxonProcessor *saxonProcessor;
   char * filename;
    int len;

    if (zend_parse_parameters(ZEND_NUM_ARGS() TSRMLS_CC, "s",&filename, &len) == FAILURE) {
        RETURN_NULL();
    }
    saxonProcessor_object *obj = (saxonProcessor_object *)zend_object_store_get_object(getThis() TSRMLS_CC);
    //saxonProcessor = obj->saxonProcessor;
    if (filename != NULL) {
	obj->sfilename = filename;
    }
}

PHP_METHOD(SaxonProcessor, parseString)
{

   SaxonProcessor * saxonProcessor;
   char * source;
   int len1;	

    if (zend_parse_parameters(ZEND_NUM_ARGS() TSRMLS_CC, "s", &source, &len1) == FAILURE) {
        RETURN_NULL();
    }
    saxonProcessor_object *obj = (saxonProcessor_object *)zend_object_store_get_object(getThis() TSRMLS_CC);
    assert (obj != NULL);
    saxonProcessor = obj->saxonProcessor;
    if (saxonProcessor != NULL) {
	XdmValue* node = saxonProcessor->parseString(source);

//	php_error(E_WARNING, " create XdmValue");E_ERROR
       if(node != NULL) {
	  if (object_init_ex(return_value, xdmValue_ce) != SUCCESS) {
              	RETURN_NULL();
	  } else {
	    struct xdmValue_object* vobj = (struct xdmValue_object *)zend_object_store_get_object(return_value TSRMLS_CC);
            assert (vobj != NULL); 
            vobj->xdmValue = node;
	 }
      } else {
		obj->xsltProcessor->checkException();
	}
    } else {
    RETURN_NULL();
}	
    
}


PHP_METHOD(SaxonProcessor, parseFile)
{

   SaxonProcessor * saxonProcessor;
   char * source;
   int len1;	

    if (zend_parse_parameters(ZEND_NUM_ARGS() TSRMLS_CC, "s", &source, &len1) == FAILURE) {
        RETURN_NULL();
    }
    saxonProcessor_object *obj = (saxonProcessor_object *)zend_object_store_get_object(getThis() TSRMLS_CC);
    assert (obj != NULL);
    saxonProcessor = obj->saxonProcessor;
    if (saxonProcessor != NULL) {
	XdmValue* node = saxonProcessor->parseFile(source);

//	php_error(E_WARNING, " create XdmValue");E_ERROR
       if(node != NULL) {
	  if (object_init_ex(return_value, xdmValue_ce) != SUCCESS) {
              	RETURN_NULL();
	  } else {
	    struct xdmValue_object* vobj = (struct xdmValue_object *)zend_object_store_get_object(return_value TSRMLS_CC);
            assert (vobj != NULL); 
            vobj->xdmValue = node;
	 }
      } else {
		obj->xsltProcessor->checkException();
	}
    } else {
    RETURN_NULL();
}	
    
}


PHP_METHOD(SaxonProcessor, createXdmValue)
{

   XdmValue * xdmValue = NULL;
   SaxonProcessor * proc;
   char * source;
   int len1;	
   zval *zvalue;
    bool bVal;
    char * sVal;
    int len;
    long iVal;
    double dVal;
    if (zend_parse_parameters(ZEND_NUM_ARGS() TSRMLS_CC, "z",&zvalue) == FAILURE) {
        RETURN_NULL();
    }
    saxonProcessor_object *obj = (saxonProcessor_object *)zend_object_store_get_object(getThis() TSRMLS_CC);
    assert (obj != NULL);
    proc = obj->saxonProcessor;
    assert (proc != NULL);

    if (proc != NULL) {
	//if (zend_parse_parameters(ZEND_NUM_ARGS() TSRMLS_CC, "z",&zvalue) == SUCCESS) { 
	switch (Z_TYPE_P(zvalue)) {
       
        case IS_BOOL:
	  bVal = Z_BVAL_P(zvalue);
         xdmValue = new XdmValue(bVal);
       //  obj->xdmValue = xdmValue;
	 break;
        case IS_LONG:
	     iVal = Z_LVAL_P(zvalue);
             xdmValue = new XdmValue((int)iVal);
          //   obj->xdmValue = xdmValue;
	  break;
        case IS_STRING:
            sVal = Z_STRVAL_P(zvalue);
            len = Z_STRLEN_P(zvalue);
	    xdmValue = new XdmValue(string()+sVal);
          //  obj->xdmValue = xdmValue;
            break;
	 case IS_NULL:
	    xdmValue = new XdmValue();
       	    //obj->xdmValue = xdmValue;
	    break;
        case IS_DOUBLE:
           //index = (long)Z_DVAL_P(zvalue);
            //break;
        case IS_ARRAY:
            //break;
        case IS_OBJECT:
            //break;
        default:
	  obj = NULL;
          zend_throw_exception(zend_exception_get_default(TSRMLS_C), "unknown type specified in XdmValue", 0 TSRMLS_CC); 
	RETURN_NULL();
   }

       if(xdmValue == NULL) {
		//obj->xsltProcessor->checkException();
		 RETURN_NULL();

	}
	  if (object_init_ex(return_value, xdmValue_ce) != SUCCESS) {
              	RETURN_NULL();
	  } else {
	    struct xdmValue_object* vobj = (struct xdmValue_object *)zend_object_store_get_object(return_value TSRMLS_CC);
            assert (vobj != NULL); 
            vobj->xdmValue = xdmValue;

		//return;
	 }
       
   
  } else {
//	   php_error(E_WARNING, " createXdmValue - should not reach!");
		 RETURN_NULL();
}

   
	
    
}


PHP_METHOD(SaxonProcessor, setProperty)
{

   SaxonProcessor *saxonProcessor;
   char * name;
   char * value;
   int len1, len2, myint;	

    if (zend_parse_parameters(ZEND_NUM_ARGS() TSRMLS_CC, "ss", &name, &len1, &value, &len2) == FAILURE) {
        RETURN_NULL();
    }
    saxonProcessor_object *obj = (saxonProcessor_object *)zend_object_store_get_object(
        getThis() TSRMLS_CC);
    saxonProcessor = obj->saxonProcessor;
    if (saxonProcessor != NULL) {
	saxonProcessor->setProperty(name, value);
    }
}

PHP_METHOD(SaxonProcessor, setParameter)
{

   SaxonProcessor *saxonProcessor;
   char * namespacei;
   char * name;
   zval* oth;
   int len1, len2, len3, myint;	
    if (zend_parse_parameters(ZEND_NUM_ARGS() TSRMLS_CC, "ssO", &namespacei, &len1, &name, &len2, &oth, xdmValue_ce) == FAILURE) {
        RETURN_NULL();
    }
    saxonProcessor_object *obj = (saxonProcessor_object *)zend_object_store_get_object(
        getThis() TSRMLS_CC);
    saxonProcessor = obj->saxonProcessor;
    if (saxonProcessor != NULL) {
	xdmValue_object* ooth = (xdmValue_object*)zend_object_store_get_object(oth TSRMLS_CC);
	if(ooth != NULL){
		XdmValue * value = ooth->xdmValue;
		if(value != NULL) {
		saxonProcessor->setParameter("", name, value);
		}
	}
	
	/*const char * errStr = xsltProcessor->getErrorMessage();
	if(errStr!=NULL) {
	//throw exception
   	}*/
    }
}

PHP_METHOD(SaxonProcessor, getParameter)
{

   SaxonProcessor * saxonProcessor;
   char * name;
   int len1;	

    if (zend_parse_parameters(ZEND_NUM_ARGS() TSRMLS_CC, "s", &name, &len1) == FAILURE) {
        RETURN_NULL();
    }
    saxonProcessor_object *obj = (saxonProcessor_object *)zend_object_store_get_object(getThis() TSRMLS_CC);
    assert (obj != NULL);
    saxonProcessor = obj->saxonProcessor;
    if (saxonProcessor != NULL) {
	XdmValue* node = saxonProcessor->getParameter(name);

       if(node != NULL) {
	  if (object_init_ex(return_value, xdmValue_ce) != SUCCESS) {
		//php_error(E_WARNING,"parseString reported as null");
              	RETURN_NULL();
	  } else {
	    struct xdmValue_object* vobj = (struct xdmValue_object *)zend_object_store_get_object(return_value TSRMLS_CC);
            assert (vobj != NULL); 
            vobj->xdmValue = node;
	 }
      } 
    } else {

    RETURN_NULL();
}
	
    
}


PHP_METHOD(SaxonProcessor, getProperty)
{

   SaxonProcessor * saxonProcessor;
   char * name;
   int len1;	

    if (zend_parse_parameters(ZEND_NUM_ARGS() TSRMLS_CC, "s", &name, &len1) == FAILURE) {
        RETURN_NULL();
    }
    saxonProcessor_object *obj = (saxonProcessor_object *)zend_object_store_get_object(getThis() TSRMLS_CC);
    assert (obj != NULL);
    saxonProcessor = obj->saxonProcessor;
    if (saxonProcessor != NULL) {
	const char * value  = saxonProcessor->getProperty(name);

       if(value != NULL) {
	 RETURN_STRING(value, 0);
       }

    }
    RETURN_NULL();	
    
}

PHP_METHOD(SaxonProcessor, clearParameters)
{

   SaxonProcessor *saxonProcessor;
	if (ZEND_NUM_ARGS()>0)  {
		WRONG_PARAM_COUNT;
	}

    saxonProcessor_object *obj = (saxonProcessor_object *)zend_object_store_get_object(getThis() TSRMLS_CC);
    saxonProcessor = obj->saxonProcessor;
    if (saxonProcessor != NULL) {
	saxonProcessor->clearParameters();
    }
}

PHP_METHOD(SaxonProcessor, clearProperties)
{

   SaxonProcessor *saxonProcessor;
	if (ZEND_NUM_ARGS()>0)  {
		WRONG_PARAM_COUNT;
	}

    saxonProcessor_object *obj = (saxonProcessor_object *)zend_object_store_get_object(getThis() TSRMLS_CC);
    saxonProcessor = obj->saxonProcessor;
    if (saxonProcessor != NULL) {
	saxonProcessor->clearProperties();
    }
}


PHP_METHOD(SaxonProcessor, version)
{

   SaxonProcessor *saxonProcessor;

    saxonProcessor_object *obj = (saxonProcessor_object *)zend_object_store_get_object(getThis() TSRMLS_CC);
	if (ZEND_NUM_ARGS()>0)  {
		WRONG_PARAM_COUNT;
	}

    saxonProcessor = obj->saxonProcessor;
    if (saxonProcessor != NULL) {
	char *str = estrdup(saxonProcessor->version());
	RETURN_STRING(str, 0);
    }
   RETURN_NULL();
}

PHP_METHOD(SaxonProcessor, getExceptionCount)
{

   XsltProcessor *xsltProcessor;

    saxonProcessor_object *obj = (saxonProcessor_object *)zend_object_store_get_object(getThis() TSRMLS_CC);
	if (ZEND_NUM_ARGS()>0)  {
		WRONG_PARAM_COUNT;
	}

    xsltProcessor = obj->xsltProcessor;
    if (xsltProcessor != NULL) {
	int count = xsltProcessor->exceptionCount();
	   RETURN_LONG(count);
   }
   RETURN_LONG(0);
}

PHP_METHOD(SaxonProcessor, getErrorCode)
{

   XsltProcessor *xsltProcessor;
   long index;
    if (zend_parse_parameters(ZEND_NUM_ARGS() TSRMLS_CC, "l", &index) == FAILURE) {
        RETURN_NULL();
    }
    saxonProcessor_object *obj = (saxonProcessor_object *)zend_object_store_get_object(getThis() TSRMLS_CC);
    xsltProcessor = obj->xsltProcessor;
    if (xsltProcessor != NULL) {
	const char * errCode = xsltProcessor->getErrorCode((int)index);
	if(errCode != NULL) {
	  char *str = estrdup(errCode);
	  RETURN_STRING(str, 0);	
	}
    }
   RETURN_NULL();
}

PHP_METHOD(SaxonProcessor, getErrorMessage)
{

   XsltProcessor *xsltProcessor;
   long index;
    if (zend_parse_parameters(ZEND_NUM_ARGS() TSRMLS_CC, "l", &index) == FAILURE) {
        RETURN_NULL();
    }
    saxonProcessor_object *obj = (saxonProcessor_object *)zend_object_store_get_object(getThis() TSRMLS_CC);
    xsltProcessor = obj->xsltProcessor;
    if (xsltProcessor != NULL) {
	const char * errStr = xsltProcessor->getErrorMessage((int)index);
	if(errStr != NULL) {
	  char *str = estrdup(errStr);
	  RETURN_STRING(str, 0);	
	}
    }
   RETURN_NULL();
}


PHP_METHOD(SaxonProcessor, close)
{
php_error(E_WARNING,"XSLT2 PHP close");
   SaxonProcessor *saxonProcessor;

    saxonProcessor_object *obj = (saxonProcessor_object *)zend_object_store_get_object(getThis() TSRMLS_CC);
    saxonProcessor = obj->saxonProcessor;
    if (saxonProcessor != NULL) {
	saxonProcessor->close();
    }
     
}


PHP_METHOD(SaxonProcessor, exceptionClear)
{

   XsltProcessor *xsltProcessor;

    saxonProcessor_object *obj = (saxonProcessor_object *)zend_object_store_get_object(getThis() TSRMLS_CC);
    xsltProcessor = obj->xsltProcessor;
    if (xsltProcessor != NULL) {
	xsltProcessor->exceptionClear();
    }
}
	

PHP_METHOD(SaxonProcessor, queryToString)
{

   XQueryProcessor *xqueryProcessor;
    saxonProcessor_object *obj = (saxonProcessor_object *)zend_object_store_get_object(
        getThis() TSRMLS_CC);

	if (ZEND_NUM_ARGS()>0)  {
		WRONG_PARAM_COUNT;
	}


    xqueryProcessor = obj->xqueryProcessor;
    char * queryStr = obj->queryStr;
    char * queryFile = obj->queryFile;
	char * sfilename  = NULL;
	if(obj->sfilename != NULL) {	
		sfilename = obj->sfilename;
	}
    if (xqueryProcessor != NULL) {
	
	/*string failures = "xsltApplyStylesheet failures:="+string(xsltProcessor->checkFailures());
	php_error(E_WARNING,failures.c_str());*/
	if(queryStr == NULL & queryFile != NULL) {
		xqueryProcessor->setQueryFile(queryFile);	
	}
	const char * result = xqueryProcessor->executeQueryToString(sfilename,(queryStr==NULL ? NULL : queryStr));
         if(result != NULL) {
	  char *str = estrdup(result);
	  RETURN_STRING(str, 0);
	  return;
        } else {
		xqueryProcessor->checkException();
	}
    }
   RETURN_NULL();
  
}

PHP_METHOD(SaxonProcessor, queryToFile)
{

   XQueryProcessor *xqueryProcessor;
   char * outfilename;
   char * querystr;
   int len1;	

    if (zend_parse_parameters(ZEND_NUM_ARGS() TSRMLS_CC, "s", &outfilename, &len1) == FAILURE) {
        RETURN_NULL();
    }
    saxonProcessor_object *obj = (saxonProcessor_object *)zend_object_store_get_object(
        getThis() TSRMLS_CC);
    xqueryProcessor = obj->xqueryProcessor;
    char * queryStr = obj->queryStr;
    char * queryFile = obj->queryFile;
    char * sfilename  = NULL;
    if(obj->sfilename != NULL) {	
	sfilename = obj->sfilename;
    }
    if (xqueryProcessor != NULL) {
	if(queryStr == NULL && queryFile != NULL) {
		xqueryProcessor->setQueryFile(queryFile);	
	}
	/*string failures = "xsltApplyStylesheet failures:="+string(xsltProcessor->checkFailures());
	php_error(E_WARNING,failures.c_str());*/
	xqueryProcessor->executeQueryToFile(sfilename, outfilename, queryStr);        
	xqueryProcessor->checkException();
    } 
}


PHP_METHOD(SaxonProcessor, queryToValue)
{

   XQueryProcessor *xqueryProcessor;


    saxonProcessor_object *obj = (saxonProcessor_object *)zend_object_store_get_object(
        getThis() TSRMLS_CC);

	if (ZEND_NUM_ARGS()>0)  {
		WRONG_PARAM_COUNT;
	}

    char * queryStr = obj->queryStr;
    char * queryFile = obj->queryFile;
    xqueryProcessor = obj->xqueryProcessor;
    char * sfilename  = NULL;
	if(obj->sfilename != NULL) {	
		sfilename = obj->sfilename;
     }
    if (xqueryProcessor != NULL) {
	
	/*string failures = "xsltApplyStylesheet failures:="+string(xsltProcessor->checkFailures());
	php_error(E_WARNING,failures.c_str());*/
	if(queryStr == NULL && queryFile != NULL) {
		xqueryProcessor->setQueryFile(queryFile);	
	}
	XdmValue * node = xqueryProcessor->executeQueryToValue(sfilename, queryStr);
         if(node != NULL) {
	  if (object_init_ex(return_value, xdmValue_ce) != SUCCESS) {
		//php_error(E_WARNING,"parseString reported as null");
              	RETURN_NULL();
		return;
	  } else {
	    struct xdmValue_object* vobj = (struct xdmValue_object *)zend_object_store_get_object(return_value TSRMLS_CC);
            assert (vobj != NULL); 
            vobj->xdmValue = node;
	    return;
	 }
      } 
	xqueryProcessor->checkException();
    } else {
  	 RETURN_NULL();
  }
}



zend_function_entry XsltProcessor_methods[] = {
    PHP_ME(SaxonProcessor,  __construct,     NULL, ZEND_ACC_PUBLIC | ZEND_ACC_CTOR)
    PHP_ME(SaxonProcessor,  __destruct,     NULL, ZEND_ACC_PUBLIC | ZEND_ACC_DTOR)
    PHP_ME(SaxonProcessor,  createXdmValue,      NULL, ZEND_ACC_PUBLIC)
    PHP_ME(SaxonProcessor,  setSourceValue,      NULL, ZEND_ACC_PUBLIC)
    PHP_ME(SaxonProcessor,  setSourceFile,      NULL, ZEND_ACC_PUBLIC)
    PHP_ME(SaxonProcessor,  parseString,      NULL, ZEND_ACC_PUBLIC)
    PHP_ME(SaxonProcessor,  parseFile,      NULL, ZEND_ACC_PUBLIC)
    PHP_ME(SaxonProcessor,  setParameter,      NULL, ZEND_ACC_PUBLIC)
    PHP_ME(SaxonProcessor,  setProperty,      NULL, ZEND_ACC_PUBLIC)
    PHP_ME(SaxonProcessor,  getParameter,      NULL, ZEND_ACC_PUBLIC)
    PHP_ME(SaxonProcessor,  getProperty,      NULL, ZEND_ACC_PUBLIC)
    PHP_ME(SaxonProcessor,  clearParameters,      NULL, ZEND_ACC_PUBLIC)
    PHP_ME(SaxonProcessor,  clearProperties,      NULL, ZEND_ACC_PUBLIC)
//    PHP_ME(SaxonProcessor,  importDocument,      NULL, ZEND_ACC_PUBLIC)
    PHP_ME(SaxonProcessor,  setStylesheetContent,      NULL, ZEND_ACC_PUBLIC)
    PHP_ME(SaxonProcessor,  setStylesheetFile,      NULL, ZEND_ACC_PUBLIC)
    PHP_ME(SaxonProcessor,  setQueryContent,      NULL, ZEND_ACC_PUBLIC)
    PHP_ME(SaxonProcessor,  setQueryFile,      NULL, ZEND_ACC_PUBLIC)
//    PHP_ME(SaxonProcessor,  registerPHPFunction,      NULL, ZEND_ACC_PUBLIC)
//    PHP_ME(SaxonProcessor,  transformToDoc,      NULL, ZEND_ACC_PUBLIC)
    PHP_ME(SaxonProcessor,  transformToFile,      NULL, ZEND_ACC_PUBLIC)
    PHP_ME(SaxonProcessor,  transformToString,      NULL, ZEND_ACC_PUBLIC)
    PHP_ME(SaxonProcessor,  transformToValue,      NULL, ZEND_ACC_PUBLIC)
    PHP_ME(SaxonProcessor,  queryToFile,      NULL, ZEND_ACC_PUBLIC)
    PHP_ME(SaxonProcessor,  queryToValue,      NULL, ZEND_ACC_PUBLIC)
    PHP_ME(SaxonProcessor,  queryToString,      NULL, ZEND_ACC_PUBLIC)
    PHP_ME(SaxonProcessor,  exceptionClear,      NULL, ZEND_ACC_PUBLIC)
    PHP_ME(SaxonProcessor,  close,      NULL, ZEND_ACC_PUBLIC)
    PHP_ME(SaxonProcessor,  getErrorCode,      NULL, ZEND_ACC_PUBLIC)
    PHP_ME(SaxonProcessor,  getErrorMessage,      NULL, ZEND_ACC_PUBLIC)
    PHP_ME(SaxonProcessor,  getExceptionCount,      NULL, ZEND_ACC_PUBLIC)
    PHP_ME(SaxonProcessor,  version,      NULL, ZEND_ACC_PUBLIC)
    {NULL, NULL, NULL}
};




/*     ============== PHP Interface of   XdmValue =============== */

void xdmValue_free_storage(void *object TSRMLS_DC)
{
//	php_error(E_WARNING,"xdmValue freestorage");
    xdmValue_object *obj = (xdmValue_object *)object;
    delete obj->xdmValue; 

    zend_hash_destroy(obj->std.properties);
    FREE_HASHTABLE(obj->std.properties);

    efree(obj);
}

zend_object_value xdmValue_create_handler(zend_class_entry *type TSRMLS_DC)
{
    zval *tmp;
    zend_object_value retval;
//	php_error(E_WARNING,"xdmValue create_handlers");
    xdmValue_object *obj = (xdmValue_object *)emalloc(sizeof(xdmValue_object));
    memset(obj, 0, sizeof(xdmValue_object));
    obj->std.ce = type;

    ALLOC_HASHTABLE(obj->std.properties);
    zend_hash_init(obj->std.properties, 0, NULL, ZVAL_PTR_DTOR, 0);
    object_properties_init(&obj->std, type);


    retval.handle = zend_objects_store_put(obj, NULL,
        xdmValue_free_storage, NULL TSRMLS_CC);
    retval.handlers = &xdmValue_object_handlers;

    return retval;
}

PHP_METHOD(XdmValue, __construct)
{
    XdmValue *xdmValue = NULL;
    bool bVal;
    char * sVal;
    int len;
    long iVal;
    double dVal;
     zval *zvalue; 

    SaxonProcessor *proc= NULL;
 xdmValue_object *obj = (xdmValue_object *)zend_object_store_get_object(
        getThis() TSRMLS_CC);

   
 if (zend_parse_parameters(ZEND_NUM_ARGS() TSRMLS_CC, "z",&zvalue) == SUCCESS) { 
switch (Z_TYPE_P(zvalue)) {
       
        case IS_BOOL:
	  bVal = Z_BVAL_P(zvalue);
         xdmValue = new XdmValue(bVal);
         obj = (xdmValue_object *)zend_object_store_get_object(getThis() TSRMLS_CC);
         obj->xdmValue = xdmValue;
	 break;
        case IS_LONG:
	     iVal = Z_LVAL_P(zvalue);
             xdmValue = new XdmValue((int)iVal);
             obj = (xdmValue_object *)zend_object_store_get_object(getThis() TSRMLS_CC);
             obj->xdmValue = xdmValue;
	  break;
        case IS_STRING:
            sVal = Z_STRVAL_P(zvalue);
            len = Z_STRLEN_P(zvalue);
	    xdmValue = new XdmValue("string", sVal);
	    obj = (xdmValue_object *)zend_object_store_get_object(getThis() TSRMLS_CC);
            obj->xdmValue = xdmValue;
            break;
	 case IS_NULL:
	    xdmValue = new XdmValue();
            obj = (xdmValue_object *)zend_object_store_get_object(getThis() TSRMLS_CC);
       	    obj->xdmValue = xdmValue;
	    break;
        case IS_DOUBLE:
           //index = (long)Z_DVAL_P(zvalue);
            //break;
        case IS_ARRAY:
            //break;
        case IS_OBJECT:
            //break;
        default:
	  obj = NULL;
          zend_throw_exception(zend_exception_get_default(TSRMLS_C), "unknown type specified in XdmValue", 0 TSRMLS_CC);
    }

   } 



}


PHP_METHOD(XdmValue, getErrorCode)
{

   XdmValue *xdmValue;
   long index;
    if (zend_parse_parameters(ZEND_NUM_ARGS() TSRMLS_CC, "l", &index) == FAILURE) {
        RETURN_NULL();
    }
    xdmValue_object *obj = (xdmValue_object *)zend_object_store_get_object(getThis() TSRMLS_CC);
    xdmValue = obj->xdmValue;
    if (xdmValue != NULL) {
	const char * errCode = xdmValue->getErrorCode(index);
	if(errCode != NULL) {
	  char *str = estrdup(errCode);
	  RETURN_STRING(str, 0);	
	}
    }
   RETURN_NULL();
}



PHP_METHOD(XdmValue, getStringValue)
{

   XdmValue *xdmValue;
    xdmValue_object *obj = (xdmValue_object *)zend_object_store_get_object(getThis() TSRMLS_CC);
    xdmValue = obj->xdmValue;
    if (xdmValue != NULL) {
//	const char * valueStr = xdmValue->getStringValue(); //TODO
	//if(valueStr != NULL) {
	  char *str = estrdup(""/*valueStr*/);
	  RETURN_STRING(str, 0);	
	//}
    }
   RETURN_NULL();
}



zend_function_entry xdmValue_methods[] = {
    PHP_ME(XdmValue,  __construct,     NULL, ZEND_ACC_PUBLIC | ZEND_ACC_CTOR)
    PHP_ME(XdmValue,  getErrorCode,      NULL, ZEND_ACC_PUBLIC)
    PHP_ME(XdmValue,  getStringValue,      NULL, ZEND_ACC_PUBLIC)
    {NULL, NULL, NULL}
};

/*static void php_saxon_init_globals(zend_saxon_globals *saxon_globals)
{
}*/



PHP_MINIT_FUNCTION(saxon)
{
//ts_allocate_id(&saxon_globals_id, sizeof(saxonProcessor_object), (ts_allocate_ctor)saxonProcessor_object,(ts_allocate_dtor)saxonProcessor_object);
    zend_class_entry ce;
    INIT_CLASS_ENTRY(ce, "SaxonProcessor", XsltProcessor_methods);
    saxonProcessor_ce = zend_register_internal_class(&ce TSRMLS_CC);
    saxonProcessor_ce->create_object = saxonProcessor_create_handler;
    memcpy(&saxonProcessor_object_handlers,
        zend_get_std_object_handlers(), sizeof(zend_object_handlers));
    saxonProcessor_object_handlers.clone_obj = NULL;


    INIT_CLASS_ENTRY(ce, "XdmValue", xdmValue_methods);
    xdmValue_ce = zend_register_internal_class(&ce TSRMLS_CC);
    xdmValue_ce->create_object = xdmValue_create_handler;
    memcpy(&xdmValue_object_handlers,
        zend_get_std_object_handlers(), sizeof(zend_object_handlers));
    xdmValue_object_handlers.clone_obj = NULL;


// ZEND_INIT_MODULE_GLOBALS(saxon, php_saxon_init_globals,NULL);

   // REGISTER_INI_ENTRIES();

    return SUCCESS;
}

// function implementation
PHP_MINFO_FUNCTION(saxon)
{
    php_info_print_table_start();
    php_info_print_table_header(2, "Saxon/C", "enabled");
    php_info_print_table_row(2, "Saxon/C EXT version", "0.2");
    php_info_print_table_row(2, "Saxon-HEJ", "9.5.1.3");
    php_info_print_table_row(2, "Excelsior JET (MP1)", "9.0");
    php_info_print_table_end();
    DISPLAY_INI_ENTRIES();
}

PHP_MSHUTDOWN_FUNCTION(saxon){
 //	php_error(E_WARNING,"entered MSHUTDOWN");
	UNREGISTER_INI_ENTRIES();
	return SUCCESS;
}

PHP_RSHUTDOWN_FUNCTION(saxon){
 //	php_error(E_WARNING,"entered RSHUTDOWN");
	return SUCCESS;
}

PHP_RINIT_FUNCTION(saxon){
//    php_error(E_WARNING,"entered RINT");
    return SUCCESS;
}


zend_module_entry saxon_module_entry = {
#if ZEND_MODULE_API_NO >= 20010901
    STANDARD_MODULE_HEADER,
#endif
    PHP_SAXON_EXTNAME,
    NULL,        /* Functions */
    PHP_MINIT(saxon),        /* MINIT */
    PHP_MSHUTDOWN(saxon),        /* MSHUTDOWN */
    /*PHP_RINIT(saxon)*/NULL,        /* RINIT */
    PHP_RSHUTDOWN(saxon),        /* RSHUTDOWN */
    PHP_MINFO(saxon),        /* MINFO */
#if ZEND_MODULE_API_NO >= 20010901
    PHP_SAXON_EXTVER,
#endif
    STANDARD_MODULE_PROPERTIES
};



//#ifdef COMPILE_DL_SAXON
extern "C" {
ZEND_GET_MODULE(saxon)
}
//#endif
