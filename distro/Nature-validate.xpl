<?xml version="1.0"?>

<!--

Pipeline for performing validation on journal articles of Nature that conform to
the NLM journal publishing model version 3.0.

source: a single journal article, the URI of which is specified by the "candidate-sysid" option.
result: a validation report.     
     
-->     

<p:pipeline name="nature-validate" xmlns:p="http://www.w3.org/ns/xproc"
  xmlns:xo="http://xmlopen.org/pipelines" version="1.0"
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xlink="http://www.w3.org/1999/xlink"
  xmlns:svrl="http://purl.oclc.org/dsdl/svrl" xmlns:c="http://www.w3.org/ns/xproc-step"
  xmlns:cx="http://xmlcalabash.com/ns/extensions">

  <!-- The URI of the candidate to validate -->
  <p:option name="candidate-sysid" required="true"/>


  <!-- 
    Sub-pipeline to perform DTD validation on an NLM instance.
    
    The DTD must be declared in the instance in the normal way.
    
    The required option "candidate-sysid" gives the URI of the instance
    to be validated.  
    
    Emits a document rooted on <c:errors>.
  -->
  <p:pipeline type="xo:dtd-validate">

    <p:option name="candidate-sysid" required="true"/>

    <p:try name="validate">

      <!-- Attempt to load document enforcing DTD validation. This will generate
  a dynamic error when the document is invalid -->
      <p:group>
        <p:load name="load-doc">
          <p:with-option name="dtd-validate" select="'true'"/>
          <p:with-option name="href" select="$candidate-sysid"/>
        </p:load>
      </p:group>

      <!-- If it's invalid, this catch block handles the error, and puts the 
  validation report on the pipeline -->
      <p:catch name="invalid">
        <p:identity>
          <p:input port="source">
            <p:pipe step="invalid" port="error"/>
          </p:input>
        </p:identity>
      </p:catch>

    </p:try>

    <!-- Massage the result to it's ALWAYS a <c:errors> document. (If the document was
      valid the p:load step operation merely forwards it itself - so we modify this into
      an empty <c:errors> document.) -->
    <p:replace match="article">
      <p:input port="replacement">
        <p:inline>
          <c:errors/>
        </p:inline>
      </p:input>
    </p:replace>

    <p:add-attribute match="c:error" attribute-name="validated-by" attribute-value="dtd"/>

  </p:pipeline>


  <!-- 
  Sub-pipeline to perform Schematron validation on an NLM instance.
  
  The required option "candidate-sysid" gives the URI of the instance
  to be validated.  
  
  Emits an SVRL report (with not-useful elements removed).
-->
  <p:pipeline type="xo:schematron-validate">

    <p:option name="candidate-sysid" required="true"/>

    <!-- load the document -->
    <p:load name="load-doc">
      <p:with-option name="dtd-validate" select="'false'"/>
      <p:with-option name="href" select="$candidate-sysid"/>
    </p:load>

    <!-- validate it with Schematron -->
    <p:validate-with-schematron name="sch" assert-valid="false">
      <p:input port="schema">
        <p:document href="file:Nature-NLM.sch"/>
      </p:input>
    </p:validate-with-schematron>

    <p:sink/>

    <!-- place the SVRL report on the pipeline (we don't want the instance) -->
    <p:identity>
      <p:input port="source">
        <p:pipe port="report" step="sch"/>
      </p:input>
    </p:identity>

    <!-- tidy the SVRL by deleteing the noisy "logging" elements -->
    <p:delete
      match="svrl:fired-rule|svrl:ns-prefix-in-attribute-values|svrl:active-pattern|@*[not(name(.)='id' or name(.)='location')]"/>

    <p:add-attribute match="svrl:failed-assert|svrl:successful-report" attribute-name="validated-by"
      attribute-value="schematron"/>

  </p:pipeline>

  <!-- declarations end; processing begins here ... -->

  <!-- STEP 1. Generate the document map of xpath locations against line/col locations.
  N.B. this uses some Java-based functionality -->
  <p:exec name="documap" command="java">
    <p:with-option name="args" select="concat('Documap ',$candidate-sysid)"/>
  </p:exec>

  <!-- STEP 2. Generate a DTD validation report -->
  <xo:dtd-validate name="dtd-val-report">
    <p:with-option name="candidate-sysid" select="$candidate-sysid"/>
  </xo:dtd-validate>

  <!-- STEP 3. Generate a SVRL (Schematron) validation report) ... which is forced
  empty if there have been DTD errors -->
  <p:choose>
    <p:when test="//c:error">
      <p:identity>
        <p:input port="source">
          <p:inline>
            <!-- when DTD errors exist, synthesize an empty SVRL report -->
            <svrl:schematron-output/>
          </p:inline>
        </p:input>
      </p:identity>
    </p:when>
    <p:otherwise>
      <xo:schematron-validate>
        <p:with-option name="candidate-sysid" select="$candidate-sysid"/>
      </xo:schematron-validate>
    </p:otherwise>
  </p:choose>

  <p:identity name="svrl-report"/>

  <!-- join the above 3 generated fragments together into a report document -->
  <p:wrap-sequence wrapper="report">
    <p:input port="source">
      <p:pipe step="documap" port="result"/>
      <p:pipe step="dtd-val-report" port="result"/>
      <p:pipe step="svrl-report" port="result"/>
    </p:input>
  </p:wrap-sequence>

  <!-- get the output into a somewhat consistent form -->
  <p:rename match="svrl:failed-assert|svrl:successful-report|c:error" new-name="message"/>
  <p:unwrap match="svrl:schematron-output|svrl:text|c:errors|c:result"/>

  <!-- use the document map to enrich the SVRL messages with line/column attributes -->
  <p:xslt>
    <p:input port="stylesheet">
      <p:inline>
        <xsl:stylesheet version="2.0">

          <xsl:template match="message[not(@line)]">
            <message>
              <xsl:variable name="xpath"
                select="if( contains(@location,'/@')) then (substring-before(@location,'/@')) else @location"/>
              <xsl:variable name="line"
                select="ancestor::report[1]/documap/place[@xpath=$xpath]/@line"/>
              <xsl:variable name="column"
                select="ancestor::report[1]/documap/place[@xpath=$xpath]/@column"/>
              <xsl:copy-of select="@*"/>
              <xsl:if test="$line!=''">
                <xsl:attribute name="line">
                  <xsl:value-of select="$line"/>
                </xsl:attribute>
              </xsl:if>
              <xsl:if test="$column!=''">
                <xsl:attribute name="column">
                  <xsl:value-of select="$column"/>
                </xsl:attribute>
              </xsl:if>
              <xsl:copy-of select="text()|*"/>
            </message>
          </xsl:template>

          <xsl:template match="@*|*|processing-instruction()|comment()">
            <xsl:copy>
              <xsl:apply-templates select="*|@*|text()|processing-instruction()|comment()"/>
            </xsl:copy>
          </xsl:template>
        </xsl:stylesheet>

      </p:inline>
    </p:input>
  </p:xslt>

  <!-- discard the document map - not wanted in the report -->
  <p:delete match="documap"/>

  <!-- de-namespaceification -->
  <p:xslt>
    <p:input port="stylesheet">
      <p:inline>
        <xsl:stylesheet version="2.0">
          <xsl:output indent="no"/>
          <xsl:template match="*">
            <xsl:element name="{local-name(.)}">
              <xsl:copy-of select="@*"/>
              <xsl:apply-templates/>
            </xsl:element>
          </xsl:template>
        </xsl:stylesheet>
      </p:inline>
    </p:input>
  </p:xslt>


</p:pipeline>
