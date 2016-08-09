<?xml version="1.0" encoding="UTF-8"?>
<!--

* Schematron rules for testing semantic validity of XML files in the JATS DTD submitted to Springer Nature *

Due to the configuration of XSLT templates used in the validation service, attributes cannot be used as the 'context' of a rule.

For example, context="article[@article-type]" will recognise the context as 'article' with an 'article-type' attribute, but context="article/@article-type" will set context as 'article'.
Use the <let> element to define the attribute if necessary.

-->
<schema xmlns="http://purl.oclc.org/dsdl/schematron"
        xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
        queryBinding="xslt2">
  <title>Schematron rules for Springer Nature content in JATS v1.0</title>
  <ns uri="http://www.w3.org/1998/Math/MathML" prefix="mml"/>
  <ns uri="http://www.niso.org/standards/z39-96/ns/oasis-exchange/table"
       prefix="oasis"/>
  <ns uri="http://www.w3.org/1999/xlink" prefix="xlink"/>
  
  <ns prefix="npg" uri="http://ns.nature.com/terms/"/>
  <ns prefix="rdf" uri="http://www.w3.org/1999/02/22-rdf-syntax-ns#"/>
  <ns prefix="skos" uri="http://www.w3.org/2004/02/skos/core#"/>
  <ns prefix="bibo" uri="http://purl.org/ontology/bibo/"/>
  <ns prefix="foaf" uri="http://xmlns.com/foaf/0.1/"/>
  <ns prefix="owl" uri="http://www.w3.org/2002/07/owl#"/>
  <ns prefix="dc" uri="http://purl.org/dc/elements/1.1/"/>
  <ns prefix="rdfs" uri="http://www.w3.org/2000/01/rdf-schema#"/>
  
  <let name="allowed-values"
        value="document( 'allowed-values-nlm.xml' )/allowed-values"/>
   <!--Points at document containing information on allowed attribute values-->
  <let name="allowed-article-types"
        value="document( 'allowed-article-types.xml' )/allowed-article-types"/>
   <!--look-up file for allowed article types. Once the product ontology contains this information, this file can be deleted and the Schematron rules updated-->

  <let name="journals" value="document('journals.xml')"/>
      
  <ns prefix="functx" uri="http://www.functx.com"/>
   <!--extended XPath functions from Priscilla Walmsley-->
  <xsl:function xmlns:functx="http://www.functx.com"
                 name="functx:substring-after-last"
                 as="xs:string">
      <xsl:param name="arg" as="xs:string?"/> 
      <xsl:param name="delim" as="xs:string"/> 
      <xsl:sequence select="replace ($arg,concat('^.*',functx:escape-for-regex($delim)),'')"/>
  </xsl:function>
  
  <xsl:function xmlns:functx="http://www.functx.com"
                 name="functx:escape-for-regex"
                 as="xs:string">
      <xsl:param name="arg" as="xs:string?"/> 
      <xsl:sequence select="replace($arg,'(\.|\[|\]|\\|\||\-|\^|\$|\?|\*|\+|\{|\}|\(|\))','\\$1')"/>
  </xsl:function>
  
  <xsl:function xmlns:functx="http://www.functx.com"
                 name="functx:substring-before-last"
                 as="xs:string">
      <xsl:param name="arg" as="xs:string?"/> 
      <xsl:param name="delim" as="xs:string"/> 
      <xsl:sequence select="if (matches($arg, functx:escape-for-regex($delim)))       then replace($arg,concat('^(.*)', functx:escape-for-regex($delim),'.*'),'$1')       else ''"/>
  </xsl:function>
  
  <!--Regularly used values throughout rules-->
  <let name="journal-title"
        value="//journal-meta/journal-title-group/journal-title"/>
  <let name="pcode" value="//journal-meta/journal-id[1]"/>
  <let name="article-type" value="article/@article-type"/>
  <let name="article-id"
        value="article/front/article-meta/article-id[@pub-id-type='publisher-id'][1]"/>
  
  <let name="volume" value="article/front/article-meta/volume"/>
  <let name="maestro-aj"
        value="if (matches($pcode,'^(nmstr|palmstr|testnatfile|testpalfile|paldelor|mtm|hortres|sdata|bdjteam|palcomms|hgv|npjbiofilms|npjschz|npjpcrm|npjamd|micronano|npjqi|npjquantmats|mto|npjsba|npjmgrav|celldisc|npjbcancer|npjparkd|npjscilearn|npjgenmed|npjcompumats|npjregenmed|bdjopen|cddiscovery|scsandc|npjpollcon|npjvaccines|sigtrans|npjmolphen|npjcleanwater|npjtracklife|npjscifood|npjmatdeg|npjclimatsci|npjflexelectron|npjprecisiononcology|npj2dmaterials|npjdepression|npjdigitalmed)$')) then 'yes'     else if ($pcode eq 'boneres' and number($volume) gt 1) then 'yes'     else if ($pcode eq 'npjnutd' and number($volume) gt 5) then 'yes'     else ()"/>
  <let name="transition"
        value="if ($journals//npg:Journal[npg:pcode=$pcode]/npg:isTransitionJournal='true') then 'yes'     else ()"/>
  <let name="maestro-rj"
        value="if (matches($pcode,'^(maestrorj|npgdelor|testnatevent|testpalevent|nplants|nrdp|nmicrobiol|nenergy|natrevmats|natastron|natbiomedeng|natecolevol|nathumbehav|natrevchem)$')) then 'yes'     else ()"/>
  <let name="maestro"
        value="if (matches($pcode,'^(testnatevent|testpalevent)$')) then 'no' else      if ($maestro-aj='yes' or $maestro-rj='yes') then 'yes' else ()"/>
  <let name="npj_journal"
        value="if (matches($pcode,'^(npjschz|npjmgrav|npjbcancer|npjparkd|npjqi|npjbiofilms|npjpcrm|npjgenmed|npjscilearn|npjregenmed|npjvaccines)$')) then 'yes' else ()"/>
   <!--for testing that all articles (@article-type="af") have a long-summary. Currently only the US/UK npj titles - check if should be all of them-->
  <let name="pubevent"
        value="if (matches($pcode,'^(bdjteam|scsandc)$')) then 'no' else      if ($journals//npg:Journal[npg:pcode=$pcode]/npg:isIssueBased='true') then 'yes'     else 'no'"/>
  <let name="existing-oa-aj"
        value="if (matches($pcode,'^(am|bcj|cddis|ctg|cti|emi|emm|lsa|msb|mtm|mtna|ncomms|nutd|oncsis|psp|scibx|srep|tp)$')) then 'yes'     else ()"/>
  <let name="new-eloc"
        value="if (ends-with($article-id,'test')) then 'none'     else if (matches($pcode,'^(bdjteam|palcomms|hgv|npjbiofilms|npjpcrm|npjschz|npjamd|micronano|npjqi|mto|nplants|npjsba|npjmgrav|celldisc|nrdp|npjbcancer|npjparkd|npjscilearn|npjgenmed|npjcompumats|npjregenmed|bdjopen|nmicrobiol|nenergy|cddiscovery|scsandc|natrevmats|npjpollcon|npjvaccines|sigtrans|npjmolphen|npjcleanwater|npjtracklife|npjscifood|npjmatdeg|npjclimatsci|npjflexelectron|npjquantmats|natastron|natbiomedeng|natecolevol|nathumbehav|natrevchem|npjprecisiononcology|npj2dmaterials|npjdepression|npjdigitalmed)$')) then 'three'     else if ($pcode eq 'boneres' and number($volume) gt 1) then 'three'     else if ($pcode eq 'mtm' and number(substring(replace($article-id,$pcode,''),1,4)) gt 2013) then 'three'     else if ($pcode eq 'sdata' and number(substring(replace($article-id,$pcode,''),1,4)) gt 2013) then 'four'     else if ($pcode eq 'npjnutd' and number($volume) gt 5) then 'three'     else ()"/>
  <let name="test-journal"
        value="if (matches($pcode,'^(nmstr|palmstr|maestrorj|testnatfile|testpalfile|paldelor|testnatevent|npgdelor|testpalevent)$')) then 'yes' else 'no'"/>
  <let name="collection"
        value="$journals//npg:Journal[npg:pcode=$pcode]/npg:hasDomain/functx:substring-after-last(@rdf:resource,'/')"/>
  <let name="full-text"
        value="if (//article/body[@specific-use='search-only']) then 'no' else 'yes'"/>
  
   <pattern>
      <rule context="article" role="error"><!--Does the article have an article-type attribute-->
         <let name="article-type"
              value="descendant::subj-group[@subj-group-type='category']/subject"/>
         <assert id="article1" test="@article-type">All articles should have an article-type attribute on "article". The value should be the same as the information contained in the "subject" element with attribute subj-group-type="category"<value-of select="if ($article-type ne '') then concat(' (',$article-type,')') else ()"/>.</assert>
      </rule>
  </pattern>
   <pattern>
      <rule context="article[@article-type]" role="error"><!--Does the article-type have a value?-->
         <report id="article2" test="$article-type = ''">"article" 'article-type' attribute should have a value and not be empty.</report>
      </rule>
  </pattern>
   <pattern>
      <rule context="article[@xml:lang]" role="error"><!--If @xml:lang exists, does it have an allowed value-->
         <let name="lang" value="@xml:lang"/>
         <assert id="article3" test="$allowed-values/languages/language[.=$lang]">Unexpected language (<value-of select="$lang"/>) declared on root article element. Expected values are "en" (English), "de" (German) and "ja" (Japanese/Kanji).</assert>
      </rule>
  </pattern>
   <pattern>
      <rule context="journal-meta" role="error"><!--Correct attribute value included-->
         <report id="jmeta1a"
                 test="count(journal-id) eq 1 and not(journal-id/@journal-id-type='publisher')">The "journal-id" element should have attribute: journal-id-type="publisher".</report>
      </rule>
  </pattern>
   <pattern>
      <rule context="journal-meta" role="error"><!--Only one journal-id included-->
         <assert id="jmeta1b" test="count(journal-id) eq 1">There should only be one "journal-id" element in Springer Nature articles, with attribute: journal-id-type="publisher".</assert>
      </rule>
  </pattern>
   <pattern>
      <rule context="journal-meta/journal-id[@journal-id-type='publisher'][.='']"
            role="error"><!--Journal id should not be empty-->
         <report id="jmeta1c" test=".">Publisher journal-id should not be empty.</report>
      </rule>
  </pattern>
   <pattern>
      <rule context="journal-meta" role="error"><!--Journal title exists-->
         <assert id="jmeta2a"
                 test="descendant::journal-title-group/journal-title and not($journal-title='')">Journal title is missing from the journal metadata section. Other rules are based on having a correct journal title and therefore will not be run. Please resubmit this file when the title has been added.</assert>
      </rule>
  </pattern>
   <pattern>
      <rule context="journal-title-group" role="error"><!--only one journal-title-group-->
         <report id="jmeta2b" test="preceding-sibling::journal-title-group">Only one journal-title-group should be used.</report>
      </rule>
  </pattern>
   <pattern>
      <rule context="journal-title-group[not($pcode='')][not($transition='yes')][not($journal-title='')]"
            role="error"><!--Is the journal title valid-->
         <assert id="jmeta3a"
                 test="not(descendant::journal-title) or $journals//npg:Journal[dc:title=$journal-title]">Journal titles must be from the prescribed list of journal names. "<value-of select="$journal-title"/>" is not on this list - check spelling, spacing of words or use of the ampersand. Other rules are based on having a correct journal title and therefore will not be run. Please resubmit this file when the title has been corrected.</assert>
      </rule>
    </pattern>
   <pattern>
      <rule context="journal-title-group[not($journal-title='')]" role="error"><!--Is the journal id valid?-->
         <assert id="jmeta3b"
                 test="$journals//npg:Journal[npg:pcode=$pcode] or not($journals//npg:Journal[dc:title=$journal-title])">Journal id is incorrect (<value-of select="$pcode"/>). For <value-of select="$journal-title"/>, it should be: <value-of select="$journals//npg:Journal[dc:title=$journal-title]/npg:pcode"/>. Other rules are based on having a correct journal id and therefore will not be run. Please resubmit this file when the journal id has been corrected.</assert>
      </rule>
    </pattern>
   <pattern>
      <rule context="journal-title-group[not($journal-title='')]" role="error"><!--Do the journal title and id match each other?-->
         <assert id="jmeta3c"
                 test="$pcode=$journals//npg:Journal[dc:title=$journal-title]/npg:pcode or not($journals//npg:Journal[dc:title=$journal-title]) or not($journals//npg:Journal[npg:pcode=$pcode])">Journal id (<value-of select="$pcode"/>) does not match journal title: <value-of select="$journal-title"/>. Check which is the correct value.</assert>
      </rule>
  </pattern>
   <pattern>
      <rule context="journal-subtitle | trans-title-group" role="error"><!--No other children of journal-title-group used-->
         <report id="jmeta4" test="parent::journal-title-group">Unexpected use of "<name/>" in "journal-title-group".</report>
      </rule>
  </pattern>
   <pattern>
      <rule context="journal-title-group/journal-title" role="error"><!--Only one journal title present-->
         <report id="jmeta4b" test="preceding-sibling::journal-title">More than one journal title found. Only one journal title should be used.</report>
      </rule>
  </pattern>
   <pattern>
      <rule context="journal-title-group/abbrev-journal-title" role="error"><!--Only one journal title present-->
         <report id="jmeta4c" test="preceding-sibling::abbrev-journal-title">More than one abbreviated journal title found. Only one abbreviated journal title should be used.</report>
      </rule>
  </pattern>
   <pattern>
      <rule context="journal-meta/issn" role="error"><!--Correct attribute value inserted; ISSN matches expected syntax-->
         <assert id="jmeta5a"
                 test="@pub-type='ppub' or @pub-type='epub' or @pub-type='supplement'">ISSN should have attribute pub-type="ppub" for print, pub-type="epub" for electronic publication, or pub-type="supplement" where an additional ISSN has been created for a supplement.</assert>
      </rule>
  </pattern>
   <pattern><!--ISSN ppub declared in XML has equivalent print issn in ontology-->
      <rule context="journal-meta/issn[@pub-type='ppub']" role="error">
         <assert id="jmeta5b1a"
                 test="not($journal-title) or not($journals//npg:Journal[dc:title=$journal-title]) or not($journals//npg:Journal[npg:pcode=$pcode]) or $journals//npg:Journal[npg:pcode=$pcode][bibo:issn]">Print ISSN given in XML, but <value-of select="$journal-title"/> is online only. Only an electronic ISSN should be given.</assert>
      </rule>
  </pattern>
   <pattern><!--Journal with print issn in ontology has ISSN ppub declared in XML-->
      <rule context="journal-meta[not($pcode='am')]" role="error">
         <assert id="jmeta5b1b"
                 test="not($journal-title) or not($journals//npg:Journal[dc:title=$journal-title]) or not($journals//npg:Journal[npg:pcode=$pcode]) or not($journals//npg:Journal[npg:pcode=$pcode][bibo:issn]) or issn[@pub-type='ppub']">
            <value-of select="$journal-title"/> should have print ISSN (<value-of select="$journals//npg:Journal[npg:pcode=$pcode]/bibo:issn"/>).</assert>
      </rule>
  </pattern>
   <pattern><!--ISSN ppub matches print issn in ontology-->
      <rule context="journal-meta/issn[@pub-type='ppub']" role="error">
         <assert id="jmeta5b2"
                 test="not($journal-title) or not($journals//npg:Journal[dc:title=$journal-title]) or not($journals//npg:Journal[npg:pcode=$pcode]) or not($journals//npg:Journal[npg:pcode=$pcode][bibo:issn]) or .=$journals//npg:Journal[npg:pcode=$pcode]/bibo:issn">Incorrect print ISSN (<value-of select="."/>) for <value-of select="$journal-title"/>. Expected value is: <value-of select="$journals//npg:Journal[npg:pcode=$pcode]/bibo:issn"/>.</assert>
      </rule>
  </pattern>
   <pattern><!--ISSN epub declared in XML has equivalent eissn in ontology-->
      <rule context="journal-meta/issn[@pub-type='epub']" role="error">
         <assert id="jmeta5c1a"
                 test="not($journal-title) or not($journals//npg:Journal[dc:title=$journal-title]) or not($journals//npg:Journal[npg:pcode=$pcode]) or $journals//npg:Journal[npg:pcode=$pcode][bibo:eissn]">Electronic ISSN given in XML, but <value-of select="$journal-title"/> is print only. Only a print ISSN should be given.</assert>
      </rule>
  </pattern>
   <pattern><!--Journal with eissn in ontology has ISSN epub declared in XML-->
      <rule context="journal-meta" role="error">
         <assert id="jmeta5c1b"
                 test="not($journal-title) or not($journals//npg:Journal[dc:title=$journal-title]) or not($journals//npg:Journal[npg:pcode=$pcode]) or not($journals//npg:Journal[npg:pcode=$pcode][bibo:eissn]) or issn[@pub-type='epub']">
            <value-of select="$journal-title"/> should have eISSN (<value-of select="$journals//npg:Journal[npg:pcode=$pcode]/bibo:eissn"/>).</assert>
      </rule>
  </pattern>
   <pattern><!--ISSN ppub matches print issn in ontology-->
      <rule context="journal-meta/issn[@pub-type='epub']" role="error">
         <assert id="jmeta5c2"
                 test="not($journal-title) or not($journals//npg:Journal[dc:title=$journal-title]) or not($journals//npg:Journal[npg:pcode=$pcode]) or not($journals//npg:Journal[npg:pcode=$pcode][bibo:eissn]) or .=$journals//npg:Journal[npg:pcode=$pcode]/bibo:eissn">Incorrect electronic ISSN (<value-of select="."/>) for <value-of select="$journal-title"/>. Expected value is: <value-of select="$journals//npg:Journal[npg:pcode=$pcode]/bibo:eissn"/>.</assert>
      </rule>
  </pattern>
   <pattern><!--Only one of each issn pub-type used-->
      <rule context="journal-meta/issn" role="error">
         <report id="jmeta5d" test="@pub-type=./preceding-sibling::issn/@pub-type">There should only be one instance of each "issn" element with "pub-type" attribute value of "<value-of select="@pub-type"/>".</report>
      </rule>
  </pattern>
   <pattern>
      <rule context="journal-meta/contrib-group | journal-meta/isbn | journal-meta/notes | journal-meta/self-uri"
            role="error"><!--Unexpected elements in journal-meta-->
         <report id="jmeta6" test=".">Do not use the "<name/>" element in "journal-meta".</report>
      </rule>
  </pattern>
   <pattern>
      <rule context="journal-meta" role="error"><!--Other expected and unexpected elements-->
         <assert id="jmeta7a" test="publisher">Journal metadata should include a "publisher" element.</assert>
      </rule>
  </pattern>
   <pattern>
      <rule context="publisher" role="error">
         <report id="jmeta7b" test="publisher-loc">Do not use "publisher-loc" element in publisher information.</report>
      </rule>
  </pattern>
   <pattern>
      <rule context="journal-title-group | journal-title | publisher">
         <report id="jmeta8a" test="@content-type">Unnecessary use of "content-type" attribute on "<name/>" element.</report>
      </rule>
  </pattern>
   <pattern>
      <rule context="article-meta[not(article-id[@pub-id-type='doi'] and article-id[@pub-id-type='publisher-id'])]"
            role="error"><!--Two article ids, one doi and one publisher-id-->
         <report id="ameta1a" test=".">Article metadata should contain at least two "article-id" elements, one with attribute pub-id-type="doi" and one with attribute pub-id-type="publisher-id".</report>
      </rule>
    </pattern>
   <pattern>
      <rule context="article-meta[not(article-categories)]" role="error">
         <report id="ameta1b" test=".">Article metadata should include an "article-categories" element.</report>
      </rule>
  </pattern>
   <pattern>
      <rule context="article-meta/article-id[@pub-id-type='publisher-id'][.=preceding-sibling::article-id[@pub-id-type='publisher-id']]"
            role="error"><!--Duplicate article id given-->
         <report id="ameta1c" test=".">A duplicate publisher article-id has been given - please delete.</report>
      </rule>
    </pattern>
   <pattern>
      <rule context="article-meta/article-id[@pub-id-type='doi'][.=preceding-sibling::article-id[@pub-id-type='doi']]"
            role="error"><!--Duplicate article id given-->
         <report id="ameta1d" test=".">A duplicate article DOI has been given - please delete.</report>
      </rule>
    </pattern>
   <pattern><!--Does article categories contain "category" information and does it match article/@article-type?-->
      <rule context="article-categories[not(subj-group[@subj-group-type='category'])]"
            role="error">
         <report id="ameta2a" test=".">Article categories should contain a "subj-group" element with attribute "subj-group-type='category'". The value of the child "subject" element should be the same as the main article-type attribute: <value-of select="$article-type"/>.</report>
      </rule>
    </pattern>
   <pattern>
      <rule context="article-categories[not($transition='yes')]/subj-group[@subj-group-type='category'][$article-type and subject][not(subject = $article-type)]"
            role="error">
         <report id="ameta2b" test=".">Subject category (<value-of select="subject"/>) does not match root article type (<value-of select="$article-type"/>)</report>
      </rule>
  </pattern>
   <pattern>
      <rule context="article-categories/subj-group[not(@subj-group-type)]">
         <report id="ameta2c" test=".">"subj-group" should have attribute 'subj-group-type' declared.</report>
      </rule>
  </pattern>
   <pattern>
      <rule context="article-categories/subj-group[@subj-group-type][not(@subj-group-type=$allowed-values/subj-group-types/subj-group-type)]">
         <report id="ameta2d" test=".">Invalid value for 'subj-group-type' attribute (<value-of select="@subj-group-type"/>). Refer to the Tagging Instructions for allowed values.</report>
      </rule>
  </pattern>
   <pattern>
      <rule context="article-categories/subj-group[@subj-group-type='article-heading']/subject[not(@content-type)]">
         <report id="ameta2e" test=".">"subject" within "subj-group" (subj-group-type="article-heading") should have a 'content-type' attribute.</report>
      </rule>
  </pattern>
   <pattern>
      <rule context="subj-group[@specific-use]">
         <report id="ameta2f" test=".">Do not 'specific-use' attribute on "subj-group".</report>
      </rule>
  </pattern>
   <pattern>
      <rule context="subj-group[@xml:lang]">
         <report id="ameta2g" test=".">Do not 'xml:lang' attribute on "subj-group".</report>
      </rule>
  </pattern>
   <pattern><!--only one of each subj-group-type used-->
      <rule context="subj-group[not(@subj-group-type='study-parameters')][@subj-group-type=./preceding-sibling::subj-group/@subj-group-type]"
            role="error">
         <report id="ameta2h" test=".">Only one "subj-group" of subj-group-type "<value-of select="@subj-group-type"/>" should appear in an article - merge these elements.</report>
      </rule>
  </pattern>
   <pattern><!--only one of each subj-group-type used-->
      <rule context="subj-group/subject[@id]" role="error">
         <report id="ameta2i" test=".">Do not use 'id' attribute on "subject".</report>
      </rule>
  </pattern>
   <pattern><!--subject codes should have @content-type="npg.subject" (for transforms to work properly) in new journals-->
      <rule context="article[$maestro='yes']//subj-group[@subj-group-type='subject']/subject[not(@content-type='npg.subject')][not(@content-type='npg.technique')]">
         <report id="subject1" test=".">In "subj-group" with attribute 'subj-group="subject"', child "subject" elements should have 'content-type="npg.subject"'.</report>
      </rule>
  </pattern>
   <pattern><!--subject codes should only contained "named-content"-->
      <rule context="subj-group[@subj-group-type='subject']/subject[@content-type='npg.subject']/*[not(self::named-content)]">
         <report id="subject2" test=".">"subject" should only contain "named-content" child elements. Do not use "<name/>".</report>
      </rule>
  </pattern>
   <pattern><!--subject codes should contain three "named-content" children-->
      <rule context="subj-group[@subj-group-type='subject']/subject[@content-type='npg.subject'][count(named-content) ne 3]">
         <report id="subject3" test=".">"subject" contains <value-of select="count(named-content)"/> "named-content" children. It should contain 3, with 'content-type' values of "id", "path" and "version".</report>
      </rule>
  </pattern>
   <pattern><!--"named-content" @content-type should be id, path or version-->
      <rule context="subj-group[@subj-group-type='subject']/subject[@content-type='npg.subject'][count(named-content) eq 3 and count(*) eq 3]/named-content[not(matches(@content-type,'^(id|path|version)$'))]">
         <report id="subject4" test=".">Unexpected value for 'content-type' in subject codes (<value-of select="@content-type"/>). Allowed values are on each of: "id", "path" and "version".</report>
      </rule>
  </pattern>
   <pattern><!--"version" included-->
      <rule context="subj-group[@subj-group-type='subject']/subject[@content-type='npg.subject'][count(named-content) eq 3 and count(*) eq 3][not(named-content[not(matches(@content-type,'^(id|path|version)$'))])][not(named-content[@content-type='version'])]">
         <report id="subject5" test=".">Missing "named-content" with 'content-type="version"' in subject codes. "subject" should contain three "named-content" children, with one of each 'content-type' attribute value: "id", "path" and "version".</report>
      </rule>
  </pattern>
   <pattern><!--"id" included-->
      <rule context="subj-group[@subj-group-type='subject']/subject[@content-type='npg.subject'][count(named-content) eq 3 and count(*) eq 3][not(named-content[not(matches(@content-type,'^(id|path|version)$'))])][not(named-content[@content-type='id'])]">
         <report id="subject6" test=".">Missing "named-content" with 'content-type="id"' in subject codes. "subject" should contain three "named-content" children, with one of each 'content-type' attribute value: "id", "path" and "version".</report>
      </rule>
  </pattern>
   <pattern><!--"path" included-->
      <rule context="subj-group[@subj-group-type='subject']/subject[@content-type='npg.subject'][count(named-content) eq 3 and count(*) eq 3][not(named-content[not(matches(@content-type,'^(id|path|version)$'))])][not(named-content[@content-type='path'])]">
         <report id="subject7" test=".">Missing "named-content" with 'content-type="path"' in subject codes. "subject" should contain three "named-content" children, with one of each 'content-type' attribute value: "id", "path" and "version".</report>
      </rule>
  </pattern>
   <pattern><!--named-content should only use @content-type-->
      <rule context="subj-group[@subj-group-type='subject']/subject[@content-type='npg.subject']/named-content[@id]">
         <report id="subject8a" test=".">Only 'content-type' should be used as an attribute on "named-content" in "subject". Do not use 'id'.</report>
      </rule>
  </pattern>
   <pattern>
      <rule context="subj-group[@subj-group-type='subject']/subject[@content-type='npg.subject']/named-content[@alt]">
         <report id="subject8b" test=".">Only 'content-type' should be used as an attribute on "named-content" in "subject". Do not use 'alt'.</report>
      </rule>
  </pattern>
   <pattern>
      <rule context="subj-group[@subj-group-type='subject']/subject[@content-type='npg.subject']/named-content[@rid]">
         <report id="subject8c" test=".">Only 'content-type' should be used as an attribute on "named-content" in "subject". Do not use 'rid'.</report>
      </rule>
  </pattern>
   <pattern>
      <rule context="subj-group[@subj-group-type='subject']/subject[@content-type='npg.subject']/named-content[@specific-use]">
         <report id="subject8d" test=".">Only 'content-type' should be used as an attribute on "named-content" in "subject". Do not use 'specific-use'.</report>
      </rule>
  </pattern>
   <pattern>
      <rule context="subj-group[@subj-group-type='subject']/subject[@content-type='npg.subject']/named-content[@xlink:actuate]">
         <report id="subject8e" test=".">Only 'content-type' should be used as an attribute on "named-content" in "subject". Do not use 'xlink:actuate'.</report>
      </rule>
  </pattern>
   <pattern>
      <rule context="subj-group[@subj-group-type='subject']/subject[@content-type='npg.subject']/named-content[@xlink:href]">
         <report id="subject8f" test=".">Only 'content-type' should be used as an attribute on "named-content" in "subject". Do not use 'xlink:href'.</report>
      </rule>
  </pattern>
   <pattern>
      <rule context="subj-group[@subj-group-type='subject']/subject[@content-type='npg.subject']/named-content[@xlink:role]">
         <report id="subject8g" test=".">Only 'content-type' should be used as an attribute on "named-content" in "subject". Do not use 'xlink:role'.</report>
      </rule>
  </pattern>
   <pattern>
      <rule context="subj-group[@subj-group-type='subject']/subject[@content-type='npg.subject']/named-content[@xlink:show]">
         <report id="subject8h" test=".">Only 'content-type' should be used as an attribute on "named-content" in "subject". Do not use 'xlink:show'.</report>
      </rule>
  </pattern>
   <pattern>
      <rule context="subj-group[@subj-group-type='subject']/subject[@content-type='npg.subject']/named-content[@xlink:title]">
         <report id="subject8i" test=".">Only 'content-type' should be used as an attribute on "named-content" in "subject". Do not use 'xlink:title'.</report>
      </rule>
  </pattern>
   <pattern>
      <rule context="subj-group[@subj-group-type='subject']/subject[@content-type='npg.subject']/named-content[@xlink:type]">
         <report id="subject8j" test=".">Only 'content-type' should be used as an attribute on "named-content" in "subject". Do not use 'xlink:type'.</report>
      </rule>
  </pattern>
   <pattern>
      <rule context="subj-group[@subj-group-type='subject']/subject[@content-type='npg.subject']/named-content[@xml:lang]">
         <report id="subject8k" test=".">Only 'content-type' should be used as an attribute on "named-content" in "subject". Do not use 'xml:lang'.</report>
      </rule>
  </pattern>
   <pattern><!--subjects should be in own subj-group-->
      <rule context="subject[@content-type='npg.subject'][parent::subj-group[not(@subj-group-type='subject')]]">
         <let name="subj-group-type" value="parent::subj-group/@subj-group-type"/>
         <report id="subject9a" test=".">Subjects should not be included in "subj-group/@subj-group-type='<value-of select="$subj-group-type"/>'". Create a separate "subj-group" with '@subj-group-type='subject'.</report>
      </rule>
  </pattern>
   <pattern><!--techniques should be in own subj-group-->
      <rule context="subject[@content-type='npg.technique'][parent::subj-group[not(@subj-group-type='technique')]]">
         <let name="subj-group-type" value="parent::subj-group/@subj-group-type"/>
         <report id="tech1a" test=".">Techniques should not be included in "subj-group/@subj-group-type='<value-of select="$subj-group-type"/>'". Create a separate "subj-group" with '@subj-group-type='technique'.</report>
      </rule>
  </pattern>
   <pattern>
      <rule context="trans-title-group[parent::title-group][not($transition='yes')]"
            role="error"><!--No unexpected children of article title-group used-->
         <report id="arttitle1a" test=".">Unexpected use of "trans-title-group" in article "title-group". "title-group" should only contain "article-title", "subtitle", "alt-title" or "fn-group".</report>
      </rule>
  </pattern>
   <pattern>
      <rule context="article-title[@id]" role="error"><!--No @id on article title-->
         <report id="arttitle2" test=".">Do not use "id" attribute on "article-title".</report>
      </rule>
  </pattern>
   <pattern>
      <rule context="title-group/article-title/styled-content[@specific-use]"
            role="error"><!--correct attributes used on styled-content element-->
         <report id="arttitle3a" test=".">Unnecessary use of "specific-use" attribute on "styled-content" element in "article-title".</report>
      </rule>
    </pattern>
   <pattern>
      <rule context="title-group/article-title/styled-content[@style]" role="error">
         <report id="arttitle3b" test=".">Unnecessary use of "style" attribute on "styled-content" element in "article-title".</report>
      </rule>
    </pattern>
   <pattern>
      <rule context="title-group/article-title/styled-content[not(@style-type='hide')]"
            role="error">
         <report id="arttitle3c" test=".">The "styled-content" element in "article-title" should have attribute "style-type='hide'". If the correct element has been used here, add the required attribute.</report>
      </rule>
  </pattern>
   <pattern><!--Rules around expected attribute values of pub-date, and only one of each type-->
      <rule context="pub-date[not(@pub-type)]" role="error">
         <report id="pubdate0a" test=".">"pub-date" element should have attribute "pub-type" declared. Allowed values are: cover-date, aop, collection, epub, epreprint, fav (final author version or author-ms) and ppub. Please check with Springer Nature.</report>
      </rule>
    </pattern>
   <pattern>
      <rule context="pub-date[@pub-type][not(@pub-type=$allowed-values/pub-types/pub-type)]"
            role="error">
         <report id="pubdate0b" test=".">Unexpected value for "pub-type" attribute on "pub-date" element (<value-of select="@pub-type"/>). Allowed values are: cover-date, aop, collection, epub, epreprint, fav (final author version or author-ms) and ppub. Please check with Springer Nature.</report>
      </rule>
  </pattern>
   <pattern>
      <rule context="pub-date[@pub-type=./preceding-sibling::pub-date/@pub-type]"
            role="error">
         <report id="pubdate0c" test=".">There should only be one instance of the "pub-date" element with "pub-type" attribute value of "<value-of select="@pub-type"/>". Please check with Springer Nature.</report>
      </rule>
  </pattern>
   <pattern><!--Valid values for year, month and day-->
      <rule context="pub-date/year[not(matches(.,'^(19|20)[0-9]{2}$'))]"
            role="error">
         <report id="pubdate1a" test=".">Invalid year value: <value-of select="."/>. It should be a 4-digit number starting with 19 or 20.</report>
      </rule>
    </pattern>
   <pattern>
      <rule context="pub-date/month[not(matches(.,'^((0[1-9])|(1[0-2]))$'))]"
            role="error">
         <report id="pubdate1b" test=".">Invalid month value: <value-of select="."/>. It should be a 2-digit number between 01 and 12.</report>
      </rule>
    </pattern>
   <pattern>
      <rule context="pub-date/day[not(matches(., '^(0[1-9]|[12][0-9]|3[01])$'))]"
            role="error">
         <report id="pubdate1c" test=".">Invalid day value: <value-of select="."/>. It should be a 2-digit number between 01 and 31.</report>
      </rule>
  </pattern>
   <pattern>
      <rule context="pub-date/season" role="error">
         <report id="pubdate1d" test=".">Do not use "season" (<value-of select="."/>). "Day" and "month" are the only other elements which should be used.</report>
      </rule>
  </pattern>
   <pattern><!--Concatenate year/month/day and check valid if those elements have already passed basic validation checks. This regex taken from http://regexlib.com, author Ted Chambron -->
      <rule context="pub-date[matches(year, '^(19|20)[0-9]{2}$') and matches(month, '^((0[1-9])|(1[0-2]))$') and matches(day, '^(0[1-9]|[12][0-9]|3[01])$')]"
            role="error">
         <assert id="pubdate2"
                 test="matches(concat(year,'-',month,'-',day), '^((((19|20)(([02468][048])|([13579][26]))-02-29))|((20[0-9][0-9])|(19[0-9][0-9]))-((((0[1-9])|(1[0-2]))-((0[1-9])|(1[0-9])|(2[0-8])))|((((0[13578])|(1[02]))-31)|(((0[1,3-9])|(1[0-2]))-(29|30)))))$')">Invalid publication date - the day value (<value-of select="day"/>) does not exist for the month (<value-of select="month"/>) in the year (<value-of select="year"/>).</assert>
      </rule>
  </pattern>
   <pattern><!--Year/Day - invalid combination in pub-date-->
      <rule context="pub-date[year and day][not(month)]" role="error">
         <report id="pubdate3" test=".">Missing month in pub-date. Currently only contains year and day.</report>
      </rule>
  </pattern>
   <pattern>
      <rule context="pub-date/day[@content-type] | pub-date/month[@content-type] | pub-date/year[@content-type]"
            role="error"><!--No content-type attribute on day, month or year-->
         <report id="pubdate4" test=".">Do not use "content-type" attribute on "<name/>" within "pub-date" element.</report>
      </rule>
  </pattern>
   <pattern>
      <rule context="article-meta/volume[not(normalize-space(.) or *)] | article-meta/issue[not(normalize-space(.) or *)] | article-meta/fpage[not(normalize-space(.) or *)] | article-meta/lpage[not(normalize-space(.) or *)]"
            role="error">
         <report id="artinfo1a" test=".">Empty "<name/>" element should not be used.</report>
      </rule>
    </pattern>
   <pattern>
      <rule context="article-meta/volume[@content-type] | article-meta/issue[@content-type] | article-meta/fpage[@content-type] | article-meta/lpage[@content-type]"
            role="error">
         <report id="artinfo1b" test=".">Do not use "content-type" attribute on "<name/>" within article metadata.</report>
      </rule>
  </pattern>
   <pattern>
      <rule context="volume[parent::article-meta] | lpage[not($pcode='pcrj')][parent::article-meta]"
            role="error">
         <let name="value" value="replace(.,'test','')"/>
         <assert id="artinfo2"
                 test="not(normalize-space($value) or *) or matches($value,'^S?[0-9]+$')">Invalid value for "<name/>" (<value-of select="."/>) - this may start with a capital S, but otherwise should only contain numerals.</assert>
      </rule>
  </pattern>
   <pattern>
      <rule context="counts[page-count][not(preceding-sibling::fpage)]"
            role="error">
         <report id="artinfo3b" test=".">As "page-count" is used, we also expect "fpage" and "lpage" elements to be used in article metadata. Please check if "page-count" should have been used.</report>
      </rule>
  </pattern>
   <pattern>
      <let name="span"
           value="//article-meta/lpage[normalize-space(.) or *][matches(.,'^[0-9]+$')] - //article-meta/fpage[normalize-space(.) or *][matches(.,'^[0-9]+$')] + 1"/>
      <rule context="counts/page-count[matches(@count,'^[0-9]+$')]">
         <assert id="artinfo4" test="@count = $span or not($span)">Incorrect value given for "page-count" attribute "count" (<value-of select="@count"/>). Expected value is: <value-of select="$span"/>.</assert>
      </rule>
  </pattern>
   <pattern>
      <rule context="fig-count | table-count | equation-count | ref-count | word-count"
            role="error">
         <report id="artinfo5" test=".">Unexpected use of "<name/>" element - please delete.</report>
      </rule>
  </pattern>
   <pattern><!--Rules around expected attribute values of date-->
      <rule context="history/date[not(@date-type)]" role="error">
         <report id="histdate0a" test=".">"date" element should have attribute "date-type" declared. Allowed values are: created, received, rev-recd (revision received), first-decision, accepted and misc. Please check with Springer Nature.</report>
      </rule>
  </pattern>
   <pattern>
      <rule context="history/date[@date-type][not(@date-type=$allowed-values/date-types/date-type)]"
            role="error">
         <report id="histdate0b" test=".">Unexpected value for "date-type" attribute on "date" element (<value-of select="@date-type"/>). Allowed values are: created, received, rev-recd (revision received), first-decision, accepted and misc. Please check with Springer Nature.</report>
      </rule>
  </pattern>
   <pattern><!--... and only one of each type-->
      <rule context="history/date[not(@date-type='rev-recd')][@date-type=./preceding-sibling::date/@date-type]"
            role="error">
         <report id="histdate0c" test=".">There should only be one instance of the "date" element with "date-type" attribute value of "<value-of select="@date-type"/>". Please check with Springer Nature.</report>
      </rule>
  </pattern>
   <pattern><!--Valid values for year, month and day-->
      <rule context="history/date/year[not(matches(., '^(19|20)[0-9]{2}$'))]"
            role="error">
         <report id="histdate1a" test=".">Invalid year value: <value-of select="."/>. It should be a 4-digit number starting with 19 or 20.</report>
      </rule>
  </pattern>
   <pattern>
      <rule context="history/date/month[not(matches(., '^((0[1-9])|(1[0-2]))$'))]"
            role="error">
         <report id="histdate1b" test=".">Invalid month value: <value-of select="."/>. It should be a 2-digit number between 01 and 12.</report>
      </rule>
  </pattern>
   <pattern>
      <rule context="history/date/day[not(matches(., '^(0[1-9]|[12][0-9]|3[01])$'))]"
            role="error">
         <report id="histdate1c" test=".">Invalid day value: <value-of select="."/>. It should be a 2-digit number between 01 and 31.</report>
      </rule>
  </pattern>
   <pattern>
      <rule context="history/date/season" role="error">
         <report id="histdate1d" test=".">Do not use "season" (<value-of select="."/>) in historical dates. "Day" and "month" are the only other elements which should be used.</report>
      </rule>
  </pattern>
   <pattern><!--Concatenate year/month/day and check valid if those elements have already passed basic validation checks. This regex taken from http://regexlib.com, author Ted Cambron-->
      <rule context="history/date[matches(year, '^(19|20)[0-9]{2}$') and matches(month, '^((0[1-9])|(1[0-2]))$') and matches(day, '^(0[1-9]|[12][0-9]|3[01])$')]"
            role="error">
         <assert id="histdate2"
                 test="matches(concat(year,'-',month,'-',day), '^((((19|20)(([02468][048])|([13579][26]))-02-29))|((20[0-9][0-9])|(19[0-9][0-9]))-((((0[1-9])|(1[0-2]))-((0[1-9])|(1[0-9])|(2[0-8])))|((((0[13578])|(1[02]))-31)|(((0[1,3-9])|(1[0-2]))-(29|30)))))$')">Invalid history date - the day value (<value-of select="day"/>) does not exist for the month (<value-of select="month"/>) in the year (<value-of select="year"/>).</assert>
      </rule>
  </pattern>
   <pattern><!--Year/Day - invalid combination in date-->
      <rule context="history/date[year and day][not(month)]" role="error">
         <report id="histdate3" test=".">Missing month in "date" element. Currently only contains year and day.</report>
      </rule>
  </pattern>
   <pattern><!--No content-type attribute on day, month or year-->
      <rule context="history//day[@content-type] | history//month[@content-type] | history//year[@content-type]"
            role="error">
         <report id="histdate4" test=".">Do not use "content-type" attribute on <name/> within "date" element.</report>
      </rule>
  </pattern>
   <pattern>
      <rule context="article-meta[not(permissions)]"><!--permissions and expected children exist-->
         <report id="copy1a" test=".">Article metadata should include a "permissions" element.</report>
      </rule>
  </pattern>
   <pattern>
      <rule context="permissions[not(copyright-year)]"><!--permissions and expected children exist-->
         <report id="copy1b" test=".">Permissions should include the copyright year.</report>
      </rule>
  </pattern>
   <pattern>
      <rule context="permissions[not(copyright-holder)]">
         <report id="copy1c" test=".">Permissions should include the copyright holder.</report>
      </rule>
  </pattern>
   <pattern>
      <rule context="permissions/copyright-holder[not(normalize-space(.) or *)]">
         <report id="copy1d" test=".">"copyright-holder" should not be empty. Please add correct information.</report>
      </rule>
  </pattern>
   <pattern>
      <rule context="permissions[$pcode='nplants']/copyright-holder[. ne 'Macmillan Publishers Limited']">
         <report id="copy1e" test=".">"copyright-holder" for Nature Plants should be "Macmillan Publishers Limited", not "<value-of select="."/>".</report>
      </rule>
    </pattern>
   <pattern>
      <rule context="permissions[count(copyright-holder) gt 1]">
         <report id="copy1f" test=".">"permissions" should only include one "copyright-holder".</report>
      </rule>
  </pattern>
   <pattern><!--Is the copyright year valid?-->
      <rule context="copyright-year[not(matches(.,'^(19|20)[0-9]{2}$'))]"
            role="error">
         <report id="copy2" test=".">Invalid year value for copyright: <value-of select="."/>. It should be a 4-digit number starting with 19 or 20.</report>
      </rule>
  </pattern>
   <pattern><!--No other elements in copyright-statement-->
      <rule context="copyright-statement/*" role="error">
         <report id="copy4" test=".">Do not use "<name/>" element in "copyright-statement" - it should only contain text.</report>
      </rule>  
  </pattern>
   <pattern><!--licence link is present-->
      <rule context="license[not(@xlink:href)][contains(license-p,'http://creativecommons.org/licenses/')]"
            role="error">
         <let name="stub"
              value="normalize-space(license-p/substring-after(.,'http://creativecommons.org/licenses/'))"/>
         <let name="standardizeStub"
              value="if (contains($stub,'/. ')) then substring-before($stub,'. ') else         if (contains($stub,') ')) then substring-before($stub,')') else         if (contains($stub,' ')) then substring-before($stub,' ') else         if (ends-with($stub,'.')) then functx:substring-before-last($stub,'.') else          if (contains($stub,'deed.en_US')) then substring-before($stub,'deed.en_US') else $stub"/>
         <let name="url"
              value="concat('http://creativecommons.org/licenses/',$standardizeStub)"/>
         <report id="license1a" test=".">"license" should have 'xlink:href' attribute containing the url declared in the license text - "<value-of select="$url"/>".</report>
      </rule>  
  </pattern>
   <pattern><!--licence type is present-->
      <rule context="license[not(@license-type)][contains(license-p,'http://creativecommons.org/licenses/')]"
            role="error">
         <let name="stub"
              value="normalize-space(license-p/substring-after(.,'http://creativecommons.org/licenses/'))"/>
         <let name="standardizeStub"
              value="if (contains($stub,'/. ')) then substring-before($stub,'. ') else         if (contains($stub,') ')) then substring-before($stub,')') else         if (contains($stub,' ')) then substring-before($stub,' ') else         if (ends-with($stub,'.')) then functx:substring-before-last($stub,'.') else          if (contains($stub,'deed.en_US')) then substring-before($stub,'deed.en_US') else $stub"/>
         <let name="typeStub"
              value="if (ends-with($standardizeStub,'/')) then functx:substring-before-last($standardizeStub,'/') else $standardizeStub"/>
         <let name="type" value="replace($typeStub,'/','-')"/>
         <report id="license1b" test=".">"license" should have 'license-type' attribute giving the license type declared in the license text - "<value-of select="$type"/>".</report>
      </rule>  
  </pattern>
   <pattern><!--licence links is correct-->
      <rule context="license[@xlink:href][contains(license-p,'http://creativecommons.org/licenses/')]"
            role="error">
         <let name="stub"
              value="normalize-space(license-p/substring-after(.,'http://creativecommons.org/licenses/'))"/>
         <let name="standardizeStub"
              value="if (contains($stub,'/. ')) then substring-before($stub,'. ') else         if (contains($stub,') ')) then substring-before($stub,')') else         if (contains($stub,' ')) then substring-before($stub,' ') else         if (ends-with($stub,'.')) then functx:substring-before-last($stub,'.') else          if (contains($stub,'deed.en_US')) then substring-before($stub,'deed.en_US') else $stub"/>
         <let name="url"
              value="concat('http://creativecommons.org/licenses/',$standardizeStub)"/>
         <assert id="license2a"
                 test="($url eq @xlink:href) or ($url eq concat(@xlink:href,'/') or (concat($url,'/') eq @xlink:href))">"license" 'xlink:href' attribute (<value-of select="@xlink:href"/>) does not match the url declared in the license text (<value-of select="$url"/>).</assert>
      </rule>  
  </pattern>
   <pattern><!--licence type is correct-->
      <rule context="license[@license-type][contains(license-p,'http://creativecommons.org/licenses/')]"
            role="error">
         <let name="stub"
              value="normalize-space(license-p/substring-after(.,'http://creativecommons.org/licenses/'))"/>
         <let name="standardizeStub"
              value="if (contains($stub,'/. ')) then substring-before($stub,'. ') else         if (contains($stub,') ')) then substring-before($stub,')') else         if (contains($stub,' ')) then substring-before($stub,' ') else         if (ends-with($stub,'.')) then functx:substring-before-last($stub,'.') else          if (contains($stub,'deed.en_US')) then substring-before($stub,'deed.en_US') else $stub"/>
         <let name="typeStub"
              value="if (ends-with($standardizeStub,'/')) then functx:substring-before-last($standardizeStub,'/') else $standardizeStub"/>
         <let name="type" value="replace($typeStub,'/','-')"/>
         <assert id="license2b" test="$type eq @license-type">"license" 'license-type' attribute (<value-of select="@license-type"/>) does not match the license type declared in the license text (<value-of select="$type"/>).</assert>
      </rule>  
  </pattern>
   <pattern><!--Related-article with a link should have @ext-link-type-->
      <rule context="article-meta/related-article[@xlink:href][not(@ext-link-type)]"
            role="error">
         <report id="relart1a" test=".">"related-article" element of type '<value-of select="@related-article-type"/>' should also have 'ext-link-type' attribute.</report>
      </rule>  
  </pattern>
   <pattern><!--Related-article should have @xlink:href-->
      <rule context="article-meta/related-article[not(@related-article-type='original-article') and @ext-link-type][not(@xlink:href)]"
            role="error">
         <report id="relart1b" test=".">"related-article" element of type '<value-of select="@related-article-type"/>' should have 'xlink:href' attribute.</report>
      </rule>  
  </pattern>
   <pattern><!--Bi directional articles should have @xlink:href and @ext-link-type-->
      <rule context="article-meta/related-article[not(@related-article-type='original-article') and not(@ext-link-type)][not(@xlink:href)]"
            role="error">
         <report id="relart1c" test=".">"related-article" element of type '<value-of select="@related-article-type"/>' should have 'xlink:href' and 'ext-link-type' attributes.</report>
      </rule>  
  </pattern>
   <pattern><!--@related-article-type has allowed value-->
      <rule context="article-meta/related-article" role="error">
         <let name="relatedArticleType" value="@related-article-type"/>
         <assert id="relart2"
                 test="$allowed-values/related-article-types/related-article-type[.=$relatedArticleType]">"related-article" element has incorrect 'related-article-type' value (<value-of select="@related-article-type"/>). Allowed values are: is-addendum-to, is-comment-to, is-correction-to, is-corrigendum-to, is-erratum-to, is-news-and-views-to, is-prime-view-to, is-protocol-to, is-protocol-update-to, is-related-to, is-research-highlight-to, is-response-to, is-retraction-to, is-update-to</assert>
      </rule>  
  </pattern>
   <pattern>
      <rule context="abstract[@abstract-type]" role="error">
         <report id="abs2a"
                 test="@abstract-type=./preceding-sibling::abstract/@abstract-type">Only one abstract of type "<value-of select="@abstract-type"/>" should appear in an article.</report>
      </rule>
  </pattern>
   <pattern>
      <rule context="abstract[not(normalize-space(.) or *)]" role="error">
         <report id="abs5a" test=".">"abstract" should not be empty. If this article does not have an abstract, please delete "abstract" tags.</report>
      </rule>
  </pattern>
   <pattern>
      <rule context="abstract[not(descendant::text())]" role="error">
         <report id="abs5b" test=".">Abstracts and editorial summaries should not be empty. Add required text, or delete "abstract" tags.</report>
      </rule>
  </pattern>
   <pattern><!--update $derived-status with all Frontiers titles if they are converted to JATS-->
      <rule context="article-meta[not($transition='yes')]" role="error">
         <let name="derived-status"
              value="if ($maestro-aj='yes' or $existing-oa-aj='yes') then 'online'         else if (pub-date[@pub-type='epub'] or pub-date[@pub-type='cover-date']) then 'issue'         else if (pub-date[@pub-type='aop']) then 'aop'         else if (pub-date[@pub-type='fav']) then 'fav'         else 'issue'"/> 
         <assert id="custom1"
                 test="not($journals//npg:Journal[npg:pcode=$pcode]) or custom-meta-group/custom-meta[meta-name='publish-type']">All articles should contain publication status information at the end of "article-metadata". Insert "custom-meta-group/custom-meta" with "meta-name". For this journal and publication status, "meta-value" should be "<value-of select="$derived-status"/>".</assert>
      </rule>
  </pattern>
   <pattern><!--update $derived-status with all Frontiers titles if they are converted to JATS-->
      <rule context="article-meta/custom-meta-group/custom-meta[meta-name='publish-type']"
            role="error">
         <let name="status" value="meta-value"/>
         <let name="derived-status"
              value="if ($maestro-aj='yes' or $existing-oa-aj='yes') then 'online'         else if ($maestro-rj='yes' and ancestor::article-meta/pub-date[@pub-type='epub']) then 'online'         else if ($maestro-rj='yes' and ancestor::article-meta/pub-date[@pub-type='aop']) then 'aop'         else if (ancestor::article-meta/pub-date[@pub-type='epub'] or ancestor::article-meta/pub-date[@pub-type='cover-date']) then 'issue'         else if (ancestor::article-meta/pub-date[@pub-type='aop']) then 'aop'         else if (ancestor::article-meta/pub-date[@pub-type='fav']) then 'fav'         else 'issue'"/>
         <assert id="custom2"
                 test="not($journals//npg:Journal[npg:pcode=$pcode]) or $status=$derived-status">Unexpected value for "publish-type" (<value-of select="$status"/>). Expected value for this journal and publication status is "<value-of select="$derived-status"/>".</assert>
      </rule>
  </pattern>
   <pattern>
      <rule context="article-meta/custom-meta-group/custom-meta[meta-name='publish-type'][1]"
            role="error">
         <report id="custom2b"
                 test="following-sibling::custom-meta[meta-name='publish-type']">'publish-type' should only be used once in "custom-meta".</report>
      </rule>
  </pattern>
   <pattern>
      <rule context="article[$maestro='yes' and $allowed-article-types/journal[@pcode=$pcode]]"
            role="error">
         <assert id="oa-aj1"
                 test="$allowed-article-types/journal[@pcode eq $pcode]/article-type[$article-type=@code]">Invalid article-type used (<value-of select="$article-type"/>). The only article types allowed in "<value-of select="$journal-title"/>" are: <value-of select="for $j in 1 to count($allowed-article-types/journal[@pcode eq $pcode]/article-type) return concat(string-join($allowed-article-types/journal[@pcode eq $pcode]/article-type[$j]/article-heading,' or '),' (',$allowed-article-types/journal[@pcode eq $pcode]/article-type[$j]/@code,'),')"/>.</assert>
      </rule>
  </pattern>
   <pattern><!--volume should be given in all new OA only journals; #not allowed in issue-based journals#-->
      <rule context="article[$maestro='yes' and $pubevent='no' and not(matches($pcode,'^(bdjteam|scsandc)$'))]/front/article-meta"
            role="error">
         <assert id="oa-aj2a" test="volume">A "volume" element should be used in "<value-of select="$journal-title"/>".</assert>
      </rule>
  </pattern>
   <pattern><!--volume should be given Nature Energy, Nature Microbiology and Nature Plants; also for 2017 Nature-branded journals-->
      <rule context="article[matches($pcode,'^(nenergy|nmicrobiol|nplants|natastron|natbiomedeng|natecolevol|nathumbehav|natrevchem)$')]/front/article-meta"
            role="error">
         <assert id="vol-npg" test="volume">A "volume" element should be used in "<value-of select="$journal-title"/>".</assert>
      </rule>
  </pattern>
   <pattern><!--expected volume value should be used in all maestro OA only journals - add mtm, mto, scsandc when needed; #not allowed in issue-based journals
  	npjpcrm (formerly pcrj) - volume 1 in 1991
  	npjnutd (formerly nutd) - volume 1 in 2011
  	boneres - volume 1 in 2013
  	hortres, sdata, hgv - volume 1 in 2014
  	nrdp, bdjopen, cddiscovery, celldisc, micronano, npjamd, npjbcancer, npjbiofilms, npjcompumats, npjmgrav, npjparkd, npjqi, npjsba, npjschz, palcomms - volume 1 in 2015
  	npjpollcon, sigtrans, npjmolphen, npjcleanwater, npjtracklife, npjscifood, npjmatdeg, npjgenmed, npjregenmed, npjvaccines, npjclimatsci, npjflexelectron, npjquantmats, npjprecisiononcology, npjdepression - volume 1 in 2016
  	natastron, natbiomedeng, natecolevol, nathumbehav, natrevchem, npj2dmaterials - volume 1 in 2017
  	-->
      <rule context="article[$maestro='yes' and $pubevent='no' and $test-journal='no' and not(matches($pcode,'^(bdjteam|mtm|mto|scsandc)$'))]/front/article-meta[pub-date/@pub-type='epub']/volume"
            role="error">
         <let name="pub_year"
              value="preceding-sibling::pub-date[@pub-type='epub']/year"/>
         <let name="expected_volume"
              value="if (matches($pcode,'^(npjpcrm)$')) then $pub_year - 1990 else         if (matches($pcode,'^(npjnutd)$')) then $pub_year - 2010 else          if (matches($pcode,'^(boneres)$')) then $pub_year - 2012 else          if (matches($pcode,'^(hortres|sdata|hgv)$')) then $pub_year - 2013 else          if (matches($pcode,'^(bdjopen|cddiscovery|celldisc|micronano|npjamd|npjbcancer|npjbiofilms|npjcompumats|npjmgrav|npjparkd|npjqi|npjsba|npjschz|palcomms|nrdp)$')) then $pub_year - 2014 else          if (matches($pcode,'^(npjpollcon|sigtrans|npjmolphen|npjcleanwater|npjtracklife|npjscifood|npjmatdeg|npjgenmed|npjvaccines|npjclimatsci|npjflexelectron|npjquantmats|npjprecisiononcology|npjregenmed|npjscilearn|npjdepression)$')) then $pub_year - 2015 else          if (matches($pcode,'^(natastron|natbiomedeng|natecolevol|nathumbehav|natrevchem|npj2dmaterials|npjdigitalmed)$')) then $pub_year - 2016 else ()"/>
         <assert id="oa-aj2a3" test=". = $expected_volume">Unexpected volume number: "<value-of select="."/>". For an "<value-of select="$journal-title"/>" article published in <value-of select="$pub_year"/>, the expected volume number is "<value-of select="$expected_volume"/>".</assert>
      </rule>
  </pattern>
   <pattern><!--issue should not be used in new OA only journals nor event-based publishing-->
      <rule context="article[$maestro='yes']/front/article-meta/issue" role="error">
         <report id="oa-aj2b" test=".">An "issue" element should not be used in "<value-of select="$journal-title"/>".</report>
      </rule>
  </pattern>
   <pattern><!--elocation-id should be given in all Maestro journals-->
      <rule context="article[$maestro='yes']/front/article-meta" role="error">
         <assert id="oa-aj2c" test="elocation-id">An "elocation-id" should be used in "<value-of select="$journal-title"/>".</assert>
      </rule>
  </pattern>
   <pattern><!--elocation-id should be numerical, i.e. does not start with 'e' or leading zeros-->
      <rule context="article[$maestro='yes']/front/article-meta/elocation-id"
            role="error">
         <assert id="oa-aj2d" test="matches(.,'^[1-9][0-9]*$')">"elocation-id" in "<value-of select="$journal-title"/>" should be a numerical value only (with no leading zeros), not "<value-of select="."/>".</assert>
      </rule>
  </pattern>
   <pattern><!--open access license info should be given in all new OA only journals (except in correction articles)-->
      <rule context="article[$maestro-aj='yes' and not(matches($article-type,'^(add|cg|cs|er|ret)$')) and not(matches($pcode,'^(bdjteam|scsandc)$'))]/front/article-meta/permissions"
            role="error">
         <assert id="oa-aj3" test="license">"<value-of select="$journal-title"/>" should contain "license", which gives details of the Open Access license being used. Please contact Springer Nature for this information.</assert>
      </rule>
  </pattern>
   <pattern><!--open access license info should not be given in BDJ Team, which is free. If this applies to other journals start a new variable $free rather than hard-coding pcodes here-->
      <rule context="article[$pcode='bdjteam']/front/article-meta/permissions/license"
            role="error">
         <report id="oa-aj3c" test=".">"license" should not be used in <value-of select="$journal-title"/>, as it is a free journal.</report>
      </rule>
  </pattern>
   <pattern><!--error in pcode, but numerical value ok-->
      <rule context="article[$maestro='yes']//article-meta/article-id[@pub-id-type='publisher-id']"
            role="error">
         <let name="derivedPcode" value="tokenize(.,'[0-9][0-9]')[1]"/>
         <let name="numericValue" value="replace(.,$derivedPcode,'')"/>
         <report id="oa-aj4a2"
                 test="not($pcode=$derivedPcode) and ($derivedPcode ne '' and matches($numericValue,'^20[1-9][0-9][1-9][0-9]*$'))">Article id (<value-of select="."/>) should start with the pcode/journal-id (<value-of select="$pcode"/>) not "<value-of select="$derivedPcode"/>". Other rules are based on having a correct article id and therefore will not be run. Please resubmit this file when the article id has been corrected.</report>
      </rule>
  </pattern>
   <pattern><!--pcode ok but error in numerical value-->
      <rule context="article[$maestro='yes' and not(ends-with($article-id,'test'))]//article-meta/article-id[@pub-id-type='publisher-id']"
            role="error">
         <let name="derivedPcode" value="tokenize(.,'[0-9][0-9]')[1]"/>
         <let name="numericValue" value="replace(.,$derivedPcode,'')"/>
         <report id="oa-aj4a3"
                 test="not(matches($numericValue,'^20[1-9][0-9][1-9][0-9]*$')) and ($derivedPcode ne '' and $pcode=$derivedPcode)">Article id after the "<value-of select="$pcode"/>" pcode (<value-of select="$numericValue"/>) should have format year + number of article (without additional letters or leading zeros). Other rules are based on having a correct article id and therefore will not be run. Please resubmit this file when the article id has been corrected.</report>
      </rule>
  </pattern>
   <pattern><!--errors in pcode and numerical value-->
      <rule context="article[$maestro='yes']//article-meta/article-id[@pub-id-type='publisher-id']"
            role="error">
         <let name="derivedPcode" value="tokenize(.,'[0-9][0-9]')[1]"/>
         <let name="numericValue" value="replace(.,$derivedPcode,'')"/>
         <report id="oa-aj4a4"
                 test="$derivedPcode ne '' and not($pcode=$derivedPcode) and not(matches($numericValue,'^20[1-9][0-9][1-9][0-9]*$'))">Article id (<value-of select="."/>) should have format pcode + year + number of article (without additional letters or leading zeros). Other rules are based on having a correct article id and therefore will not be run. Please resubmit this file when the article id has been corrected.</report>
      </rule>
  </pattern>
   <pattern><!--Does doi match article-id? # check formatting of nplants DOIs #-->
      <rule context="article[$maestro='yes']//article-meta/article-id[@pub-id-type='doi']"
            role="error">
      <!--let name="filename" value="functx:substring-after-last(functx:substring-before-last(base-uri(.),'.'),'/')"/--><!--or not($article-id=$filename)-->
         <let name="derivedPcode" value="tokenize($article-id,'[0-9][0-9]')[1]"/>
         <let name="numericValue" value="replace($article-id,$derivedPcode,'')"/>
         <let name="baseDOI"
              value="if ($collection='nature') then '10.1038/' else if ($collection='palgrave') then '10.1057/' else ()"/>
         <let name="derivedDoi"
              value="concat($baseDOI,$derivedPcode,'.',substring($numericValue,1,4),'.',substring($numericValue,5))"/>
         <assert id="oa-aj5"
                 test=".=$derivedDoi or not($derivedPcode ne '' and $pcode=$derivedPcode and matches($numericValue,'^20[1-9][0-9][1-9][0-9]*$'))">Article DOI (<value-of select="."/>) does not match the expected value based on the article id (<value-of select="$derivedDoi"/>).</assert>
      </rule>
  </pattern>
   <pattern><!--valid @abstract-type-->
      <rule context="abstract[@abstract-type]" role="error">
         <assert id="oa-aj-abs1a"
                 test="matches(@abstract-type,'^(standfirst|long-summary|short-summary|key-points)$')">Unexpected value for "abstract-type" attribute (<value-of select="@abstract-type"/>). Allowed values are: standfirst, long-summary, short-summary and key-points.</assert>
      </rule>
  </pattern>
   <pattern><!--no subsections in editorial summaries-->
      <rule context="abstract[@abstract-type][sec]" role="error">
         <report id="oa-aj-abs1b" test=".">Do not use sections in editorial summaries (<value-of select="@abstract-type"/>) - please contact Springer Nature.</report>
      </rule>
  </pattern>
   <pattern><!--standfirst - no title-->
      <rule context="abstract[@abstract-type='standfirst'][title]" role="error">
         <report id="oa-aj-abs1c" test=".">Do not use "title" in standfirsts - please contact Springer Nature.</report>
      </rule>
  </pattern>
   <pattern><!--standfirst - no images-->
      <rule context="abstract[@abstract-type='standfirst'][descendant::xref[@ref-type='other'][@rid=ancestor::article//graphic[@content-type='illustration']/@id]]"
            role="error">
         <report id="oa-aj-abs1d" test=".">Do not use images in standfirsts - please contact Springer Nature.</report>
      </rule>
  </pattern>
   <pattern><!--standfirst - one paragraph-->
      <rule context="abstract[@abstract-type='standfirst'][count(p) gt 1]"
            role="error">
         <report id="oa-aj-abs1e" test=".">Standfirsts should only contain one paragraph - please contact Springer Nature.</report>
      </rule>
  </pattern>
   <pattern><!--only one true abstract used; there is a general rule to test for more than one of the same @abstract-type-->
      <rule context="abstract[not(@xml:lang)][not(@abstract-type)][preceding-sibling::abstract[not(@abstract-type)]]"
            role="error">
         <report id="oa-aj-abs2a" test=".">Only one true abstract should appear in an article.</report>
      </rule>
  </pattern>
   <pattern>
      <rule context="article[$maestro='yes']//fig[not(@specific-use='suppinfo')]//graphic[@xlink:href][not(@xlink:href='')]"
            role="error">
      <!--let name="filename" value="functx:substring-after-last(functx:substring-before-last(base-uri(.),'.'),'/')"/--><!--or not($article-id=$filename)--> 
         <let name="derivedPcode" value="tokenize($article-id,'[0-9][0-9]')[1]"/>
         <let name="numericValue" value="replace($article-id,$derivedPcode,'')"/>
         <let name="fig-image" value="substring-before(@xlink:href,'.')"/>
         <let name="fig-number"
              value="replace(replace($fig-image,$article-id,''),'-','')"/>
         <assert id="oa-aj6a"
                 test="starts-with($fig-image,concat($article-id,'-')) and matches($fig-number,'^f[1-9][0-9]*[a-z]?$') or not($derivedPcode ne '' and $pcode=$derivedPcode and matches($numericValue,'^20[1-9][0-9][1-9][0-9]*$'))">Unexpected filename for figure image (<value-of select="$fig-image"/>). Expected format is "<value-of select="concat($article-id,'-f')"/>"+number (and following letters, if figure has multiple images).</assert>
      </rule>
  </pattern>
   <pattern>
      <rule context="article[$maestro='yes']//fig[not(@specific-use='suppinfo')]//supplementary-material[@content-type='slide'][@xlink:href]"
            role="error">
      <!--let name="filename" value="functx:substring-after-last(functx:substring-before-last(base-uri(.),'.'),'/')"/--><!--or not($article-id=$filename)--> 
         <let name="derivedPcode" value="tokenize($article-id,'[0-9][0-9]')[1]"/>
         <let name="numericValue" value="replace($article-id,$derivedPcode,'')"/>
         <let name="fig-image" value="substring-before(@xlink:href,'.')"/>
         <let name="fig-number"
              value="replace(replace($fig-image,$article-id,''),'-','')"/>
         <assert id="oa-aj6b"
                 test="starts-with($fig-image,concat($article-id,'-')) and matches($fig-number,'^pf[1-9][0-9]*[a-z]?$') or not($derivedPcode ne '' and $pcode=$derivedPcode and matches($numericValue,'^20[1-9][0-9][1-9][0-9]*$'))">Unexpected filename for figure slide (<value-of select="$fig-image"/>). Expected format is "<value-of select="concat($article-id,'-pf')"/>"+number (and following letters, if figure has multiple slides).</assert>
      </rule>
  </pattern>
   <pattern>
      <rule context="article[$maestro-rj='yes']//fig[@specific-use='suppinfo']//graphic[@xlink:href]"
            role="error">
         <let name="derivedPcode" value="tokenize($article-id,'[0-9][0-9]')[1]"/>
         <let name="numericValue" value="replace($article-id,$derivedPcode,'')"/>
         <let name="fig-image" value="substring-before(@xlink:href,'.')"/>
         <let name="fig-number"
              value="replace(replace($fig-image,$article-id,''),'-','')"/>
         <assert id="oa-aj6c"
                 test="starts-with($fig-image,concat($article-id,'-')) and matches($fig-number,'^sf[1-9][0-9]*[a-z]?$') or not($derivedPcode ne '' and $pcode=$derivedPcode and matches($numericValue,'^20[1-9][0-9][1-9][0-9]*$'))">Unexpected filename for supplementary figure image (<value-of select="$fig-image"/>). Expected format is "<value-of select="concat($article-id,'-sf')"/>"+number (and following letters, if figure has multiple images).</assert>
      </rule>
  </pattern>
   <pattern>
      <rule context="article[$maestro='yes']//table-wrap//graphic[@xlink:href]"
            role="error">
      <!--let name="filename" value="functx:substring-after-last(functx:substring-before-last(base-uri(.),'.'),'/')"/--><!--or not($article-id=$filename)--> 
         <let name="derivedPcode" value="tokenize($article-id,'[0-9][0-9]')[1]"/>
         <let name="numericValue" value="replace($article-id,$derivedPcode,'')"/>
         <let name="tab-image" value="substring-before(@xlink:href,'.')"/>
         <let name="tab-number"
              value="replace(replace($tab-image,$article-id,''),'-','')"/>
         <assert id="oa-aj7a"
                 test="starts-with($tab-image,concat($article-id,'-')) and matches($tab-number,'^t[1-9][0-9]*?$') or not($derivedPcode ne '' and $pcode=$derivedPcode and matches($numericValue,'^20[1-9][0-9][1-9][0-9]*$'))">Unexpected filename for table image (<value-of select="$tab-image"/>). Expected format is "<value-of select="concat($article-id,'-t')"/>"+number.</assert>
      </rule>
  </pattern>
   <pattern>
      <rule context="article[$maestro='yes']//table-wrap//supplementary-material[@content-type='slide'][@xlink:href]"
            role="error">
      <!--let name="filename" value="functx:substring-after-last(functx:substring-before-last(base-uri(.),'.'),'/')"/--><!--or not($article-id=$filename)--> 
         <let name="derivedPcode" value="tokenize($article-id,'[0-9][0-9]')[1]"/>
         <let name="numericValue" value="replace($article-id,$derivedPcode,'')"/>
         <let name="tab-image" value="substring-before(@xlink:href,'.')"/>
         <let name="tab-number"
              value="replace(replace($tab-image,$article-id,''),'-','')"/>
         <assert id="oa-aj7b"
                 test="starts-with($tab-image,concat($article-id,'-')) and matches($tab-number,'^pt[1-9][0-9]*?$') or not($derivedPcode ne '' and $pcode=$derivedPcode and matches($numericValue,'^20[1-9][0-9][1-9][0-9]*$'))">Unexpected filename for table slide (<value-of select="$tab-image"/>). Expected format is "<value-of select="concat($article-id,'-pt')"/>"+number.</assert>
      </rule>
  </pattern>
   <pattern>
      <rule context="article[$maestro='yes']//floats-group/graphic[@content-type='illustration'][contains(@xlink:href,'.')][not(@id=ancestor::article//abstract[@abstract-type]//xref[@ref-type='other']/@rid)]"
            role="error">
      <!--let name="filename" value="functx:substring-after-last(functx:substring-before-last(base-uri(.),'.'),'/')"/--><!--or not($article-id=$filename)--> 
         <let name="derivedPcode" value="tokenize($article-id,'[0-9][0-9]')[1]"/>
         <let name="numericValue" value="replace($article-id,$derivedPcode,'')"/>
         <let name="ill-image" value="substring-before(@xlink:href,'.')"/>
         <let name="ill-number"
              value="replace(replace($ill-image,$article-id,''),'-','')"/>
         <assert id="oa-aj8"
                 test="starts-with($ill-image,concat($article-id,'-')) and matches($ill-number,'^i[1-9][0-9]*?$') or not($derivedPcode ne '' and $pcode=$derivedPcode and matches($numericValue,'^20[1-9][0-9][1-9][0-9]*$'))">Unexpected filename for illustration (<value-of select="$ill-image"/>). Expected format is "<value-of select="concat($article-id,'-i')"/>"+number.</assert>
      </rule>
  </pattern>
   <pattern><!--graphical abstract filename-->
      <rule context="article[$maestro='yes']//floats-group/graphic[@content-type='toc-image'][contains(@xlink:href,'.')]"
            role="error">
         <let name="derivedPcode" value="tokenize($article-id,'[0-9][0-9]')[1]"/>
         <let name="numericValue" value="replace($article-id,$derivedPcode,'')"/>
         <let name="ill-image" value="substring-before(@xlink:href,'.')"/>
         <let name="graphab" value="concat($article-id,'-toc')"/>
         <assert id="oa-aj8b"
                 test="($ill-image eq $graphab) or not($derivedPcode ne '' and $pcode=$derivedPcode and matches($numericValue,'^20[1-9][0-9][1-9][0-9]*$'))">Unexpected filename for graphical abstract (<value-of select="$ill-image"/>). Expected format is "<value-of select="concat($article-id,'-toc')"/>".</assert>
      </rule>
  </pattern>
   <pattern>
      <rule context="article[$maestro='yes']//floats-group/supplementary-material[@xlink:href][matches(@id,'^s[0-9]+$')][not(@content-type='isa-tab')]"
            role="error">
      <!--let name="filename" value="functx:substring-after-last(functx:substring-before-last(base-uri(.),'.'),'/')"/--><!--or not($article-id=$filename)--> 
         <let name="derivedPcode" value="tokenize($article-id,'[0-9][0-9]')[1]"/>
         <let name="numericValue" value="replace($article-id,$derivedPcode,'')"/>
         <let name="supp-image" value="substring-before(@xlink:href,'.')"/>
         <let name="supp-number"
              value="replace(replace($supp-image,$article-id,''),'-','')"/>
         <let name="supp-id" value="@id"/>
         <let name="extension" value="functx:substring-after-last(@xlink:href,'.')"/>
         <assert id="oa-aj9"
                 test="not(matches($extension,'^(eps|gif|jpg|jpeg|bmp|png|pict|ps|tiff|wmf|doc|docx|pdf|pps|ppt|pptx|xls|xlsx|tar|tgz|zip|c|csv|htm|html|rtf|txt|xml|aiff|au|avi|midi|mov|mp2|mp3|mp4|mpa|mpg|noa|qt|ra|ram|rv|swf|wav|wmv|cif|exe|pdb|sdf|sif)$')) or starts-with($supp-image,concat($article-id,'-')) and matches($supp-number,$supp-id) or not($derivedPcode ne '' and $pcode=$derivedPcode and matches($numericValue,'^20[1-9][0-9][1-9][0-9]*$'))">Unexpected filename for supplementary information (<value-of select="@xlink:href"/>). Expected format is "<value-of select="concat($article-id,'-',$supp-id,'.',$extension)"/>", i.e. XML filename + dash + id of supplementary material.</assert>
      </rule>
  </pattern>
   <pattern>
      <rule context="article[$pcode='sdata']//floats-group/supplementary-material[@xlink:href][@content-type='isa-tab']"
            role="error">
      <!--let name="filename" value="functx:substring-after-last(functx:substring-before-last(base-uri(.),'.'),'/')"/--><!--or not($article-id=$filename)--> 
         <let name="derivedPcode" value="tokenize($article-id,'[0-9][0-9]')[1]"/>
         <let name="numericValue" value="replace($article-id,$derivedPcode,'')"/>
         <let name="supp-image" value="substring-before(@xlink:href,'.')"/>
         <let name="supp-number"
              value="replace(replace($supp-image,$article-id,''),'-','')"/>
         <assert id="oa-aj9b"
                 test="starts-with($supp-image,concat($article-id,'-')) and matches($supp-number,'^isa1') or not($derivedPcode ne '' and $pcode=$derivedPcode and matches($numericValue,'^20[1-9][0-9][1-9][0-9]*$'))">Unexpected filename for ISA-tab file (<value-of select="$supp-image"/>). It does not follow the same numbering as other supplementary information files. Expected value is "<value-of select="concat($article-id,'-isa1')"/>".</assert>
      </rule>
  </pattern>
   <pattern><!--id should be final value in subject path-->
      <rule context="article[($maestro='yes' or $transition='yes') and $test-journal='no']//subject[@content-type='npg.subject'][named-content[@content-type='id']]">
         <let name="path" value="named-content[@content-type='path'][1]"/>
         <let name="id" value="named-content[@content-type='id']"/>
         <let name="derivedId" value="functx:substring-after-last($path,'/')"/>
         <assert id="oa-aj10c"
                 test="$id=$derivedId or not($journals//npg:Journal[npg:pcode=$pcode]/npg:subjectPath[.=$path]) or not($journals//npg:subjectPath[.=$path])">Subject 'id' (<value-of select="$id"/>) does not match the final part of subject 'path' (<value-of select="$derivedId"/>). Please check the information supplied by Springer Nature.</assert>
      </rule>
  </pattern>
   <pattern><!--article-type and article heading should be equivalent-->
      <rule context="article[$maestro='yes' and $allowed-article-types/journal[@pcode=$pcode]/article-type[$article-type=@code]]/front/article-meta//subject[@content-type='article-heading']"
            role="error">
         <let name="article-heading"
              value="replace(string-join($allowed-article-types/journal[@pcode eq $pcode]/article-type[@code=$article-type]/article-heading,' or '),'\W\([a-z]+\)','')"/>
         <assert id="oa-aj11a" test=".=tokenize($article-heading,' or ')">Mismatch between article-heading (<value-of select="."/>) and expected value based on article-type "<value-of select="$article-type"/>" (<value-of select="$article-heading"/>).</assert>
      </rule>
  </pattern>
   <pattern><!--article-heading should be used-->
      <rule context="article[$transition='yes']/front/article-meta/article-categories[not(subj-group/@subj-group-type='article-heading')]"
            role="error">
         <report id="transition1" test=".">Article categories should contain a "subj-group" element with attribute "subj-group-type='article-heading'".</report>
      </rule>
  </pattern>
   <pattern><!--article-heading should be used-->
      <rule context="article[$maestro='yes' and $allowed-article-types/journal[@pcode=$pcode]/article-type[$article-type=@code]]/front/article-meta/article-categories"
            role="error">
         <let name="article-heading"
              value="replace(string-join($allowed-article-types/journal[@pcode eq $pcode]/article-type[@code=$article-type]/article-heading,' or '),'\W\([a-z]+\)','')"/>
         <assert id="oa-aj11c" test="subj-group/@subj-group-type='article-heading'">Article categories should contain a "subj-group" element with attribute "subj-group-type='article-heading'". The value of the child "subject" element (with attribute "content-type='article-heading'") should be: <value-of select="$article-heading"/>.</assert>
      </rule>
  </pattern>
   <pattern><!--authors should link to their affiliated body, even when there is only one aff-->
      <rule context="article[$maestro='yes']/front/article-meta[aff]/contrib-group//contrib[@contrib-type='author'][not(ancestor::collab[@collab-type='authors'])]"
            role="error">
         <assert id="oa-aj12" test="xref[@ref-type='aff']">All authors should be linked to an affiliated body. Insert xref with 'ref-type="aff"'.</assert>
      </rule>
  </pattern>
   <pattern><!--pub-date should have @pub-type="epub"-->
      <rule context="article[$maestro-aj='yes']/front/article-meta/pub-date"
            role="error">
         <assert id="oa-aj13a" test="@pub-type='epub'">Online-only open access journals should have publication date with the 'pub-type' attribute value "epub", not "<value-of select="@pub-type"/>". </assert>
      </rule>
  </pattern>
   <pattern><!--pub-date should have day element-->
      <rule context="article[$maestro='yes']/front/article-meta/pub-date[matches(@pub-type,'^(epub|aop)$')]"
            role="error">
         <assert id="oa-aj13b" test="day">Online-only journals should have a full publication date - "day" is missing.</assert>
      </rule>
  </pattern>
   <pattern><!--Only one author email per corresp element-->
      <rule context="corresp[count(email) gt 1][$maestro='yes']" role="error">
         <report id="maestro1" test=".">Corresponding author information should only contain one email address. Please split "corresp" with id='<value-of select="@id"/>' into separate "corresp" elements - one for each corresponding author. You will also need to update the equivalent "xref" elements with the new 'rid' values.</report>
      </rule>
  </pattern>
   <pattern><!--Do not include the word 'correspondence' in the corresp element-->
      <rule context="corresp[$maestro='yes']" role="error">
         <report id="aj-corresp1"
                 test="starts-with(.,'correspondence') or starts-with(.,'Correspondence') or starts-with(.,'CORRESPONDENCE')">Do not include the unnecessary text 'Correspondence' in the "corresp" element.</report>
      </rule>
  </pattern>
   <pattern><!--no empty xrefs for ref-types="author-notes"-->
      <rule context="xref[@ref-type='author-notes'][$maestro-aj='yes' and not($pcode='sdata')]"
            role="error">
         <assert id="aj-aunote1a" test="normalize-space(.) or *">"xref" with ref-type="author-notes" and rid="<value-of select="@rid"/>" should contain text. Please see Tagging Instructions for further examples.</assert>
      </rule>
  </pattern>
   <pattern>
      <rule context="author-notes/fn[not(@fn-type)][@id][$maestro-aj='yes' and not($pcode='sdata')]"
            role="error">
         <let name="id" value="@id"/>
         <let name="symbol"
              value="(ancestor::article//xref[matches(@rid,$id)])[1]//text()"/>
         <assert id="aj-aunote1b" test="label">Missing "label" element in author footnote - please insert one containing the same text as the corresponding "xref" element<value-of select="if ($symbol ne '') then concat(' (',$symbol,')') else ()"/>.</assert>
      </rule>
  </pattern>
   <pattern><!--Current address and death notices should not be in "aff"-->
      <rule context="aff[$maestro='yes'][contains(.,'address')]" role="error">
         <report id="aj-aunote2a" test=".">Do not use "aff" for current address information - use author notes instead. Refer to Tagging Instructions.</report>
      </rule>
  </pattern>
   <pattern>
      <rule context="aff[$maestro='yes'][contains(.,'Deceased')]" role="error">
         <report id="aj-aunote2b" test=".">Do not use "aff" for deceased information - use author notes instead. Refer to Tagging Instructions.</report>
      </rule>
  </pattern>
   <pattern><!--correction articles should contain a related-article element-->
      <rule context="article[($maestro='yes' or $transition='yes') and matches($article-type,'^(add|cg|cs|er|ret)$')]/front/article-meta[not(article-categories/subj-group/subject[@content-type='article-heading']/.='Case Study')]"
            role="error">
         <let name="article-heading"
              value="if ($article-type='add') then 'Addendum articles'          else if ($article-type='cg') then 'Corrigendum articles'          else if ($article-type='cs') then 'Correction articles'          else if ($article-type='er') then 'Erratum articles'          else if ($article-type='ret') then 'Retraction articles' else ()"/>
         <let name="related-article-type"
              value="if ($article-type='add') then 'is-addendum-to'          else if ($article-type='cg') then 'is-corrigendum-to'          else if ($article-type='cs') then 'is-correction-to'          else if ($article-type='er') then 'is-erratum-to'          else if ($article-type='ret') then 'is-retraction-to' else ()"/>
         <assert id="correct1a" test="related-article">
            <value-of select="$article-heading"/> should have a "related-article" element giving information on the article being corrected (following the "permissions" element). It should have 'related-article-type="<value-of select="$related-article-type"/>"', 'ext-link-type="doi"' and an 'xlink:href' giving the full doi of the corrected article.</assert>
      </rule>
  </pattern>
   <pattern><!--check correction articles have matching @related-article-type and @article-type values-->
      <rule context="article[($maestro='yes' or $transition='yes') and matches($article-type,'^(add|cg|cs|er|ret)$')]/front/article-meta/related-article"
            role="error">
         <let name="related-article-type"
              value="if ($article-type='add') then 'is-addendum-to'          else if ($article-type='cg') then 'is-corrigendum-to'          else if ($article-type='cs') then 'is-correction-to'          else if ($article-type='er') then 'is-erratum-to'          else if ($article-type='ret') then 'is-retraction-to' else ()"/>
         <assert id="correct1b" test="@related-article-type=$related-article-type">Mismatch between 'related-article-type' attribute (<value-of select="@related-article-type"/>) and expected value based on article-type (<value-of select="$related-article-type"/>).</assert>
      </rule>
  </pattern>
   <pattern><!--elocation-id follows expected format (three-digit article number)-->
      <rule context="article[$new-eloc='three']/front/article-meta/elocation-id"
            role="error">
         <let name="year" value="substring(replace($article-id,$pcode,''),1,4)"/>
         <let name="artnum" value="replace(replace($article-id,$pcode,''),$year,'')"/>
         <let name="fullartnum"
              value="if (string-length($artnum)=1) then concat('00',$artnum) else          if (string-length($artnum)=2) then concat('0',$artnum) else $artnum"/>
         <let name="eloc" value="concat(substring($year,3,4),$fullartnum)"/>
         <assert id="oa-eloc1a" test=".=$eloc">Mismatch between elocation-id/article number (<value-of select="."/>) and expected value based on article id: <value-of select="$eloc"/>.</assert>
      </rule>
  </pattern>
   <pattern><!--elocation-id follows expected format (four-digit article number-->
      <rule context="article[$new-eloc='four']/front/article-meta/elocation-id"
            role="error">
         <let name="year" value="substring(replace($article-id,$pcode,''),1,4)"/>
         <let name="artnum" value="replace(replace($article-id,$pcode,''),$year,'')"/>
         <let name="fullartnum"
              value="if (string-length($artnum)=1) then concat('000',$artnum) else          if (string-length($artnum)=2) then concat('00',$artnum) else          if (string-length($artnum)=3) then concat('0',$artnum) else $artnum"/>
         <let name="eloc" value="concat(substring($year,3,4),$fullartnum)"/>
         <assert id="oa-eloc1b" test=".=$eloc">Mismatch between elocation-id/article number (<value-of select="."/>) and expected value based on article id: <value-of select="$eloc"/>.</assert>
      </rule>
  </pattern>
   <pattern><!--monospace should not be used-->
      <rule context="article[$maestro='yes']//monospace" role="error">
         <report id="style2d" test=".">Do not use "monospace", as this will not render correctly. Please change to "preformat" with 'preformat-type="inline"'.</report>
      </rule>
  </pattern>
   <pattern><!--suppinfo should not be tif in maestro titles - use tiff instead-->
      <rule context="floats-group[$maestro='yes']/supplementary-material[not(@content-type='external-media')][contains(@xlink:href,'.') and not(contains(@xlink:href,'.doi.'))]"
            role="error">
         <let name="extension" value="functx:substring-after-last(@xlink:href,'.')"/>
         <report id="maestro-tif" test="$extension = 'tif'">Do not use 'tif' files for supplementary material. Please change file extension to 'tiff' on the asset, in the article XML and in the manifest file.</report>
      </rule>
  </pattern>
   <pattern><!--ext-link should be used instead of uri-->
      <rule context="uri" role="error">
         <report id="uri1" test=".">Do not use "uri" for links to websites. Please change to "ext-link" with attributes 'ext-link-type="url"' and 'xlink:href' containing the full address.</report>
      </rule>
  </pattern>
   <pattern><!--npj 'af' articles should have an editorial summary-->
      <rule context="article[@article-type='af']/front/article-meta[$npj_journal='yes'][not(abstract[@abstract-type='long-summary'])]"
            role="error">
         <report id="npj1a" test=".">All Articles (article-type "af") in "<value-of select="$journal-title"/>" should have an editorial summary (abstract with 'abstract-type="long-summary"'). If you have not been provided with the text for this summary, please contact Springer Nature Production.</report>
      </rule>
  </pattern>
   <pattern><!--"is-data-descriptor-to should be added by sync tool-->
      <rule context="article[$pcode='sdata'][$article-type='dd'][not(descendant::subj-group[@subj-group-type='study-parameters'])]//related-article[@related-article-type='is-data-descriptor-to']"
            role="error">
         <report id="sdata1b" test=".">"related-article" with 'related-article-type' of "is-data-descriptor-to" should be added by the SciData synch tool. It does not need to be included as part of the typesetting process - please delete.</report>
      </rule>
  </pattern>
   <pattern><!--only one element-citation in ref-->
      <rule context="ref-list[@content-type='data-citations']/ref[@id]/element-citation[1][following-sibling::element-citation]"
            role="error">
         <report id="sdata2a" test=".">Error in data citation <value-of select="parent::ref/@id"/>: data citation references should only contain one child "element-citation". Please refer to the Tagging Instructions.</report>
      </rule>
  </pattern>
   <pattern><!--should be element-citation not mixed-citation-->
      <rule context="ref-list[@content-type='data-citations']/ref[@id]/mixed-citation"
            role="error">
         <report id="sdata2b" test=".">Error in data citation <value-of select="parent::ref/@id"/>: data citation references should use "element-citation", not "mixed-citation". Please refer to the Tagging Instructions.</report>
      </rule>
  </pattern>
   <pattern><!--named-content for source info is not required in sdata-->
      <rule context="ref-list[@content-type='data-citations'][$pcode='sdata']/ref[@id]//named-content[@content-type='source']"
            role="error">
         <report id="sdata2c" test=".">Error in data citation <value-of select="ancestor::ref/@id"/>: data citation references in Scientific Data do not need the source status (new/existing) declared, as this information will not be supplied by Springer Nature. Please delete the "named-content" element.</report>
      </rule>
  </pattern>
   <pattern><!--year should be included-->
      <rule context="ref-list[@content-type='data-citations']/ref[@id][not(descendant::year)]"
            role="error">
         <report id="sdata2d" test=".">Error in data citation <value-of select="@id"/>: the "year" should be marked up in data citations. Please refer to the Tagging Instructions.</report>
      </rule>
  </pattern>
   <pattern><!--separate contrib elements for each data citation contributor-->
      <rule context="ref-list[@content-type='data-citations']/ref//contrib[count(name) gt 1]"
            role="error">
         <let name="id" value="ancestor::ref/@id"/>
         <report id="sdata3a" test=".">Multiple names given in one "contrib" in data citation <value-of select="$id"/>: use a separate "contrib" element for each contributor. Please refer to the Tagging Instructions.</report>
      </rule>
  </pattern>
   <pattern>
      <rule context="related-article[@related-article-type='is-data-descriptor-to'][not($article-type='dd')]"
            role="error">
         <report id="sdata5" test=".">related-article-type="is-data-descriptor-to" should only be used for Data Descriptor articles. Please use the correct relationship for this type of article.</report>
      </rule>
  </pattern>
   <pattern>
      <rule context="contrib-group[not(@content-type='contributor')]/contrib/xref"
            role="error"><!--Contrib xref should have @ref-type-->
         <assert id="contrib1a" test="@ref-type">Contributor "xref" should have a 'ref-type' attribute. The allowed values are "aff" (for links to affilation information), "corresp" (for correspondence information) and "author-notes" for any other notes.</assert>
      </rule>
  </pattern>
   <pattern>
      <rule context="contrib/xref" role="error"><!--Contrib xref should have @rid-->
         <assert id="contrib1b" test="@rid">Contributor "xref" should have an 'rid' attribute.</assert>
      </rule>
  </pattern>
   <pattern>
      <rule context="contrib[not($article-type='qa')]/xref[@ref-type]" role="error"><!--Contrib xref ref-type should have allowed value-->
        <assert id="contrib1c"
                 test="matches(@ref-type,'^(aff|corresp|author-notes|statement)$')">Unexpected value for contributor "xref" 'ref-type' attribute (<value-of select="@ref-type"/>). The allowed values are "aff" (for links to affilation information), "corresp" (for correspondence information) and "author-notes" for any other notes.</assert>
      </rule>
    </pattern>
   <pattern>
      <rule context="contrib[$article-type='qa']/xref[@ref-type]" role="error"><!--Contrib xref ref-type should have allowed value-->
        <assert id="contrib1d"
                 test="matches(@ref-type,'^(aff|corresp|author-notes|other|statement)$')">Unexpected value for contributor "xref" 'ref-type' attribute (<value-of select="@ref-type"/>). The allowed values are "aff" (for links to affilation information), "corresp" (for correspondence information), "other" for a contributor photo, and "author-notes" for any other notes.</assert>
      </rule>
    </pattern>
   <pattern>
      <rule context="article-meta[$maestro='yes'][not(contrib-group)][$article-type='com']"
            role="error">
         <report id="contrib2" test=".">All "Comment" articles should have at least one author. If this information has not been provided, please contact Springer Nature.</report>
      </rule>
   </pattern>
   <pattern>
      <rule context="front//aff" role="error"><!--should be a child of article-meta-->
         <assert id="aff1" test="parent::article-meta">"aff" element should be a direct child of "article-meta" after "contrib-group" - not a child of "<value-of select="name(parent::*)"/>".</assert>
      </rule>
  </pattern>
   <pattern>
      <rule context="xref[@ref-type='aff'][@rid]" role="error"><!--xref/@ref-type='aff' should be empty-->
         <report id="aff2a" test="matches(.,replace(@rid,'a',''))">Do not use text in "xref" element with ref-type="aff" - these values can be auto-generated from the ids.</report>
      </rule>
  </pattern>
   <pattern>
      <rule context="aff/label" role="error"><!--aff should not contain label-->
         <report id="aff2b" test="matches(.,replace(parent::aff/@id,'a',''))">Do not use "label" in "aff" element - these values can be auto-generated from the ids.</report>
      </rule>
  </pattern>
   <pattern>
      <rule context="aff" role="error"><!--Affiliation information should have id-->
         <assert id="aff3a" test="@id">Missing 'id' attribute - "aff" should have an 'id' of the form "a"+number (with no leading zeros).</assert>
      </rule>
  </pattern>
   <pattern>
      <rule context="aff[@id]" role="error"><!--Affiliation id in required format-->
         <assert id="aff3b" test="matches(@id,'^a[1-9][0-9]*$')">Invalid 'id' value ("<value-of select="@id"/>"). "aff" 'id' attribute should be of the form "a"+number (with no leading zeros). Also, update the values in any linking "xref" elements.</assert>
      </rule>
  </pattern>
   <pattern>
      <rule context="article-meta/aff[@id]" role="error"><!--Affiliation information given, but no corresponding author in contrib list-->
         <let name="id" value="@id"/>
         <assert id="aff3c" test="ancestor::article//contrib//xref[@rid=$id]">Affiliation information has been given (id="<value-of select="@id"/>"), but no link has been added to the contrib information. Insert an "xref" link with attributes ref-type="aff" and rid="<value-of select="@id"/>" on the relevant contributor.</assert>
      </rule>
  </pattern>
   <pattern>
      <rule context="addr-line[not(parent::address)]" role="error">
         <assert id="aff10a" test="@content-type">"addr-line" should have a 'content-type' attribute. Allowed values are: street, city, state, and zip.</assert>
      </rule>
    </pattern>
   <pattern>
      <rule context="addr-line[@content-type]" role="error">
         <assert id="aff10b" test="matches(@content-type,'^(street|city|state|zip)$')">Unexpected value for "addr-line" 'content-type' attribute (<value-of select="@content-type"/>). Allowed values are: street, city, state, and zip.</assert>
      </rule>
  </pattern>
   <pattern>
      <rule context="corresp" role="error"><!--Correspondence information should have id-->
        <assert id="corres1a" test="@id">Missing 'id' attribute - "corresp" should have an 'id' of the form "c"+number.</assert>
      </rule>
    </pattern>
   <pattern>
      <rule context="corresp[@id]" role="error"><!--Correspondence id in required format-->
         <assert id="corres1b" test="matches(@id,'^c[0-9]+$')">Invalid 'id' value ("<value-of select="@id"/>"). "corresp" 'id' attribute should be of the form "c"+number.</assert>
      </rule>
  </pattern>
   <pattern>
      <rule context="corresp[@id][named-content/@content-type='author']"
            role="error"><!--Correspondence information given, but no corresponding author in contrib list-->
         <let name="id" value="@id"/>
         <assert id="corres1c1"
                 test="ancestor::article//xref[@ref-type='corresp'][@rid=$id]">Corresponding author information has been given for <value-of select="named-content[@content-type='author']"/>, but no link has been added to the contrib information. For the corresponding "contrib" element, change 'corresp' attribute to "yes" and insert an "xref" link with attributes ref-type="corresp" and rid="<value-of select="@id"/>".</assert>
      </rule>
  </pattern>
   <pattern>
      <rule context="corresp[@id][not(named-content/@content-type='author')]"
            role="error"><!--Correspondence information given, but no corresponding author in contrib list-->
         <let name="id" value="@id"/>
         <assert id="corres1c2"
                 test="ancestor::article//xref[@ref-type='corresp'][@rid=$id]">Corresponding author information has been given, but no contributor has been linked. Please add linking information to the relevant "contrib" element - change 'corresp' attribute to "yes" and insert an "xref" link with attributes ref-type="corresp" and rid="<value-of select="@id"/>"</assert>
      </rule>
  </pattern>
   <pattern>
      <rule context="xref[@ref-type='corresp'][parent::contrib/@contrib-type='author']"
            role="error"><!--Correspondence information given, but no corresponding author in contrib list-->
         <assert id="corres1d" test="parent::contrib[@corresp='yes']">Contributor has an "xref" link to correspondence information (ref-type="corresp"), but has not been identified as a corresponding author (corresp="yes").</assert>
      </rule>
  </pattern>
   <pattern>
      <rule context="contrib[@corresp='yes'][not($transition='yes')]" role="error"><!--Correspondence information given, but no corresponding author in contrib list-->
         <assert id="corres1e" test="xref[@ref-type='corresp']">Contributor has been identified as a corresponding author (corresp="yes"), but no "xref" link (ref-type="corresp") has been given.</assert>
      </rule>
  </pattern>
   <pattern>
      <rule context="corresp[count(email) gt 1]/named-content[@content-type='author'][not(matches($pcode,'^(nmstr|mtm|hortres|sdata)$'))]"
            role="error"><!--Only one author email per corresp element-->
         <report id="corres2" test="contains(.,' or ')">Corresponding author information should only contain one email address. Please split "corresp" with id='<value-of select="parent::corresp/@id"/>' into separate "corresp" elements - one for each corresponding author. You will also need to update the equivalent "xref" elements with the new 'rid' values.</report>
      </rule>
  </pattern>
   <pattern>
      <rule context="corresp[not(phone)]/text()[contains(.,'Tel:') or contains(.,'Tel.')]"
            role="error"><!--phone numbers should be contained in "phone" element-->
         <report id="corres3a" test=".">Please use "phone" element on telephone numbers in correspondence details.</report>
      </rule>
  </pattern>
   <pattern>
      <rule context="corresp[not(fax)]/text()[contains(.,'Fax')]" role="error"><!--fax numbers should be contained in "fax" element-->
         <report id="corres3b" test=".">Please use "fax" element on fax numbers in correspondence details.</report>
      </rule>
  </pattern>
   <pattern>
      <rule context="author-notes/fn[@fn-type='conflict']/p" role="error"><!--Conflict of interest statement should not be empty - common in NPG titles. I assume XBuilder auto-generates it-->
         <assert id="conflict1" test="normalize-space(.) or *">Empty "conflict of interest" statement used. Please add text of the statement as used in the pdf.</assert>
      </rule>
  </pattern>
   <pattern>
      <rule context="author-notes/fn[@fn-type='conflict']" role="error"><!--Conflict of interest statement should not have an id-->
         <report id="conflict2a" test="@id">'id' is not required on conflict of interest statements - please delete.</report>
      </rule>
  </pattern>
   <pattern>
      <rule context="author-notes/fn[@fn-type='conflict']" role="error"><!--Conflict of interest statement should have @specific-use-->
         <assert id="conflict2b" test="@specific-use">Conflict of interest statements should have 'specific-use' attribute taking the value "conflict" or "no-conflict". "no-conflict" should only be used when none of the authors have a conflict.</assert>
      </rule>
  </pattern>
   <pattern>
      <rule context="author-notes/fn[@fn-type='conflict'][@specific-use]"
            role="error"><!--Conflict of interest statement @specific-use has allowed values-->
         <assert id="conflict2c"
                 test="matches(@specific-use,'^(conflict|no-conflict)$')">Conflict of interest statement 'specific-use' attribute should take the value "conflict" or "no-conflict", not <value-of select="@specific-use"/>. "no-conflict" should only be used when none of the authors have a conflict.</assert>
      </rule>
  </pattern>
   <pattern>
      <rule context="author-notes/fn[not(@fn-type)]" role="error"><!--author notes should have an id-->
         <assert id="aunote1a" test="@id">Missing 'id' attribute on author note - "fn" should have an 'id' of the form "n"+number (without leading zeros).</assert>
      </rule>
  </pattern>
   <pattern>
      <rule context="author-notes/fn[not(@fn-type)][@id]" role="error"><!--author notes id in required format-->
         <assert id="aunote1b" test="matches(@id,'^n[1-9][0-9]*$')">Invalid 'id' value ("<value-of select="@id"/>"). "author-notes/fn" 'id' attribute should be of the form "n"+number (without leading zeros).</assert>
      </rule>
  </pattern>
   <pattern>
      <rule context="author-notes/fn[not(@fn-type)][matches(@id,'^n[1-9][0-9]*$')]"
            role="error"><!--author notes linked to from at least one contributor-->
         <let name="id" value="@id"/>
         <assert id="aunote1c"
                 test="ancestor::article//xref[@ref-type='author-notes'][@rid=$id]">An author note appears, but no contributor has been linked. Please add linking information to the relevant "contrib" element(s) - insert an "xref" link with attributes ref-type="author-notes" and rid="<value-of select="@id"/>".</assert>
      </rule>
  </pattern>
   <pattern>
      <rule context="author-notes/fn[@fn-type='equal']" role="error"><!--use author-notes not equal footnotes-->
         <report id="aunote2" test=".">Do not use author footnote with 'fn-type="equal"' in Springer Nature articles. Mark up as a normal author footnote instead, i.e. "fn" with no 'fn-type' attribute, and a linking xref from the relevant contributors. See example in Tagging Instructions.</report>
      </rule>
  </pattern>
   <pattern>
      <rule context="contrib[collab][attribute::*]" role="error"><!--no attributes required when contributor is a collaboration-->
         <report id="collab1a" test=".">No attributes are required when a contributor is a collaboration - element should just be &lt;contrib&gt;.</report>
      </rule>
  </pattern>
   <pattern>
      <rule context="contrib[collab[@collab-type='on-behalf-of']]/xref"
            role="error"><!--no xref links allowed when contributor is a collaboration-->
         <let name="refType"
              value="if (@ref-type='aff') then 'an affiliation' else         if (@ref-type='corresp') then 'correspondence information' else         if (@ref-type='author-notes') then 'author notes' else 'xref links'"/>
         <report id="collab1b" test=".">"on behalf of" collaborations cannot have <value-of select="$refType"/>. Please contact Springer Nature for markup instructions.</report>
      </rule>
  </pattern>
   <pattern>
      <rule context="contrib/collab[@collab-type='authors']/xref[@ref-type='author-notes']"
            role="error"><!--no author-notes on consortia-->
         <report id="collab2" test=".">Do not use author notes for consortia, use group text instead. See Tagging Instructions for further details.</report>
      </rule>
  </pattern>
   <pattern><!--markup for orcids is correct-->
      <rule context="contrib-id[not(@contrib-id-type='orcid')]" role="error">
         <report id="orcid1a" test=".">"contrib-id" should have 'contrib-id-type="orcid"'.</report>
      </rule>
  </pattern>
   <pattern>
      <rule context="contrib-id[@content-type]" role="error">
         <report id="orcid1b" test=".">Do not use 'content-type' attribute on "contrib-id".</report>
      </rule>
  </pattern>
   <pattern>
      <rule context="contrib-id[@specific-use]" role="error">
         <report id="orcid1c" test=".">Do not use 'specific-use' attribute on "contrib-id".</report>
      </rule>
  </pattern>
   <pattern>
      <rule context="contrib-id" role="error">
         <assert id="orcid2a" test="normalize-space(.) or *">"contrib-id" should contain the orcid url as text content of the element.</assert>
      </rule>
  </pattern>
   <pattern>
      <rule context="contrib-id[normalize-space(.) or *]" role="error">
         <assert id="orcid2b" test="starts-with(.,'http://orcid.org/')">"contrib-id" should contain the full orcid url, i.e. start with "http://orcid.org/".</assert>
      </rule>
  </pattern>
   <pattern><!--sec - sec-type or specific-use attribute used-->
      <rule context="sec[not(@sec-type or @specific-use)]" role="error">
         <report id="sec1a" test=".">"sec" should have "sec-type" or "specific-use" attribute.</report>
      </rule>
  </pattern>
   <pattern><!--sec - sec-type or specific-use attribute used-->
      <rule context="sec[@sec-type and @specific-use]" role="error">
         <report id="sec1b" test=".">"sec" should only use one "sec-type" or "specific-use" attribute, not both.</report>
      </rule>
  </pattern>
   <pattern>
      <rule context="sec[@xml:lang]" role="error">
         <report id="sec1d" test=".">Do not use "xml:lang" attribute on "sec".</report>
      </rule>
  </pattern>
   <pattern><!--sec - sec-type is valid-->
      <rule context="sec[@sec-type]" role="error">
         <let name="secType" value="@sec-type"/>
         <assert id="sec2a" test="$allowed-values/sec-types/sec-type[.=$secType]">Unexpected value for "sec-type" attribute (<value-of select="$secType"/>). Allowed values are: "bookshelf" (only for use in book reviews), "materials", "online-methods", "procedure" and "transcript" (only for use in video articles).</assert>
      </rule>
  </pattern>
   <pattern><!--sec - sec-type transcript only allowed in video articles-->
      <rule context="sec[@sec-type='bookshelf'][not($article-type='bo')]"
            role="error">
         <report id="sec2a-1" test=".">Unexpected value for "sec-type" attribute (bookshelf). This is only allowed in Book Reviews (article type: "bo"). Allowed values are: "materials", "online-methods", "procedure" and "transcript" (only for use in video articles).</report>
      </rule>
  </pattern>
   <pattern><!--sec - sec-type transcript only allowed in video articles-->
      <rule context="sec[@sec-type='transcript'][not($article-type='video')]"
            role="error">
         <report id="sec2a-2" test=".">Unexpected value for "sec-type" attribute (transcript). This is only allowed in Video articles (article type: "video"). Allowed values are: "bookshelf" (only for use in book reviews), "materials", "online-methods", "procedure".</report>
      </rule>
  </pattern>
   <pattern><!--sec/@specific-use - follows expected syntax-->
      <rule context="sec[@specific-use][not(matches(@specific-use,'^heading-level-[0-9]+$'))]"
            role="error">
         <report id="sec2b" test=".">The "specific-use" attribute on "sec" (<value-of select="@specific-use"/>) should be used to show the section heading level. It should be "heading-level-" followed by a number.</report>
      </rule>
  </pattern>
   <pattern><!--sec/@specific-use="heading-level-1" is a child of body, abstract or appendix-->
      <rule context="sec[@specific-use='heading-level-1'][not(parent::body|parent::abstract|parent::app)]"
            role="error">
         <report id="sec3a" test=".">Section heading level 1 should only be used in body, abstract or app - check nesting and "specific-use" attribute values.</report>
      </rule>
  </pattern>
   <pattern><!--sec/@specific-use="heading-level-2" is a child of sec heading level 1-->
      <rule context="sec[@specific-use='heading-level-2'][not(parent::sec[@specific-use='heading-level-1'] or parent::sec[@sec-type='online-methods'][parent::sec/@specific-use='heading-level-1'])][not(ancestor::boxed-text)]"
            role="error">
         <report id="sec3b" test=".">Section heading level 2 should be a child of section heading level 1 - check nesting and "specific-use" attribute values.</report>
      </rule>
  </pattern>
   <pattern><!--sec/@specific-use="heading-level-3" is a child of sec heading level 2-->
      <rule context="sec[@specific-use='heading-level-3'][not(parent::sec[@specific-use='heading-level-2'] or parent::sec[@sec-type='online-methods'][parent::sec/@specific-use='heading-level-2'])][not(ancestor::boxed-text)]"
            role="error">
         <report id="sec3c" test=".">Section heading level 3 should be a child of section heading level 2 - check nesting and "specific-use" attribute values.</report>
      </rule>
  </pattern>
   <pattern><!--sec/@specific-use="heading-level-4" is a child of sec heading level 3-->
      <rule context="sec[@specific-use='heading-level-4'][not(parent::sec/@specific-use='heading-level-3')][not(ancestor::boxed-text)]"
            role="error">
         <report id="sec3d" test=".">Section heading level 4 should be a child of section heading level 3 - check nesting and "specific-use" attribute values.</report>
      </rule>
  </pattern>
   <pattern><!--sec/@specific-use="heading-level-5" is a child of sec heading level 4-->
      <rule context="sec[@specific-use='heading-level-5'][not(parent::sec/@specific-use='heading-level-4')][not(ancestor::boxed-text)]"
            role="error">
         <report id="sec3e" test=".">Section heading level 5 should be a child of section heading level 4 - check nesting and "specific-use" attribute values.</report>
      </rule>
  </pattern>
   <pattern><!--sec/@specific-use="heading-level-6" is a child of sec heading level 5-->
      <rule context="sec[@specific-use='heading-level-6'][not(parent::sec/@specific-use='heading-level-5')][not(ancestor::boxed-text)]"
            role="error">
         <report id="sec3f" test=".">Section heading level 6 should be a child of section heading level 5 - check nesting and "specific-use" attribute values.</report>
      </rule>
  </pattern>
   <pattern><!--sec/@specific-use="heading-level-7" is a child of sec heading level 6-->
      <rule context="sec[@specific-use='heading-level-7'][not(parent::sec/@specific-use='heading-level-6')][not(ancestor::boxed-text)]"
            role="error">
         <report id="sec3g" test=".">Section heading level 7 should be a child of section heading level 6 - check nesting and "specific-use" attribute values.</report>
      </rule>
  </pattern>
   <pattern><!--sec/@specific-use="heading-level-8" is a child of sec heading level 7-->
      <rule context="sec[@specific-use='heading-level-8'][not(parent::sec/@specific-use='heading-level-7')][not(ancestor::boxed-text)]"
            role="error">
         <report id="sec3h" test=".">Section heading level 8 should be a child of section heading level 7 - check nesting and "specific-use" attribute values.</report>
      </rule>
  </pattern>
   <pattern><!--sec - sec-type or specific-use attribute used-->
      <rule context="sec/sec-meta | sec/label | sec/address | sec/alternatives | sec/array | sec/chem-struct-wrap | sec/graphic | sec/media | sec/supplementary-material | sec/disp-formula-group | sec[not($transition='yes')]/def-list | sec/mml:math | sec/related-article | sec/related-object | sec/speech | sec/statement | sec/verse-group | sec/fn-group | sec/glossary | sec/ref-list"
            role="error">
         <report id="sec4" test=".">Children of "sec" should only be "title", "p", "sec", "disp-formula", "disp-quote" or "preformat" - do not use "<name/>".</report>
      </rule>
  </pattern>
   <pattern><!--title - no attributes used-->
      <rule context="title[@id]">
         <report id="title1a" test=".">Unnecessary use of "id" attribute on "title" element.</report>
      </rule>
  </pattern>
   <pattern>
      <rule context="title[@content-type]">
         <report id="title1b" test=".">Unnecessary use of "content-type" attribute on "title" element.</report>
      </rule>
  </pattern>
   <pattern>
      <rule context="sec/title[not(normalize-space(.) or *)]">
         <report id="title1c" test=".">Do not use empty section "title" for formatting purposes.</report>
      </rule>
  </pattern>
   <pattern><!--List does not have an id-->
      <rule context="list[@id]" role="error">
         <report id="list1" test=".">The "id" attribute is not necessary on lists.</report>
      </rule>
  </pattern>
   <pattern><!--List - no unnecessary attributes-->
      <rule context="list[@continued-from]" role="error">
         <report id="list2b" test=".">Do not use "continued-from" attribute on "list" element.</report>
      </rule>
  </pattern>
   <pattern>
      <rule context="list[@prefix-word]" role="error">
         <report id="list2c" test=".">Do not use "prefix-word" attribute on "list" element.</report>
      </rule>
  </pattern>
   <pattern>
      <rule context="list[@specific-use]" role="error">
         <report id="list2d" test=".">Do not use "specific-use" attribute on "list" element.</report>
      </rule>
  </pattern>
   <pattern><!--List-item - no id attribute-->
      <rule context="list-item[not(ancestor::supplementary-material[@content-type='annotations'])][@id]"
            role="error">
         <report id="list2e" test=".">Do not use "id" attribute on "list-item" element.</report>
      </rule>
  </pattern>
   <pattern><!--List - list-type attribute stated (apart from interview/quizzes)-->
      <rule context="list[not(@list-content)][not(ancestor::supplementary-material[@content-type='annotations'])][not(@list-type)]"
            role="error">
         <report id="list3a" test=".">Use "list-type" attribute to show type of list used. Allowed values are: none, bullet, number, lcletter, ucletter, lcroman and ucroman for unbracketed labels. Use number-paren, lcletter-paren and roman-paren for labels in parentheses.</report>
      </rule>
  </pattern>
   <pattern><!--list-type attribute is valid--><!--needs work - excludes lists in body when no sec exists; does it work in abstracts?-->
      <rule context="list[@list-content='boxed-list' or not(@list-content)][@list-type]"
            role="error">
         <let name="listType" value="@list-type"/>
         <assert id="list3b" test="$allowed-values/list-types/list-type[.=$listType]">Unexpected value for "list-type" attribute (<value-of select="$listType"/>). Allowed values are: none, bullet, number, lcletter, ucletter, lcroman and ucroman for unbracketed labels. Use number-paren, lcletter-paren and roman-paren for labels in parentheses.</assert>
      </rule>
  </pattern>
   <pattern><!--List-item - no labels needed-->
      <rule context="list-item[not(ancestor::list/@list-content='interview')]/label"
            role="error">
         <report id="list4" test=".">Do not use "label" element in "list-item".</report>
      </rule>
  </pattern>
   <pattern><!--Interview is block-level, i.e. not a child of p or list-item-->
      <rule context="list[@list-content='interview']" role="error">
         <assert id="int1a" test="not(parent::p or parent::list-item)">Interviews should be modelled as block-level lists and should not be enclosed in paragraphs or other lists.</assert>
      </rule>
  </pattern>
   <pattern><!--Interview does not have @list-type-->
      <rule context="list[@list-content='interview']" role="error">
         <assert id="int1c" test="not(@list-type)">The "list-type" attribute is not necessary on interviews.</assert>
      </rule>
  </pattern>
   <pattern><!--Interview has list-items containing one question and one answer-->
      <rule context="list[@list-content='interview']/list-item" role="error">
         <assert id="int2"
                 test="count(list[@list-content='question'])=1 and count(list[@list-content='answer'])=1">Interview list-items should contain one question and one answer.</assert>
      </rule>
  </pattern>
   <pattern><!--Question and answer lists only used in interview or quiz-->
      <rule context="list[@list-content='question']" role="error">
         <assert id="intquiz1"
                 test="ancestor::list/@list-content='interview' or ancestor::list/@list-content='quiz'">Question lists (list-content="question") should only be used in interviews or quizzes.</assert>
      </rule>
  </pattern>
   <pattern><!--Question and answer lists only used in interview or quiz-->
      <rule context="list[@list-content='answer']" role="error">
         <assert id="intquiz2"
                 test="ancestor::list/@list-content='interview' or ancestor::list/@list-content='quiz'">Answer lists (list-content="answer") should only be used in interviews or quizzes.</assert>
      </rule>
  </pattern>
   <pattern><!--Interview is block-level, i.e. not a child of p or list-item-->
      <rule context="list[@list-content='quiz']" role="error">
         <assert id="quiz1a" test="not(parent::p or parent::list-item)">Quizzes should be modelled as block-level lists and should not be enclosed in paragraphs or other lists.</assert>
      </rule>
  </pattern>
   <pattern><!--Interview does not have @list-type-->
      <rule context="list[@list-content='quiz']" role="error">
         <assert id="quiz1c" test="not(@list-type)">The "list-type" attribute is not necessary on quizzes.</assert>
      </rule>
  </pattern>
   <pattern><!--Interview has list-items containing one question and one answer-->
      <rule context="list[@list-content='quiz']/list-item" role="error">
         <assert id="quiz2"
                 test="count(list[@list-content='question'])=1 and count(list[@list-content='answer'])=1">Quiz list-items should contain one question and one answer.</assert>
      </rule>
  </pattern>
   <pattern><!--content-type attribute is valid-->
      <rule context="p[not(ancestor::sec/@sec-type)][not(ancestor::ack or ancestor::app or ancestor::app-group or ancestor::boxed-text or ancestor::table-wrap)][not(ancestor::supplementary-material[@content-type='annotations'])][@content-type]"
            role="error">
         <let name="contentType" value="@content-type"/>
         <assert id="para1a"
                 test="$allowed-values/content-types/content-type[.=$contentType]">Unexpected value for "content-type" attribute (<value-of select="$contentType"/>). Allowed values are: cross-head, dateline and greeting. </assert>
      </rule>
  </pattern>
   <pattern><!--p - no unnecessary attributes-->
      <rule context="p[not(ancestor::supplementary-material[@content-type='annotations'])][@id]"
            role="error">
         <report id="para1b" test=".">Do not use "id" attribute on "p" element.</report>
      </rule>
  </pattern>
   <pattern>
      <rule context="p[@specific-use][not(@specific-use='search-only')]"
            role="error">
         <report id="para1c" test=".">Do not use "specific-use" attribute on "p" element (apart from when defining a paragraph as "search-only").</report>
      </rule>
  </pattern>
   <pattern>
      <rule context="p[@xml:lang]" role="error">
         <report id="para1d" test=".">Do not use "xml:lang" attribute on "p" element.</report>
      </rule>
  </pattern>
   <pattern><!--dateline para in correct place-->
      <rule context="body//p[@content-type='dateline']" role="error">
         <assert id="para2" test="not(preceding-sibling::p)">Dateline paragraphs should only appear as the first element in "body", or directly following a section "title".</assert>
      </rule>
  </pattern>
   <pattern><!--underline should have @underline-style in order to transform correctly to AJ-->
      <rule context="underline" role="error">
         <assert id="style1a" test="@underline-style">"underline" should have an 'underline-style' attribute with value "single" (for one line) or "double" (for two lines).</assert>
      </rule>
  </pattern>
   <pattern><!--@underline-style should have allowed values-->
      <rule context="underline[@underline-style]" role="error">
         <assert id="style1b"
                 test="@underline-style='single' or @underline-style='double'">"underline" 'underline-style' attribute should have value "single" (for one line) or "double" (for two lines), not "<value-of select="@underline-style"/>".</assert>
      </rule>
  </pattern>
   <pattern><!--preformat should have @preformat-type to assist rendering-->
      <rule context="preformat" role="error">
         <assert id="style2a" test="@preformat-type">"preformat" should have a 'preformat-type' attribute with value "inline" (for inline monospaced type) or "block" (for set out code).</assert>
      </rule>
  </pattern>
   <pattern><!--@preformat-type should have allowed values-->
      <rule context="preformat[@preformat-type]" role="error">
         <assert id="style2b" test="@preformat-type='inline' or @preformat-type='block'">"preformat" 'preformat-type' attribute should have value "inline" (for inline monospaced type) or "block" (for set out code), not "<value-of select="@preformat-type"/>".</assert>
      </rule>
  </pattern>
   <pattern><!--block code should not be a child of p-->
      <rule context="preformat[@preformat-type='block'][parent::p[ancestor::body]]"
            role="error">
         <report id="style2c" test=".">Preformatted blocks should not be included in "p" - change to be a sibling of "p" within "<name path="parent::p/parent::*"/>".</report>
      </rule>
  </pattern>
   <pattern><!--quote should have @content-type to assist rendering-->
      <rule context="disp-quote[not(@content-type)]" role="error">
         <report id="quote1a" test=".">"disp-quote" should have an 'content-type' attribute with value "pullquote" (for quotes shown at the side of the text) or "quote" (for an indented block of text within the body of the article).</report>
      </rule>
  </pattern>
   <pattern><!--quote should have valid @content-type (NPG)-->
      <rule context="disp-quote[$collection='nature'][@content-type]" role="error">
         <assert id="quote1b" test="@content-type='pullquote' or @content-type='quote'">"disp-quote" 'content-type' attribute should have value "pullquote" (for quotes shown at the side of the text) or "quote" (for an indented block of text within the body of the article), not "<value-of select="@content-type"/>".</assert>
      </rule>
  </pattern>
   <pattern><!--quote should have valid @content-type (Palgrave)-->
      <rule context="disp-quote[$collection='palgrave'][@content-type]"
            role="error">
         <assert id="quote1b2"
                 test="@content-type='pullquote' or @content-type='quote' or @content-type='sidenote'">"disp-quote" 'content-type' attribute should have value "pullquote" (for quotes shown at the side of the text), "quote" (for an indented block of text within the body of the article), or "sidenote" (for a note in the sidebar of the article), not "<value-of select="@content-type"/>".</assert>
      </rule>
  </pattern>
   <pattern><!--block quotes should not have atrribution-->
      <rule context="disp-quote[@content-type='quote']/attrib" role="error">
         <report id="quote2" test=".">Do not use "attrib" in block quotes. The attribution statement should just follow the text of the quote itself.</report>
      </rule>
  </pattern>
   <pattern><!--quote should not have @id-->
      <rule context="disp-quote[@id]" role="error">
         <report id="quote3a" test=".">Unnecessary use of 'id' attribute on "disp-quote" element.</report>
      </rule>
  </pattern>
   <pattern><!--quote should not have @specific-use-->
      <rule context="disp-quote[@specific-use]" role="error">
         <report id="quote3b" test=".">Unnecessary use of 'specific-use' attribute on "disp-quote" element.</report>
      </rule>
  </pattern>
   <pattern><!--quote should only contain p or attrib-->
      <rule context="disp-quote/*[not(self::p or self::attrib)]" role="error">
         <report id="quote4" test=".">Do not use "<name/>" in "disp-quote". Only "p" or "attrib" should be used.</report>
      </rule>
  </pattern>
   <pattern><!--quote should be a block-level element-->
      <rule context="disp-quote[not($transition='yes')][parent::p]" role="error">
         <report id="quote5" test=".">Do not enclose "disp-quote" in the "p" element, as it should be block-level only.</report>
      </rule>
  </pattern>
   <pattern><!--url starting https should not have extra http added to @xlink:href-->
      <rule context="ext-link[not($transition='yes')][contains(@xlink:href,'http://http')]"
            role="error">
         <report id="url1a" test=".">Do not insert extra "http://" on an 'xlink-href' which already has an http protocol - <value-of select="@xlink:href"/>.</report>
      </rule>
  </pattern>
   <pattern><!--url starting ftp:// should not have extra http added to @xlink:href-->
      <rule context="ext-link[not($transition='yes')][contains(@xlink:href,'http://ftp://')]"
            role="error">
         <report id="url1b" test=".">Do not insert "http://" on an 'xlink-href' to an ftp - <value-of select="@xlink:href"/>.</report>
      </rule>
  </pattern>
   <pattern><!--url starting mailto should not have extra http added to @xlink:href-->
      <rule context="ext-link[not($transition='yes')][contains(@xlink:href,'http://mailto')]"
            role="error">
         <report id="url1c" test=".">Do not use "ext-link" for links to email addresses. Use the "email" element, retaining the 'xlink:href' attribute (and delete 'http://mailto' from it).</report>
      </rule>
  </pattern>
   <pattern><!--@xlink:href shouldn't target doifinder - does not work on Maestro-->
      <rule context="ext-link[contains(@xlink:href,'doifinder')]" role="error">
         <report id="url1d" test=".">Do not link to doifinder in "ext-link" as this does not work for JATS articles. 'xlink:href' should be: <value-of select="concat('http://dx.doi.org',substring-after(@xlink:href,'doifinder'))"/>.</report>
      </rule>
  </pattern>
   <pattern><!--ext-link should have @xlink:href-->
      <rule context="ext-link[not(@xlink:href)][not(ancestor::notes/@notes-type='database-links')]"
            role="error">
         <report id="url2a" test=".">"ext-link" should have an 'xlink:href' attribute giving the target website or ftp site.</report>
      </rule>
  </pattern>
   <pattern><!--ext-link should have non-empty @xlink:href-->
      <rule context="ext-link[@xlink:href=''][not(ancestor::notes/@notes-type='database-links')]"
            role="error">
         <report id="url2b" test=".">"ext-link" 'xlink:href' attribute should not be empty. It should contain the address for the target website or ftp site.</report>
      </rule>
  </pattern>
   <pattern><!--ext-link @xlink:href should not contain whitespace-->
      <rule context="ext-link[not($transition='yes')][matches(@xlink:href,'\s')]"
            role="error">
         <report id="url2c" test=".">"ext-link" 'xlink:href' attribute (<value-of select="@xlink:href"/>) should not contain whitespace - this may create a broken link in the online article. Please delete spaces and new lines.</report>
      </rule>
  </pattern>
   <pattern><!--ext-link should not be used for email addresses-->
      <rule context="ext-link[not($transition='yes')][starts-with(@xlink:href,'mailto')]"
            role="error">
         <report id="url2d" test=".">Do not use "ext-link" for links to email addresses. Use the "email" element, retaining the 'xlink:href' attribute (and delete 'mailto' from it).</report>
      </rule>
  </pattern>
   <pattern><!--ext-link should have @xlink:href-->
      <rule context="ext-link[not(@ext-link-type)][not(ancestor::ref-list[@content-type='data-citations'])][not(ancestor::notes/@notes-type='database-links')]"
            role="error">
         <report id="url3a" test=".">"ext-link" should have an 'ext-link-type' attribute: "url" for a link to a website; "ftp" for a link to an ftp site.</report>
      </rule>
  </pattern>
   <pattern><!--ext-link should have non-empty @xlink:href-->
      <rule context="ext-link[@ext-link-type=''][not(ancestor::ref-list[@content-type='data-citations'])][not(ancestor::notes/@notes-type='database-links')]"
            role="error">
         <report id="url3b" test=".">"ext-link" 'ext-link-type' attribute should not be empty. It should be "url" for a link to a website; "ftp" for a link to an ftp site.</report>
      </rule>
  </pattern>
   <pattern><!--no empty xrefs for some ref-types-->
      <rule context="xref[matches(@ref-type,'^(bibr|fig|supplementary-material|table-fn)$')][not($pcode='pcrj')][not($transition='yes')]"
            role="error">
         <let name="ref-type" value="@ref-type"/>
         <assert id="xref1" test="normalize-space(.) or *">"xref" with ref-type="<value-of select="$ref-type"/>" and rid="<value-of select="@rid"/>" should contain text. Please see Tagging Instructions for further examples.</assert>
      </rule>
  </pattern>
   <pattern><!--tweaked rule for PCRJ archive and transition journals only - no empty xrefs for some ref-types, ok for figures-->
      <rule context="xref[matches(@ref-type,'^(bibr|disp-formula|supplementary-material|table-fn)$')][$pcode='pcrj']"
            role="error">
         <let name="ref-type" value="@ref-type"/>
         <assert id="xref1b" test="normalize-space(.) or *">"xref" with ref-type="<value-of select="$ref-type"/>" and rid="<value-of select="@rid"/>" should contain text. Please see Tagging Instructions for further examples.</assert>
      </rule>
  </pattern>
   <pattern><!--Multiple rid values only allowed in bibrefs-->
      <rule context="xref[not(@ref-type='bibr')]" role="error">
         <let name="ref-type" value="@ref-type"/>
         <report id="xref2" test="contains(@rid,' ')">"xref" with ref-type="<value-of select="$ref-type"/>" should only contain one 'rid' value (<value-of select="."/>). Please split into separate "xref" elements.</report>
      </rule>
  </pattern>
   <pattern><!--compare single bib rid with text as long as text is numeric (i.e. excludes references which have author names)-->
      <rule context="xref[@ref-type='bibr' and not(contains(@rid,' ')) and not(.='') and matches(.,'^[1-9][0-9]?[0-9]?$')]"
            role="error">
         <assert id="xref3a" test="matches(.,replace(@rid,'b',''))">Mismatch in bibref: rid="<value-of select="@rid"/>" but text is "<value-of select="."/>".</assert>
      </rule>
  </pattern>
   <pattern><!--multiple @rids should not be used where citation is author name-->
      <rule context="xref[@ref-type='bibr' and contains(@rid,' ')]" role="error">
         <report id="xref3b" test="matches(.,'[a-z]')">Multiple bibref rid values should only be used in numeric reference lists, not when author names are used. Please split into separate "xref" elements.</report>
      </rule>
  </pattern>
   <pattern><!--xref/@ref-type="bibr", @rid should not be to two values-->
      <rule context="xref[@ref-type='bibr' and contains(@rid,' ') and not(.='') and not(matches(.,'[a-z]'))]"
            role="error">
         <report id="xref3c" test="count(tokenize(@rid, '\W+')[. != '']) eq 2">Bibrefs should be to a single reference or a range of three or more references. See Tagging Instructions for examples.</report>
      </rule>
  </pattern>
   <pattern><!--check start of range value is a number-->
      <rule context="xref[@ref-type='bibr' and count(tokenize(@rid, '\W+')[. != '']) gt 2][contains(.,'–')]"
            role="error"><!--range items must be numbers-->
         <let name="first" value="substring-before(.,'–')"/>
         <assert id="xref3d1a" test="matches($first,'^[0-9]+$')">Non-numeric character included at the start of citation range: <value-of select="$first"/>. Please make this a number.</assert>
      </rule>
  </pattern>
   <pattern><!--check end of range value is a number-->
      <rule context="xref[@ref-type='bibr' and count(tokenize(@rid, '\W+')[. != '']) gt 2][contains(.,'–')]"
            role="error"><!--range items must be numbers-->
         <let name="last" value="substring-after(.,'–')"/>
         <assert id="xref3d1b" test="matches($last,'^[0-9]+$')">Non-numeric character included at the end of citation range: <value-of select="$last"/>. Please make this a number.</assert>
      </rule>
  </pattern>
   <pattern><!--check start of range value is a number-->
      <rule context="xref[@ref-type='bibr' and count(tokenize(@rid, '\W+')[. != '']) gt 2][contains(.,'—')]"
            role="error"><!--range items must be numbers-->
         <let name="first" value="substring-before(.,'—')"/>
         <assert id="xref3d1a-2" test="matches($first,'^[0-9]+$')">Non-numeric character included at the start of citation range: <value-of select="$first"/>. Please make this a number.</assert>
      </rule>
  </pattern>
   <pattern><!--check end of range value is a number-->
      <rule context="xref[@ref-type='bibr' and count(tokenize(@rid, '\W+')[. != '']) gt 2][contains(.,'—')]"
            role="error"><!--range items must be numbers-->
         <let name="last" value="substring-after(.,'—')"/>
         <assert id="xref3d1b-2" test="matches($last,'^[0-9]+$')">Non-numeric character included at the end of citation range: <value-of select="$last"/>. Please make this a number.</assert>
      </rule>
  </pattern>
   <pattern><!--check start of range value is a number-->
      <rule context="xref[@ref-type='bibr' and count(tokenize(@rid, '\W+')[. != '']) gt 2][contains(.,'-')]"
            role="error"><!--range items must be numbers-->
         <let name="first" value="substring-before(.,'-')"/>
         <assert id="xref3d1a-3" test="matches($first,'^[0-9]+$')">Non-numeric character included at the start of citation range: <value-of select="$first"/>. Please make this a number.</assert>
      </rule>
  </pattern>
   <pattern><!--check end of range value is a number-->
      <rule context="xref[@ref-type='bibr' and count(tokenize(@rid, '\W+')[. != '']) gt 2][contains(.,'-')]"
            role="error"><!--range items must be numbers-->
         <let name="last" value="substring-after(.,'-')"/>
         <assert id="xref3d1b-4" test="matches($last,'^[0-9]+$')">Non-numeric character included at the end of citation range: <value-of select="$last"/>. Please make this a number.</assert>
      </rule>
  </pattern>
   <pattern><!--compare multiple bib rids with text-->
      <rule context="xref[@ref-type='bibr' and count(tokenize(@rid, '\W+')[. != '']) gt 2][matches(substring-before(.,'–'),'^[0-9]+$')][matches(substring-after(.,'–'),'^[0-9]+$')]"
            role="error"><!--find multiple bibrefs, text must contain a dash (i.e. is a range)-->
         <let name="first" value="xs:integer(substring-before(.,'–'))"/>
         <!--find start of range-->
         <let name="last" value="xs:integer(substring-after(.,'–'))"/>
         <!--find end of range-->
         <let name="range" value="$last - $first + 1"/>
         <!--find number of refs in the range-->
         <let name="derivedRid"
              value="for $j in $first to $last return concat('b',$j)"/>
         <!--generate expected sequence of rid values-->
         <let name="normalizedRid" value="tokenize(@rid,'\W+')"/>
         <!--turn rid into a sequence for comparison purposes-->
         <assert id="xref3d2"
                 test="every $i in 1 to $range satisfies $derivedRid[$i]=$normalizedRid[$i]">xref with ref-type="bibr" range <value-of select="."/> has non-matching multiple rids (<value-of select="@rid"/>). See Tagging Instructions for examples.</assert>
         <!--if any pair does not match, then test will fail-->
      </rule>
  </pattern>
   <pattern><!--compare multiple bib rids with text-->
      <rule context="xref[@ref-type='bibr' and count(tokenize(@rid, '\W+')[. != '']) gt 2][matches(substring-before(.,'—'),'^[0-9]+$')][matches(substring-after(.,'—'),'^[0-9]+$')]"
            role="error"><!--find multiple bibrefs, text must contain a dash (i.e. is a range)-->
         <let name="first" value="xs:integer(substring-before(.,'—'))"/>
         <!--find start of range-->
         <let name="last" value="xs:integer(substring-after(.,'—'))"/>
         <!--find end of range-->
         <let name="range" value="$last - $first + 1"/>
         <!--find number of refs in the range-->
         <let name="derivedRid"
              value="for $j in $first to $last return concat('b',$j)"/>
         <!--generate expected sequence of rid values-->
         <let name="normalizedRid" value="tokenize(@rid,'\W+')"/>
         <!--turn rid into a sequence for comparison purposes-->
         <assert id="xref3d2-2"
                 test="every $i in 1 to $range satisfies $derivedRid[$i]=$normalizedRid[$i]">xref with ref-type="bibr" range <value-of select="."/> has non-matching multiple rids (<value-of select="@rid"/>). See Tagging Instructions for examples.</assert>
         <!--if any pair does not match, then test will fail-->
      </rule>
  </pattern>
   <pattern><!--compare multiple bib rids with text-->
      <rule context="xref[@ref-type='bibr' and count(tokenize(@rid, '\W+')[. != '']) gt 2][matches(substring-before(.,'-'),'^[0-9]+$')][matches(substring-after(.,'-'),'^[0-9]+$')]"
            role="error"><!--find multiple bibrefs, text must contain a dash (i.e. is a range)-->
         <let name="first" value="xs:integer(substring-before(.,'-'))"/>
         <!--find start of range-->
         <let name="last" value="xs:integer(substring-after(.,'-'))"/>
         <!--find end of range-->
         <let name="range" value="$last - $first + 1"/>
         <!--find number of refs in the range-->
         <let name="derivedRid"
              value="for $j in $first to $last return concat('b',$j)"/>
         <!--generate expected sequence of rid values-->
         <let name="normalizedRid" value="tokenize(@rid,'\W+')"/>
         <!--turn rid into a sequence for comparison purposes-->
         <assert id="xref3d2-3"
                 test="every $i in 1 to $range satisfies $derivedRid[$i]=$normalizedRid[$i]">xref with ref-type="bibr" range <value-of select="."/> has non-matching multiple rids (<value-of select="@rid"/>). See Tagging Instructions for examples.</assert>
         <!--if any pair does not match, then test will fail-->
      </rule>
  </pattern>
   <pattern><!--multiple rids not allowed for non-ranges-->
      <rule context="xref[@ref-type='bibr'  and (count(tokenize(@rid, '\W+')[. != '']) gt 2) and not(.='') and not(matches(.,'[a-z]'))]"
            role="error">
         <report id="xref3e" test="contains(.,',')">Multiple rid values should only be used for a range of references - please split into separate "xref" elements. See Tagging Instructions for examples.</report>
      </rule>
  </pattern>
   <pattern><!--range not marked up properly-->
      <rule context="xref[not($transition='yes')][@ref-type='bibr'][following::node()[1]='–'][following-sibling::xref[@ref-type='bibr'][1]]"
            role="error">
         <let name="end" value="following-sibling::xref[@ref-type='bibr'][1]/text()"/>
         <report id="xref3f1" test=".">For a range of references, do not put a separate "xref" on the start and end value. One "xref" should cover the range using multiple 'rid' values - one for each reference in the range. "xref" text should be "<value-of select="."/>&amp;#x2013;<value-of select="$end"/>". See the Tagging Instructions for example markup.</report>
      </rule>
  </pattern>
   <pattern><!--range not marked up properly-->
      <rule context="xref[not($transition='yes')][@ref-type='bibr'][following::node()[1]='—'][following-sibling::xref[@ref-type='bibr'][1]]"
            role="error">
         <let name="end" value="following-sibling::xref[@ref-type='bibr'][1]/text()"/>
         <report id="xref3f2" test=".">For a range of references, do not put a separate "xref" on the start and end value. One "xref" should cover the range using multiple 'rid' values - one for each reference in the range. "xref" text should be "<value-of select="."/>&amp;#x2014;<value-of select="$end"/>". See the Tagging Instructions for example markup.</report>
      </rule>
  </pattern>
   <pattern><!--range not marked up properly-->
      <rule context="xref[not($transition='yes')][@ref-type='bibr'][following::node()[1]='-'][following-sibling::xref[@ref-type='bibr'][1]]"
            role="error">
         <let name="end" value="following-sibling::xref[@ref-type='bibr'][1]/text()"/>
         <report id="xref3f3" test=".">For a range of references, do not put a separate "xref" on the start and end value. One "xref" should cover the range using multiple 'rid' values - one for each reference in the range. "xref" text should be "<value-of select="."/>-<value-of select="$end"/>". See the Tagging Instructions for example markup.</report>
      </rule>
  </pattern>
   <pattern>
      <rule context="floats-group[$full-text='yes']/fig[not(@fig-type='cover-image')][not(@specific-use='suppinfo')][@id]"
            role="error"><!--All figures should be referenced in the text-->
         <let name="id" value="@id"/>
         <assert id="xref4a"
                 test="ancestor::article//xref[@ref-type='fig' and matches(@rid,$id)]">Figure <value-of select="replace($id,'f','')"/> is not linked to in the XML and therefore will not appear in the online article. Please add an xref link in the required location. If the text itself does not reference Figure <value-of select="replace($id,'f','')"/>, please contact Springer Nature.</assert>
      </rule>
  </pattern>
   <pattern>
      <rule context="floats-group[$full-text='yes']/table-wrap[@id]" role="error"><!--All tables should be referenced in the text-->
         <let name="id" value="@id"/>
         <assert id="xref4b"
                 test="ancestor::article//xref[@ref-type='table' and matches(@rid,$id)]">Table <value-of select="replace($id,'t','')"/> is not linked to in the XML and therefore will not appear in the online article. Please add an xref link in the required location. If the text itself does not reference Table <value-of select="replace($id,'t','')"/>, please contact Springer Nature.</assert>
      </rule>
  </pattern>
   <pattern>
      <rule context="floats-group[$full-text='yes']/graphic[@content-type='illustration'][@id]"
            role="error"><!--All tables should be referenced in the text-->
         <let name="id" value="@id"/>
         <assert id="xref4c"
                 test="ancestor::article//xref[@ref-type='other' and matches(@rid,$id)]">Illustration <value-of select="replace($id,'i','')"/> is not linked to in the XML and therefore will not appear in the online article. Please add an xref link in the required location.</assert>
      </rule>
  </pattern>
   <pattern>
      <rule context="floats-group[$full-text='yes']/boxed-text[@id]" role="error"><!--All boxes should be referenced in the text-->
         <let name="id" value="@id"/>
         <assert id="xref4d"
                 test="ancestor::article//xref[@ref-type='boxed-text' and matches(@rid,$id)]">Box <value-of select="replace($id,'bx','')"/> is not linked to in the XML and therefore will not appear in the online article. Please add an xref link in the required location. If the text itself does not reference Box <value-of select="replace($id,'bx','')"/>, please contact Springer Nature.</assert>
      </rule>
  </pattern>
   <pattern>
      <rule context="xref[@ref-type='other'][not(ancestor::abstract)][not(parent::contrib)][@rid=ancestor::article//graphic[@content-type='illustration']/@id][not(@specific-use)]"><!--xref to illustration should have @specific-use for image alignment info-->
         <report id="xref5a" test=".">"xref" to illustration "<value-of select="@rid"/>" should have 'specific-use' attribute containing image alignment. Allowed values are: "align-left", "align-center" and "align-right".</report>
      </rule>
  </pattern>
   <pattern>
      <rule context="xref[@ref-type='other'][@rid=ancestor::article//graphic[@content-type='illustration']/@id][@specific-use]"><!--xref @specific-use should have valid value-->
         <assert id="xref5b"
                 test="matches(@specific-use,'^(align-left|align-right|align-center)$')">"xref" to illustration "<value-of select="@rid"/>" has invalid 'specific-use' value (<value-of select="@specific-use"/>). Allowed values are: "align-left", "align-center" and "align-right".</assert>
      </rule>
  </pattern>
   <pattern>
      <rule context="xref[@ref-type='other'][@rid=ancestor::article//graphic[@content-type='illustration']/@id]/named-content[@content-type='image-align']"><!--xref to illustration should not use named-content for image alignment info-->
         <report id="xref5c" test=".">Do not use "named-content" in "xref" to illustration "<value-of select="parent::xref/@rid"/>" for image alignment information.</report>
      </rule>
  </pattern>
   <pattern>
      <rule context="xref[not(@ref-type)][not(ancestor::contrib)]"><!--xref should have a ref-type attribute-->
         <report id="xref6a" test=".">"xref" should have a 'ref-type' attribute describing the target object, e.g. "bibr", "fig", etc.</report>
      </rule>
  </pattern>
   <pattern>
      <rule context="xref[not(@rid)][not(ancestor::contrib)]"><!--xref should have an rid attribute-->
         <report id="xref6b" test=".">"xref" should have a 'rid' attribute giving the id of the target object, e.g. "b1", "f2", etc.</report>
      </rule>
  </pattern>
   <pattern><!--xref rid format should match expected value based on ref-type-->
      <rule context="xref[matches(@rid,'^a[1-9][0-9]*$')][@ref-type][not(@ref-type='aff')]">
         <report id="xref7a" test=".">Mismatch between "xref" 'rid' format ("a"+number) and 'ref-type' ("<value-of select="@ref-type"/>"). Please check which attribute is correct - expected 'ref-type' value for 'rid' "a"+number is "aff".</report>
      </rule>
  </pattern>
   <pattern>
      <rule context="xref[matches(@rid,'^c[1-9][0-9]*$')][@ref-type][not(@ref-type='corresp')]">
         <report id="xref7b" test=".">Mismatch between "xref" 'rid' format ("c"+number) and 'ref-type' ("<value-of select="@ref-type"/>"). Please check which attribute is correct - expected 'ref-type' value for 'rid' "c"+number is "corresp".</report>
      </rule>
  </pattern>
   <pattern>
      <rule context="xref[matches(@rid,'^d[1-9][0-9]*$')][@ref-type][not(@ref-type='other')]">
         <report id="xref7c-1" test=".">Mismatch between "xref" 'rid' format ("d"+number) and 'ref-type' ("<value-of select="@ref-type"/>"). Please check which attribute is correct - expected 'ref-type' value for 'rid' "d"+number (used for data citations) is "other".</report>
      </rule>
  </pattern>
   <pattern>
      <rule context="xref[matches(@rid,'^i[1-9][0-9]*$')][@ref-type][not(@ref-type='other')]">
         <report id="xref7c-2" test=".">Mismatch between "xref" 'rid' format ("i"+number) and 'ref-type' ("<value-of select="@ref-type"/>"). Please check which attribute is correct - expected 'ref-type' value for 'rid' "i"+number (used for illustrations) is "other".</report>
      </rule>
  </pattern>
   <pattern>
      <rule context="xref[matches(@rid,'^f[1-9][0-9]*$')][@ref-type][not(@ref-type='fig')]">
         <report id="xref7d" test=".">Mismatch between "xref" 'rid' format ("f"+number) and 'ref-type' ("<value-of select="@ref-type"/>"). Please check which attribute is correct - expected 'ref-type' value for 'rid' "f"+number is "fig".</report>
      </rule>
  </pattern>
   <pattern>
      <rule context="xref[matches(@rid,'^eq[1-9][0-9]*$')][@ref-type][not(@ref-type='disp-formula')]">
         <report id="xref7e" test=".">Mismatch between "xref" 'rid' format ("eq"+number) and 'ref-type' ("<value-of select="@ref-type"/>"). Please check which attribute is correct - expected 'ref-type' value for 'rid' "eq"+number is "disp-formula".</report>
      </rule>
  </pattern>
   <pattern>
      <rule context="xref[matches(@rid,'^t[1-9][0-9]*$')][@ref-type][not(@ref-type='table')]">
         <report id="xref7f" test=".">Mismatch between "xref" 'rid' format ("t"+number) and 'ref-type' ("<value-of select="@ref-type"/>"). Please check which attribute is correct - expected 'ref-type' value for 'rid' "t"+number is "table".</report>
      </rule>
  </pattern>
   <pattern>
      <rule context="xref[matches(@rid,'^t[1-9][0-9]?-fn[1-9][0-9]?$')][@ref-type][not(@ref-type='table-fn')]">
         <report id="xref7g" test=".">Mismatch between "xref" 'rid' format ("t"+number-"fn"+number) and 'ref-type' ("<value-of select="@ref-type"/>"). Please check which attribute is correct - expected 'ref-type' value for 'rid' "t"+number-"fn"+number is "table-fn".</report>
      </rule>
  </pattern>
   <pattern>
      <rule context="xref[matches(@rid,'^s[1-9][0-9]*$')][@ref-type][not(@ref-type='supplementary-material')]">
         <report id="xref7h" test=".">Mismatch between "xref" 'rid' format ("s"+number) and 'ref-type' ("<value-of select="@ref-type"/>"). Please check which attribute is correct - expected 'ref-type' value for 'rid' "s"+number is "supplementary-material".</report>
      </rule>
  </pattern>
   <pattern>
      <rule context="xref[matches(@rid,'^sc[1-9][0-9]*$')][@ref-type][not(@ref-type='scheme')]">
         <report id="xref7i" test=".">Mismatch between "xref" 'rid' format ("sc"+number) and 'ref-type' ("<value-of select="@ref-type"/>"). Please check which attribute is correct - expected 'ref-type' value for 'rid' "sc"+number is "scheme".</report>
      </rule>
  </pattern>
   <pattern>
      <rule context="xref[matches(@rid,'^app[1-9][0-9]*$')][@ref-type][not(@ref-type='app')]">
         <report id="xref7j" test=".">Mismatch between "xref" 'rid' format ("app"+number) and 'ref-type' ("<value-of select="@ref-type"/>"). Please check which attribute is correct - expected 'ref-type' value for 'rid' "app"+number is "app".</report>
      </rule>
  </pattern>
   <pattern>
      <rule context="xref[matches(@rid,'^bx[1-9][0-9]*$')][@ref-type][not(@ref-type='boxed-text')]">
         <report id="xref7k" test=".">Mismatch between "xref" 'rid' format ("bx"+number) and 'ref-type' ("<value-of select="@ref-type"/>"). Please check which attribute is correct - expected 'ref-type' value for 'rid' "bx"+number is "boxed-text".</report>
      </rule>
  </pattern>
   <pattern>
      <rule context="xref[matches(@rid,'^fn[1-9][0-9]*$')][@ref-type][not(@ref-type='fn')]">
         <report id="xref7l" test=".">Mismatch between "xref" 'rid' format ("fn"+number) and 'ref-type' ("<value-of select="@ref-type"/>"). Please check which attribute is correct - expected 'ref-type' value for 'rid' "fn"+number is "fn".</report>
      </rule>
  </pattern>
   <pattern><!--elements which should have two child elements-->
      <rule context="mml:mfrac|mml:mroot|mml:msub|mml:msup|mml:munder|mml:mover"
            role="error">
         <assert id="form1a" test="count(*)=2">The MathML "<value-of select="local-name()"/>" element should have two children, not <value-of select="count(*)"/>.</assert>
      </rule>
  </pattern>
   <pattern><!--elements which should have three child elements-->
      <rule context="mml:munderover|mml:msubsup" role="error">
         <assert id="form1b" test="count(*)=3">The MathML "<value-of select="local-name()"/>" element should have three children not <value-of select="count(*)"/>.</assert>
      </rule>
  </pattern>
   <pattern><!--equation with @id has used mtable to mark up the formula content-->
      <rule context="disp-formula[@id]/mml:math">
         <assert id="form2a" test="mml:mtable/mml:mlabeledtr">Where an equation is numbered in the pdf, the expression should be captured using "mml:mtable". The label should be captured as the first cell of "mml:mlabeledtr". If the equation is not numbered in the pdf, delete the 'id' attribute.</assert>
      </rule>
  </pattern>
   <pattern><!--do not use @display on mml:math-->
      <rule context="mml:math[@display]">
         <report id="form3" test=".">Do not use 'display' attribute on "mml:math". If the formula is inline, then use "inline-formula" as the parent element, otherwise use "disp-formula".</report>
      </rule>
  </pattern>
   <pattern><!--mml:labeledtr should only have mml:mtd child elements-->
      <rule context="mml:mlabeledtr[*[not(self::mml:mtd)]]">
         <report id="form4a" test=".">"mml:labeledtr" should only have "mml:mtd" child elements.</report>
      </rule>
  </pattern>
   <pattern><!--mml:mtr should only have mml:mtd child elements-->
      <rule context="mml:mtr[*[not(self::mml:mtd)]]">
         <report id="form4b" test=".">"mml:mtr" should only have "mml:mtd" child elements.</report>
      </rule>
  </pattern>
   <pattern><!--mml:math should not be child of p-->
      <rule context="mml:math[parent::p]">
         <report id="form5" test=".">Do not use "mml:math" on its own - please wrap the expression in "inline-formula".</report>
      </rule>
  </pattern>
   <pattern><!--inline-formula/mml:math should not be used for single letters-->
      <rule context="inline-formula/mml:math[count(descendant::*)=1][not(mml:mi/@mathvariant='script')]">
         <report id="form6" test=".">Single letters should not be tagged as an inline formula with MathML markup. Please use regular article elements and/or Unicode characters.</report>
      </rule>
  </pattern>
   <pattern>
		    <rule context="inline-formula[parent::italic]">
			      <report id="form7" test=".">Formulae should not appear inside italics. Please close "italic" element before start of "inline-formula" and reopen afterwards (if appropriate).</report>
		    </rule>
	  </pattern>
   <pattern><!--back - label or title should not be used-->
      <rule context="back/label | back/title" role="error">
         <report id="back1" test=".">Do not use "<name/>" at start of "back" matter.</report>
      </rule>
  </pattern>
   <pattern><!--ack - zero or one-->
      <rule context="ack" role="error">
         <report id="ack1" test="preceding-sibling::ack">There should only be one acknowledgements section.</report>
      </rule>
  </pattern>
   <pattern><!--ack - only p as child-->
      <rule context="ack/*[not(self::p)]" role="error">
         <report id="ack2" test=".">Acknowledgements should only contain paragraphs - do not use "<name/>".</report>
      </rule>
  </pattern>
   <pattern><!--ack - no attributes used-->
      <rule context="ack">
         <report id="ack3a" test="@id">Unnecessary use of "id" attribute on "ack" element.</report>
      </rule>
  </pattern>
   <pattern>
      <rule context="ack">
         <report id="ack3b" test="@content-type">Unnecessary use of "content-type" attribute on "ack" element.</report>
      </rule>
  </pattern>
   <pattern>
      <rule context="ack">
         <report id="ack3c" test="@specific-use">Unnecessary use of "specific-use" attribute on "ack" element.</report>
      </rule>
  </pattern>
   <pattern><!--ack/p - no attributes used-->
      <rule context="ack/p">
         <report id="ack4" test="@content-type">Unnecessary use of "content-type" attribute on "p" element in acknowledgements.</report>
      </rule>
  </pattern>
   <pattern><!--app-group - zero or one-->
      <rule context="app-group" role="error">
         <report id="app1" test="preceding-sibling::app-group">There should only be one appendix grouping.</report>
      </rule>
  </pattern>
   <pattern><!--app-group - no children apart from p and app used-->
      <rule context="app-group/*">
         <assert id="app2" test="self::p or self::app">Only "p" and "app" should be used in "app-group". Do not use "<name/>".</assert>
      </rule>
  </pattern>
   <pattern><!--app-group - no attributes used-->
      <rule context="app-group">
         <report id="app3a" test="@id">Unnecessary use of "id" attribute on "app-group" element.</report>
      </rule>
  </pattern>
   <pattern>
      <rule context="app-group">
         <report id="app3b" test="@content-type">Unnecessary use of "content-type" attribute on "app-group" element.</report>
      </rule>
  </pattern>
   <pattern>
      <rule context="app-group">
         <report id="app3c" test="@specific-use">Unnecessary use of "specific-use" attribute on "app-group" element.</report>
      </rule>
  </pattern>
   <pattern><!--app-group - no attributes on p used-->
      <rule context="app-group/p">
         <report id="app4" test="@content-type">Unnecessary use of "content-type" attribute on "p" in appendix.</report>
      </rule>
  </pattern>
   <pattern><!--app - no attributes used-->
      <rule context="app">
         <report id="app5b" test="@content-type">Unnecessary use of "content-type" attribute on "app" element.</report>
      </rule>
  </pattern>
   <pattern>
      <rule context="app">
         <report id="app5c" test="@specific-use">Unnecessary use of "specific-use" attribute on "app" element.</report>
      </rule>
  </pattern>
   <pattern><!--app - no attributes on p used-->
      <rule context="app//p">
         <report id="app6" test="@content-type">Unnecessary use of "content-type" attribute on "p" in appendix.</report>
      </rule>
  </pattern>
   <pattern><!--bio - zero or one-->
      <rule context="back/bio" role="error">
         <report id="bio1" test="preceding-sibling::bio">There should only be one "bio" (author information section) in "back".</report>
      </rule>
  </pattern>
   <pattern><!--bio - only p as child-->
      <rule context="back/bio/*[not(self::p|self::title)]" role="error">
         <report id="bio2" test=".">"bio" (author information section) in "back" should only contain paragraphs or title - do not use "<name/>".</report>
      </rule>
  </pattern>
   <pattern><!--bio - no attributes used-->
      <rule context="back/bio">
         <report id="bio3" test="attribute::*">Do not use attributes on "bio" element.</report>
      </rule>
  </pattern>
   <pattern><!--p in bio - no attributes used-->
      <rule context="back/bio/p">
         <report id="bio4" test="@content-type">Do not use "content-type" attribute on paragraphs in "bio" section.</report>
      </rule>
  </pattern>
   <pattern><!--fn-group - label or title should not be used-->
      <rule context="back/fn-group/label | back/fn-group/title" role="error">
         <report id="back-fn1" test=".">Do not use "<name/>" at start of footnote group in "back" matter.</report>
      </rule>
  </pattern>
   <pattern><!--fn-group - @content-type stated-->
      <rule context="back/fn-group" role="error">
         <assert id="back-fn2a" test="@content-type">Footnote groups in back matter should have 'content-type' attribute stated. Allowed values are "article-notes", "closenotes", "endnotes" or "footnotes".</assert>
      </rule>
  </pattern>
   <pattern><!--fn-group - @content-type allowed-->
      <rule context="back/fn-group[@content-type]" role="error">
         <assert id="back-fn2b"
                 test="@content-type='endnotes' or @content-type='footnotes' or @content-type='closenotes' or @content-type='article-notes'">Allowed values for 'content-type' attribute on "fn-group" are "article-notes", "closenotes", "endnotes" or "footnotes".</assert>
      </rule>
  </pattern>
   <pattern><!--fn-group - no id or specific-use attribute-->
      <rule context="back/fn-group" role="error">
         <report id="back-fn2c" test="@id">Do not use "id" attribute on "fn-group" in back matter.</report>
      </rule>
  </pattern>
   <pattern>
      <rule context="back/fn-group" role="error">
         <report id="back-fn2d" test="@specific-use">Do not use "specific-use" attribute on "fn-group" in back matter.</report>
      </rule>
  </pattern>
   <pattern><!--endnotes - fn-type="other"-->
      <rule context="back/fn-group[@content-type='endnotes']/fn" role="error">
         <assert id="back-fn4a" test="@fn-type='other'">"fn" within endnotes should have attribute fn-type="other".</assert>
      </rule>
  </pattern>
   <pattern><!--endnotes - id attribute not necessary-->
      <rule context="back/fn-group[@content-type='endnotes']/fn" role="error">
         <report id="back-fn4b" test="@id">'id' attribute is not necessary on endnotes.</report>
      </rule>
  </pattern>
   <pattern><!--endnotes - symbol attribute not necessary-->
      <rule context="back/fn-group[@content-type='endnotes']/fn" role="error">
         <report id="back-fn4c" test="@symbol">'symbol' attribute is not necessary on endnotes.</report>
      </rule>
  </pattern>
   <pattern><!--footnotes - @id used-->
      <rule context="back/fn-group[@content-type='footnotes']/fn" role="error">
         <assert id="back5a" test="@id">"fn" within footnotes section should have attribute 'id' declared. Expected format is "fn" followed by a number.</assert>
      </rule>
  </pattern>
   <pattern><!--footnotes - @id has required format-->
      <rule context="back/fn-group[@content-type='footnotes']/fn[@id]" role="error">
         <assert id="back5b" test="matches(@id,'^fn[0-9]+$')">Unexpected 'id' format found (<value-of select="@id"/>). Footnote ids should be "fn" followed by a number.</assert>
      </rule>
  </pattern>
   <pattern><!--footnotes - fn-type attribute not necessary-->
      <rule context="back/fn-group[@content-type='footnotes']/fn" role="error">
         <report id="back-fn5c" test="@fn-type">'fn-type' attribute is not necessary on article footnotes.</report>
      </rule>
  </pattern>
   <pattern><!--footnotes - symbol attribute not necessary-->
      <rule context="back/fn-group[@content-type='footnotes']/fn" role="error">
         <report id="back-fn5d" test="@symbol">'symbol' attribute is not necessary on article footnotes.</report>
      </rule>
  </pattern>
   <pattern><!--closenotes - fn-type="other"-->
      <rule context="back/fn-group[@content-type='closenotes']/fn" role="error">
         <assert id="back-fn6a" test="@fn-type='other'">"fn" within closenotes should have attribute fn-type="other".</assert>
      </rule>
  </pattern>
   <pattern><!--closenotes - id attribute not necessary-->
      <rule context="back/fn-group[@content-type='closenotes']/fn" role="error">
         <report id="back-fn6b" test="@id">'id' attribute is not necessary on closenotes.</report>
      </rule>
  </pattern>
   <pattern><!--closenotes - symbol attribute not necessary-->
      <rule context="back/fn-group[@content-type='closenotes']/fn" role="error">
         <report id="back-fn6c" test="@symbol">'symbol' attribute is not necessary on closenotes.</report>
      </rule>
  </pattern>
   <pattern><!--article-notes - fn-type="other"-->
      <rule context="back/fn-group[@content-type='article-notes']/fn" role="error">
         <assert id="back-fn7a" test="@fn-type='other'">"fn" within article-notes should have attribute fn-type="other".</assert>
      </rule>
  </pattern>
   <pattern><!--article-notes - id attribute not necessary-->
      <rule context="back/fn-group[@content-type='article-notes']/fn" role="error">
         <report id="back-fn7b" test="@id">'id' attribute is not necessary on article-notes.</report>
      </rule>
  </pattern>
   <pattern><!--article-notes - symbol attribute not necessary-->
      <rule context="back/fn-group[@content-type='article-notes']/fn" role="error">
         <report id="back-fn7c" test="@symbol">'symbol' attribute is not necessary on article-notes.</report>
      </rule>
  </pattern>
   <pattern><!--notes - should have @notes-type-->
      <rule context="back/notes[not(@notes-type)]" role="error">
         <report id="notes1" test=".">"notes" should have 'notes-type' attribute. Allowed values are: "database-links", "note-in-proof", "disclaimer" or "contact".</report>
      </rule>
  </pattern>
   <pattern><!--notes - @notes-type="database-links"-->
      <rule context="back/notes[@notes-type]" role="error">
         <assert id="notes2a"
                 test="matches(@notes-type,'^(database-links|note-in-proof|disclaimer|contact)$')">Unexpected value for "notes" attribute 'notes-type' ("<value-of select="@notes-type"/>").  Allowed values are: "database-links", "note-in-proof", "disclaimer" or "contact".</assert>
      </rule>
  </pattern>
   <pattern><!--notes - no id or specific-use attribute-->
      <rule context="back/notes" role="error">
         <report id="notes2b" test="@id">Do not use "id" attribute on "notes" in back matter.</report>
      </rule>
  </pattern>
   <pattern><!--notes - no id or specific-use attribute-->
      <rule context="back/notes" role="error">
         <report id="notes2c" test="@specific-use">Do not use "specific-use" attribute on "notes" in back matter.</report>
      </rule>
  </pattern>
   <pattern><!--notes - @notes-type="database-links"-->
      <rule context="back/notes[matches(@notes-type,'^(disclaimer|contact)$')]"
            role="error">
         <assert id="notes2d" test="$article-type='advert'">"<value-of select="@notes-type"/>" note should only be used in adverts. Please contact Production to get tagging instructions.</assert>
      </rule>
  </pattern>
   <pattern><!--para in notes - only one ext-link per para-->
      <rule context="back/notes/p">
         <report id="notes3a" test="count(ext-link) gt 1">Take a new paragraph for each "ext-link" in the database link (notes) section.</report>
      </rule>
  </pattern>
   <pattern><!--para in notes - no attributes used-->
      <rule context="back/notes/p">
         <report id="notes3b" test="attribute::*">Do not use attributes on paragraphs in the database link (notes) section.</report>
      </rule>
  </pattern>
   <pattern><!--notes ext-link - @ext-link-type used-->
      <rule context="back/notes/p/ext-link">
         <assert id="notes4a" test="@ext-link-type">External links to databases should have 'ext-link-type' attribute stated. Allowed values are "genbank" or "pdb".</assert>
      </rule>
  </pattern>
   <pattern><!--notes ext-link - @ext-link-type allowed-->
      <rule context="back/notes/p/ext-link[@ext-link-type]" role="error">
         <assert id="notes4b" test="@ext-link-type='genbank' or @ext-link-type='pdb'">Allowed values for 'ext-link-type' attribute on "ext-link" in notes section are "genbank" or "pdb".</assert>
      </rule>
  </pattern>
   <pattern><!--notes ext-link - @ext-link-type allowed-->
      <rule context="back/notes/p/ext-link" role="error">
         <assert id="notes4c" test="@xlink:href">External database links should have attribute 'xlink:href' declared.</assert>
      </rule>
  </pattern>
   <pattern><!--notes ext-link - @ext-link-type allowed-->
      <rule context="back/notes/p/ext-link[@xlink:href]" role="error">
         <assert id="notes4d" test="@xlink:href=.">'xlink:href' should be equal to the link text (<value-of select="."/>).</assert>
      </rule>
  </pattern>
   <pattern><!--elements not allowed as children of mixed-citation-->
      <rule context="ref/mixed-citation/alternatives|ref/mixed-citation/chem-struct|ref/mixed-citation/conf-date|ref/mixed-citation/conf-loc|ref/mixed-citation/conf-name|ref/mixed-citation/conf-sponsor|ref/mixed-citation/date|ref/mixed-citation/date-in-citation|ref/mixed-citation/inline-graphic|ref/mixed-citation/institution|ref/mixed-citation/label|ref/mixed-citation/name|ref/mixed-citation/name-alternatives|ref/mixed-citation/private-char|ref/mixed-citation/role|ref/mixed-citation/series|ref/mixed-citation/size|ref/mixed-citation/supplement"
            role="error">
         <report id="disallowed2" test=".">Do not use "<name/>" element in "mixed-citation" in Springer Nature articles.</report>
      </rule>
  </pattern>
   <pattern><!--elements not allowed as children of ref-list-->
      <rule context="ref-list/label|ref-list/address|ref-list/alternatives|ref-list/array|ref-list/chem-struct-wrap|ref-list/graphic|ref-list/media|ref-list/preformat|ref-list/disp-formula|ref-list/disp-formula-group|ref-list/def-list|ref-list/list|ref-list/mml:math|ref-list/related-article|ref-list/related-object|ref-list/disp-quote|ref-list/speech|ref-list/statement|ref-list/verse-group"
            role="error">
         <report id="disallowed3" test=".">Do not use "<name/>" element in "ref-list" in Springer Nature articles.</report>
      </rule>
  </pattern>
   <pattern><!--no brackets in year-->
      <rule context="ref[not($transition='yes')]/mixed-citation/year" role="error">
         <report id="punct1a" test="starts-with(.,'(') or ends-with(.,')')">Do not include parentheses in the "year" element in citations in Springer Nature articles.</report>
      </rule>
  </pattern>
   <pattern><!--no brackets in publisher-name-->
      <rule context="ref/mixed-citation/publisher-name" role="error">
         <report id="punct1b" test="starts-with(.,'(') and ends-with(.,')')">Do not include parentheses in the "publisher-name" element in citations in Springer Nature articles.</report>
      </rule>
  </pattern>
   <pattern><!--elocation-id should have @content-type in citations-->
      <rule context="ref/mixed-citation/elocation-id" role="error">
         <assert id="eloc1a" test="@content-type">"elocation-id" should have a 'content-type' attribute when used in citations. Allowed values are "doi" and "article-number". If the reference is to an ISBN or ISSN, then use "isbn" or "issn" elements instead.</assert>
      </rule>
  </pattern>
   <pattern><!--elocation-id should only be used for doi and article number, not issn or isbn-->
      <rule context="ref/mixed-citation/elocation-id[@content-type]" role="error">
         <assert id="eloc1b"
                 test="@content-type='doi' or @content-type='article-number'">"elocation-id" 'content-type' attribute in citations only has allowed values of "doi" or "article-number". If the reference is to an ISBN or ISSN, then use "isbn" or "issn" elements instead on the number only (the text 'ISBN' or 'ISSN' should remain outside the element).</assert>
      </rule>
  </pattern>
   <pattern><!--elocation-id should not contain text 'doi'-->
      <rule context="ref[not($transition='yes')]/mixed-citation/elocation-id[@content-type='doi']"
            role="error">
         <report id="eloc1c" test="starts-with(.,'doi')">"elocation-id" should contain the DOI value only - move the text 'doi' and any punctuation to be outside the "doi" element.</report>
      </rule>
  </pattern>
   <pattern><!--isbn should not contain text 'ISBN'-->
      <rule context="ref[not($transition='yes')]/mixed-citation/isbn" role="error">
         <report id="isbn1" test="starts-with(.,'ISBN')">"isbn" should contain the ISBN value only - move the text 'ISBN' and any punctuation to be outside the "isbn" element.</report>
      </rule>
  </pattern>
   <pattern><!--Reference lists should have specific-use attribute to give style info-->
      <rule context="back/ref-list[not(@content-type)]" role="error">
         <assert id="reflist1a" test="@specific-use">Ref-list should have a 'specific-use' attribute with value "alpha" (for alphabetical references) or "numero" (for numbered references).</assert>
      </rule>
  </pattern>
   <pattern><!--ref-list specific-use attribute should be 'alpha' or 'numero'-->
      <rule context="back/ref-list[not(@content-type)][@specific-use]" role="error">
         <assert id="reflist1b" test="@specific-use='alpha' or @specific-use='numero'">Ref-list 'specific-use' attribute should have value "alpha" (for alphabetical references) or "numero" (for numbered references), not "<value-of select="@specific-use"/>".</assert>
      </rule>
  </pattern>
   <pattern><!--ref-list - do not use 'id' attribute-->
      <rule context="ref-list" role="error">
         <report id="reflist1c" test="@id">Do not use 'id' attribute on "ref-list".</report>
      </rule>
  </pattern>
   <pattern><!--ref-list - do not use 'content-type' attribute (except for link groups)-->
      <rule context="ref-list[@content-type]" role="error">
         <assert id="reflist1d"
                 test="@content-type='link-group' or @content-type='data-citations'">Do not use 'content-type' attribute on "ref-list", except for 'link-group' or 'data-citations'.</assert>
      </rule>
  </pattern>
   <pattern><!--ref-list does not need title "References"-->
      <rule context="back/ref-list[not(@content-type)]/title" role="error">
         <report id="reflist2a" test="lower-case(.)='references'">A "title" element with text 'References' is not necessary at the start of the References section - please delete.</report>
      </rule>
  </pattern>
   <pattern><!--citations in ref-list do not need labels, values can be generated from id-->
      <rule context="back/ref-list[not(@content-type='link-group')]//ref/label"
            role="error">
         <report id="reflist3a" test=".">Delete unnecessary "label" element in reference.</report>
      </rule>
  </pattern>
   <pattern><!--ref - must have an @id-->
      <rule context="back/ref-list[not(@content-type)]/ref" role="error">
         <assert id="reflist4a" test="@id">Missing 'id' attribute - "ref" should have an 'id' of the form "b"+number (with no leading zeros).</assert>
      </rule>
  </pattern>
   <pattern><!--ref - @id must be correct format-->
      <rule context="back/ref-list[not(@content-type)]/ref[@id]" role="error">
         <assert id="reflist4b" test="matches(@id,'^b[1-9][0-9]*$')">Invalid 'id' value ("<value-of select="@id"/>"). "ref" 'id' attribute should be of the form "b"+number (with no leading zeros).</assert>
      </rule>
  </pattern>
   <pattern><!--data citation - must have an @id-->
      <rule context="back/ref-list[@content-type='data-citations']/ref"
            role="error">
         <assert id="reflist4c" test="@id">Missing 'id' attribute - "ref" should have an 'id' of the form "d"+number (with no leading zeros).</assert>
      </rule>
  </pattern>
   <pattern><!--data citation - @id must be correct format-->
      <rule context="back/ref-list[@content-type='data-citations']/ref[@id]"
            role="error">
         <assert id="reflist4d" test="matches(@id,'^d[1-9][0-9]*$')">Invalid 'id' value ("<value-of select="@id"/>"). "ref" 'id' attribute should be of the form "d"+number (with no leading zeros).</assert>
      </rule>
  </pattern>
   <pattern><!--surname and given-names should be separated by whitespace, otherwise do not get rendered properly-->
      <rule context="back/ref-list[not(@content-type)]//ref/mixed-citation/string-name/surname"
            role="error">
         <report id="reflist5a" test="following::node()[1]/self::given-names">Insert a space between "surname" and "given-names" in references.</report>
      </rule>
  </pattern>
   <pattern>
      <rule context="etal" role="error"><!--etal not followed by full stop-->
         <report id="reflist5b" test="starts-with(following::node()[1],'.')">"etal" should not be followed by a full stop - in Springer Nature articles, it is the equivalent of 'et al.' in italics.</report>
      </rule>
  </pattern>
   <pattern>
      <rule context="etal" role="error"><!--etal should be empty-->
         <report id="reflist5c" test="normalize-space(.) or *">"etal" should be an empty element in Springer Nature articles - please delete content.</report>
      </rule>
  </pattern>
   <pattern><!--collab should have @collab-type-->
      <rule context="back/ref-list[not(@content-type)]//ref/mixed-citation/collab"
            role="error">
         <assert id="reflist5d" test="@collab-type">"collab" should have a 'collab-type' attribute with value "corporate-author" (for a committee, consortium or other collaborative group) or "on-behalf-of" (where this text is used in the reference).</assert>
      </rule>
  </pattern>
   <pattern><!--@collab-type should have allowed values-->
      <rule context="back/ref-list[not(@content-type)]//ref/mixed-citation/collab[@collab-type]"
            role="error">
         <assert id="reflist5e"
                 test="@collab-type='corporate-author' or @collab-type='on-behalf-of'">"collab" 'collab-type' attribute should have value "corporate-author" (for a committee, consortium or other collaborative group) or "on-behalf-of" (where this text is used in the reference), not "<value-of select="@collab-type"/>".</assert>
      </rule>
  </pattern>
   <pattern><!--book citations should not have "article-title"-->
      <rule context="back/ref-list[not(@content-type)]//ref/mixed-citation[@publication-type='book']/article-title"
            role="error">
         <report id="reflist6a" test=".">"article-title" should not be used in book citation "<value-of select="ancestor::ref/@id"/>". Use "chapter-title" instead.</report>
      </rule>
  </pattern>
   <pattern><!--book citations should have "source" and "year"-->
      <rule context="back/ref-list[not(@content-type)]//ref/mixed-citation[@publication-type='book'][not(source) and not(year)]"
            role="error">
         <report id="reflist6b" test=".">Book citation "<value-of select="ancestor::ref/@id"/>" does not have "source" or "year". Either mark these up, or change 'publication-type' to "other".</report>
      </rule>
  </pattern>
   <pattern><!--book citations should have "source" and "year"-->
      <rule context="back[$maestro='yes']/ref-list[not(@content-type)]//ref/mixed-citation[@publication-type='book'][source and not(year)]"
            role="error">
         <report id="reflist6c" test=".">Book citation "<value-of select="ancestor::ref/@id"/>" has "source" but no "year". Either mark up the year, or change 'publication-type' to "other".</report>
      </rule>
  </pattern>
   <pattern><!--book citations should have "source" and "year"-->
      <rule context="back/ref-list[not(@content-type)]//ref/mixed-citation[@publication-type='book'][not(source) and year]"
            role="error">
         <report id="reflist6d" test=".">Book citation "<value-of select="ancestor::ref/@id"/>" has "year" but no "source". Either mark up the source, or change 'publication-type' to "other".</report>
      </rule>
  </pattern>
   <pattern><!--second set of authors in book citation should be contained in person-group-->
      <rule context="back[not($transition='yes')]//mixed-citation[@publication-type='book']/chapter-title"
            role="error">
         <report id="reflist7a" test="following-sibling::string-name">The second set of author/editor names in book citation "<value-of select="ancestor::ref/@id"/>" should be enclosed in "person-group" with a 'person-group-type' attribute to identify authors/editors etc.</report>
      </rule>
  </pattern>
   <pattern><!--person-group should have @person-group-type-->
      <rule context="back//mixed-citation[@publication-type='book']/person-group"
            role="error">
         <assert id="reflist7b" test="@person-group-type">"person-group" in citation "<value-of select="ancestor::ref/@id"/>" should have a 'person-group-type' attribute to identify authors/editors etc.</assert>
      </rule>
  </pattern>
   <pattern><!--person-group should not have @id-->
      <rule context="back//mixed-citation[@publication-type='book']/person-group"
            role="error">
         <report id="reflist7c" test="@id">Do not use 'id' attribute on "person-group" in citation "<value-of select="ancestor::ref/@id"/>".</report>
      </rule>
  </pattern>
   <pattern><!--person-group should not have @specific-use-->
      <rule context="back//mixed-citation[@publication-type='book']/person-group"
            role="error">
         <report id="reflist7d" test="@specific-use">Do not use 'specific-use' attribute on "person-group" in citation "<value-of select="ancestor::ref/@id"/>".</report>
      </rule>
  </pattern>
   <pattern><!--person-group should not have @xml:lang-->
      <rule context="back//mixed-citation[@publication-type='book']/person-group"
            role="error">
         <report id="reflist7e" test="@xml:lang">Do not use 'xml:lang' attribute on "person-group" in citation "<value-of select="ancestor::ref/@id"/>".</report>
      </rule>
  </pattern>
   <pattern><!--person-group should only be used in book citations for the second group of authors-->
      <rule context="back//mixed-citation[not(@publication-type='other')]/person-group"
            role="error">
         <assert id="reflist7f"
                 test="parent::mixed-citation[@publication-type='book'] and preceding-sibling::*">"person-group" should only be used to capture the second group of editors/authors in a book citation. Do not use it in citation "<value-of select="ancestor::ref/@id"/>".</assert>
      </rule>
  </pattern>
   <pattern><!--"other" publication-type should not have "article-title" and "source"-->
      <rule context="ref/mixed-citation[@publication-type='other'][source and article-title]"
            role="error">
         <report id="reflist8a" test=".">Citation "<value-of select="parent::ref/@id"/>" contains an article-title (<value-of select="article-title"/>) and a "source" (<value-of select="source"/>). Therefore it should have 'publication-type="journal"', not "other".</report>
      </rule>
  </pattern>
   <pattern><!--publisher-loc should not be used instead of publisher-name-->
      <rule context="ref/mixed-citation[not(publisher-name)]/publisher-loc"
            role="error">
         <report id="reflist9a" test=".">Citation "<value-of select="ancestor::ref/@id"/>" has "publisher-loc" (<value-of select="."/>), but no corresponding "publisher-name". Change "publisher-loc" to "publisher-name" or add publisher name information.</report>
      </rule>
  </pattern>
   <pattern><!--article-title should not contain 'ext-link'-->
      <rule context="ref/mixed-citation/article-title[ext-link]" role="error">
         <report id="reflist9b" test=".">"ext-link" should not be used in "article-title". The closing tag of "article-title" is probably in the wrong place - please check.</report>
      </rule>
  </pattern>
   <pattern><!--journal citation should not contain chapter-title-->
      <rule context="ref[$maestro-aj='yes']/mixed-citation[@publication-type='journal']/chapter-title"
            role="error">
         <report id="reflist10a" test=".">Journal citation "<value-of select="ancestor::ref/@id"/>" (source: <value-of select="parent::mixed-citation/source"/>) should not use "chapter-title". Change this to "article-title" (or check if this should be a book citation).</report>
      </rule>
  </pattern>
   <pattern><!--journal citation should have source and article-title-->
      <rule context="ref[$maestro-aj='yes']/mixed-citation[@publication-type='journal'][source][not(chapter-title|article-title)]"
            role="error">
         <report id="reflist10b" test=".">Journal citation "<value-of select="parent::ref/@id"/>" only has "source" identified (<value-of select="source"/>). Mark up the "article-title" or change to 'publication-type="book"'.</report>
      </rule>
  </pattern>
   <pattern><!--journal citation should have source and article-title-->
      <rule context="ref[$maestro-aj='yes']/mixed-citation[@publication-type='journal'][not(source)]"
            role="error">
         <report id="reflist10c" test="article-title">Journal citation "<value-of select="parent::ref/@id"/>" only has "article-title" identified (<value-of select="article-title"/>). Mark up the "source" also.</report>
      </rule>
  </pattern>
   <pattern><!--citation should not contain two <years> - messes up transforms-->
      <rule context="ref[$maestro='yes']/mixed-citation[count(year) gt 1]"
            role="error">
         <report id="reflist11a" test=".">Citation "<value-of select="ancestor::ref/@id"/>" has two "year" elements. Please check that the citation has been constructed correctly.</report>
      </rule>
  </pattern>
   <pattern><!--table-wrap should be child of floats-group-->
        <rule context="table-wrap[not(ancestor::floats-group)]" role="error">
            <report id="tab1" test="." role="error">"table-wrap" should be within "floats-group", not "<value-of select="local-name(ancestor::*[parent::article])"/>".</report>
        </rule>
    </pattern>
   <pattern><!--table-wrap should not be inside another table-->
        <rule context="table-wrap[@id][ancestor::table-wrap[@id]]" role="error">
         <let name="tabId" value="substring-after(@id,'t')"/>
         <let name="ancestorId" value="substring-after(ancestor::table-wrap/@id,'t')"/>
            <report id="tab1b" test="." role="error">Table <value-of select="$tabId"/> is contained within Table <value-of select="$ancestorId"/>. It should be a separate block-level element in "floats-group".</report>
        </rule>
    </pattern>
   <pattern><!--table - must have an @id-->
        <rule context="table-wrap[not(@id)]" role="error">
            <report id="tab2a" test=".">Missing 'id' attribute - "table-wrap" should have an 'id' of the form "t"+number (with no leading zeros).</report>
        </rule>
    </pattern>
   <pattern><!--table - @id must be correct format-->
        <rule context="table-wrap[@id][not($transition='yes')]" role="error">
            <assert id="tab2b" test="matches(@id,'^t[A-Z]?[1-9][0-9]*$')">Invalid 'id' value ("<value-of select="@id"/>"). "table-wrap" 'id' attribute should be of the form "t"+number (with no leading zeros).</assert>
        </rule>
    </pattern>
   <pattern><!--table - label not necessary if text is of form "Table 1" etc-->
        <rule context="table-wrap[matches(@id,'^t[A-Z]?[1-9][0-9]*$')]/label"
            role="error">
            <let name="derivedLabel"
              value="concat('Table ',translate(parent::table-wrap/@id,'t',''))"/>
            <report id="tab2c" test=".=$derivedLabel">Table "label" is not necessary when text is of the standard format "<value-of select="$derivedLabel"/>" - please delete.</report>
        </rule>
    </pattern>
   <pattern><!--table footnote - @id must be correct format-->
        <rule context="table-wrap-foot/fn[@id][not($transition='yes')]" role="error">
        	<let name="tabfn-id-stem" value="concat(ancestor::table-wrap/@id,'-fn')"/>
            <assert id="tab3" test="matches(@id,'^t[A-Za-z]?[1-9][0-9]*-fn[1-9][0-9]*$')">Invalid 'id' value ("<value-of select="@id"/>"). Table footnote 'id' attribute should be of the form "<value-of select="$tabfn-id-stem"/>"+number (with no leading zeros).</assert>
        </rule>
    </pattern>
   <pattern><!--caption must contain a title-->
        <rule context="table-wrap/caption[not(title) and p]" role="error">
            <report id="tab5a" test="." role="error">Table-wrap "caption" should contain a "title" element - change "p" to "title".</report>
        </rule>
    </pattern>
   <pattern><!--caption should not be empty (strip out unicode spaces as well - &#x2003; &#x2009;)-->
        <rule context="table-wrap/caption" role="error">
            <let name="text" value="replace(.,'( )|( )','')"/>
            <assert id="tab5b" test="normalize-space($text) or *" role="error">Table-wrap "caption" should not be empty - it should contain a "title" or not be used at all.</assert>
        </rule>
    </pattern>
   <pattern><!--caption children should not be empty (strip out unicode spaces as well - &#x2003; &#x2009;)-->
        <rule context="table-wrap/caption/p" role="error">
            <let name="text" value="replace(.,'( )|( )','')"/>
            <assert id="tab5c" test="normalize-space($text) or *" role="error">Do not use empty "p" element in table-wrap "caption".</assert>
        </rule>
    </pattern>
   <pattern><!--caption should not have attributes-->
        <rule context="table-wrap/caption[attribute::*]" role="error">
            <report id="tab5d" test="." role="error">Do not use attributes on table-wrap "caption".</report>
        </rule>
    </pattern>
   <pattern><!--caption title should not have attributes-->
        <rule context="table-wrap/caption/title[@specific-use]" role="error">
            <report id="tab5e-1" test="." role="error">Do not use 'specific-use' attribute on "title" within table-wrap "caption".</report>
        </rule>
    </pattern>
   <pattern><!--caption p should not have attributes-->
        <rule context="table-wrap/caption/p[@content-type]" role="error">
            <report id="tab5e-2" test="." role="error">Do not use 'content-type' attribute on "p" within table-wrap "caption".</report>
        </rule>
    </pattern>
   <pattern>
      <rule context="table-wrap-foot[$maestro='yes']/fn" role="error">
        <let name="id" value="@id"/>
        <assert id="tab10a"
                 test="ancestor::article//xref[@ref-type='table-fn'][@rid=$id]">Table footnote is not linked to. Either insert a correctly numbered link, or just mark up as a table footer paragraph.</assert>
      </rule>
    </pattern>
   <pattern>
        <rule context="table-wrap-foot[$maestro='yes']/fn" role="error">
            <let name="id" value="@id"/>
            <assert id="tab10b"
                 test="not(ancestor::article//xref[@ref-type='table-fn'][@rid=$id]) or label">Table footnote should contain "label" element - check if it is a footnote or should just be a table footer paragraph.</assert>
        </rule>
    </pattern>
   <pattern>
        <rule context="xref[@ref-type='table-fn'][not($transition='yes')]"
            role="error"><!--Does symbol in link match symbol on footnote?-->
            <let name="id" value="@rid"/>
            <let name="sup-link" value="descendant::text()"/>
            <let name="sup-fn"
              value="ancestor::article//table-wrap-foot/fn[@id=$id]/label//text()"/>
            <assert id="tab10c" test="not($sup-fn) or not($sup-link) or $sup-link=$sup-fn">Mismatch on linking text: "<value-of select="$sup-link"/>" in table, but "<value-of select="$sup-fn"/>" in footnote. Please check that correct footnote has been linked to.</assert>
        </rule>
    </pattern>
   <pattern>
        <rule context="xref[@ref-type='table-fn'][not($transition='yes')][not(parent::sup or descendant::sup)][matches(descendant::text(),'^[a-z]$')]"
            role="error"><!--single letter references should be superscript-->
            <report id="tab10d" test=".">Table footnote xref to "<value-of select="@rid"/>" should be wrapped in superscript element "sup".</report>
        </rule>
    </pattern>
   <pattern>
        <rule context="table-wrap-foot/fn-group" role="error"><!--do not use fn-group in table footer-->
            <report id="tab10e" test=".">Do not use "fn-group" within "table-wrap-foot".</report>
        </rule>
    </pattern>
   <pattern>
        <rule context="oasis:entry[@namest and @nameend and not(@align)]">
            <report id="tab11a" test=".">Spanning table entries should also have an 'align' attribute.</report>
        </rule>
    </pattern>
   <pattern>
        <rule context="oasis:entry[@nameend and not(@namest)]">
            <report id="tab11b" test=".">Table entry has 'nameend' attribute (<value-of select="@nameend"/>), but there is no 'namest' attribute. Spanning entries should have both these attributes; non-spanning entries should have neither.</report>
        </rule>
    </pattern>
   <pattern>
        <rule context="oasis:entry[@namest and not(@nameend)]">
            <report id="tab11c" test=".">Table entry has 'namest' attribute (<value-of select="@namest"/>), but there is no 'nameend' attribute. Spanning entries should have both these attributes; non-spanning entries should have neither.</report>
        </rule>
    </pattern>
   <pattern>
        <rule context="oasis:entry[@namest and @nameend and @colname]">
            <report id="tab11d" test=".">Spanning table entries should not have 'colname' attribute - please delete.</report>
        </rule>
    </pattern>
   <pattern>
        <rule context="oasis:entry[@namest]">
        	<let name="namest" value="@namest"/>
            <assert id="tab12a"
                 test="ancestor::oasis:tgroup/oasis:colspec[@colname eq $namest]">Table entry 'namest' attribute (<value-of select="$namest"/>) has not been defined in colspec.</assert>
        </rule>
    </pattern>
   <pattern>
        <rule context="oasis:entry[@nameend]">
        	<let name="nameend" value="@nameend"/>
            <assert id="tab12b"
                 test="ancestor::oasis:tgroup/oasis:colspec[@colname eq $nameend]">Table entry 'nameend' attribute (<value-of select="$nameend"/>) has not been defined in colspec.</assert>
        </rule>
    </pattern>
   <pattern>
        <rule context="oasis:entry[matches(@namest,'[0-9]') and matches(@nameend,'[0-9]')]">
        	<let name="namest" value="number(replace(@namest, '[^\d]', ''))"/>
        	<let name="nameend" value="number(replace(@nameend, '[^\d]', ''))"/>
            <assert id="tab12c" test="$nameend gt $namest">In spanning table entries, the value of the 'nameend' (<value-of select="@nameend"/>) attribute should be greater than the 'namest' attribute (<value-of select="@namest"/>).</assert>
        </rule>
    </pattern>
   <pattern>
      <rule context="fig//graphic[@xlink:href='' or @mimetype='' or @mime-subtype='']"
            role="error">
        <report id="fig1a" test=".">Graphic attribute values 'xlink:href', 'mimetype' and 'mime-subtype' should be used and not be empty. If the article has been converted from AJ or NPG XML, please check that entity declarations have been converted correctly before transformation.</report>
      </rule>
   </pattern>
   <pattern>
        <rule context="fig-group" role="error">
            <report id="fig1b" test=".">Do not use "fig-group" in Springer Nature articles. Figures should be captured as direct children of "floats-group".</report>
        </rule>
    </pattern>
   <pattern>
        <rule context="fig[not(parent::floats-group or parent::fig-group)]"
            role="error">
            <report id="fig1c" test=".">"fig" should be only be a child of "floats-group" in Springer Nature articles - not "<value-of select="local-name(parent::*)"/>".</report>
        </rule>
    </pattern>
   <pattern><!--fig - allowed children only-->
        <rule context="fig/alt-text | fig/long-desc | fig/email | fig/ext-link | fig/disp-formula | fig/disp-formula-group | fig/chem-struct-wrap | fig/disp-quote | fig/speech | fig/statement | fig/verse-group | fig/table-wrap | fig/p | fig/def-list | fig/list | fig/array | fig/media | fig/preformat | fig/permissions"
            role="error">
            <report id="fig2a" test=".">Do not use "<name/>" as a child of "fig". Refer to Tagging Instructions for sample markup.</report>
        </rule>
    </pattern>
   <pattern><!--fig - caption must not be empty-->
        <rule context="fig/caption" role="error">
            <assert id="fig2b" test="normalize-space(.)">Figure "caption" should not be empty.</assert>
        </rule>
    </pattern>
   <pattern><!--fig - caption must not have attributes-->
        <rule context="fig/caption[attribute::*]" role="error">
            <report id="fig2c" test=".">Do not use attributes on figure "caption".</report>
        </rule>
    </pattern>
   <pattern><!--fig - label must not have attributes-->
        <rule context="fig/label[attribute::*]" role="error">
            <report id="fig2d" test=".">Do not use attributes on figure "label".</report>
        </rule>
    </pattern>
   <pattern><!--fig - label not necessary if text is of form "Figure 1" etc-->
        <rule context="fig[matches(@id,'^f[A-Z]?[1-9][0-9]*$')]/label" role="error">
            <let name="derivedLabel"
              value="concat('Figure ',translate(parent::fig/@id,'f',''))"/>
            <report id="fig2e" test=".=$derivedLabel">Figure "label" is not necessary when text is of the standard format "<value-of select="$derivedLabel"/>" - please delete.</report>
        </rule>
    </pattern>
   <pattern><!--fig - must have an @id-->
        <rule context="fig[not(@fig-type='cover-image')][not(@id)]" role="error">
            <report id="fig3a" test=".">Missing 'id' attribute - "fig" should have an 'id' of the form "f"+number (with no leading zeros).</report>
        </rule>
    </pattern>
   <pattern><!--fig - @id must be correct format-->
        <rule context="fig[@id][not(@specific-use='suppinfo')]" role="error">
            <assert id="fig3b" test="matches(@id,'^f[A-Z]?[1-9][0-9]*$')">Invalid 'id' value ("<value-of select="@id"/>"). "fig" 'id' attribute should be of the form "f"+number (with no leading zeros).</assert>
        </rule>
    </pattern>
   <pattern><!--supplementary figures - @id must be correct format-->
        <rule context="fig[@id][@specific-use='suppinfo']" role="error">
            <assert id="fig3b-2" test="matches(@id,'^sf[A-Z]?[1-9][0-9]*$')">Invalid 'id' value ("<value-of select="@id"/>"). Supplementary figure 'id' attribute should be of the form "sf"+number (with no leading zeros).</assert>
        </rule>
    </pattern>
   <pattern>
        <rule context="fig[@specific-use][not(@specific-use='suppinfo')]"
            role="error">
            <report id="fig3c" test="." role="error">Do not use "specific-use" attribute on "fig".</report>
        </rule>
    </pattern>
   <pattern>
        <rule context="fig[@xml:lang]" role="error">
            <report id="fig3d" test="." role="error">Do not use "xml:lang" attribute on "fig".</report>
        </rule>
    </pattern>
   <pattern><!--fig - must have an @xlink:href-->
        <rule context="fig//graphic[not(@xlink:href)]" role="error">
            <report id="fig4a" test=".">Missing 'xlink:href' attribute on figure "graphic". The 'xlink:href' should contain the filename (including extension) of the graphic. Do not include any path information.</report>
        </rule>
    </pattern>
   <pattern><!--@xlink:href does not contain filepath info-->
        <rule context="fig//graphic[@xlink:href]" role="error">
            <report id="fig4b" test="contains(@xlink:href,'/')">Do not include filepath information for figure graphic files "<value-of select="@xlink:href"/>".</report>
        </rule>
    </pattern>
   <pattern><!--@xlink:href contains a '.' and therefore may have an extension-->
        <rule context="fig//graphic[@xlink:href][not(@xlink:href='')]" role="error">
            <assert id="fig4c" test="contains(@xlink:href,'.')">Figure graphic 'xlink:href' value ("<value-of select="@xlink:href"/>") should contain the file extension (e.g. jpg, gif, etc).</assert>
        </rule>
    </pattern>
   <pattern><!--@xlink:href has valid file extension - check allowed image extensions-->
        <rule context="fig//graphic[@xlink:href][not(@xlink:href='')][contains(@xlink:href,'.')]"
            role="error">
            <let name="extension" value="functx:substring-after-last(@xlink:href,'.')"/>
            <assert id="fig4d"
                 test="matches($extension,'^(eps|gif|jpg|jpeg|bmp|png|pict|ps|tiff|wmf|doc|docx|pdf|pps|ppt|pptx|xls|xlsx|tar|tgz|zip|c|csv|htm|html|rtf|txt|xml|aiff|au|avi|midi|mov|mp2|mp3|mp4|mpa|mpg|noa|qt|ra|ram|rv|swf|wav|wmv|cif|exe|pdb|sdf|sif)$')">Unexpected file extension value ("<value-of select="$extension"/>") in figure "graphic" '@xlink:href' attribute - please check.</assert>
        </rule>
    </pattern>
   <pattern><!--fig graphic - must have a @mimetype; when @xlink:href does not exist, point to Tagging instructions-->
        <rule context="fig//graphic[not(@xlink:href or contains(@xlink:href,'.'))][not(@mimetype)]"
            role="error">
            <report id="fig5a" test=".">Missing 'mimetype' attribute on figure "graphic". Refer to Tagging Instructions for correct value.</report>
        </rule>
    </pattern>
   <pattern><!--fig graphic - must have a @mimetype; when @xlink:href is invalid, point to Tagging instructions-->
        <rule context="fig//graphic[contains(@xlink:href,'.')]" role="error">
            <let name="extension" value="functx:substring-after-last(@xlink:href,'.')"/>
            <report id="fig5b"
                 test="not(matches($extension,'^(eps|gif|jpg|jpeg|bmp|png|pict|ps|tiff|wmf|doc|docx|pdf|pps|ppt|pptx|xls|xlsx|tar|tgz|zip|c|csv|htm|html|rtf|txt|xml|aiff|au|avi|midi|mov|mp2|mp3|mp4|mpa|mpg|noa|qt|ra|ram|rv|swf|wav|wmv|cif|exe|pdb|sdf|sif)$')) and not(@mimetype)">Missing 'mimetype' attribute on figure "graphic". Refer to Tagging Instructions for correct value.</report>
        </rule>
    </pattern>
   <pattern><!--fig graphic - must have a @mimetype; when @xlink:href exists (and is valid) gives value that should be used-->
        <rule context="fig//graphic[contains(@xlink:href,'.')]" role="error">
            <let name="extension" value="functx:substring-after-last(@xlink:href,'.')"/>
            <let name="mimetype"
              value="if (matches($extension,'^(doc|docx|eps|exe|noa|pdf|pps|ppt|pptx|ps|rtf|swf|tar|tgz|wmf|xls|xlsx|xml|zip)$')) then 'application'                 else if (matches($extension,'^(mp2|mp3|ra|wav)$')) then 'audio'                 else if (matches($extension,'^(cif|pdb|sdf)$')) then 'chemical'                 else if (matches($extension,'^(bmp|gif|jpeg|jpg|pict|png|tiff)$')) then 'image'                 else if (matches($extension,'^(c|csv|htm|html|sif|txt)$')) then 'text'                 else if (matches($extension,'^(avi|mov|mp4|mpg|qt|rv|wmv)$')) then 'video'                 else ()"/>
            <assert id="fig5c"
                 test="@mimetype or not(matches($extension,'^(eps|gif|jpg|jpeg|bmp|png|pict|ps|tiff|wmf|doc|docx|pdf|pps|ppt|pptx|xls|xlsx|tar|tgz|zip|c|csv|htm|html|rtf|txt|xml|aiff|au|avi|midi|mov|mp2|mp3|mp4|mpa|mpg|noa|qt|ra|ram|rv|swf|wav|wmv|cif|exe|pdb|sdf|sif)$'))">Missing 'mimetype' attribute on figure "graphic". For files with extension "<value-of select="$extension"/>", this should have the value "<value-of select="$mimetype"/>".</assert>
        </rule>
    </pattern>
   <pattern><!--value used for @mimetype is correct based on file extension (includes test for valid extension)-->
        <rule context="fig//graphic[@mimetype][not(@mimetype='')][contains(@xlink:href,'.')]"
            role="error">
            <let name="extension" value="functx:substring-after-last(@xlink:href,'.')"/>
            <let name="mimetype"
              value="if (matches($extension,'^(doc|docx|eps|exe|noa|pdf|pps|ppt|pptx|ps|rtf|swf|tar|tgz|wmf|xls|xlsx|xml|zip)$')) then 'application'                 else if (matches($extension,'^(mp2|mp3|ra|wav)$')) then 'audio'                 else if (matches($extension,'^(cif|pdb|sdf)$')) then 'chemical'                 else if (matches($extension,'^(bmp|gif|jpeg|jpg|pict|png|tiff)$')) then 'image'                 else if (matches($extension,'^(c|csv|htm|html|sif|txt)$')) then 'text'                 else if (matches($extension,'^(avi|mov|mp4|mpg|qt|rv|wmv)$')) then 'video'                 else ()"/>
            <assert id="fig5d"
                 test="@mimetype=$mimetype or not(matches($extension,'^(eps|gif|jpg|jpeg|bmp|png|pict|ps|tiff|wmf|doc|docx|pdf|pps|ppt|pptx|xls|xlsx|tar|tgz|zip|c|csv|htm|html|rtf|txt|xml|aiff|au|avi|midi|mov|mp2|mp3|mp4|mpa|mpg|noa|qt|ra|ram|rv|swf|wav|wmv|cif|exe|pdb|sdf|sif)$'))">For figure graphics with extension "<value-of select="$extension"/>", the 'mimetype' attribute should have the value "<value-of select="$mimetype"/>" (not "<value-of select="@mimetype"/>").</assert>
        </rule>
    </pattern>
   <pattern><!--fig graphic - must have a @mime-subtype; when @xlink:href does not exist or is invalid, point to Tagging instructions-->
        <rule context="fig//graphic[not(@xlink:href or contains(@xlink:href,'.'))]"
            role="error">
            <assert id="fig6a" test="@mime-subtype">Missing 'mime-subtype' attribute on figure "graphic". Refer to Tagging Instructions for correct value.</assert>
        </rule>
    </pattern>
   <pattern><!--fig graphic - must have a @mime-subtype; when @xlink:href exists (and is invalid) points to Tagging instructions-->
        <rule context="fig//graphic[contains(@xlink:href,'.')]" role="error">
            <let name="extension" value="functx:substring-after-last(@xlink:href,'.')"/>
            <report id="fig6b"
                 test="not(matches($extension,'^(eps|gif|jpg|jpeg|bmp|png|pict|ps|tiff|wmf|doc|docx|pdf|pps|ppt|pptx|xls|xlsx|tar|tgz|zip|c|csv|htm|html|rtf|txt|xml|aiff|au|avi|midi|mov|mp2|mp3|mp4|mpa|mpg|noa|qt|ra|ram|rv|swf|wav|wmv|cif|exe|pdb|sdf|sif)$')) and not(@mime-subtype)">Missing 'mime-subtype' attribute on figure "graphic". Refer to Tagging Instructions for correct value.</report>
        </rule>
    </pattern>
   <pattern><!--fig - must have a @mime-subtype; when @xlink:href exists (and is valid) gives value that should be used-->
        <rule context="fig//graphic[contains(@xlink:href,'.')]" role="error">
            <let name="extension" value="functx:substring-after-last(@xlink:href,'.')"/>
            <let name="mime-subtype"
              value="if ($extension='tgz') then 'application/gzip'                 else if ($extension='bmp') then 'bmp'                 else if ($extension='csv') then 'csv'                 else if ($extension='gif') then 'gif'                 else if ($extension='htm' or $extension='html') then 'html'                 else if ($extension='jpeg' or $extension='jpg') then 'jpeg'                 else if ($extension='mp4' or $extension='mp2' or $extension='mp3' or $extension='mpg') then 'mpeg'                 else if ($extension='doc' or $extension='dot') then 'msword'                 else if ($extension='exe' or $extension='noa' or $extension='ole' or $extension='wp') then 'octet-stream'                 else if ($extension='pdf') then 'pdf'                 else if ($extension='c' or $extension='sif' or $extension='txt') then 'plain'                 else if ($extension='png') then 'png'                 else if ($extension='eps' or $extension='ps') then 'postscript'                 else if ($extension='mov' or $extension='qt') then 'quicktime'                 else if ($extension='rtf') then 'rtf'                 else if ($extension='sbml') then 'sbml+xml'                 else if ($extension='tiff') then 'tiff'                 else if ($extension='xls') then 'vnd.ms-excel'                 else if ($extension='xlsm') then 'vnd.ms-excel.sheet.macroEnabled.12'                 else if ($extension='pps' or $extension='ppt') then 'vnd.ms-powerpoint'                 else if ($extension='pptm') then 'vnd.ms-powerpoint.presentation.macroEnabled.12'                 else if ($extension='docm') then 'vnd.ms-word.document.macroEnabled.12'                 else if ($extension='pptx') then 'vnd.openxmlformats-officedocument.presentationml.presentation'                 else if ($extension='xlsx') then 'vnd.openxmlformats-officedocument.spreadsheetml.sheet'                 else if ($extension='docx') then 'vnd.openxmlformats-officedocument.wordprocessingml.document'                 else if ($extension='ra') then 'vnd.rn-realaudio'                 else if ($extension='rv') then 'vnd.rn-realvideo'                 else if ($extension='cdx') then 'x-cdx'                 else if ($extension='cif') then 'x-cif'                 else if ($extension='jdx') then 'x-jcamp-dx'                 else if ($extension='tex') then 'x-latex'                 else if ($extension='mol') then 'x-mdl-molfile'                 else if ($extension='sdf') then 'x-mdl-sdfile'                 else if ($extension='xml') then 'xml'                 else if ($extension='wmf') then 'x-msmetafile'                 else if ($extension='avi') then 'x-msvideo'                 else if ($extension='wmv') then 'x-ms-wmv'                 else if ($extension='pdb') then 'x-pdb'                 else if ($extension='pict') then 'x-pict'                 else if ($extension='swf') then 'x-shockwave-flash'                 else if ($extension='tar') then 'x-tar'                 else if ($extension='wav') then 'x-wav'                 else if ($extension='zip') then 'x-zip-compressed'                 else ()"/>
            <assert id="fig6c"
                 test="@mime-subtype or not(matches($extension,'^(eps|gif|jpg|jpeg|bmp|png|pict|ps|tiff|wmf|doc|docx|pdf|pps|ppt|pptx|xls|xlsx|tar|tgz|zip|c|csv|htm|html|rtf|txt|xml|aiff|au|avi|midi|mov|mp2|mp3|mp4|mpa|mpg|noa|qt|ra|ram|rv|swf|wav|wmv|cif|exe|pdb|sdf|sif)$'))">Missing 'mime-subtype' attribute on figure "graphic". For files with extension "<value-of select="$extension"/>", this should have the value "<value-of select="$mime-subtype"/>".</assert>
        </rule>
    </pattern>
   <pattern><!--value used for @mimetype is correct based on file extension (includes test for valid extension)-->
        <rule context="fig//graphic[@mime-subtype][not(@mime-subtype='')][contains(@xlink:href,'.')]"
            role="error">
            <let name="extension" value="functx:substring-after-last(@xlink:href,'.')"/>
            <let name="mime-subtype"
              value="if ($extension='tgz') then 'application/gzip'                 else if ($extension='bmp') then 'bmp'                 else if ($extension='csv') then 'csv'                 else if ($extension='gif') then 'gif'                 else if ($extension='htm' or $extension='html') then 'html'                 else if ($extension='jpeg' or $extension='jpg') then 'jpeg'                 else if ($extension='mp4' or $extension='mp2' or $extension='mp3' or $extension='mpg') then 'mpeg'                 else if ($extension='doc' or $extension='dot') then 'msword'                 else if ($extension='exe' or $extension='noa' or $extension='ole' or $extension='wp') then 'octet-stream'                 else if ($extension='pdf') then 'pdf'                 else if ($extension='c' or $extension='sif' or $extension='txt') then 'plain'                 else if ($extension='png') then 'png'                 else if ($extension='eps' or $extension='ps') then 'postscript'                 else if ($extension='mov' or $extension='qt') then 'quicktime'                 else if ($extension='rtf') then 'rtf'                 else if ($extension='sbml') then 'sbml+xml'                 else if ($extension='tiff') then 'tiff'                 else if ($extension='xls') then 'vnd.ms-excel'                 else if ($extension='xlsm') then 'vnd.ms-excel.sheet.macroEnabled.12'                 else if ($extension='pps' or $extension='ppt') then 'vnd.ms-powerpoint'                 else if ($extension='pptm') then 'vnd.ms-powerpoint.presentation.macroEnabled.12'                 else if ($extension='docm') then 'vnd.ms-word.document.macroEnabled.12'                 else if ($extension='pptx') then 'vnd.openxmlformats-officedocument.presentationml.presentation'                 else if ($extension='xlsx') then 'vnd.openxmlformats-officedocument.spreadsheetml.sheet'                 else if ($extension='docx') then 'vnd.openxmlformats-officedocument.wordprocessingml.document'                 else if ($extension='ra') then 'vnd.rn-realaudio'                 else if ($extension='rv') then 'vnd.rn-realvideo'                 else if ($extension='cdx') then 'x-cdx'                 else if ($extension='cif') then 'x-cif'                 else if ($extension='jdx') then 'x-jcamp-dx'                 else if ($extension='tex') then 'x-latex'                 else if ($extension='mol') then 'x-mdl-molfile'                 else if ($extension='sdf') then 'x-mdl-sdfile'                 else if ($extension='xml') then 'xml'                 else if ($extension='wmf') then 'x-msmetafile'                 else if ($extension='avi') then 'x-msvideo'                 else if ($extension='wmv') then 'x-ms-wmv'                 else if ($extension='pdb') then 'x-pdb'                 else if ($extension='pict') then 'x-pict'                 else if ($extension='swf') then 'x-shockwave-flash'                 else if ($extension='tar') then 'x-tar'                 else if ($extension='wav') then 'x-wav'                 else if ($extension='zip') then 'x-zip-compressed'                 else ()"/>
            <assert id="fig6d"
                 test="@mime-subtype=$mime-subtype or not(matches($extension,'^(eps|gif|jpg|jpeg|bmp|png|pict|ps|tiff|wmf|doc|docx|pdf|pps|ppt|pptx|xls|xlsx|tar|tgz|zip|c|csv|htm|html|rtf|txt|xml|aiff|au|avi|midi|mov|mp2|mp3|mp4|mpa|mpg|noa|qt|ra|ram|rv|swf|wav|wmv|cif|exe|pdb|sdf|sif)$'))">For figure graphics with extension "<value-of select="$extension"/>", the 'mime-subtype' attribute should have the value "<value-of select="$mime-subtype"/>" (not "<value-of select="@mime-subtype"/>").</assert>
        </rule>
    </pattern>
   <pattern><!--no other attributes used on fig graphics-->
        <rule context="fig//graphic[@specific-use]" role="error">
            <report id="fig7a" test="." role="error">Do not use "specific-use" attribute on figure "graphic".</report>
        </rule>
    </pattern>
   <pattern>
        <rule context="fig//graphic[@xlink:actuate]" role="error">
            <report id="fig7b" test="." role="error">Do not use "xlink:actuate" attribute on figure "graphic".</report>
        </rule>
    </pattern>
   <pattern>
        <rule context="fig//graphic[not(@content-type='external-media')][@xlink:role]"
            role="error">
            <report id="fig7c" test="." role="error">Do not use "xlink:role" attribute on figure "graphic".</report>
        </rule>
    </pattern>
   <pattern>
        <rule context="fig//graphic[@xlink:show]" role="error">
            <report id="fig7d" test="." role="error">Do not use "xlink:show" attribute on figure "graphic".</report>
        </rule>
    </pattern>
   <pattern>
        <rule context="fig//graphic[@xlink:title]" role="error">
            <report id="fig7e" test="." role="error">Do not use "xlink:title" attribute on figure "graphic".</report>
        </rule>
    </pattern>
   <pattern>
        <rule context="fig//graphic[@xlink:type]" role="error">
            <report id="fig7f" test="." role="error">Do not use "xlink:type" attribute on figure "graphic".</report>
        </rule>
    </pattern>
   <pattern>
        <rule context="fig//graphic[@xml:lang]" role="error">
            <report id="fig7g" test="." role="error">Do not use "xml:lang" attribute on figure "graphic".</report>
        </rule>
    </pattern>
   <pattern>
        <rule context="fig//graphic[@id]" role="error">
            <report id="fig7h" test="." role="error">Do not use "id" attribute on figure "graphic".</report>
        </rule>
    </pattern>
   <pattern>
        <rule context="floats-group/graphic" role="error">
            <assert id="ill1a"
                 test="matches(@content-type,'^(illustration|toc-image)$')"
                 role="error">Unexpected "graphic" as child of "floats-group". If this is an illustration, add content-type='illustration'. If this is a figure image, enclose in "fig" and add "caption" information. If this is a graphical abstract, add content-type='toc-image'.</assert>
        </rule>
    </pattern>
   <pattern>
        <rule context="graphic[@content-type='illustration'][not(parent::floats-group)]"
            role="error">
            <report id="ill1b" test="." role="error">Illustration "<value-of select="@id"/>" should be a child of "floats-group" at the end of the article.</report>
        </rule>
    </pattern>
   <pattern>
        <rule context="graphic[@content-type='toc-image'][not(parent::floats-group)]"
            role="error">
            <report id="ill1b-2" test="." role="error">Graphical abstract "graphic" should be a child of "floats-group" at the end of the article.</report>
        </rule>
    </pattern>
   <pattern><!--illustration - must have an @id-->
        <rule context="graphic[@content-type='illustration'][not(@id)]" role="error">
            <report id="ill1c" test=".">Missing 'id' attribute - illustration should have an 'id' of the form "i"+number (with no leading zeros).</report>
        </rule>
    </pattern>
   <pattern><!--graphical abstract should not have an @id-->
        <rule context="graphic[@content-type='toc-image'][@id]" role="error">
            <report id="ill1c-2" test=".">Graphical abstract "graphic" should not have an 'id' attribute.</report>
        </rule>
    </pattern>
   <pattern><!--illustration - @id must be correct format (restricted to new oa ajs for now)-->
        <rule context="graphic[@content-type='illustration'][@id][$maestro-aj='yes']"
            role="error">
            <assert id="ill1d" test="matches(@id,'^i[1-9][0-9]*$')">Invalid 'id' value ("<value-of select="@id"/>"). Illustration 'id' attribute should be of the form "i"+number (with no leading zeros).</assert>
        </rule>
    </pattern>
   <pattern><!--illustration and toc image - should have @position="anchor"-->
        <rule context="graphic[@content-type='illustration' or @content-type='toc-image'][not(@position='anchor')]"
            role="error">
            <report id="ill1e" test=".">"graphic" should have attribute 'position="anchor"'.</report>
        </rule>
    </pattern>
   <pattern><!--@xlink:href does not contain filepath info-->
        <rule context="graphic[@content-type][not($maestro='yes')]" role="error">
            <report id="ill2a" test="contains(@xlink:href,'/')">Do not include filepath information in graphic "<value-of select="@xlink:href"/>".</report>
        </rule>
    </pattern>
   <pattern><!--@xlink:href contains a '.' and therefore may have an extension-->
        <rule context="graphic[@content-type]" role="error">
            <assert id="ill2b" test="contains(@xlink:href,'.')">"graphic" 'xlink:href' value ("<value-of select="@xlink:href"/>") should contain the file extension (e.g. jpg, gif, etc).</assert>
        </rule>
    </pattern>
   <pattern><!--@xlink:href has valid file extension - check allowed image extensions-->
        <rule context="graphic[@content-type][contains(@xlink:href,'.')]"
            role="error">
            <let name="extension" value="functx:substring-after-last(@xlink:href,'.')"/>
            <assert id="ill2c"
                 test="matches($extension,'^(bmp|gif|jpeg|jpg|pict|png|tiff)$')">Unexpected file extension value ("<value-of select="$extension"/>") in "graphic" '@xlink:href' attribute - please check.</assert>
        </rule>
    </pattern>
   <pattern><!--graphic - must have a @mimetype="image"-->
        <rule context="graphic[@content-type][not(@mimetype='image')]" role="error">
            <report id="ill3a" test=".">"graphic" should have 'mimetype='image'".</report>
        </rule>
    </pattern>
   <pattern><!--illustration - must have a @mime-subtype; when @xlink:href exists (and is valid) gives value that should be used-->
        <rule context="graphic[@content-type][contains(@xlink:href,'.')][not(@mime-subtype)]"
            role="error">
            <let name="extension" value="functx:substring-after-last(@xlink:href,'.')"/>
            <let name="mime-subtype"
              value="if ($extension='bmp') then 'bmp'                 else if ($extension='gif') then 'gif'                 else if ($extension='jpeg' or $extension='jpg') then 'jpeg'                 else if ($extension='png') then 'png'                 else if ($extension='tiff') then 'tiff'                 else if ($extension='pict') then 'x-pict'                 else ()"/>
            <assert id="ill4b"
                 test="@mime-subtype or not(matches($extension,'^(bmp|gif|jpeg|jpg|pict|png|tiff)$'))">Missing 'mime-subtype' attribute on "graphic". For files with extension "<value-of select="$extension"/>", this should have the value "<value-of select="$mime-subtype"/>".</assert>
        </rule>
    </pattern>
   <pattern><!--value used for @mimetype is correct based on file extension (includes test for valid extension)-->
        <rule context="graphic[@content-type][@mime-subtype][contains(@xlink:href,'.')]"
            role="error">
            <let name="extension" value="functx:substring-after-last(@xlink:href,'.')"/>
            <let name="mime-subtype"
              value="if ($extension='bmp') then 'bmp'                 else if ($extension='gif') then 'gif'                 else if ($extension='jpeg' or $extension='jpg') then 'jpeg'                 else if ($extension='png') then 'png'                 else if ($extension='tiff') then 'tiff'                 else if ($extension='pict') then 'x-pict'                 else ()"/>
            <assert id="ill4c"
                 test="@mime-subtype=$mime-subtype or not(matches($extension,'^(bmp|gif|jpeg|jpg|pict|png|tiff)$'))">For "graphic" with extension "<value-of select="$extension"/>", the 'mime-subtype' attribute should have the value "<value-of select="$mime-subtype"/>" (not "<value-of select="@mime-subtype"/>").</assert>
        </rule>
    </pattern>
   <pattern><!--no other attributes used on illustrations-->
        <rule context="graphic[@content-type][@specific-use]" role="error">
            <report id="ill5a" test="." role="error">Do not use "specific-use" attribute on "graphic".</report>
        </rule>
    </pattern>
   <pattern>
        <rule context="graphic[@content-type][@xlink:actuate]" role="error">
            <report id="ill5b" test="." role="error">Do not use "xlink:actuate" attribute on "graphic".</report>
        </rule>
    </pattern>
   <pattern>
        <rule context="graphic[@content-type][@xlink:role]" role="error">
            <report id="ill5c" test="." role="error">Do not use "xlink:role" attribute on "graphic".</report>
        </rule>
    </pattern>
   <pattern>
        <rule context="graphic[@content-type][@xlink:show]" role="error">
            <report id="ill5d" test="." role="error">Do not use "xlink:show" attribute on "graphic".</report>
        </rule>
    </pattern>
   <pattern>
        <rule context="graphic[@content-type][@xlink:title]" role="error">
            <report id="ill5e" test="." role="error">Do not use "xlink:title" attribute on "graphic".</report>
        </rule>
    </pattern>
   <pattern>
        <rule context="graphic[@content-type][@xlink:type]" role="error">
            <report id="ill5f" test="." role="error">Do not use "xlink:type" attribute on "graphic".</report>
        </rule>
    </pattern>
   <pattern>
        <rule context="graphic[@content-type][@xml:lang]" role="error">
            <report id="ill5g" test="." role="error">Do not use "xml:lang" attribute on "graphic".</report>
        </rule>
    </pattern>
   <pattern><!--no other elements used in graphics-->
        <rule context="graphic[@content-type]/alt-text[not($article-type eq 'pv')] | graphic[@content-type]/email | graphic[@content-type]/ext-link | graphic[@content-type]/label | graphic[@content-type]/long-desc | graphic[@content-type]/permissions | graphic[@content-type]/uri"
            role="error">
            <report id="ill6a" test="." role="error">Do not use "<name/>" in "graphic".</report>
        </rule>
    </pattern>
   <pattern><!--illustration - caption must not be empty-->
        <rule context="graphic/caption" role="error">
            <assert id="ill7" test="normalize-space(.)">Illustration "caption" should not be empty.</assert>
        </rule>
    </pattern>
   <pattern>
        <rule context="boxed-text[not(@content-type='excerpt')][not(parent::floats-group)]"
            role="error">
            <report id="box1a" test=".">"boxed-text" (which is not an excerpt) should only be a child of "floats-group" - not "<value-of select="local-name(parent::*)"/>".</report>
        </rule>
    </pattern>
   <pattern><!--box - allowed children of regular boxes-->
      <rule context="boxed-text/sec-meta | boxed-text/address | boxed-text/alternatives | boxed-text/array | boxed-text/chem-struct-wrap | boxed-text/graphic | boxed-text/media |  boxed-text/supplementary-material | boxed-text/table-wrap | boxed-text/table-wrap-group | boxed-text/disp-formula-group | boxed-text/def-list | boxed-text/mml:math | boxed-text[not(@content-type='excerpt')]/related-article | boxed-text/related-object | boxed-text/disp-quote | boxed-text/speech | boxed-text/statement | boxed-text/verse-group | boxed-text/fn-group | boxed-text/glossary | boxed-text/ref-list | boxed-text[not(@content-type='excerpt')]/sec | boxed-text/attrib | boxed-text/permissions"
            role="error">
         <report id="box2" test=".">Do not use "<name/>" as a child of "boxed-text".</report>
      </rule>
  </pattern>
   <pattern><!--box - caption must not be empty-->
        <rule context="boxed-text/caption" role="error">
            <assert id="box3a" test="normalize-space(.) or *">Box "caption" should not be empty - delete or include required title.</assert>
        </rule>
    </pattern>
   <pattern><!--box - caption must not have attributes-->
        <rule context="boxed-text/caption[attribute::*]" role="error">
            <report id="box3b" test=".">Do not use attributes on box "caption".</report>
        </rule>
    </pattern>
   <pattern><!--box - label must not have attributes-->
        <rule context="boxed-text/label[attribute::*]" role="error">
            <report id="box3c" test=".">Do not use attributes on box "label".</report>
        </rule>
    </pattern>
   <pattern><!--box - label not necessary if text is of form "Box 1" etc-->
        <rule context="boxed-text[matches(@id,'^bx[1-9][0-9]*$')]/label" role="error">
            <let name="derivedLabel"
              value="concat('Box ',translate(parent::boxed-text/@id,'bx',''))"/>
            <report id="box3d" test=".=$derivedLabel">Box "label" is not necessary when text is of the standard format "<value-of select="$derivedLabel"/>" - please delete.</report>
        </rule>
    </pattern>
   <pattern><!--box - must have an @id-->
        <rule context="boxed-text[not(@content-type='excerpt')][not(@id)]"
            role="error">
            <report id="box4a" test=".">Missing 'id' attribute - "boxed-text" should have an 'id' of the form "bx"+number (with no leading zeros).</report>
        </rule>
    </pattern>
   <pattern><!--box - @id must be correct format-->
        <rule context="boxed-text[not(@content-type='excerpt')][@id]" role="error">
            <assert id="box4b" test="matches(@id,'^bx[1-9][0-9]*$')">Invalid 'id' value ("<value-of select="@id"/>"). "boxed-text" 'id' attribute should be of the form "bx"+number (with no leading zeros).</assert>
        </rule>
    </pattern>
   <pattern>
        <rule context="boxed-text[@specific-use]" role="error">
            <report id="box4c" test="." role="error">Do not use "specific-use" attribute on "boxed-text".</report>
        </rule>
    </pattern>
   <pattern>
        <rule context="boxed-text[@xml:lang]" role="error">
            <report id="box4d" test="." role="error">Do not use "xml:lang" attribute on "boxed-text".</report>
        </rule>
    </pattern>
   <pattern><!--caption must contain a title-->
        <rule context="boxed-text/caption" role="error">
            <report id="box5a" test="not(child::title) and child::p" role="error">Box "caption" should contain a "title" element - change "p" to "title".</report>
        </rule>
    </pattern>
   <pattern><!--supplementary-material - only caption or alternatives allowed as a child-->
      <rule context="floats-group/supplementary-material[not(@content-type='external-media' or @content-type='annotations')]/*"
            role="error">
         <assert id="supp1a" test="self::caption or self::alternatives">Only "caption" should be used as a child of "supplementary-material" - do not use "<name/>".</assert>
      </rule>
  </pattern>
   <pattern><!--supplementary-material - caption must contain title-->
      <rule context="floats-group/supplementary-material/caption" role="error">
         <assert id="supp1b" test="title">Supplementary-material "caption" must contain "title".</assert>
      </rule>
  </pattern>
   <pattern><!--supplementary-material - should be child of floats gropu-->
      <rule context="supplementary-material[matches(@id,'^s[0-9]+$')][not(parent::floats-group)]"
            role="error">
         <let name="parent" value="parent::*"/>
         <report id="supp1c" test=".">Supplementary information should be a child of "floats-group" not "<value-of select="local-name($parent)"/>".</report>
      </rule>
  </pattern>
   <pattern><!--supplementary-material - must have an @id-->
      <rule context="floats-group/supplementary-material[not(@content-type='external-media' or @content-type='annotations')][not(@id)]"
            role="error">
         <report id="supp2a" test=".">Missing 'id' attribute - "supplementary-material" should have an 'id' of the form "s"+number.</report>
      </rule>
  </pattern>
   <pattern><!--supplementary-material - @id must be correct format-->
      <rule context="floats-group/supplementary-material[not(@content-type='external-media' or @content-type='annotations')][@id]"
            role="error">
         <assert id="supp2b" test="matches(@id,'^s[0-9]+$')">Invalid 'id' value ("<value-of select="@id"/>"). "supplementary-material" 'id' attribute should be of the form "s"+number.</assert>
      </rule>
  </pattern>
   <pattern><!--supplementary-material - must have an @content-type-->
      <rule context="floats-group/supplementary-material[not(@xlink:href) or not(contains(@xlink:href,'.'))][not(@content-type)]"
            role="error">
         <report id="supp3a" test=".">Missing 'content-type' attribute on "supplementary-material". Refer to Tagging Instructions for correct value.</report>
      </rule>
  </pattern>
   <pattern><!--supplementary-material - must have a @content-type; when @xlink:href is invalid, point to Tagging instructions-->
      <rule context="floats-group/supplementary-material[not(@content-type='external-media' or @content-type='annotations')][contains(@xlink:href,'.')]"
            role="error">
         <let name="extension" value="functx:substring-after-last(@xlink:href,'.')"/>
         <report id="supp3b"
                 test="not(matches($extension,'^(eps|gif|jpg|jpeg|bmp|png|pict|ps|tif|tiff|wmf|doc|docm|docx|pdf|pps|ppt|pptx|xls|xlsx|tar|tgz|zip|c|csv|htm|html|rtf|txt|xml|aiff|au|avi|midi|mov|mp2|mp3|mp4|mpa|mpeg|mpg|noa|qt|ra|ram|rv|swf|wav|wmv|cdx|cif|exe|pdb|sdf|sif|dta|do|fcf|hkl)$')) and not(@content-type)">Missing 'content-type' attribute on "supplementary-material". Refer to Tagging Instructions for correct value.</report>
      </rule>
  </pattern>
   <pattern><!--supplementary-material - must have a @content-type; when @xlink:href exists (and is valid) gives value that should be used-->
      <rule context="floats-group/supplementary-material[not(@content-type='external-media' or @content-type='annotations')][contains(@xlink:href,'.')]"
            role="error">
         <let name="extension" value="functx:substring-after-last(@xlink:href,'.')"/>
         <let name="content-type"
              value="if (matches($extension,'^(doc|docm|docx|pdf|pps|ppt|pptx|xls|xlsx|dta)$')) then 'document'         else if (matches($extension,'^(eps|gif|jpg|bmp|png|pict|ps|tif|tiff|wmf)$')) then 'image'         else if (matches($extension,'^(tar|tgz|zip)$')) then 'archive'         else if (matches($extension,'^(c|csv|htm|html|rtf|txt|xml|do|fcf|hkl)$')) then 'text'         else if (matches($extension,'^(aiff|au|avi|midi|mov|mp2|mp3|mp4|mpa|mpeg|mpg|noa|qt|ra|ram|rv|swf|wav|wmv)$')) then 'movie'         else if (matches($extension,'^(cdx|cif|exe|pdb|sdf|sif)$')) then 'other'         else ()"/>
         <assert id="supp3c"
                 test="@content-type or not(matches($extension,'^(eps|gif|jpg|jpeg|bmp|png|pict|ps|tif|tiff|wmf|doc|docm|docx|pdf|pps|ppt|pptx|xls|xlsx|tar|tgz|zip|c|csv|htm|html|rtf|txt|xml|aiff|au|avi|midi|mov|mp2|mp3|mp4|mpa|mpeg|mpg|noa|qt|ra|ram|rv|swf|wav|wmv|cdx|cif|exe|pdb|sdf|sif|dta|do|fcf|hkl)$'))">Missing 'content-type' attribute on "supplementary-material". For files with extension "<value-of select="$extension"/>", this should have the value "<value-of select="$content-type"/>".</assert>
      </rule>
  </pattern>
   <pattern><!--value used for @content-type is correct based on file extension (includes test for valid extension)-->
      <rule context="floats-group/supplementary-material[not(@content-type='external-media' or @content-type='isa-tab')][@content-type][contains(@xlink:href,'.')]"
            role="error">
         <let name="extension" value="functx:substring-after-last(@xlink:href,'.')"/>
         <let name="content-type"
              value="if (matches($extension,'^(doc|docm|docx|pdf|pps|ppt|pptx|xls|xlsx|dta)$')) then 'document'         else if (matches($extension,'^(eps|gif|jpg|bmp|png|pict|ps|tif|tiff|wmf)$')) then 'image'         else if (matches($extension,'^(tar|tgz|zip)$')) then 'archive'         else if (matches($extension,'^(c|csv|htm|html|rtf|txt|xml|do|fcf|hkl)$')) then 'text'         else if (matches($extension,'^(aiff|au|avi|midi|mov|mp2|mp3|mp4|mpa|mpeg|mpg|noa|qt|ra|ram|rv|swf|wav|wmv)$')) then 'movie'         else if (matches($extension,'^(cdx|cif|exe|pdb|sdf|sif)$')) then 'other'         else ()"/>
         <assert id="supp3d"
                 test="@content-type=$content-type or not(matches($extension,'^(eps|gif|jpg|jpeg|bmp|png|pict|ps|tif|tiff|wmf|doc|docm|docx|pdf|pps|ppt|pptx|xls|xlsx|tar|tgz|zip|c|csv|htm|html|rtf|txt|xml|aiff|au|avi|midi|mov|mp2|mp3|mp4|mpa|mpeg|mpg|noa|qt|ra|ram|rv|swf|wav|wmv|cdx|cif|exe|pdb|sdf|sif|dta|do|fcf|hkl)$'))">For supplementary material files with extension "<value-of select="$extension"/>", the content-type attribute should have the value "<value-of select="$content-type"/>" (not "<value-of select="@content-type"/>").</assert>
      </rule>
  </pattern>
   <pattern><!--supplementary-material - must have an @xlink:href-->
      <rule context="floats-group/supplementary-material[not(@content-type='external-media' or @content-type='annotations')]"
            role="error">
         <assert id="supp4a" test="@xlink:href">Missing 'xlink:href' attribute on "supplementary-material". The 'xlink:href' should contain the filename (including extension) of the item of supplementary information. Do not include any path information.</assert>
      </rule>
  </pattern>
   <pattern><!--@xlink:href does not contain filepath info-->
      <rule context="floats-group/supplementary-material[not(@content-type='external-media')][@xlink:href and not(contains(@xlink:href,'.doi.'))]"
            role="error">
         <report id="supp4b" test="contains(@xlink:href,'/')">Do not include filepath information for supplementary material files "<value-of select="@xlink:href"/>".</report>
      </rule>
  </pattern>
   <pattern><!--@xlink:href contains a '.' and therefore may have an extension-->
      <rule context="floats-group/supplementary-material[not(@content-type='external-media')][@xlink:href]"
            role="error">
         <assert id="supp4c" test="contains(@xlink:href,'.')">Supplementary-material 'xlink:href' value ("<value-of select="@xlink:href"/>") should contain the file extension (e.g. jpg, doc, etc).</assert>
      </rule>
  </pattern>
   <pattern><!--@xlink:href has valid file extension-->
      <rule context="floats-group/supplementary-material[not(@content-type='external-media')][contains(@xlink:href,'.') and not(contains(@xlink:href,'.doi.'))]"
            role="error">
         <let name="extension" value="functx:substring-after-last(@xlink:href,'.')"/>
         <assert id="supp4d"
                 test="matches($extension,'^(eps|gif|jpg|jpeg|bmp|png|pict|ps|tif|tiff|wmf|doc|docm|docx|pdf|pps|ppt|pptx|xls|xlsx|tar|tgz|zip|c|csv|htm|html|rtf|txt|xml|aiff|au|avi|midi|mov|mp2|mp3|mp4|mpa|mpeg|mpg|noa|qt|ra|ram|rv|swf|wav|wmv|cdx|cif|exe|pdb|sdf|sif|dta|do|fcf|hkl)$')">Unexpected file extension value ("<value-of select="$extension"/>") in supplementary material '@xlink:href' attribute - please check.</assert>
      </rule>
  </pattern>
   <pattern><!--supplementary-material - must have a @mimetype; when @xlink:href does not exist, point to Tagging instructions-->
      <rule context="floats-group/supplementary-material[not(@content-type='external-media' or @content-type='annotations')][not(@xlink:href) or not(contains(@xlink:href,'.'))]"
            role="error">
         <assert id="supp5a" test="@mimetype">Missing 'mimetype' attribute on "supplementary-material". Refer to Tagging Instructions for correct value.</assert>
      </rule>
  </pattern>
   <pattern><!--supplementary-material - must have a @mimetype; when @xlink:href is invalid, point to Tagging instructions-->
      <rule context="floats-group/supplementary-material[not(@content-type='external-media' or @content-type='annotations')][contains(@xlink:href,'.')]"
            role="error">
         <let name="extension" value="functx:substring-after-last(@xlink:href,'.')"/>
         <report id="supp5b"
                 test="not(matches($extension,'^(eps|gif|jpg|jpeg|bmp|png|pict|ps|tif|tiff|wmf|doc|docm|docx|pdf|pps|ppt|pptx|xls|xlsx|tar|tgz|zip|c|csv|htm|html|rtf|txt|xml|aiff|au|avi|midi|mov|mp2|mp3|mp4|mpa|mpeg|mpg|noa|qt|ra|ram|rv|swf|wav|wmv|cdx|cif|exe|pdb|sdf|sif|dta|do|fcf|hkl)$')) and not(@mimetype)">Missing 'mimetype' attribute on "supplementary-material". Refer to Tagging Instructions for correct value.</report>
      </rule>
  </pattern>
   <pattern><!--supplementary-material - must have a @mimetype; when @xlink:href exists (and is valid) gives value that should be used-->
      <rule context="floats-group/supplementary-material[not(@content-type='external-media' or @content-type='annotations')][contains(@xlink:href,'.')]"
            role="error">
         <let name="extension" value="functx:substring-after-last(@xlink:href,'.')"/>
         <let name="mimetype"
              value="if (matches($extension,'^(doc|docm|docx|eps|exe|noa|pdf|pps|ppt|pptx|ps|rtf|swf|tar|tgz|wmf|xls|xlsx|xml|zip|dta|do)$')) then 'application'         else if (matches($extension,'^(mp2|mp3|ra|wav)$')) then 'audio'         else if (matches($extension,'^(cdx|cif|pdb|sdf)$')) then 'chemical'         else if (matches($extension,'^(bmp|gif|jpeg|jpg|pict|png|tif|tiff)$')) then 'image'         else if (matches($extension,'^(c|csv|htm|html|sif|txt|fcf|hkl)$')) then 'text'         else if (matches($extension,'^(avi|mov|mp4|mpeg|mpg|qt|rv|wmv)$')) then 'video'         else ()"/>
         <assert id="supp5c"
                 test="@mimetype or not(matches($extension,'^(eps|gif|jpg|jpeg|bmp|png|pict|ps|tif|tiff|wmf|doc|docm|docx|pdf|pps|ppt|pptx|xls|xlsx|tar|tgz|zip|c|csv|htm|html|rtf|txt|xml|aiff|au|avi|midi|mov|mp2|mp3|mp4|mpa|mpeg|mpg|noa|qt|ra|ram|rv|swf|wav|wmv|cdx|cif|exe|pdb|sdf|sif|dta|do|fcf|hkl)$'))">Missing 'mimetype' attribute on "supplementary-material". For files with extension "<value-of select="$extension"/>", this should have the value "<value-of select="$mimetype"/>".</assert>
      </rule>
  </pattern>
   <pattern><!--value used for @mimetype is correct based on file extension (includes test for valid extension)-->
      <rule context="floats-group/supplementary-material[not(@content-type='external-media')][@mimetype][contains(@xlink:href,'.')]"
            role="error">
         <let name="extension" value="functx:substring-after-last(@xlink:href,'.')"/>
         <let name="mimetype"
              value="if (matches($extension,'^(doc|docm|docx|eps|exe|noa|pdf|pps|ppt|pptx|ps|rtf|swf|tar|tgz|wmf|xls|xlsx|xml|zip|dta|do)$')) then 'application'         else if (matches($extension,'^(mp2|mp3|ra|wav)$')) then 'audio'         else if (matches($extension,'^(cdx|cif|pdb|sdf)$')) then 'chemical'         else if (matches($extension,'^(bmp|gif|jpeg|jpg|pict|png|tif|tiff)$')) then 'image'         else if (matches($extension,'^(c|csv|htm|html|sif|txt|fcf|hkl)$')) then 'text'         else if (matches($extension,'^(avi|mov|mp4|mpeg|mpg|qt|rv|wmv)$')) then 'video'         else ()"/>
         <assert id="supp5d"
                 test="@mimetype=$mimetype or not(matches($extension,'^(eps|gif|jpg|jpeg|bmp|png|pict|ps|tif|tiff|wmf|doc|docm|docx|pdf|pps|ppt|pptx|xls|xlsx|tar|tgz|zip|c|csv|htm|html|rtf|txt|xml|aiff|au|avi|midi|mov|mp2|mp3|mp4|mpa|mpeg|mpg|noa|qt|ra|ram|rv|swf|wav|wmv|cdx|cif|exe|pdb|sdf|sif|dta|do|fcf|hkl)$'))">For supplementary material files with extension "<value-of select="$extension"/>", the mimetype attribute should have the value "<value-of select="$mimetype"/>" (not "<value-of select="@mimetype"/>").</assert>
      </rule>
  </pattern>
   <pattern><!--supplementary-material - must have a @mime-subtype; when @xlink:href does not exist or is invalid, point to Tagging instructions-->
      <rule context="floats-group/supplementary-material[not(@content-type='external-media' or @content-type='annotations')][not(@xlink:href) or not(contains(@xlink:href,'.'))]"
            role="error">
         <assert id="supp6a" test="@mime-subtype">Missing 'mime-subtype' attribute on "supplementary-material". Refer to Tagging Instructions for correct value.</assert>
      </rule>
  </pattern>
   <pattern><!--supplementary-material - must have a @mime-subtype; when @xlink:href exists (and is invalid) points to Tagging instructions-->
      <rule context="floats-group/supplementary-material[not(@content-type='external-media' or @content-type='annotations')][contains(@xlink:href,'.')]"
            role="error">
         <let name="extension" value="functx:substring-after-last(@xlink:href,'.')"/>
         <report id="supp6b"
                 test="not(matches($extension,'^(eps|gif|jpg|jpeg|bmp|png|pict|ps|tif|tiff|wmf|doc|docm|docx|pdf|pps|ppt|pptx|xls|xlsx|tar|tgz|zip|c|csv|htm|html|rtf|txt|xml|aiff|au|avi|midi|mov|mp2|mp3|mp4|mpa|mpeg|mpg|noa|qt|ra|ram|rv|swf|wav|wmv|cdx|cif|exe|pdb|sdf|sif|dta|do|fcf|hkl)$')) and not(@mime-subtype)">Missing 'mime-subtype' attribute on "supplementary-material". Refer to Tagging Instructions for correct value.</report>
      </rule>
  </pattern>
   <pattern><!--supplementary-material - must have a @mime-subtype; when @xlink:href exists (and is valid) gives value that should be used-->
      <rule context="floats-group/supplementary-material[not(@content-type='external-media' or @content-type='annotations')][contains(@xlink:href,'.')]"
            role="error">
         <let name="extension" value="functx:substring-after-last(@xlink:href,'.')"/>
         <let name="mime-subtype"
              value="if ($extension='tgz') then 'gzip'         else if ($extension='bmp') then 'bmp'         else if ($extension='csv') then 'csv'         else if ($extension='gif') then 'gif'         else if ($extension='htm' or $extension='html') then 'html'         else if ($extension='jpeg' or $extension='jpg') then 'jpeg'         else if ($extension='mp4') then 'mp4'         else if ($extension='mp2' or $extension='mp3' or $extension='mpg' or $extension='mpeg') then 'mpeg'         else if ($extension='doc' or $extension='dot') then 'msword'         else if ($extension='exe' or $extension='do' or $extension='dta' or $extension='noa' or $extension='ole' or $extension='wp') then 'octet-stream'         else if ($extension='pdf') then 'pdf'         else if ($extension='c' or $extension='sif' or $extension='txt' or $extension='fcf' or $extension='hkl') then 'plain'         else if ($extension='png') then 'png'         else if ($extension='eps' or $extension='ps') then 'postscript'         else if ($extension='mov' or $extension='qt') then 'quicktime'         else if ($extension='rtf') then 'rtf'         else if ($extension='sbml') then 'sbml+xml'         else if ($extension='tiff' or $extension='tif') then 'tiff'         else if ($extension='xls') then 'vnd.ms-excel'         else if ($extension='xlsm') then 'vnd.ms-excel.sheet.macroEnabled.12'         else if ($extension='pps' or $extension='ppt') then 'vnd.ms-powerpoint'         else if ($extension='pptm') then 'vnd.ms-powerpoint.presentation.macroEnabled.12'         else if ($extension='docm') then 'vnd.ms-word.document.macroEnabled.12'         else if ($extension='pptx') then 'vnd.openxmlformats-officedocument.presentationml.presentation'         else if ($extension='xlsx') then 'vnd.openxmlformats-officedocument.spreadsheetml.sheet'         else if ($extension='docx') then 'vnd.openxmlformats-officedocument.wordprocessingml.document'         else if ($extension='ra') then 'vnd.rn-realaudio'         else if ($extension='rv') then 'vnd.rn-realvideo'         else if ($extension='cdx') then 'x-cdx'         else if ($extension='cif') then 'x-cif'         else if ($extension='jdx') then 'x-jcamp-dx'         else if ($extension='tex') then 'x-latex'         else if ($extension='mol') then 'x-mdl-molfile'         else if ($extension='sdf') then 'x-mdl-sdfile'         else if ($extension='xml') then 'xml'         else if ($extension='wmf') then 'x-msmetafile'         else if ($extension='avi') then 'x-msvideo'         else if ($extension='wmv') then 'x-ms-wmv'         else if ($extension='pdb') then 'x-pdb'         else if ($extension='pict') then 'x-pict'         else if ($extension='swf') then 'x-shockwave-flash'         else if ($extension='tar') then 'x-tar'         else if ($extension='wav') then 'x-wav'         else if ($extension='zip') then 'x-zip-compressed'         else ()"/>
         <assert id="supp6c"
                 test="@mime-subtype or not(matches($extension,'^(eps|gif|jpg|jpeg|bmp|png|pict|ps|tif|tiff|wmf|doc|docm|docx|pdf|pps|ppt|pptx|xls|xlsx|tar|tgz|zip|c|csv|htm|html|rtf|txt|xml|aiff|au|avi|midi|mov|mp2|mp3|mp4|mpa|mpeg|mpg|noa|qt|ra|ram|rv|swf|wav|wmv|cdx|cif|exe|pdb|sdf|sif|dta|do|fcf|hkl)$'))">Missing 'mime-subtype' attribute on "supplementary-material". For files with extension "<value-of select="$extension"/>", this should have the value "<value-of select="$mime-subtype"/>".</assert>
      </rule>
  </pattern>
   <pattern><!--value used for @mimetype is correct based on file extension (includes test for valid extension)-->
      <rule context="floats-group/supplementary-material[not(@content-type='external-media')][@mime-subtype][contains(@xlink:href,'.')]"
            role="error">
         <let name="extension" value="functx:substring-after-last(@xlink:href,'.')"/>
         <let name="mime-subtype"
              value="if ($extension='tgz') then 'gzip'         else if ($extension='bmp') then 'bmp'         else if ($extension='csv') then 'csv'         else if ($extension='gif') then 'gif'         else if ($extension='htm' or $extension='html') then 'html'         else if ($extension='jpeg' or $extension='jpg') then 'jpeg'         else if ($extension='mp4') then 'mp4'         else if ($extension='mp2' or $extension='mp3' or $extension='mpg' or $extension='mpeg') then 'mpeg'         else if ($extension='doc' or $extension='dot') then 'msword'         else if ($extension='exe' or $extension='do' or $extension='dta' or $extension='noa' or $extension='ole' or $extension='wp') then 'octet-stream'         else if ($extension='pdf') then 'pdf'         else if ($extension='c' or $extension='sif' or $extension='txt' or $extension='fcf' or $extension='hkl') then 'plain'         else if ($extension='png') then 'png'         else if ($extension='eps' or $extension='ps') then 'postscript'         else if ($extension='mov' or $extension='qt') then 'quicktime'         else if ($extension='rtf') then 'rtf'         else if ($extension='sbml') then 'sbml+xml'         else if ($extension='tiff' or $extension='tif') then 'tiff'         else if ($extension='xls') then 'vnd.ms-excel'         else if ($extension='xlsm') then 'vnd.ms-excel.sheet.macroEnabled.12'         else if ($extension='pps' or $extension='ppt') then 'vnd.ms-powerpoint'         else if ($extension='pptm') then 'vnd.ms-powerpoint.presentation.macroEnabled.12'         else if ($extension='docm') then 'vnd.ms-word.document.macroEnabled.12'         else if ($extension='pptx') then 'vnd.openxmlformats-officedocument.presentationml.presentation'         else if ($extension='xlsx') then 'vnd.openxmlformats-officedocument.spreadsheetml.sheet'         else if ($extension='docx') then 'vnd.openxmlformats-officedocument.wordprocessingml.document'         else if ($extension='ra') then 'vnd.rn-realaudio'         else if ($extension='rv') then 'vnd.rn-realvideo'         else if ($extension='cdx') then 'x-cdx'         else if ($extension='cif') then 'x-cif'         else if ($extension='jdx') then 'x-jcamp-dx'         else if ($extension='tex') then 'x-latex'         else if ($extension='mol') then 'x-mdl-molfile'         else if ($extension='sdf') then 'x-mdl-sdfile'         else if ($extension='xml') then 'xml'         else if ($extension='wmf') then 'x-msmetafile'         else if ($extension='avi') then 'x-msvideo'         else if ($extension='wmv') then 'x-ms-wmv'         else if ($extension='pdb') then 'x-pdb'         else if ($extension='pict') then 'x-pict'         else if ($extension='swf') then 'x-shockwave-flash'         else if ($extension='tar') then 'x-tar'         else if ($extension='wav') then 'x-wav'         else if ($extension='zip') then 'x-zip-compressed'         else ()"/>
         <assert id="supp6d"
                 test="@mime-subtype=$mime-subtype or not(matches($extension,'^(eps|gif|jpg|jpeg|bmp|png|pict|ps|tif|tiff|wmf|doc|docm|docx|pdf|pps|ppt|pptx|xls|xlsx|tar|tgz|zip|c|csv|htm|html|rtf|txt|xml|aiff|au|avi|midi|mov|mp2|mp3|mp4|mpa|mpeg|mpg|noa|qt|ra|ram|rv|swf|wav|wmv|cdx|cif|exe|pdb|sdf|sif|dta|do|fcf|hkl)$'))">For supplementary material files with extension "<value-of select="$extension"/>", the mime-subtype attribute should have the value "<value-of select="$mime-subtype"/>" (not "<value-of select="@mime-subtype"/>").</assert>
      </rule>
  </pattern>
   <pattern><!--no other attributes used on supplementary-material-->
      <rule context="floats-group/supplementary-material" role="error">
         <report id="supp7a" test="@specific-use" role="error">Do not use "specific-use" attribute on "supplementary-material".</report>
      </rule>
  </pattern>
   <pattern>
      <rule context="floats-group/supplementary-material" role="error">
         <report id="supp7b" test="@xlink:actuate" role="error">Do not use "xlink:actuate" attribute on "supplementary-material".</report>
      </rule>
  </pattern>
   <pattern>
      <rule context="floats-group/supplementary-material[not(@content-type='external-media')]"
            role="error">
         <report id="supp7c" test="@xlink:role" role="error">Do not use "xlink:role" attribute on "supplementary-material".</report>
      </rule>
  </pattern>
   <pattern>
      <rule context="floats-group/supplementary-material" role="error">
         <report id="supp7d" test="@xlink:show" role="error">Do not use "xlink:show" attribute on "supplementary-material".</report>
      </rule>
  </pattern>
   <pattern>
      <rule context="floats-group/supplementary-material" role="error">
         <report id="supp7e" test="@xlink:title" role="error">Do not use "xlink:title" attribute on "supplementary-material".</report>
      </rule>
  </pattern>
   <pattern>
      <rule context="floats-group/supplementary-material" role="error">
         <report id="supp7f" test="@xlink:type" role="error">Do not use "xlink:type" attribute on "supplementary-material".</report>
      </rule>
  </pattern>
   <pattern>
      <rule context="floats-group/supplementary-material" role="error">
         <report id="supp7g" test="@xml:lang" role="error">Do not use "xml:lang" attribute on "supplementary-material".</report>
      </rule>
  </pattern>
   <pattern><!--elements not allowed in NPG JATS content-->
      <rule context="abbrev | collab-alternatives | comment | gov | issn-l | issue-id | issue-part | issue-title | milestone-end | milestone-start | object-id |  page-range | part-title | patent | pub-id | roman | std | tex-math | trans-abstract | trans-source | volume-id | volume-series"
            role="error">
         <report id="disallowed1" test=".">Do not use "<name/>" element in Springer Nature articles.</report>
      </rule>
  </pattern>
</schema>
