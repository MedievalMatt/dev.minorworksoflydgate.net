#ifndef SAXON_XSLT_H
#define SAXON_XSLT_H


#include "SaxonProcessor.h"
#include "XdmValue.h"
#include <string>


/*! An <code>XsltProcessor</code> represents factory to compile, load and execute a stylesheet.
 * It is possible to cache the context and the stylesheet in the <code>XsltProcessor</code>.
 * <p/>
 */
class XsltProcessor {

public:

    //! A constructor.
    /*!
      license flag not required in Saxon-HE product
      cwd - set the current working directory
    */
    XsltProcessor(SaxonProcessor* proc, bool license=false, string cwd="");

     ~XsltProcessor(){}


    /**
     * Set the source document from a XdmValue for the transformation.
    */
    void setSourceValue(XdmValue * value);

    /**
     * Set the source from file for the transformation.
    */
    void setSourceFile(const char * filename);

    /**
     * Set the output file of where the transformation result is sent
    */
    void setOutputfile(const char* outfile);

    /**
     * Set the value of a stylesheet parameter
     *
     * @param namespacei currently not used
     * @param name  the name of the stylesheet parameter, as a string
     * @param value the value of the stylesheet parameter, or null to clear a previously set value
     */
    void setParameter(const char* namespacei, const char* name, XdmValue*value);

    /**
     * Get a parameter value by name
     * @param name - Specified paramater name to get
     * @return XdmValue
    */
     XdmValue* getParameter(const char* name);


    /**
     * Remove a parameter (name, value) pair from a stylesheet
     *
     * @param namespacei currently not used
     * @param name  the name of the stylesheet parameter
     * @return bool - outcome of the romoval
     */
    bool removeParameter(const char* namespacei, const char* name);

    /**
     * Set a property.
     *
     * @param name of the property
     * @param value of the property
     */
    void setProperty(const char* name, const char* value);

    /**
     * Get a property value by name
     * @param name - Specified paramater name to get
     * @return string - Get string of the property as char pointer array
    */
    const char* getProperty(const char* name);

    /**
     * Clear parameter values set
     */
    void clearParameters();

    /**
     * Clear property values set
     */
    void clearProperties();


    /**
     * Perform a one shot transformation. The result is stored in the supplied outputfile.
     *
     * @param sourcefile - The file name of the source document
     * @param stylesheetfile - The file name of the stylesheet document
     * @param outputfile - The file name where results will be stored
     */
    void xsltSaveResultToFile(const char* sourcefile, const char* stylesheetfile, const char* outputfile); 

    /**
     * Perform a one shot transformation. The result is returned as a string
     *
     * @param sourcefile - The file name of the source document
     * @param stylesheetfile - The file name of the stylesheet document
     * @return char array - result of the transformation
     */
    const char * xsltApplyStylesheet(const char* sourcefile, const char* stylesheetfile);

    /**
     * Perform a one shot transformation. The result is returned as an XdmValue
     *
     * @param sourcefile - The file name of the source document
     * @param stylesheetfile - The file name of the stylesheet document
     * @return XdmValue - result of the transformation
     */
    XdmValue * xsltApplyStylesheetToValue(const char* sourcefile, const char* stylesheetfile);


    /**
     * compile a stylesheet received as a string.
     *
     * Not implemented yet. Available in next release
     * @param stylesheet as a lexical string representation
     */
    void compileString(const char* stylesheet);

    /**
     * Perform the transformation returned as a string.
     * Not implemented yet. Available in next release
     *
     */
    const char * transformToString();

    /**
     * Perform the transformation returned as a XdmValue.
     * Not implemented yet. Available in next release
     *
     */
    XdmValue * transformToValue();

    /**
     * Checks for pending exceptions without creating a local reference to the exception object
     * @return bool - true when there is a pending exception; otherwise return false
    */
    bool exceptionOccurred();



    SaxonApiException* checkException();
    void exceptionClear();
    int exceptionCount();
    const char * getErrorMessage(int i);
    const char * getErrorCode(int i);


    /**
    * Method for testing purposes. Available only in alpha release
    */
    string sizes(int number){
	std::ostringstream ostr; //output string stream
    	ostr << number;
	return ostr.str();
	}

    /**
    * Method for testing purposes. Available only in alpha release
    */
     string checkFailures(){return failure;}	//for testing

private:
	SaxonProcessor* proc;
	jclass  cppClass;
	jobject cpp;
	string outputfile1; /*!< output file where result will be saved */
	string failure; //for testing
	bool nodeCreated;

};


#endif /* SAXON_XSLT_H */
