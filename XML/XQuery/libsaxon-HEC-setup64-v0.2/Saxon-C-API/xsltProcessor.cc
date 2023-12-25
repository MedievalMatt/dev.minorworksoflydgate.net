#include "saxonProcessor.h"
//#include "php_saxon.h"



/*JNIEnv *env;
HANDLE myDllHandle;
JavaVM *jvm;*/


/*
 * Load dll.
 */
/*HANDLE loadDll(char* name)
{
    HANDLE hDll = LoadLibrary (name);

    if (!hDll) {
        printf ("Unable to load %s\n", name);
        exit(1);
    }

   // printf ("%s loaded\n", name);

    return hDll;
}

extern "C" {
jint (JNICALL * JNI_GetDefaultJavaVMInitArgs_func) (void *args);
jint (JNICALL * JNI_CreateJavaVM_func) (JavaVM **pvm, void **penv, void *args);
}

void finalizeJavaRT (JavaVM* jvmi)
{
	
    jvmi->DestroyJavaVM ();
}
*/
/*
 * Initialize JET run-time.
 */
/*extern "C" void initJavaRT(HANDLE myDllHandle, JavaVM** pjvm, JNIEnv** penv)
{
    int            result;
    JavaVMInitArgs args;

    JNI_GetDefaultJavaVMInitArgs_func = 
             (jint (JNICALL *) (void *args))
             GetProcAddress (myDllHandle, "JNI_GetDefaultJavaVMInitArgs");

    JNI_CreateJavaVM_func =
             (jint (JNICALL *) (JavaVM **pvm, void **penv, void *args))
             GetProcAddress (myDllHandle, "JNI_CreateJavaVM");

    if(!JNI_GetDefaultJavaVMInitArgs_func) {
        printf ("%s doesn't contain public JNI_GetDefaultJavaVMInitArgs\n", dllname);
        exit (1);
    }

    if(!JNI_CreateJavaVM_func) {
        printf ("%s doesn't contain public JNI_CreateJavaVM\n", dllname);
        exit (1);
    }

    memset (&args, 0, sizeof(args));

    args.version = JNI_VERSION_1_2;
    result = JNI_GetDefaultJavaVMInitArgs_func(&args);
    if (result != JNI_OK) {
        printf ("JNI_GetDefaultJavaVMInitArgs() failed with result %d\n", result);
        exit(1);
    }
  
    //
     // NOTE: no JVM is actually created
     //this call to JNI_CreateJavaVM is intended for JET RT initialization
     //
    result = JNI_CreateJavaVM_func (pjvm, (void **)penv, &args);
    if (result != JNI_OK) {
        printf ("JNI_CreateJavaVM() failed with result %d\n", result);
        exit(1);
    }

   // printf ("JET RT initialized\n");
   // fflush (stdout);
}*/

/*
 * Look for class.
 */

/*jclass lookForClass (JNIEnv* env, const char* name)
{
    jclass clazz = (jclass)env->FindClass (name);

    if (!clazz) {
        printf("Unable to find class %s\n", name);
	fflush (stdout);
        exit(1);
    }

    //printf ("Class %s found\n", name);
    //fflush (stdout);

    return clazz;
}*/

/*jmethodID findConstructor (JNIEnv* env, jclass myClassInDll, char* arguments)
{
    jmethodID MID_init, mID;
    jobject obj;

    MID_init = (jmethodID)env->GetMethodID (myClassInDll, "<init>", arguments);
    if (!MID_init) {
        printf("Error: MyClassInDll.<init>() not found\n");
	fflush (stdout);
        return NULL;
    }

  return MID_init;
}

jobject createObject (JNIEnv* env, jclass myClassInDll, char * arguments, bool l)
{
    jmethodID MID_init, mID;
    jobject obj;

    MID_init = (jmethodID)env->GetMethodID (myClassInDll, "<init>", arguments);
    if (!MID_init) {
        printf("Error: MyClassInDll.<init>() not found\n");
	fflush (stdout);
        return NULL;
    }

      obj = (jobject)env->NewObject(myClassInDll, MID_init, (jboolean)l);
      if (!obj) {
        printf("Error: failed to allocate an object\n");
	fflush (stdout);
        return NULL;
      }
    return obj;
}*/

SaxonApiException * checkForException(JNIEnv* env, jclass callingClass,  jobject callingObject){

    if (env->ExceptionCheck()) {
	char *  result1;
	const char * errorCode = NULL;
	jthrowable exc = env->ExceptionOccurred();
	//env->ExceptionDescribe();
	 jclass exccls(env->GetObjectClass(exc));
        jclass clscls(env->FindClass("java/lang/Class"));

        jmethodID getName(env->GetMethodID(clscls, "getName", "()Ljava/lang/String;"));
        jstring name(static_cast<jstring>(env->CallObjectMethod(exccls, getName)));
        char const* utfName(env->GetStringUTFChars(name, 0));
	

	 jmethodID  getMessage(env->GetMethodID(exccls, "getMessage", "()Ljava/lang/String;"));
	if(getMessage) {

		jstring message(static_cast<jstring>(env->CallObjectMethod(exc, getMessage)));
        	char const* utfMessage(env->GetStringUTFChars(message, 0));
		if(utfMessage != NULL) {
			result1 = new char(strlen(utfName)+2+strlen(utfMessage));
			strcpy(result1, utfName);
			result1[strlen(result1)-1] = ':';
			strcat(result1, utfMessage);
		} else {
			result1 = new char[strlen(utfName)];
			strcpy(result1, utfName);
		}
		//printf(result1);
		env->ReleaseStringUTFChars(name, utfName);	
		env->ReleaseStringUTFChars(message,utfMessage);
		if(strncmp(result1, "net.sf.saxon.s9api.SaxonApiException", 36) == 0){
			jmethodID  getErrorCodeID(env->GetMethodID(callingClass, "getExceptions", "()[Lnet/sf/saxon/option/cpp/SaxonExceptionForCpp;"));
			jclass saxonExceptionClass(env->FindClass("net/sf/saxon/option/cpp/SaxonExceptionForCpp"));
				if(getErrorCodeID){	
					jobjectArray saxonExceptionObject((jobjectArray)(env->CallObjectMethod(callingObject, getErrorCodeID)));
					if(saxonExceptionObject) {
						jmethodID lineNumID = env->GetMethodID(saxonExceptionClass, "getLinenumber", "()I");
						jmethodID ecID = env->GetMethodID(saxonExceptionClass, "getErrorCode", "()Ljava/lang/String;");
						jmethodID emID = env->GetMethodID(saxonExceptionClass, "getErrorMessage", "()Ljava/lang/String;");
						jmethodID typeID = env->GetMethodID(saxonExceptionClass, "isTypeError", "()Z");
						jmethodID staticID = env->GetMethodID(saxonExceptionClass, "isStaticError", "()Z");
						jmethodID globalID = env->GetMethodID(saxonExceptionClass, "isGlobalError", "()Z");


						int exLength = (int)env->GetArrayLength(saxonExceptionObject);
						SaxonApiException * saxonExceptions = new SaxonApiException();
						for(int i=0; i<exLength;i++){
							jobject exObj = env->GetObjectArrayElement(saxonExceptionObject, i);

							jstring errCode = (jstring)(env->CallObjectMethod(exObj, ecID));
							jstring errMessage = (jstring)(env->CallObjectMethod(exObj, emID));
							jboolean isType = (env->CallBooleanMethod(exObj, typeID));
							jboolean isStatic = (env->CallBooleanMethod(exObj, staticID));
							jboolean isGlobal = (env->CallBooleanMethod(exObj, globalID));
							saxonExceptions->add((errCode ? env->GetStringUTFChars(errCode,0) : NULL )  ,(errMessage ? env->GetStringUTFChars(errMessage,0) : NULL),(int)(env->CallIntMethod(exObj, lineNumID)), (bool)isType, (bool)isStatic, (bool)isGlobal);
							env->ExceptionDescribe();
						}
						//env->ExceptionDescribe();
						env->ExceptionClear();
						return saxonExceptions;
					}
				}
		}
	}
	SaxonApiException * saxonExceptions = new SaxonApiException(NULL, result1);
	//env->ExceptionDescribe();
	env->ExceptionClear();
	return saxonExceptions;
     }
	return NULL;

}


XsltProcessor::XsltProcessor(bool license) {
   /*
     * First of all, load required component.
     * By the time of JET initialization, all components should be loaded.
     */
    myDllHandle = loadDll (dllname);

    /*
     * Initialize JET run-time.
     * The handle of loaded component is used to retrieve Invocation API.
     */
    initJavaRT (myDllHandle, &jvm, &env);

    /*
     * Look for class.
     */
     cppClass = lookForClass(env, "net/sf/saxon/option/cpp/XsltProcessorForCpp");
     versionClass = lookForClass(env, "net/sf/saxon/Version");

    cpp = createObject (env, cppClass, "(Z)V", license);
    jmethodID debugMID = env->GetStaticMethodID(cppClass, "setDebugMode", "(Z)V");
    if(debugMID){
	env->CallStaticVoidMethod(cppClass, debugMID, (jboolean)false);
    }
    parameters = new MyParameter[10];
    parLen=0;
    parCap = 10;
    properties = new MyProperty[10];
    propLen=0;
    propCap = 10;
    nodeCreated = false;
    exception = NULL;
    outputfile1 = "";

}

void XsltProcessor::close(){
	clearSettings();
	exceptionClear();
	finalizeJavaRT (jvm);
//dlclose(myDllHandle);	
 
}

    XsltProcessor::~XsltProcessor(){
//dlclose(myDllHandle);	
	clearSettings();
	exceptionClear();
	delete parameters;
	delete properties;
	delete exception;
    }



const char * XsltProcessor::getErrorCode(int i) {
	if(exception == NULL) {return NULL;}
	return exception->getErrorCode(i);
}

const char * XsltProcessor::version() {


    jmethodID MID_foo;

    char methodName[] = "getProductVersion";
    char args[] = "()Ljava/lang/String;";
    MID_foo = (jmethodID)env->GetStaticMethodID(versionClass, methodName, args);
    if (!MID_foo) {
	printf("\nError: MyClassInDll %s() not found\n",methodName);
	fflush (stdout);
        return NULL;
    }
   jstring jstr = (jstring)(env->CallStaticObjectMethod(versionClass, MID_foo));
   const char * str = env->GetStringUTFChars(jstr, NULL);
  
//    env->ReleaseStringUTFChars(jstr,str);
	return str;
}


void XsltProcessor::setSourceValue(XdmValue * node){
   xdmNode = node->getUnderlyingValue();    	
}


void XsltProcessor::setOutputfile(const char * ofile){
   outputfile1 = ofile; 
   setProperty("o", ofile);
}

XdmValue * XsltProcessor::parseString(const char * source){

    char methodName[] = "xmlparseStringing";
    char args[] = "(Ljava/lang/String;)Lnet/sf/saxon/s9api/XdmNode;";
    jmethodID mID = (jmethodID)env->GetMethodID(cppClass, methodName, args);
    if (!mID) {
	printf("\nError: MyClassInDll %s() not found\n",methodName);
	fflush (stdout);
        return NULL;
    }
   jobject xdmNodei = env->CallObjectMethod(cpp, mID, env->NewStringUTF(source));
     if(exceptionOccurred()) {
	   exception= checkForException(env, cppClass, cpp);
     } else {
	XdmValue * value = new XdmValue(xdmNodei);
	return value;
   }
   return NULL;
}

void XsltProcessor::setParameter(const char * namespacei, const char * name, XdmValue * value){
	if(getParameter("", name) != NULL){
		return;			
	}
	parLen++;	
	if(propLen > propCap) {
		parCap *=2; 
		MyParameter* temp = new MyParameter[parCap];	
		for(int i =0; i< parLen-1;i++) {
			temp[i] = parameters[i];			
		}
		delete parameters;
		parameters = temp;
	}
	int nameLen = strlen(name)+7;	
	char *newName = new char[nameLen];
  	snprint(newName, nameLen, "%s%s", "param:", name );
	parameters[parLen].name = newName;	
	parameters[parLen].value = value;
}


XdmValue* XsltProcessor::getParameter(const char* namespacei, const char * name){
	for(int i =0; i< parLen;i++) {
		if(strcmp(parameter[i].name, name) == 0)
			return parameters[i].value;			
	}
	return NULL;
}


bool XsltProcessor::removeParameter(const char * namespacei, const char * name){
	bool parFound = false;
	MyParameter * temp = new MyParameter[parCap];
	for(int i =0, j=0; i< parLen;i++) {
		if(strcmp(parameter[i].name, name) == 0){
			parFound = true;
		} else {
			temp[j] = parameter[i];	
			j++;
		}
	}
	if(parFound) {
		delete parameter;
		parLen--;
		parameter = temp;
		return true;
	}
	return false;
}

char* XsltProcessor::getProperty(const char* namespacei, const char * name){
	for(int i =0; i< propLen;i++) {
		if(strcmp(properties[i].name, name) == 0)
			return properties[i].value;			
	}
	return NULL;
}

void XsltProcessor::setProperty(const char* name, const char* value){
	if(getProperty("", name) != NULL){
		return;			
	}
	propLen++;	
	if(propLen > propCap) {
		propCap *=2; 
		MyProperty* temp = new MyProperty[propCap];	
		for(int i =0; i< propLen-1;i++) {
			temp[i] = properties[i];			
		}
		delete properties;
		properties = temp;

	}
	int nameLen = strlen(name)+1;	
	char *newName = new char[nameLen];
  	snprint(newName, nameLen, "%s", name );
	char *newValue = new char[strlen(value)+1];
  	snprint(newValue, strlen(value)+1, "%s", value );
	properties[propLen].name = newName;	
	properties[propLen].value = newValue;	

}

void XsltProcessor::clearSettings(){
	for(int i =0; i< parLen; i++){
		delete parameters[i].name;
		delete parameters[i].value;
	}

	for(int i =0; i< propLen; i++){
		delete properties[i].name;
		delete properties[i].value;
	}
        delete outputfile1;
	parLen = 0;
	propLen = 0;
}

void XsltProcessor::exceptionClear(){
	if(exception != NULL) {
		delete exception;
		exception = NULL;	
	}
}

SaxonApiException* XsltProcessor::checkException(){
	if(exception == NULL) {
		exception = checkForException(env, cppClass, cpp);
	}
        return exception;
}

bool XsltProcessor::exceptionOccurred(){
	return env->ExceptionCheck();
}

int XsltProcessor::exceptionCount(){
	if(exception != NULL){
		return exception->count();
	}
	return 0;
}

const char * XsltProcessor::xsltApplyStylesheet1(char * stylesheet){
 jmethodID mID = (jmethodID)env->GetMethodID (cppClass,"xsltApplyStylesheet", "(Ljava/lang/String;Ljava/lang/String;[Ljava/lang/String;[Ljava/lang/Object;)Ljava/lang/String;");
 if (!mID) {
        printf("Error: MyClassInDll. xsltApplyStylesheet not found\n");
	fflush (stdout);
    } else {
	jobjectArray stringArray = NULL;
	jobjectArray objectArray = NULL;
	int size = parLen + propLen;
		
	if(size >0) {
	   int i=0;
           jclass objectClass = lookForClass(env, "java/lang/Object");
	   jclass stringClass = lookForClass(env, "java/lang/String");
	   objectArray = env->NewObjectArray( (jint)size, objectClass, 0 );
	   stringArray = env->NewObjectArray( (jint)size, stringClass, 0 );
	   if((!objectArray) || (!stringArray)) { return NULL;}
	   if(xdmNode) {
		size +=1;	
	        env->SetObjectArrayElement( stringArray, i, env->NewStringUTF("s") );
     	        env->SetObjectArrayElement( objectArray, i, (jobject)(xdmNode) );
		i++;
		
	   }
	   for(int i =0; i< parLen; i++) {
		
	     env->SetObjectArrayElement( stringArray, i, env->NewStringUTF( parameters[i].name) );
		bool checkCast = env->IsInstanceOf(parameters[i].value->getUnderlyingValue(), lookForClass(env, "net/sf/saxon/option/cpp/XdmValueForCpp") );
		if(( (bool)checkCast)==false ){
			failure = "FAILURE in  array of XdmValueForCpp";
		} 
	     env->SetObjectArrayElement( objectArray, i, (jobject)(parameters[i].value->getUnderlyingValue()) );
	   }
  	   for(int i=0; i< propLen; i++) {
	     env->SetObjectArrayElement( stringArray, i, env->NewStringUTF(properties[i].name));
	     env->SetObjectArrayElement( objectArray, i, (jobject)(env->NewStringUTF(properties[i].value)) );
	   }
	}

	  jstring result = (jstring)(env->CallObjectMethod(cpp, mID, NULL, env->NewStringUTF(stylesheet.c_str()), stringArray, objectArray ));
	  env->DeleteLocalRef(objectArray);
	  env->DeleteLocalRef(stringArray);
	  if(result) {
             const char * str = env->GetStringUTFChars(result, NULL);
            //return "result should be ok";            
	    return str;
	   }
  }
  return NULL;
  
}	 

void XsltProcessor::xsltSaveResultToFile(char * source, char* stylesheet, char* outputfile) {

 jmethodID mID = (jmethodID)env->GetMethodID (cppClass,"xsltSaveResultToFile", "(Ljava/lang/String;Ljava/lang/String;Ljava/lang/String;[Ljava/lang/String;[Ljava/lang/Object;)V");
 exception = NULL;
 if (!mID) {
        printf("Error: MyClassInDll. xsltApplyStylesheet not found\n");
	fflush (stdout);
    } else {
 	jobjectArray stringArray = NULL;
	jobjectArray objectArray = NULL;
	int size = parLen + propLen;
	if(xdmNode) {
		size +=1;	
	}
	if(size >0) {
           jclass objectClass = lookForClass(env, "java/lang/Object");
	   jclass stringClass = lookForClass(env, "java/lang/String");
	   objectArray = env->NewObjectArray( (jint)size, objectClass, 0 );
	   stringArray = env->NewObjectArray( (jint)size, stringClass, 0 );
	   if((!objectArray) || (!stringArray)) { return;}
	   int i=0;
	   for(int i =0; i< parLen; i++) {
		
	     env->SetObjectArrayElement( stringArray, i, env->NewStringUTF( parameters[i].name) );
		bool checkCast = env->IsInstanceOf(parameters[i].value->getUnderlyingValue(), lookForClass(env, "net/sf/saxon/option/cpp/XdmValueForCpp") );
		if(( (bool)checkCast)==false ){
			failure = "FAILURE in  array of XdmValueForCpp";
		} 
	     env->SetObjectArrayElement( objectArray, i, (jobject)(parameters[i].value->getUnderlyingValue()) );
	   }
  	   for(int i=0; i< propLen; i++) {
	     env->SetObjectArrayElement( stringArray, i, env->NewStringUTF(properties[i].name));
	     env->SetObjectArrayElement( objectArray, i, (jobject)(env->NewStringUTF(properties[i].value)) );
	   }
	}
      env->CallObjectMethod(cpp, mID, env->NewStringUTF(source.c_str()), env->NewStringUTF(stylesheet.c_str()), env->NewStringUTF(outputfile.c_str()), stringArray, objectArray );     
  }
}

const char * XsltProcessor::xsltApplyStylesheet(char * source, char* stylesheet) {
 jmethodID mID = (jmethodID)env->GetMethodID (cppClass,"xsltApplyStylesheet", "(Ljava/lang/String;Ljava/lang/String;[Ljava/lang/String;[Ljava/lang/Object;)Ljava/lang/String;");
 if (!mID) {
        printf("Error: MyClassInDll. xsltApplyStylesheet not found\n");
	fflush (stdout);
    } else {
 	jobjectArray stringArray = NULL;
	jobjectArray objectArray = NULL;
	int size = parLen + propLen;

	if(size >0) {
           jclass objectClass = lookForClass(env, "java/lang/Object");
	   jclass stringClass = lookForClass(env, "java/lang/String");
	   objectArray = env->NewObjectArray( (jint)size, objectClass, 0 );
	   stringArray = env->NewObjectArray( (jint)size, stringClass, 0 );
	   if((!objectArray) || (!stringArray)) { return NULL;}
	   int i=0;
	   for(int i =0; i< parLen; i++) {
		
	     env->SetObjectArrayElement( stringArray, i, env->NewStringUTF( parameters[i].name) );
		bool checkCast = env->IsInstanceOf(parameters[i].value->getUnderlyingValue(), lookForClass(env, "net/sf/saxon/option/cpp/XdmValueForCpp") );
		if(( (bool)checkCast)==false ){
			failure = "FAILURE in  array of XdmValueForCpp";
		} 
	     env->SetObjectArrayElement( objectArray, i, (jobject)(parameters[i].value->getUnderlyingValue()) );
	   }
  	   for(int i=0; i< propLen; i++) {
	     env->SetObjectArrayElement( stringArray, i, env->NewStringUTF(properties[i].name));
	     env->SetObjectArrayElement( objectArray, i, (jobject)(env->NewStringUTF(properties[i].value)) );
	   }
	}
      jstring result = (jstring)(env->CallObjectMethod(cpp, mID, env->NewStringUTF(source.c_str()), env->NewStringUTF(stylesheet.c_str()), stringArray, objectArray ));
      if(result) {
       const char * str = env->GetStringUTFChars(result, NULL);
       //return "result should be ok";            
	return str;
     }
  }
  return NULL;
}

    const char * XsltProcessor::getErrorMessage(int i ){
	if(exception == NULL) {return NULL;}
	return exception->getErrorMessage(i);
    }




/*
* XdmNode Class implementation
*/

        XdmValue::XdmValue(){
	 if(env == NULL) {
           myDllHandle = loadDll (dllname);
          initJavaRT (myDllHandle, &jvm, &env);
	 }
	   xdmValueClass = lookForClass(env, "net/sf/saxon/option/cpp/XdmValueForCpp");
	   jmethodID MID_init = findConstructor (env, xdmValueClass, "()V");
/* 	   xdmValue = (jobject)env->NewObject(xdmValueClass, MID_init);
      		if (!xdmValue) {
	        	printf("Error: failed to allocate an object\n");
        		return;
      		}*/

	
	 xdmValue = NULL;
	}


	XdmValue::XdmValue(bool b){ 
	 if(env == NULL) {
           myDllHandle = loadDll (dllname);
          initJavaRT (myDllHandle, &jvm, &env);
	 }
		xdmValueClass = lookForClass(env, "net/sf/saxon/option/cpp/XdmValueForCpp");
	        jmethodID MID_init = findConstructor (env, xdmValueClass, "(Z)V");
 		xdmValue = (jobject)env->NewObject(xdmValueClass, MID_init, (jboolean)b);
      		if (!xdmValue) {
	        	printf("Error: failed to allocate an object\n");
			fflush (stdout);
        		return;
      		}
	}

	XdmValue::XdmValue(int i){ 
	 if(env == NULL) {
           myDllHandle = loadDll (dllname);
          initJavaRT (myDllHandle, &jvm, &env);
	 }
		xdmValueClass = lookForClass(env, "net/sf/saxon/option/cpp/XdmValueForCpp");
	        jmethodID MID_init = findConstructor (env, xdmValueClass, "(I)V");
 		xdmValue = (jobject)env->NewObject(xdmValueClass, MID_init, (jint)i);
      		if (!xdmValue) {
	        	printf("Error: failed to allocate an XdmValueForCpp object \n");
			fflush (stdout);
        		return;
      		}
	}


	XdmValue::XdmValue(char* type, char* str){ 
	 if(env == NULL) {
           myDllHandle = loadDll (dllname);
          initJavaRT (myDllHandle, &jvm, &env);
	 }
		xdmValueClass = lookForClass(env, "net/sf/saxon/option/cpp/XdmValueForCpp");
	        jmethodID MID_init = findConstructor (env, xdmValueClass, "(Ljava/lang/String;Ljava/lang/String;)V");
 		xdmValue = (jobject)env->NewObject(xdmValueClass, MID_init, env->NewStringUTF((const char*)type), env->NewStringUTF((const char*)str));
      		if (!xdmValue) {
	        	printf("Error: failed to allocate an XdmValueForCpp object \n");
			fflush (stdout);
        		return;
      		}
	}

	XdmValue::XdmValue(jobject xdmNode){ 
	 if(env == NULL) {
           myDllHandle = loadDll (dllname);
          initJavaRT (myDllHandle, &jvm, &env);
	 }
		xdmValueClass = lookForClass(env, "net/sf/saxon/option/cpp/XdmValueForCpp");
	        jmethodID MID_init = findConstructor (env, xdmValueClass, "(Lnet/sf/saxon/s9api/XdmNode;)V");
		if (!MID_init) {
			failure = "Error: MyClassInDll. XdmValueForCpp with XdmNode  not found\n";
			return;
		}		
 		xdmValue = (jobject)env->NewObject(xdmValueClass, MID_init, xdmNode);
      		if (!xdmValue) {
			failure = "Error: failed to allocate an XdmValueForCpp object with XdmNode \n";
        		return;
      		}
	}

    const char * XdmValue::getErrorMessage(int i){
	if(exception== NULL) return NULL;
	return exception->getErrorMessage(i);
    }

    const char * XdmValue::getErrorCode(int i) {
	if(exception== NULL) return NULL;
	return exception->getErrorCode(i);
     }

	int XdmValue::exceptionCount(){
		return exception->count();
	}

	const char * XdmValue::getStringValue(){
          jmethodID mID;

	  char methodName[] = "getStringValue";
          char args[] = "()Ljava/lang/String;";
          mID = (jmethodID)(env)->GetMethodID(xdmValueClass, methodName, args);
          if (!mID) {
	    printf("\nError: MyClassInDll %s() not found\n",methodName);
	    fflush (stdout);
            return NULL;
         }
	   jstring valueStr = (jstring)(env)->CallObjectMethod(xdmValue, mID);
	   if(valueStr){
		  const char * str = env->GetStringUTFChars(valueStr, NULL);
	       //return "result should be ok";            
		return str;
	   }
		return NULL;
	}



int main(int argc, char *argv[]) {
	SaxonProcessor *processor = new SaxonProcessor();
	XsltProcessor * test = processor->newTransformer();
	printf("Hello World version:%s\n",test->version());
	SaxonApiException * ex = test->checkException();
	if(ex != NULL){
		printf("%i\n", ex->count());		
	}
	//test->setSourceAsString("<node>test</node>");
	const char * result = test->xsltApplyStylesheet("xmark64.xml","q8.xsl");//test->xsltApplyStylesheet("cat.xml","test.xsl");
	if(result != NULL){ //2m 25sec //1m 0.54sec
		printf("Output: %s\n",result);
	} else {
	printf("result is null");	
	}
//	cout<<"Test output: "<<test->xsltApplyStylesheet("cat.xml","test.xsl")<<endl;
	//cout<<"Test output: "<<test->xsltApplyStylesheet("xmark100.xml","q8.xsl")<<endl;
//	cout<<"ErrorCode:"<<test->getErrorCode()<<endl;
	SaxonApiException * ex1 = test->checkException();
	if(ex != NULL){
		printf("%i\n", ex->count());	
	}
	printf("Hello World");
	fflush (stdout);
}

