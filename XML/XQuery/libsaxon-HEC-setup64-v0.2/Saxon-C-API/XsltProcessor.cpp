// XsltProcessor.cpp : Defines the exported functions for the DLL application.
//

//#include "xsltProcessor.cc"

#include "XsltProcessor.h"
#ifdef DEBUG
	#include <typeinfo> //used for testing only
#endif

XsltProcessor::XsltProcessor(SaxonProcessor * p, bool license, string curr) {

    proc = p;

    /*
     * Look for class.
     */
     cppClass = proc->lookForClass(proc->env, "net/sf/saxon/option/cpp/XsltProcessorForCpp");


    cpp = proc->createObject (proc->env, cppClass, "(Z)V", license);
    jmethodID mID_proc = (jmethodID)proc->env->GetMethodID (cppClass,"getProcessor", "()Lnet/sf/saxon/s9api/Processor;");
    proc->proc = (jobject)(proc->env->CallObjectMethod(cpp, mID_proc));
    jmethodID debugMID = proc->env->GetStaticMethodID(cppClass, "setDebugMode", "(Z)V");
    if(debugMID){
	proc->env->CallStaticVoidMethod(cppClass, debugMID, (jboolean)true);
    }
    nodeCreated = false;
    proc->exception = NULL;
    outputfile1 = "";
    if(proc->cwd.compare("")){	
	    proc->cwd = curr;
    }

}

bool XsltProcessor::exceptionOccurred(){
	return proc->exceptionOccurred();

}




const char * XsltProcessor::getErrorCode(int i) {
	if(proc->exception == NULL) {return NULL;}
	return proc->exception->getErrorCode(i);
}




void XsltProcessor::setSourceValue(XdmValue * node){
	if(node!= NULL){
		proc->setSourceValue(node);
	}  	
}


void XsltProcessor::setSourceFile(const char * ifile){
   setProperty("s", ifile); 	
}



void XsltProcessor::setOutputfile(const char * ofile){
   outputfile1 = string(ofile); 
   setProperty("o", ofile);
}



void XsltProcessor::setParameter(const char* namespacei, const char* name, XdmValue * value){
	return proc->setParameter(namespacei, name, value);
}


XdmValue* XsltProcessor::getParameter(const char* name){
	return proc->getParameter(name);
}


bool XsltProcessor::removeParameter(const char* namespacei, const char* name){
	return proc->removeParameter(namespacei, name);
}


void XsltProcessor::setProperty(const char* name, const char* value){
	return proc->setProperty(name,  value);	

}

const char* XsltProcessor::getProperty(const char* name){
	return proc->getProperty(name);
}

void XsltProcessor::clearParameters(){
	return proc->clearParameters();
}

void XsltProcessor::clearProperties(){
	return proc->clearProperties();
}

void XsltProcessor::exceptionClear(){
	if(proc->exception != NULL) {
		delete proc->exception;
		proc->exception = NULL;	
	}
}

SaxonApiException* XsltProcessor::checkException(){
	if(proc->exception == NULL) {
		proc->exception = proc->checkForException(proc->env, cppClass, cpp);
	}
        return proc->exception;
}



int XsltProcessor::exceptionCount(){
	if(proc->exception != NULL){
		return proc->exception->count();
	}
	return 0;
}

 void XsltProcessor::compileString(const char* stylesheetStr){
jmethodID mID = (jmethodID)proc->env->GetMethodID (cppClass,"createStylesheetFromString", "(Ljava/lang/String;Ljava/lang/String;)Lnet/sf/saxon/s9api/XsltExecutable;");
 if (!mID) {
        cerr<<"Error: MyClassInDll."<<"createStylesheetFromString"<<" not found\n"<<endl;

    } else {
 	
      jobject result = (jobject)(proc->env->CallObjectMethod(cpp, mID, proc->env->NewStringUTF(proc->cwd.c_str()), proc->env->NewStringUTF(stylesheetStr)));
      if(result) {
	cerr<<" compileString OK in XTP"<<endl;
     }else {
		cerr<<" compileString is NULL"<<endl;
		checkException();
}
  }



 }

XdmValue * XsltProcessor::xsltApplyStylesheetToValue(const char* sourcefile, const char* stylesheetfile){ 

jmethodID mID = (jmethodID)proc->env->GetMethodID (cppClass,"xsltApplyStylesheetToValue", "(Ljava/lang/String;Ljava/lang/String;Ljava/lang/String;Ljava/lang/String;[Ljava/lang/String;[Ljava/lang/Object;)Ljava/lang/String;");
 if (!mID) {
        cerr<<"Error: MyClassInDll."<<"xsltApplyStylesheet"<<" not found\n"<<endl;

    } else {
	std::map<string,XdmValue*> parameters= proc->getParameters();
	std::map<string,string> properties = proc->getProperties();
 	jobjectArray stringArray = NULL;
	jobjectArray objectArray = NULL;
        jclass objectClass = proc->lookForClass(proc->env, "java/lang/Object");
	jclass stringClass = proc->lookForClass(proc->env, "java/lang/String");

	int size = parameters.size() + properties.size();
	if(size >0) {
   	   objectArray = proc->env->NewObjectArray( (jint)size, objectClass, 0 );
	   stringArray = proc->env->NewObjectArray( (jint)size, stringClass, 0 );
	   int i=0;
	   for(map<string, XdmValue* >::iterator iter=parameters.begin(); iter!=parameters.end(); ++iter, i++) {
	     proc->env->SetObjectArrayElement( stringArray, i, proc->env->NewStringUTF( (iter->first).c_str() ) );
	     proc->env->SetObjectArrayElement( objectArray, i, (iter->second)->getUnderlyingValue(proc) );
	   }
  	   for(map<string, string >::iterator iter=properties.begin(); iter!=properties.end(); ++iter, i++) {
	     proc->env->SetObjectArrayElement( stringArray, i, proc->env->NewStringUTF( (iter->first).c_str()  ));
	     proc->env->SetObjectArrayElement( objectArray, i, proc->env->NewStringUTF((iter->second).c_str()) );
	   }
	}
      jobject result = (jobject)(proc->env->CallObjectMethod(cpp, mID, proc->env->NewStringUTF(proc->cwd.c_str()), (sourcefile!=NULL?proc->env->NewStringUTF(sourcefile) : NULL ), proc->env->NewStringUTF(stylesheetfile), stringArray, objectArray ));
	proc->env->DeleteLocalRef( stringArray);
	proc->env->DeleteLocalRef( objectArray);
      if(result) {
	XdmValue * node = new XdmValue(result);
	return node;
     }
  }
  return NULL;


}
	 

void XsltProcessor::xsltSaveResultToFile(const char* source, const char* stylesheet, const char* outputfile) {

 jmethodID mID = (jmethodID)proc->env->GetMethodID (cppClass,"xsltSaveResultToFile", "(Ljava/lang/String;Ljava/lang/String;Ljava/lang/String;Ljava/lang/String;[Ljava/lang/String;[Ljava/lang/Object;)V");
 proc->exception = NULL;
 if (!mID) {
        cerr<<"Error: MyClassInDll."<<"xsltApplyStylesheet"<<" not found\n"<<endl;

    } else {
	std::map<string,XdmValue*> parameters = proc->getParameters();
	std::map<string,string> properties = proc->getProperties();
 	jobjectArray stringArray = NULL;
	jobjectArray objectArray = NULL;
        jclass objectClass = proc->lookForClass(proc->env, "java/lang/Object");
	   jclass stringClass = proc->lookForClass(proc->env, "java/lang/String");

	int size = parameters.size() + properties.size();
#ifdef DEBUG
	cerr<<"Properties size: "<<properties.size()<<endl;
	cerr<<"Parameter size: "<<parameters.size()<<endl;	
#endif
	if(size >0) {
	   objectArray = proc->env->NewObjectArray( (jint)size, objectClass, 0 );
	   stringArray = proc->env->NewObjectArray( (jint)size, stringClass, 0 );
	   int i =0;	
	   for(map<string, XdmValue* >::iterator iter=parameters.begin(); iter!=parameters.end(); ++iter, i++) {
	     proc->env->SetObjectArrayElement( stringArray, i, proc->env->NewStringUTF( (iter->first).c_str() ) );
	     proc->env->SetObjectArrayElement( objectArray, i, (iter->second)->getUnderlyingValue(proc) );
	   }
  	   for(map<string, string >::iterator iter=properties.begin(); iter!=properties.end(); ++iter, i++) {
	     proc->env->SetObjectArrayElement( stringArray, i, proc->env->NewStringUTF( (iter->first).c_str()  ));
	     proc->env->SetObjectArrayElement( objectArray, i, proc->env->NewStringUTF((iter->second).c_str()) );
	   }
	}
      proc->env->CallObjectMethod(cpp, mID, proc->env->NewStringUTF(proc->cwd.c_str()), (source!=NULL?proc->env->NewStringUTF(source) : NULL ), proc->env->NewStringUTF(stylesheet), proc->env->NewStringUTF(outputfile), stringArray, objectArray );
	proc->env->DeleteLocalRef( stringArray);
	proc->env->DeleteLocalRef( objectArray);
  }
}

const char * XsltProcessor::xsltApplyStylesheet(const char* source, const char* stylesheet) {
 jmethodID mID = (jmethodID)proc->env->GetMethodID (cppClass,"xsltApplyStylesheet", "(Ljava/lang/String;Ljava/lang/String;Ljava/lang/String;[Ljava/lang/String;[Ljava/lang/Object;)Ljava/lang/String;");
 if (!mID) {
        cerr<<"Error: MyClassInDll."<<"xsltApplyStylesheet"<<" not found\n"<<endl;

    } else {
	std::map<string,XdmValue*> parameters = proc->getParameters();
	std::map<string,string> properties = proc->getProperties();
 	jobjectArray stringArray = NULL;
	jobjectArray objectArray = NULL;
        jclass objectClass = proc->lookForClass(proc->env, "java/lang/Object");
	jclass stringClass = proc->lookForClass(proc->env, "java/lang/String");

	int size = parameters.size() + properties.size();
#ifdef DEBUG
	cerr<<"Properties size: "<<properties.size()<<endl;
	cerr<<"Parameter size: "<<parameters.size()<<endl;
	cerr<<"size:"<<size<<endl;
#endif
	if(size >0) {
	   objectArray = proc->env->NewObjectArray( (jint)size, objectClass, 0 );
	   stringArray = proc->env->NewObjectArray( (jint)size, stringClass, 0 );
	    if(objectArray == NULL) {
		cerr<<"objectArray is NULL"<<endl;
   	    }
	    if(stringArray == NULL) {
		cerr<<"stringArray is NULL"<<endl;
   	    }
	   int i=0;
	   for(map<string, XdmValue* >::iterator iter=parameters.begin(); iter!=parameters.end(); ++iter, i++) {

#ifdef DEBUG
	cerr<<"map 1"<<endl;		
	cerr<<"iter->first"<<(iter->first).c_str()<<endl;
#endif
	     proc->env->SetObjectArrayElement( stringArray, i, proc->env->NewStringUTF( (iter->first).c_str() ) );
#ifdef DEBUG
string s1 = typeid(iter->second).name();
cerr<<"Type of itr:"<<s1<<endl;
jobject xx = (iter->second)->getUnderlyingValue(proc); 
if(NULL == xx) {
	cerr<<"xx failed"<<endl;
} else {
cerr<<"Type of xx:"<<(typeid(xx).name())<<endl;
}
#endif
	     proc->env->SetObjectArrayElement( objectArray, i, (iter->second)->getUnderlyingValue(proc) );
	   
	
	   }

  	   for(map<string, string >::iterator iter=properties.begin(); iter!=properties.end(); ++iter, i++) {
	     proc->env->SetObjectArrayElement( stringArray, i, proc->env->NewStringUTF( (iter->first).c_str()  ));
	     proc->env->SetObjectArrayElement( objectArray, i, proc->env->NewStringUTF((iter->second).c_str()) );
	   }
	}
      jstring result = (jstring)(proc->env->CallObjectMethod(cpp, mID, proc->env->NewStringUTF(proc->cwd.c_str()), (source!=NULL?proc->env->NewStringUTF(source) : NULL ), proc->env->NewStringUTF(stylesheet), stringArray, objectArray ));
	proc->env->DeleteLocalRef( stringArray);
	proc->env->DeleteLocalRef( objectArray);
      if(result) {
       const char * str = proc->env->GetStringUTFChars(result, NULL);
       //return "result should be ok";            
	return str;
     }
  }
  return NULL;
}

    const char * XsltProcessor::getErrorMessage(int i ){
	if(proc->exception == NULL) {return NULL;}
	return proc->exception->getErrorMessage(i);
    }












