#include <jni.h>

#ifdef __linux__
    #include <stdlib.h>
    #include <string.h>
    #include <dlfcn.h>
    #include <stdio.h>  
    #define HANDLE void*
    #define LoadLibrary(x) dlopen(x, RTLD_LAZY)
//    #define FreeLibrary(x) dlclose(x, RTLD_LAZY)
    #define GetProcAddress(x,y) dlsym(x,y)
#else
    #include <windows.h>
#endif

typedef int bool;
#define true 1
#define false 0


char dllname[] =
    #ifdef __linux__
        "/usr/lib/libsaxon.so";
    #else
        "Saxon-hec.dll";
    #endif

//===============================================================================================//
/*! <code>Environment</code>. This struct captures the jni, JVM and handler to the cross compiled Saxon/C library.
 * <p/>
 */
typedef struct {
		JNIEnv *env;
		HANDLE myDllHandle;
		JavaVM *jvm;
	} Environment;


//===============================================================================================//

/*! <code>MyParameter</code>. This struct captures details of paramaters used for the transformation as (string, value) pairs.
 * <p/>
 */
typedef struct {
		char* name;
		jobject value;
	} MyParameter;

//===============================================================================================//

/*! <code>MyProperty</code>. This struct captures details of properties used for the transformation as (string, string) pairs.
 * <p/>
 */
typedef struct {
		char * name;
		char * value;
	} MyProperty;

jobject cpp;



const char * failure;
/*
 * Load dll.
 */
HANDLE loadDll(char* name)
{
    HANDLE hDll = LoadLibrary (name);

    if (!hDll) {
        printf ("Unable to load %s\n", name);
        exit(1);
    }
#ifdef DEBUG
    printf ("%s loaded\n", name);
#endif
    return hDll;
}


jint (JNICALL * JNI_GetDefaultJavaVMInitArgs_func) (void *args);
jint (JNICALL * JNI_CreateJavaVM_func) (JavaVM **pvm, void **penv, void *args);

/*
 * Initialize JET run-time.
 */
void initJavaRT(HANDLE myDllHandle, JavaVM** pjvm, JNIEnv** penv)
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
  
    /*
     * NOTE: no JVM is actually created
     * this call to JNI_CreateJavaVM is intended for JET RT initialization
     */
    result = JNI_CreateJavaVM_func (pjvm, (void **)penv, &args);
    if (result != JNI_OK) {
        printf ("JNI_CreateJavaVM() failed with result %d\n", result);
        exit(1);
    }
#ifdef DEBUG
    printf ("JET RT initialized\n");
    fflush (stdout);
#endif
}


/*
 * Look for class.
 */
jclass lookForClass (JNIEnv* penv, char* name)
{
    jclass clazz = (*penv)->FindClass (penv, name);

    if (!clazz) {
        printf("Unable to find class %s\n", name);
	return NULL;
    }
#ifdef DEBUG
    printf ("Class %s found\n", name);
    fflush (stdout);
#endif

    return clazz;
}


/*
 * Create an object and invoke the "ifoo" instance method
 */
void invokeInstanceMethod (JNIEnv* penv, jclass myClassInDll)
{
    jmethodID MID_init, MID_ifoo;
    jobject obj;

    MID_init = (*penv)->GetMethodID (penv, myClassInDll, "<init>", "()V");
    if (!MID_init) {
        printf("Error: MyClassInDll.<init>() not found\n");
        return;
    }

    obj = (*penv)->NewObject(penv, myClassInDll, MID_init);
    if (!obj) {
        printf("Error: failed to allocate an object\n");
        return;
    }

    MID_ifoo = (*penv)->GetMethodID (penv, myClassInDll, "ifoo", "()V");

    if (!MID_ifoo) {
        printf("Error: MyClassInDll.ifoo() not found\n");
        return;
    }
    
    (*(penv))->CallVoidMethod (penv, obj, MID_ifoo);
}



/*
 * Invoke the "foo" static method
 */
void invokeStaticMethod(JNIEnv* penv, jclass myClassInDll)
{
    jmethodID MID_foo;

    MID_foo = (*penv)->GetStaticMethodID(penv, myClassInDll, "foo", "()V");
    if (!MID_foo) {
        printf("\nError: MyClassInDll.foo() not found\n");
        return;
    }
    
    (*penv)->CallStaticVoidMethod(penv, myClassInDll, MID_foo);
}

jmethodID findConstructor (JNIEnv* penv, jclass myClassInDll, char* arguments)
{
    jmethodID MID_init, mID;
    jobject obj;

    MID_init = (jmethodID)(*penv)->GetMethodID (penv, myClassInDll, "<init>", arguments);
    if (!MID_init) {
        printf("Error: MyClassInDll.<init>() not found\n");
	fflush (stdout);
        return 0;
    }

  return MID_init;
}

jobject createObject (JNIEnv* penv, jclass myClassInDll, const char * arguments)
{
    jmethodID MID_init, mID;
    jobject obj;

    MID_init = (jmethodID)(*(penv))->GetMethodID (penv, myClassInDll, "<init>", arguments);
    if (!MID_init) {
        printf("Error: MyClassInDll.<init>() not found\n");
        return NULL;
    }

      obj = (jobject)(*(penv))->NewObject(penv, myClassInDll, MID_init, (jboolean)true);
      if (!obj) {
        printf("Error: failed to allocate an object\n");
        return NULL;
      }
    return obj;
}

void checkForException(Environment environ, jclass callingClass,  jobject callingObject){

    if ((*(environ.env))->ExceptionCheck(environ.env)) {
	char *  result1;
	const char * errorCode = NULL;
	jthrowable exc = (*(environ.env))->ExceptionOccurred(environ.env);
	(*(environ.env))->ExceptionDescribe(environ.env); //comment code
	 jclass exccls = (jclass)(*(environ.env))->GetObjectClass(environ.env, exc);
        jclass clscls = (jclass)(*(environ.env))->FindClass(environ.env, "java/lang/Class");

        jmethodID getName = (jmethodID)(*(environ.env))->GetMethodID(environ.env, clscls, "getName", "()Ljava/lang/String;");
        jstring name =(jstring)((*(environ.env))->CallObjectMethod(environ.env, exccls, getName));
        char const* utfName = (char const*)(*(environ.env))->GetStringUTFChars(environ.env, name, 0);
	printf(utfName);

	 jmethodID  getMessage = (jmethodID)(*(environ.env))->GetMethodID(environ.env, exccls, "getMessage", "()Ljava/lang/String;");
	if(getMessage) {

		jstring message = (jstring)((*(environ.env))->CallObjectMethod(environ.env, exc, getMessage));
		if(message) {        	
			char const* utfMessage = (char const*)(*(environ.env))->GetStringUTFChars(environ.env, message, 0);
		}
		//if(utfMessage != NULL) {
		//	printf(utfMessage);
			/*result1 = new char(strlen(utfName)+2+strlen(utfMessage));
			strcpy(result1, utfName);
			result1[strlen(result1)-1] = ':';
			strcat(result1, utfMessage);*/
//		}
	 /*else {
			result1 = new char[strlen(utfName)];
			strcpy(result1, utfName);
		}
		//printf(result1);
		env->ReleaseStringUTFChars(name, utfName);	
		env->ReleaseStringUTFChars(message,utfMessage);
		if(strncmp(result1, "net.sf.saxon.s9api.SaxonApiException", 36) == 0){
			jmethodID  getErrorCodeID(environ.env->GetMethodID(callingClass, "getExceptions", "()[Lnet/sf/saxon/option/cpp/SaxonExceptionForCpp;"));
			jclass saxonExceptionClass(environ.env->FindClass("net/sf/saxon/option/cpp/SaxonExceptionForCpp"));
				if(getErrorCodeID){	
					jobjectArray saxonExceptionObject((jobjectArray)(environ.env->CallObjectMethod(callingObject, getErrorCodeID)));
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

							jstring errCode = (jstring)(environ.env->CallObjectMethod(exObj, ecID));
							jstring errMessage = (jstring)(environ.env->CallObjectMethod(exObj, emID));
							jboolean isType = (environ.env->CallBooleanMethod(exObj, typeID));
							jboolean isStatic = (environ.env->CallBooleanMethod(exObj, staticID));
							jboolean isGlobal = (environ.env->CallBooleanMethod(exObj, globalID));
							saxonExceptions->add((errCode ? env->GetStringUTFChars(errCode,0) : NULL )  ,(errMessage ? env->GetStringUTFChars(errMessage,0) : NULL),(int)(environ.env->CallIntMethod(exObj, lineNumID)), (bool)isType, (bool)isStatic, (bool)isGlobal);
							env->ExceptionDescribe();
						}
						//env->ExceptionDescribe();
						env->ExceptionClear();
						return saxonExceptions;
					}
				}
		}*/
	}
/*	SaxonApiException * saxonExceptions = new SaxonApiException(NULL, result1);
	//env->ExceptionDescribe();
	env->ExceptionClear();
	return saxonExceptions;*/
     }
	//return NULL;

}


void finalizeJavaRT (JavaVM* jvm)
{
    (*jvm)->DestroyJavaVM (jvm);
}


jobject getParameter(MyParameter *parameters,  int parLen, const char* namespacei, const char * name){
	int i =0;
	for(i =0; i< parLen;i++) {
		if(strcmp(parameters[i].name, name) == 0)
			return (jobject)parameters[i].value;			
	}
	return NULL;
}

char* getProperty(MyProperty * properties, int propLen, const char* namespacei, const char * name){
	int i =0;
	for(i =0; i< propLen;i++) {
		if(strcmp(properties[i].name, name) == 0)
			return properties[i].value;			
	}
	return 0;
}

void setParameter(MyParameter *parameters, int parLen, int parCap, const char * namespacei, const char * name, jobject value){

	if(getParameter(parameters, parLen, "", name) != 0){
		return;			
	}
	parLen++;	
	if(parLen > parCap) {
		parCap *=2; 
		MyParameter* temp = malloc(sizeof(MyParameter)*parCap);	
		int i =0;
		for(i =0; i< parLen-1;i++) {
			temp[i] = parameters[i];			
		}
		free(parameters);
		parameters = (MyParameter*)temp;
	}
	int nameLen = strlen(name)+7;	
	char *newName = malloc(sizeof(char)*nameLen);
  	snprintf(newName, nameLen, "%s%s", "param:", name );
	parameters[parLen].name = (char*)newName;	
	parameters[parLen].value = (jobject)value;
}

void setProperty(MyProperty * properties, int propLen, int propCap, const char* name, const char* value){	
	
	if(getProperty(properties, propLen, "", name) != 0){
		return;			
	}
	propLen++;	
	if(propLen > propCap) {
		propCap *=2; 
		MyProperty* temp = malloc(sizeof(MyProperty)*  propCap);
		int i =0;	
		for(i =0; i< propLen-1;i++) {
			temp[i] = properties[i];			
		}
		free(properties);
		properties = (MyProperty*)temp;

	}
	int nameLen = strlen(name)+1;	
	char *newName = (char*)malloc(sizeof(char)*nameLen);
  	snprintf(newName, nameLen, "%s", name );
	char *newValue = (char*)malloc(sizeof(char)*strlen(value)+1);
  	snprintf(newValue, strlen(value)+1, "%s", value );
	properties[propLen].name = (char*)newName;	
	properties[propLen].value = (char*)newValue;	

}


void clearSettings(MyParameter *parameters, int parLen, MyProperty * properties, int propLen){
	int i =0;
	for(i =0; i< parLen; i++){
		free( parameters[i].name);
		free(parameters[i].value);
	}
	for(i =0; i< propLen; i++){
		free(properties[i].name);
		free(properties[i].value);
	}
	parLen = 0;
	propLen = 0;
}



const char * versioni(Environment environ) {


    jmethodID MID_foo;
    jclass  versionClass;
     versionClass = lookForClass(environ.env, "net/sf/saxon/Version");
    char methodName[] = "getProductVersion";
    char args[] = "()Ljava/lang/String;";
    MID_foo = (jmethodID)(*(environ.env))->GetStaticMethodID(environ.env, versionClass, methodName, args);
    if (!MID_foo) {
	printf("\nError: MyClassInDll %s() not found\n",methodName);
	fflush (stdout);
        return NULL;
    }
   jstring jstr = (jstring)((*(environ.env))->CallStaticObjectMethod(environ.env, versionClass, MID_foo));
   const char * str = (*(environ.env))->GetStringUTFChars(environ.env, jstr, NULL);
  
//    env->ReleaseStringUTFChars(jstr,str);
	return str;
}

const char * xsltApplyStylesheet1(Environment environ, char * cwd, char * stylesheet, MyParameter *parameters, MyProperty * properties, int parLen, int propLen){
 jclass cppClass = lookForClass(environ.env, "net/sf/saxon/option/cpp/XsltProcessorForCpp");
 jmethodID mID = (jmethodID)(*(environ.env))->GetMethodID (environ.env, cppClass,"xsltApplyStylesheet", "(Ljava/lang/String;Ljava/lang/String;Ljava/lang/String;[Ljava/lang/String;[Ljava/lang/Object;)Ljava/lang/String;");
 if (!mID) {
        printf("Error: MyClassInDll. xsltApplyStylesheet not found\n");
	fflush (stdout);
	return NULL;
 }
	jobjectArray stringArray = NULL;
	jobjectArray objectArray = NULL;
	int size = parLen + propLen;
	if(size>0){	
           jclass objectClass = lookForClass(environ.env, "java/lang/Object");
	   jclass stringClass = lookForClass(environ.env, "java/lang/String");
	   objectArray = (*(environ.env))->NewObjectArray(environ.env, (jint)size, objectClass, 0 );
	   stringArray = (*(environ.env))->NewObjectArray(environ.env, (jint)size, stringClass, 0 );
	int i =0;
	   for(; i< parLen; i++) {
		
	     (*(environ.env))->SetObjectArrayElement(environ.env, stringArray, i, (*(environ.env))->NewStringUTF(environ.env,  parameters[i].name) );
		bool checkCast = (*(environ.env))->IsInstanceOf(environ.env, parameters[i].value, lookForClass(environ.env, "net/sf/saxon/option/cpp/XdmValueForCpp") );
		if(( (bool)checkCast)==false ){
			failure = "FAILURE in  array of XdmValueForCpp";
		} 
	     (*(environ.env))->SetObjectArrayElement(environ.env, objectArray, i, (jobject)(parameters[i].value) );
	   }
  	   for(i=0; i< propLen; i++) {
	     (*(environ.env))->SetObjectArrayElement(environ.env, stringArray, i, (*(environ.env))->NewStringUTF(environ.env, properties[i].name));
	     (*(environ.env))->SetObjectArrayElement(environ.env, objectArray, i, (jobject)((*(environ.env))->NewStringUTF(environ.env, properties[i].value)) );
	   }
	}

	  jstring result = (jstring)((*(environ.env))->CallObjectMethod(environ.env, cpp, mID, (cwd== NULL ? (*(environ.env))->NewStringUTF(environ.env, "") : (*(environ.env))->NewStringUTF(environ.env, cwd)), NULL, (*(environ.env))->NewStringUTF(environ.env, stylesheet), stringArray, objectArray ));
	  (*(environ.env))->DeleteLocalRef(environ.env, objectArray);
	  (*(environ.env))->DeleteLocalRef(environ.env, stringArray);
	  if(result) {
             const char * str = (*(environ.env))->GetStringUTFChars(environ.env, result, NULL);         
	    return str;
	   } 
  
  
  return NULL;
  
}


void xsltSaveResultToFile(Environment environ, char * cwd, char * source, char* stylesheet, char* outputfile, MyParameter *parameters, MyProperty * properties, int parLen, int propLen) {
 jclass cppClass = lookForClass(environ.env, "net/sf/saxon/option/cpp/XsltProcessorForCpp");
 jmethodID mID = (jmethodID)(*(environ.env))->GetMethodID (environ.env, cppClass,"xsltSaveResultToFile", "(Ljava/lang/String;Ljava/lang/String;Ljava/lang/String;Ljava/lang/String;[Ljava/lang/String;[Ljava/lang/Object;)V");
 if (!mID) {
        printf("Error: MyClassInDll. xsltApplyStylesheet not found\n");
	fflush (stdout);
	return;
    } 
 	jobjectArray stringArray = NULL;
	jobjectArray objectArray = NULL;
	int size = parLen + propLen;

	if(size>0) {
           jclass objectClass = lookForClass(environ.env, "java/lang/Object");
	   jclass stringClass = lookForClass(environ.env, "java/lang/String");
	   objectArray = (*(environ.env))->NewObjectArray(environ.env, (jint)size, objectClass, 0 );
	   stringArray = (*(environ.env))->NewObjectArray(environ.env, (jint)size, stringClass, 0 );
	if(size >0) {

	   if((!objectArray) || (!stringArray)) { return;}
	   int i=0;
	   for( i =0; i< parLen; i++) {
		
	     (*(environ.env))->SetObjectArrayElement(environ.env, stringArray, i, (*(environ.env))->NewStringUTF(environ.env,  parameters[i].name) );
		bool checkCast = (*(environ.env))->IsInstanceOf(environ.env, parameters[i].value, lookForClass(environ.env, "net/sf/saxon/option/cpp/XdmValueForCpp") );
		if(( (bool)checkCast)==false ){
			failure = "FAILURE in  array of XdmValueForCpp";
		} 
	     (*(environ.env))->SetObjectArrayElement(environ.env, objectArray, i, (jobject)(parameters[i].value) );
	   }
  	   for(i=0; i< propLen; i++) {
	     (*(environ.env))->SetObjectArrayElement(environ.env, stringArray, i, (*(environ.env))->NewStringUTF(environ.env, properties[i].name));
	     (*(environ.env))->SetObjectArrayElement(environ.env, objectArray, i, (jobject)((*(environ.env))->NewStringUTF(environ.env, properties[i].value)) );
	   }
	}
	}
      (*(environ.env))->CallObjectMethod(cpp, mID, (cwd== NULL ? (*(environ.env))->NewStringUTF(environ.env, "") : (*(environ.env))->NewStringUTF(environ.env, cwd)),(*(environ.env))->NewStringUTF(environ.env, source), (*(environ.env))->NewStringUTF(environ.env, stylesheet), (*(environ.env))->NewStringUTF(environ.env, outputfile), stringArray, objectArray );    
	  (*(environ.env))->DeleteLocalRef(environ.env, objectArray);
	  (*(environ.env))->DeleteLocalRef(environ.env, stringArray);
  
}

const char * xsltApplyStylesheet(Environment environ, char * cwd, const char * source, const char* stylesheet, MyParameter *parameters, MyProperty * properties, int parLen, int propLen) {

 jclass cppClass = lookForClass(environ.env, "net/sf/saxon/option/cpp/XsltProcessorForCpp");
cpp = (jobject) createObject (environ.env, cppClass, "(Z)V");
 jmethodID mID = (jmethodID)(*(environ.env))->GetMethodID (environ.env, cppClass,"xsltApplyStylesheet", "(Ljava/lang/String;Ljava/lang/String;Ljava/lang/String;[Ljava/lang/String;[Ljava/lang/Object;)Ljava/lang/String;");
 if (!mID) {
        printf("Error: MyClassInDll. xsltApplyStylesheet not found\n");
	fflush (stdout);
	return 0;
    } 
printf("found method\n");
fflush (stdout);
 	jobjectArray stringArray = NULL;
	jobjectArray objectArray = NULL;
	int size = parLen + propLen;

	if(size >0) {
           jclass objectClass = lookForClass(environ.env, "java/lang/Object");
	   jclass stringClass = lookForClass(environ.env, "java/lang/String");
	   objectArray = (*(environ.env))->NewObjectArray(environ.env, (jint)size, objectClass, 0 );
	   stringArray = (*(environ.env))->NewObjectArray(environ.env, (jint)size, stringClass, 0 );
	   if((!objectArray) || (!stringArray)) { return NULL;}
	   int i=0;
	   for(i =0; i< parLen; i++) {
		
	     (*(environ.env))->SetObjectArrayElement(environ.env, stringArray, i, (*(environ.env))->NewStringUTF(environ.env, parameters[i].name) );
		bool checkCast = (*(environ.env))->IsInstanceOf(environ.env, parameters[i].value, lookForClass(environ.env, "net/sf/saxon/option/cpp/XdmValueForCpp") );
		if(( (bool)checkCast)==false ){
			failure = "FAILURE in  array of XdmValueForCpp";
		} 
	     (*(environ.env))->SetObjectArrayElement(environ.env, objectArray, i, (jobject)(parameters[i].value) );
	   }
  	   for(i=0; i< propLen; i++) {
	     (*(environ.env))->SetObjectArrayElement(environ.env, stringArray, i, (*(environ.env))->NewStringUTF(environ.env, properties[i].name));
	     (*(environ.env))->SetObjectArrayElement(environ.env, objectArray, i, (jobject)((*(environ.env))->NewStringUTF(environ.env, properties[i].value)) );
	   }
	}
      jstring result = (jstring)((*(environ.env))->CallObjectMethod(environ.env, cpp, mID, (cwd== NULL ? (*(environ.env))->NewStringUTF(environ.env, "") : (*(environ.env))->NewStringUTF(environ.env, cwd)), (*(environ.env))->NewStringUTF(environ.env, source), (*(environ.env))->NewStringUTF(environ.env, stylesheet), stringArray, objectArray ));
      if(result) {
       const char * str = (*(environ.env))->GetStringUTFChars(environ.env, result, NULL);
       //return "result should be ok";            
	return str;
     }
printf("Source:\n");
printf(source);
printf("\nstylesheet:\n");
printf(stylesheet);
printf("\n");
  checkForException(environ, cppClass, cpp);
  return 0;
}


/*! The following functions create an <code>XdmValue</code>. Value in the XDM data model. A value is a sequence of zero or more items,
 * each item being either an atomic value or a node. The XdmValue object created is a wrapper of the XdmValue in Java.
 * <p/>
 */


    /**
     * A Constructor. Create an xs:boolean value
     * @param val - boolean value
     */
jobject BooleanValue(Environment environ, bool b){ 
	jclass  xdmValueClass = lookForClass(environ.env, "net/sf/saxon/option/cpp/XdmValueForCpp");;
	 if(environ.env == NULL) {
           environ.myDllHandle = loadDll (dllname);
          initJavaRT (environ.myDllHandle, &environ.jvm, &environ.env);
	 }
		xdmValueClass = lookForClass(environ.env, "net/sf/saxon/option/cpp/XdmValueForCpp");
	        jmethodID MID_init = (jmethodID)findConstructor (environ.env, xdmValueClass, "(Z)V");
 		jobject xdmValue = (jobject)(*(environ.env))->NewObject(environ.env, xdmValueClass, MID_init, (jboolean)b);
      		if (!xdmValue) {
	        	printf("Error: failed to allocate an object\n");
			fflush (stdout);
        		return NULL;
      		}
		return xdmValue;
	}

    /**
     * A Constructor. Create an xs:int value
     * @param val - int value
     */
jobject IntegerValue(Environment environ, int i){ 
	jclass  xdmValueClass = lookForClass(environ.env, "net/sf/saxon/option/cpp/XdmValueForCpp");;
	 if(environ.env == NULL) {
           environ.myDllHandle = loadDll (dllname);
          initJavaRT (environ.myDllHandle, &environ.jvm, &environ.env);
	 }
		xdmValueClass = lookForClass(environ.env, "net/sf/saxon/option/cpp/XdmValueForCpp");
	        jmethodID MID_init =  (jmethodID)findConstructor (environ.env, xdmValueClass, "(I)V");
 		jobject xdmValue = (jobject)(*(environ.env))->NewObject(environ.env, xdmValueClass, MID_init, (jint)i);
      		if (!xdmValue) {
	        	printf("Error: failed to allocate an XdmValueForCpp object \n");
			fflush (stdout);
        		return NULL;
      		}
		return xdmValue;
	}


    /**
     * A Constructor. Create a XdmValue based on the target type. Conversion is applied if possible
     * @param type - specify target type of the value  
     * @param val - Value to convert
     */
jobject XdmValue(Environment environ, const char* type, const char* str){ 
	jclass  xdmValueClass = lookForClass(environ.env, "net/sf/saxon/option/cpp/XdmValueForCpp");;
	 if(environ.env == NULL) {
           environ.myDllHandle = loadDll (dllname);
          initJavaRT (environ.myDllHandle, &environ.jvm, &environ.env);
	 }
		xdmValueClass = lookForClass(environ.env, "net/sf/saxon/option/cpp/XdmValueForCpp");
	        jmethodID MID_init = (jmethodID)findConstructor (environ.env, xdmValueClass, "(Ljava/lang/String;Ljava/lang/String;)V");
 		jobject xdmValue = (jobject)(*(environ.env))->NewObject(environ.env, xdmValueClass, MID_init, (*(environ.env))->NewStringUTF(environ.env, type), (*(environ.env))->NewStringUTF(environ.env, str));
      		if (!xdmValue) {
	        	printf("Error: failed to allocate an XdmValueForCpp object \n");
			fflush (stdout);
        		return NULL;
      		}
		return xdmValue;
	}


	 


int main()
{
    HANDLE myDllHandle;
    //JNIEnv *(environ.env);
    //JavaVM *jvm;
    jclass  myClassInDll;
MyParameter * parameters; /*!< array of paramaters used for the transformation as (string, value) pairs */
int parLen, parCap;
MyProperty * properties; /*!< array of properties used for the transformation as (string, string) pairs */
int propLen, propCap;
Environment environ;
    /*
     * First of all, load required component.
     * By the time of JET initialization, all components should be loaded.
     */
    environ.myDllHandle = loadDll (dllname);
	
printf("test in main");
    /*
     * Initialize JET run-time.
     * The handle of loaded component is used to retrieve Invocation API.
     */
    initJavaRT (environ.myDllHandle, &environ.jvm, &environ.env);
//printf(version(environ.env));

    const char *result = xsltApplyStylesheet(environ, "", "cat.xml","test.xsl", 0 ,0, 0, 0);
//const char * result = xsltApplyStylesheet(environ, "",  "sinsello.xml", "cadenaoriginal_3_2.xslt", 0 ,0, 0, 0);
if(!result) {
printf("result is null");
}else {
printf(result);
}
fflush(stdout);
    /*
     * Finalize JET run-time.
     */
    finalizeJavaRT (environ.jvm);

    return 0;
}
