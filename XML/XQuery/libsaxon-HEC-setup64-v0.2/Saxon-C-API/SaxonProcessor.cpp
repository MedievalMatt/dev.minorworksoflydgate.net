#ifndef __linux__
	#include "stdafx.h"
	#include <Tchar.h>
#endif


//#include "stdafx.h"
#include "SaxonProcessor.h"
#include "XsltProcessor.cpp"
#include "XQueryProcessor.cpp"
#include "XdmValue.cpp"
#ifndef CPP_ONLY
#include "php_saxon.h"
#endif
#ifdef DEBUG
#include <signal.h>
#endif
#include <stdio.h>





/*
 * Load dll.
 */
HANDLE loadDll(char* name)
{
#ifndef __linux__
	HANDLE hDll = LoadLibrary (_T("C:\\Program Files (x86)\\Saxonica\\SaxonHEC0.2\\libsaxon.dll")); // Used for windows only
#else
	HANDLE hDll = LoadLibrary(name);
#endif

    if (!hDll) {
        printf ("Unable to load %s\n", name);
      //  exit(1);
    }
#ifdef DEBUG
    printf ("%s loaded\n", name);
#endif

    return hDll;
}

#ifdef DEBUG
void mySigHandler(int sig){cerr<<"mySigHandler received signal:"<<sig<<" \n";
		signal(SIGINT, mySigHandler);
	//	penv->ExceptionDescribe();
		exit(1);}
#endif

extern "C" {
jint (JNICALL * JNI_GetDefaultJavaVMInitArgs_func) (void *args);
jint (JNICALL * JNI_CreateJavaVM_func) (JavaVM **pvm, void **penv, void *args);
}

/*
 * Initialize JET run-time.
 */
extern "C" void initJavaRT(HANDLE myDllHandle, JavaVM** pjvm, JNIEnv** penv)
{
cerr<<"test1"<<endl;
    int            result;
    JavaVMInitArgs args;
    JNI_GetDefaultJavaVMInitArgs_func = 
             (jint (JNICALL *) (void *args))
#ifndef __linux__
         GetProcAddress ((HMODULE)myDllHandle, "JNI_GetDefaultJavaVMInitArgs");    
#else
             GetProcAddress (myDllHandle, "JNI_GetDefaultJavaVMInitArgs");
#endif

    JNI_CreateJavaVM_func =
             (jint (JNICALL *) (JavaVM **pvm, void **penv, void *args))

#ifndef __linux__
        GetProcAddress ((HMODULE)myDllHandle, "JNI_CreateJavaVM");   
#else
             GetProcAddress (myDllHandle, "JNI_CreateJavaVM");

#endif

    if(!JNI_GetDefaultJavaVMInitArgs_func) {
cerr<<"test1a"<<endl;
        printf ("%s doesn't contain public JNI_GetDefaultJavaVMInitArgs\n", dllname);
        exit (1);
    }

    if(!JNI_CreateJavaVM_func) {
cerr<<"test1b"<<endl;
        printf ("%s doesn't contain public JNI_CreateJavaVM\n", dllname);
        exit (1);
    }

    memset (&args, 0, sizeof(args));

    args.version = JNI_VERSION_1_2;
    result = JNI_GetDefaultJavaVMInitArgs_func(&args);
    if (result != JNI_OK) {
        cerr<<"JNI_GetDefaultJavaVMInitArgs() failed with result"<<result<<endl;
        exit(1);
    }
  
    /*
     * NOTE: no JVM is actually created
     * this call to JNI_CreateJavaVM is intended for JET RT initialization
     */
    result = JNI_CreateJavaVM_func (pjvm, (void **)penv, &args);
    if (result != JNI_OK) {
        cerr<<"JNI_CreateJavaVM() failed with result"<<result<<endl;
        exit(1);
    }
#ifdef DEBUG
    printf ("JET RT initialized\n");
#endif
    fflush (stdout);
cerr<<"test2"<<endl;

}



void SaxonProcessor::close(){
//void finalizeJavaRT (JavaVM* jvm)
    if(!closed) {	
    	jvm->DestroyJavaVM ();
	closed = true;
    }

}


/*
 * Look for class.
 */

jclass SaxonProcessor::lookForClass (JNIEnv* env, const char* name)
{
/*	if(env == NULL){
          cerr<<"env is NULL"<<endl;;
    	  exit(1);	
	}*/
    jclass clazz = (jclass)env->FindClass (name);

    if (!clazz) {
        printf("Unable to find class %s\n", name);
        exit(1);
    }
#ifdef DEBUG
    cerr<<"Class found"<< name<<endl;
#endif
    fflush (stdout);

    return clazz;
}

jmethodID SaxonProcessor::findConstructor (JNIEnv* env, jclass myClassInDll, string arguments)
{
#ifdef DEBUG
    cerr<<"Finding constructor"<<endl;
#endif
    jmethodID MID_init, mID;
    jobject obj;

    MID_init = (jmethodID)env->GetMethodID (myClassInDll, "<init>", arguments.c_str());
    if (!MID_init) {
        cerr<<"Error: MyClassInDll.<init>() not found\n"<<endl;
        return NULL;
    }

  return MID_init;
}

jobject SaxonProcessor::createObject (JNIEnv* env, jclass myClassInDll, string arguments, bool l)
{
    jmethodID MID_init, mID;
    jobject obj;

    MID_init = (jmethodID)env->GetMethodID (myClassInDll, "<init>", arguments.c_str());
    if (!MID_init) {
        printf("Error: MyClassInDll.<init>() not found\n");
        return NULL;
    }

      obj = (jobject)env->NewObject(myClassInDll, MID_init, (jboolean)l);
      if (!obj) {
        printf("Error: failed to allocate an object\n");
        return NULL;
      }
    return obj;
}

bool SaxonProcessor::exceptionOccurred(){
	return env->ExceptionCheck();
}

SaxonApiException * SaxonProcessor::checkForException(JNIEnv* env, jclass callingClass,  jobject callingObject){

    if (env->ExceptionCheck()) {
	string result1 = "";
	string errorCode = "";
	jthrowable exc = env->ExceptionOccurred();
env->ExceptionDescribe();
#ifdef DEBUG	
	env->ExceptionDescribe();
#endif
	 jclass exccls(env->GetObjectClass(exc));
        jclass clscls(env->FindClass("java/lang/Class"));

        jmethodID getName(env->GetMethodID(clscls, "getName", "()Ljava/lang/String;"));
        jstring name(static_cast<jstring>(env->CallObjectMethod(exccls, getName)));
        char const* utfName(env->GetStringUTFChars(name, 0));
	result1 = (string(utfName));
	//env->ReleaseStringUTFChars(name, utfName);

	 jmethodID  getMessage(env->GetMethodID(exccls, "getMessage", "()Ljava/lang/String;"));
	if(getMessage) {

		jstring message(static_cast<jstring>(env->CallObjectMethod(exc, getMessage)));
        	char const* utfMessage(env->GetStringUTFChars(message, 0));
		if(utfMessage != NULL) {
			result1 = (result1 + " : ") + utfMessage;
		}
		//cout<<result1<<endl;
		//env->ReleaseStringUTFChars(message,utfMessage);
		if(callingObject != NULL && result1.compare(0,36, "net.sf.saxon.s9api.SaxonApiException", 36) == 0){
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
							//env->ExceptionDescribe();
						}
						//env->ExceptionDescribe();
						env->ExceptionClear();
						return saxonExceptions;
					}
				}
		}
	}
	SaxonApiException * saxonExceptions = new SaxonApiException(NULL, result1.c_str());
	//env->ExceptionDescribe();
	env->ExceptionClear();
	return saxonExceptions;
     }
	return NULL;

}

    SaxonProcessor::SaxonProcessor(){
	license = false;
	//SaxonProcessor(license);
    }

int SaxonProcessor::jvmCreated=0;
      /*
       * First of all, load required component.
       * By the time of JET initialization, all components should be loaded.
       */
HANDLE SaxonProcessor::myDllHandle = loadDll (dllname);


void SaxonProcessor::createJVM(){
      /*
       * Initialize JET run-time.
       * The handle of loaded component is used to retrieve Invocation API.
       */

    // using a local lock_guard to lock mtx guarantees unlocking on destruction / exception:
//    std::lock_guard<std::mutex> lck (mtx);
//	std::unique_lock<std::mutex> lck (mtx);
      initJavaRT (myDllHandle, &jvm, &env);


}

SaxonProcessor::SaxonProcessor(bool l){
	//cerr<<"SaxonProcessor constructor"<<endl;
	cwd="";
	license = l;
	SaxonProcessor::jvmCreated++;
	//cerr<<"jvmCreated :"<<SaxonProcessor::jvmCreated<<endl;
/*      if(SaxonProcessor::jvmCreated==1) {   */
	
      /*
       * Initialize JET run-time.
       * The handle of loaded component is used to retrieve Invocation API.
       */

      initJavaRT (myDllHandle, &jvm, &env);
 
	    /* } else {
	if(env!= NULL){
	cerr<<"env is not null"<<endl;		
	} else {
	return;
	}
	} */

	//signal(SIGSEGV, mySigHandler);
    versionClass = lookForClass(env, "net/sf/saxon/Version");
    procClass = lookForClass(env, "net/sf/saxon/s9api/Processor");
    saxonCAPIClass = lookForClass(env, "net/sf/saxon/option/cpp/SaxonCAPI");

    closed = false;
    }


	XsltProcessor * SaxonProcessor::newTransformer(){ 

	return (new XsltProcessor(this, license, cwd));
    }


    SaxonProcessor& SaxonProcessor::operator=( const SaxonProcessor& other ){
	versionClass = other.versionClass;
	procClass = other.procClass;
	saxonCAPIClass = other.saxonCAPIClass;
	cwd = other.cwd; 
	proc = other.proc;
	env = other.env;
	jvm = other.jvm;
	parameters = other.parameters; 
	properties = other.properties;
	license = other.license;
	closed = other.closed;
	exception = other.exception;
	return *this;
    }


XQueryProcessor * SaxonProcessor::newXQueryProcessor(){ return (new XQueryProcessor(this, license, cwd));}


const char * SaxonProcessor::version() {


    jmethodID MID_version;

    MID_version = (jmethodID)env->GetStaticMethodID(versionClass, "getProductVersion", "()Ljava/lang/String;");
    if (!MID_version) {
	cout<<"\nError: MyClassInDll "<<"getProductVersion()"<<" not found"<<endl;
        return NULL;
    }
   jstring jstr = (jstring)(env->CallStaticObjectMethod(versionClass, MID_version));
   const char * str = env->GetStringUTFChars(jstr, NULL);
  
//    env->ReleaseStringUTFChars(jstr,str);
	return str;
}




void SaxonProcessor::setcwd(const char* dir){
    cwd = string(dir);
}

XdmValue * SaxonProcessor::parseString(const char* source){

    jmethodID mID = (jmethodID)env->GetStaticMethodID(saxonCAPIClass, "xmlParseString", "(Lnet/sf/saxon/s9api/Processor;Ljava/lang/String;)Lnet/sf/saxon/s9api/XdmNode;");
    if (!mID) {
	cerr<<"\nError: MyClassInDll "<<"xmlParseString()"<<" not found"<<endl;
        return NULL;
    }
   jobject xdmNodei = env->CallStaticObjectMethod(saxonCAPIClass, mID, proc, env->NewStringUTF(source));
     if(exceptionOccurred()) {
	   exception= checkForException(env, saxonCAPIClass, NULL);
     } else {
	XdmValue * value = new XdmValue(xdmNodei);
	return value;
   }
   return NULL;
}


XdmValue * SaxonProcessor::parseFile(const char* source){

    jmethodID mID = (jmethodID)env->GetStaticMethodID(saxonCAPIClass, "xmlParseFile", "(Lnet/sf/saxon/s9api/Processor;Ljava/lang/String;Ljava/lang/String;)Lnet/sf/saxon/s9api/XdmNode;");
    if (!mID) {
	cerr<<"\nError: MyClassInDll "<<"xmlParseFile()"<<" not found"<<endl;
        return NULL;
    }
   jobject xdmNodei = env->CallStaticObjectMethod(saxonCAPIClass, mID, proc, env->NewStringUTF(cwd.c_str()),  env->NewStringUTF(source));
     if(exceptionOccurred()) {
	   exception= checkForException(env, saxonCAPIClass, NULL);
     } else {
	XdmValue * value = new XdmValue(xdmNodei);
	return value;
   }
   return NULL;
}


XdmValue * SaxonProcessor::parseURI(const char* source){

    jmethodID mID = (jmethodID)env->GetStaticMethodID(saxonCAPIClass, "xmlParseFile", "(Lnet/sf/saxon/s9api/Processor;Ljava/lang/String;Ljava/lang/String;)Lnet/sf/saxon/s9api/XdmNode;");
    if (!mID) {
	cerr<<"\nError: MyClassInDll "<<"xmlParseFile()"<<" not found"<<endl;
        return NULL;
    }
   jobject xdmNodei = env->CallStaticObjectMethod(saxonCAPIClass, mID, proc, env->NewStringUTF(""), env->NewStringUTF(source));
     if(exceptionOccurred()) {
	   exception= checkForException(env, saxonCAPIClass, NULL);
     } else {
	XdmValue * value = new XdmValue(xdmNodei);
	return value;
   }
   return NULL;
}

void SaxonProcessor::setSourceValue(XdmValue * value){
	if(value != NULL){
		parameters["node"] = value;
	}	
}


void SaxonProcessor::setSourceFile(const char * ifile){
	setProperty("s", ifile); 	
}


void SaxonProcessor::setParameter(const char* namespacei, const char* name, XdmValue * value){
	if(value != NULL){
		parameters["param:"+string(name)] = value;
	}
}


XdmValue* SaxonProcessor::getParameter(const char* name){
	if(name != NULL){
		XdmValue * value = parameters["param:"+string(name)];
		if(value != NULL) {
			return value;
		}
	}
	return NULL;
}


bool SaxonProcessor::removeParameter(const char* namespacei, const char* name){
	return (bool)(parameters.erase(string(name)));
}


void SaxonProcessor::setProperty(const char* name, const char* value){
#ifdef DEBUG
	cerr<<"SaxonProcessor::setProperty name= "<<name<<endl;
	cerr<<"SaxonProcessor::setProperty value= "<<value<<endl;
#endif
	properties[string(name)] = string(value);	

}

const char* SaxonProcessor::getProperty(const char* name){
	string value = properties[string(name)];
	if(value.empty()) {
		return NULL;
	}
	return value.c_str();
}

void SaxonProcessor::clearParameters(){
	parameters.clear();
}

void SaxonProcessor::clearProperties(){
	properties.clear();
}


map<string,XdmValue*>& SaxonProcessor::getParameters(){
	map<string,XdmValue*>& ptr = parameters;
	return ptr;
}

map<string,string>& SaxonProcessor::getProperties(){
	map<string,string> &ptr = properties;
	return ptr;
}


int main(int argc, char *argv[]) {

SaxonProcessor *processor = NULL;
//for(int i =0; i<3;i++){
//	cout<<"testXX "<<i<<endl;
	processor = new SaxonProcessor(false);
	processor->setcwd("/var/www/trax");
	XsltProcessor * test = processor->newTransformer();

        test->setSourceFile("xml/foo.xml");
		XdmValue * xdmvaluex = new XdmValue("string", "Hello to you");
		if(xdmvaluex !=NULL){
			cerr<< "xdmvaluex ok"<<endl; 			
		}
		test->setParameter("", "a-param", xdmvaluex);
                const char * resultxx = test->xsltApplyStylesheet(NULL, "xsl/foo.xsl");
		if(resultxx != NULL) {                
			cerr<<resultxx<<endl;
		} else {
			cerr<<"Result is NULL"<<endl;
		}

	processor->clearParameters();
	processor->clearProperties();
	cout<<"Hello World version:"<<processor->version()<<endl;
	SaxonApiException * ex = test->checkException();
	if(ex != NULL){
		cout<<ex->count()<<endl;	
	}

	XdmValue * node=processor->parseString("<node>test</node>");

	test->setSourceValue(node);
	test->setProperty("s","xml/foo.xml");
	const char * result = test->xsltApplyStylesheet(NULL,"xsl/foo.xsl");//test->xsltApplyStylesheet("cat.xml","test.xsl");
	if(result != NULL){ //2m 25sec
		cout<<"Output: "<<result<<endl;
	} else {
	cout<<"result is null"<<endl;	
	}
//	cout<<"Test output: "<<test->xsltApplyStylesheet("cat.xml","test.xsl")<<endl;
	//cout<<"Test output: "<<test->xsltApplyStylesheet("xmark100.xml","q8.xsl")<<endl;
//	cout<<"ErrorCode:"<<test->getErrorCode()<<endl;
	SaxonApiException * ex1 = test->checkException();
	if(ex != NULL){
		cout<<ex->count()<<endl;	
	}
	cout<<"end of xsltTransformer test"<<endl;

	processor->setcwd("/var/www/");
	processor->clearParameters();
	processor->clearProperties();
	cout<<endl<<"XQuery:"<<endl<<endl;
	XQueryProcessor * query = processor->newXQueryProcessor();
//	query->setQueryFile("q8.xq");
	//query->setQueryFile("qtest.xq");
	query->setQueryFile("query/books-to-html.xq");
//	cout<<query->executeQueryToString("xmark1.xml", "xquery version '1.0'; import module namespace webpage='http://www.example.com/webpage' at '/home/ond1/test/saxon9-5-1-1source/saxon_php3/webpage.xqm'; let $title := 'Sample Web Page' return    <html>    <head>            <title>{$title}</title>        </head>        <body>            {webpage:header()}            <h1>{$title}</h1>            <div class='content'>Content goes here.</div>            {webpage:footer()}        </body>    </html>")<<endl;
	const char * resultxxx = query->executeQueryToString("query/books.xml", NULL);
	if(resultxxx != NULL) {
		cout<<resultxxx<<endl;
	} else {
		cout<<"query is null"<<endl;
	}

	ex1 = query->checkException();
	if(ex != NULL){
		cout<<ex->count()<<endl;	
	}
	processor->close();
	delete test;
	delete processor;
}




