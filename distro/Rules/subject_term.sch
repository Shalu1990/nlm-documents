<?xml version="1.0" encoding="UTF-8"?>
<!--

* Schematron rules for testing semantic validity of XML files in the JATS DTD submitted to NPG *

Due to the configuration of XSLT templates used in the validation service, attributes cannot be used as the 'context' of a rule.

For example, context="article[@article-type]" will recognise the context as 'article' with an 'article-type' attribute, but context="article/@article-type" will set context as 'article'.
Use the <let> element to define the attribute if necessary.

-->
<schema xmlns="http://purl.oclc.org/dsdl/schematron" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" queryBinding="xslt2">
  <title>Schematron rules for NPG content in JATS v1.0</title>
  <ns uri="http://www.w3.org/1998/Math/MathML" prefix="mml"/>
  <ns uri="http://www.niso.org/standards/z39-96/ns/oasis-exchange/table" prefix="oasis"/>
  <ns uri="http://www.w3.org/1999/xlink" prefix="xlink"/>
  
  <ns prefix="npg" uri="http://ns.nature.com/terms/"/>
  <ns prefix="rdf" uri="http://www.w3.org/1999/02/22-rdf-syntax-ns#"/>
  <ns prefix="skos" uri="http://www.w3.org/2004/02/skos/core#"/>
  <ns prefix="bibo" uri="http://purl.org/ontology/bibo/"/>
  <ns prefix="foaf" uri="http://xmlns.com/foaf/0.1/"/>
  <ns prefix="owl" uri="http://www.w3.org/2002/07/owl#"/>
  <ns prefix="dc" uri="http://purl.org/dc/elements/1.1/"/>
  <ns prefix="rdfs" uri="http://www.w3.org/2000/01/rdf-schema#"/>
  
  <let name="allowed-values" value="document( 'allowed-values-nlm.xml' )/allowed-values"/><!--Points at document containing information on allowed attribute values-->
  <let name="allowed-article-types" value="document( 'allowed-article-types.xml' )/allowed-article-types"/><!--look-up file for allowed article types. Once the product ontology contains this information, this file can be deleted and the Schematron rules updated-->

  <let name="journals" value="document('journals.xml')"/>
  <let name="subjects" value="document('subjects.xml')"/>
      
  <ns prefix="functx" uri="http://www.functx.com" /><!--extended XPath functions from Priscilla Walmsley-->
  <xsl:function name="functx:substring-after-last" as="xs:string" xmlns:functx="http://www.functx.com" >
    <xsl:param name="arg" as="xs:string?"/> 
    <xsl:param name="delim" as="xs:string"/> 
    <xsl:sequence select="replace ($arg,concat('^.*',functx:escape-for-regex($delim)),'')"/>
  </xsl:function>
  
  <xsl:function name="functx:escape-for-regex" as="xs:string" xmlns:functx="http://www.functx.com" >
    <xsl:param name="arg" as="xs:string?"/> 
    <xsl:sequence select="replace($arg,'(\.|\[|\]|\\|\||\-|\^|\$|\?|\*|\+|\{|\}|\(|\))','\\$1')"/>
  </xsl:function>
  
  <xsl:function name="functx:substring-before-last" as="xs:string" 
    xmlns:functx="http://www.functx.com" >
    <xsl:param name="arg" as="xs:string?"/> 
    <xsl:param name="delim" as="xs:string"/> 
    <xsl:sequence select="if (matches($arg, functx:escape-for-regex($delim)))
      then replace($arg,concat('^(.*)', functx:escape-for-regex($delim),'.*'),'$1')
      else ''"/>
  </xsl:function>
  
  <!--Regularly used values throughout rules-->
  <let name="journal-title" value="//journal-meta/journal-title-group/journal-title"/>
  <let name="pcode" value="//journal-meta/journal-id[1]"/>
  <let name="article-type" value="article/@article-type"/>
  <let name="article-id" value="article/front/article-meta/article-id[@pub-id-type='publisher-id']"/>
  
  <let name="volume" value="article/front/article-meta/volume"/>
  <let name="maestro-aj" value="if (matches($pcode,'^(nmstr|palmstr|testnatfile|testpalfile|paldelor|mtm|hortres|sdata|bdjteam|palcomms|hgv|npjbiofilms|npjschz|npjpcrm|npjamd|micronano|npjqi|mto|npjsba|npjmgrav|celldisc|npjbcancer|npjparkd|npjscilearn|npjgenmed|npjcompumats|npjregenmed|bdjopen)$')) then 'yes'
    else if ($pcode eq 'boneres' and number($volume) gt 1) then 'yes'
    else ()"/>
  <let name="transition" value="if ($pcode eq 'srep' and number($volume) lt 6) then 'yes'
    else ()"></let>
  <let name="maestro-rj" value="if (matches($pcode,'^(maestrorj|testpalevent|testnatevent|npgdelor|nplants|nrdp)$')) then 'yes'
    else ()"/>
  <let name="maestro" value="if ($maestro-aj='yes' or $maestro-rj='yes') then 'yes' else ()"></let>
  <let name="pubevent" value="if (matches($pcode,'^(maestrorj|testnatevent|testpalevent|nplants|nrdp)$')) then 'yes'
    else 'no'"/>
  <let name="existing-oa-aj" value="if (matches($pcode,'^(am|bcj|cddis|ctg|cti|emi|emm|lsa|msb|mtm|mtna|ncomms|nutd|oncsis|psp|scibx|srep|tp)$')) then 'yes'
    else ()"/>
  <let name="new-eloc" value="if (ends-with($article-id,'test')) then 'none'
    else if (matches($pcode,'^(bdjteam|palcomms|hgv|npjbiofilms|npjpcrm|npjschz|npjamd|micronano|npjqi|mto|nplants|npjsba|npjmgrav|celldisc|nrdp|npjbcancer|npjparkd|npjscilearn|npjgenmed|npjcompumats|npjregenmed|bdjopen)$')) then 'three'
    else if ($pcode eq 'boneres' and number($volume) gt 1) then 'three'
    else if ($pcode eq 'mtm' and number(substring(replace($article-id,$pcode,''),1,4)) gt 2013) then 'three'
    else if ($pcode eq 'sdata' and number(substring(replace($article-id,$pcode,''),1,4)) gt 2013) then 'four'
    else ()"/>
  <let name="test-journal" value="if (matches($pcode,'^(nmstr|palmstr|maestrorj|testnatfile|testpalfile|paldelor|testnatevent|npgdelor|testpalevent)$')) then 'yes' else 'no'"/>
  <let name="collection" value="$journals//npg:Journal[npg:pcode=$pcode]/npg:hasDomain/functx:substring-after-last(@rdf:resource,'/')"/>
  
  <pattern><!--subject term found in subject ontology-->
    <rule context="article[($maestro='yes' or $transition='yes') and $test-journal='no']//subject[@content-type='npg.subject']/named-content[@content-type='id']">
      <assert id="subject_validation" test=".=$subjects//npg:code">Subject id (<value-of select="."/>) is not recognized by the subject ontology. Please check the information supplied by NPG.</assert>
    </rule>
  </pattern>
  
</schema>
