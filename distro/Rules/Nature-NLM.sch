<?xml version="1.0" encoding="UTF-8"?>
<!--

* Schematron rules for testing semantic validity of XML files in the JATS DTD submitted to NPG *

Due to the configuration of XSLT templates used in the validation service, attributes cannot be used as the 'context' of a rule.

For example, context="article[@article-type]" will recognise the context as 'article' with an 'article-type' attribute, but context="article/@article-type" will set context as 'article'.
Use the <let> element to define the attribute if necessary.

--><schema xmlns="http://purl.oclc.org/dsdl/schematron"
        xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
        queryBinding="xslt2">
  <title>Schematron rules for NPG content in JATS v1.0</title>
  <ns uri="http://www.w3.org/1998/Math/MathML" prefix="mml"/>
  <ns uri="http://docs.oasis-open.org/ns/oasis-exchange/table" prefix="oasis"/>
  <ns uri="http://www.w3.org/1999/xlink" prefix="xlink"/>
  <let name="allowed-values"
        value="document( 'allowed-values-nlm.xml' )/allowed-values"/>
   <!--Points at document containing information on journal titles, ids and DOIs-->

  <let name="products" value="document('products.owl')"/>
  <!--<let name="subjects" value="document('subjects.owl')/skos:concept"/>
  <ns uri="http://ns.nature.com/subjects/" prefix="skos"/>Namespace for Ontologies document-->
  <ns uri="http://ns.nature.com/terms/" prefix="terms"/>
   <!--Namespace for Ontologies document-->
  <ns uri="http://purl.org/dc/elements/1.1/" prefix="dc"/>
   <!--Namespace for Ontologies document-->
  <ns uri="http://www.w3.org/1999/02/22-rdf-syntax-ns#" prefix="rdf"/>
   <!--Namespace for Ontologies document-->
  <ns uri="http://purl.org/ontology/bibo/" prefix="bibo"/>
   <!--Namespace for Ontologies document-->
  
  <ns prefix="functx" uri="http://www.functx.com"/>
   <!--extended XPath functions from Priscilla Walmsley-->
  <xsl:function xmlns:functx="http://www.functx.com" name="functx:substring-after-last"
                 as="xs:string">
      <xsl:param name="arg" as="xs:string?"/> 
      <xsl:param name="delim" as="xs:string"/> 
      <xsl:sequence select="replace ($arg,concat('^.*',functx:escape-for-regex($delim)),'')"/>
  </xsl:function>
  
  <xsl:function xmlns:functx="http://www.functx.com" name="functx:escape-for-regex"
                 as="xs:string">
      <xsl:param name="arg" as="xs:string?"/> 
      <xsl:sequence select="replace($arg,'(\.|\[|\]|\\|\||\-|\^|\$|\?|\*|\+|\{|\}|\(|\))','\\$1')"/>
  </xsl:function>
  
  <!--Regularly used values throughout rules-->
  <let name="journal-title" value="//journal-meta/journal-title-group/journal-title"/>
  <let name="pcode" value="//journal-meta/journal-id"/>
  <let name="article-type" value="article/@article-type"/>
    
   <pattern>
      <rule context="article" role="error"><!--Does the article have an article-type attribute-->
      <assert id="article1" test="@article-type">All articles should have an article-type attribute on "article". The value should be the same as the information contained in the subject element with attribute content-type="article-type".</assert>
      </rule>
  </pattern>
   <pattern>
      <rule context="article[@article-type]" role="error"><!--Does the article-type have a value?-->
      <report id="article2" test="$article-type = ''">&lt;article&gt; 'article-type' attribute should have a value and not be empty.</report>
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
      <assert id="jmeta1b" test="count(journal-id) eq 1">There should only be one "journal-id" element in Macmillan articles, with attribute: journal-id-type="publisher".</assert>
      </rule>
  </pattern>
   <pattern>
      <rule context="journal-meta" role="error"><!--Journal title exists-->
      <assert id="jmeta2a" test="descendant::journal-title-group/journal-title">Journal title is missing from the journal metadata section. Other rules are based on having a correct journal title and therefore will not be run. Please resubmit this file when the title has been added.</assert>
      </rule>
  </pattern>
   <pattern>
      <rule context="journal-title-group" role="error"><!--only one journal-title-group-->
      <report id="jmeta2b" test="preceding-sibling::journal-title-group">Only one journal-title-group should be used.</report>
      </rule>
  </pattern>
   <pattern>
      <rule context="journal-title-group" role="error"><!--Is the journal title valid-->
      <assert id="jmeta3a"
                 test="not(descendant::journal-title) or $products[descendant::dc:title=$journal-title]">Journal titles must be from the prescribed list of journal names. "<value-of select="$journal-title"/>" is not on this list - check spelling, spacing of words or use of the ampersand. Other rules are based on having a correct journal title and therefore will not be run. Please resubmit this file when the title has been corrected.</assert>
      </rule>
    </pattern>
   <pattern>
      <rule context="journal-title-group" role="error"><!--Is the journal id valid?-->
      <assert id="jmeta3b"
                 test="$products[descendant::terms:pcode=$pcode] or not($products[descendant::dc:title=$journal-title])">Journal id is incorrect. For <value-of select="$journal-title"/>, it should be: <value-of select="$products//*[child::dc:title=$journal-title]/terms:pcode"/>. Other rules are based on having a correct journal id and therefore will not be run. Please resubmit this file when the journal id has been corrected.</assert>
      </rule>
    </pattern>
   <pattern>
      <rule context="journal-title-group" role="error"><!--Do the journal title and id match each other?-->
      <assert id="jmeta3c"
                 test="$pcode=$products//*[child::dc:title=$journal-title]/terms:pcode or not($products[descendant::dc:title=$journal-title]) or not($products[descendant::terms:pcode=$pcode])">Journal id (<value-of select="$pcode"/>) does not match journal title: <value-of select="$journal-title"/>. Check which is the correct value.</assert>
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
   <pattern><!--ISSN is correct for journal-->
    <rule context="journal-meta/issn[not(@pub-type='supplement')]" role="error">
         <let name="issn" value="concat('http://ns.nature.com/publications/',.)"/>
         <assert id="jmeta5b"
                 test="not($journal-title) or not($products[descendant::dc:title=$journal-title]) or $products//*[child::dc:title=$journal-title][terms:hasPublication[@rdf:resource=$issn]]">Unexpected ISSN value (pub-type="<value-of select="@pub-type"/>") for <value-of select="$journal-title"/> (<value-of select="."/>)</assert>
      </rule>
  </pattern>
   <pattern><!--ISSN ppub matches a print issn in ontology-->
    <rule context="journal-meta/issn[@pub-type='ppub']" role="error">
         <let name="issn" value="concat('http://ns.nature.com/publications/',.)"/>
         <assert id="jmeta5c"
                 test="not($journal-title) or not($products[descendant::dc:title=$journal-title]) or not($products//*[child::dc:title=$journal-title][terms:hasPublication[@rdf:resource=$issn]]) or .=$products//bibo:issn">ISSN (pub-type="ppub") <value-of select="."/> is valid for this journal, but is not listed as the print ISSN. Change 'pub-type' attribute to "epub".</assert>
      </rule>
  </pattern>
   <pattern><!--ISSN epub matches an electronic issn in ontology-->
    <rule context="journal-meta/issn[@pub-type='epub']" role="error">
         <let name="issn" value="concat('http://ns.nature.com/publications/',.)"/>
         <assert id="jmeta5d"
                 test="not($journal-title) or not($products[descendant::dc:title=$journal-title]) or not($products//*[child::dc:title=$journal-title][terms:hasPublication[@rdf:resource=$issn]]) or .=$products//bibo:eissn">ISSN (pub-type="epub") <value-of select="."/> is valid for this journal, but is not listed as the electronic ISSN. Change 'pub-type' attribute to "ppub".</assert>
      </rule>
  </pattern>
   <pattern><!--Only one of each issn pub-type used-->
    <rule context="journal-meta/issn" role="error">
         <report id="jmeta5e" test="@pub-type=./preceding-sibling::issn/@pub-type">There should only be one instance of each "issn" element with "pub-type" attribute value of "<value-of select="@pub-type"/>".</report>
      </rule>
  </pattern>
   <pattern>
      <rule context="journal-meta/contrib-group | journal-meta/aff | journal-meta/aff-alternatives | journal-meta/issn-l | journal-meta/isbn | journal-meta/notes | journal-meta/self-uri"
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
      <rule context="article-meta" role="error"><!--Two article ids, one doi and one publisher-id-->
      <assert id="ameta1a"
                 test="article-id[@pub-id-type='doi'] and article-id[@pub-id-type='publisher-id']">Article metadata should contain at least two "article-id" elements, one with attribute pub-id-type="doi" and one with attribute pub-id-type="publisher-id".</assert>
      </rule>
    </pattern>
   <pattern>
      <rule context="article-meta" role="error">
         <assert id="ameta1b" test="article-categories">Article metadata should include an "article-categories" element.</assert>
      </rule>
  </pattern>
   <pattern><!--Does article categories contain "category" information and does it match article/@article-type?-->
    <rule context="article-categories" role="error">
         <assert id="ameta2a" test="subj-group[@subj-group-type='category']">Article categories should contain a "subj-group" element with attribute "subj-group-type='category'". The value of the child "subject" element should be the same as the main article-type attribute: <value-of select="$article-type"/>.</assert>
      </rule>
    </pattern>
   <pattern>
      <rule context="article-categories" role="error">
         <assert id="ameta2b"
                 test="subj-group[@subj-group-type='category']/subject = $article-type or not($article-type) or not(subj-group[@subj-group-type='category']/subject)">Subject catgory (<value-of select="subj-group[@subj-group-type='category']/subject"/>) does not match root article type (<value-of select="$article-type"/>)</assert>
      </rule>
  </pattern>
   <pattern>
      <rule context="trans-title-group" role="error"><!--No unexpected children of article title-group used-->
      <report id="arttitle1a" test="parent::title-group">Unexpected use of "trans-title-group" in article "title-group". "title-group" should only contain "article-title", "subtitle", "alt-title" or "fn-group".</report>
      </rule>
  </pattern>
   <pattern>
      <rule context="article-title" role="error"><!--No @id on article title-->
      <report id="arttitle2" test="@id">Do not use "id" attribute on "article-title".</report>
      </rule>
  </pattern>
   <pattern>
      <rule context="title-group/article-title/styled-content" role="error"><!--correct attributes used on styled-content element-->
      <report id="arttitle3a" test="@specific-use">Unnecessary use of "specific-use" attribute on "styled-content" element in "article-title".</report>
      </rule>
    </pattern>
   <pattern>
      <rule context="title-group/article-title/styled-content" role="error">
         <report id="arttitle3b" test="@style">Unnecessary use of "style" attribute on "styled-content" element in "article-title".</report>
      </rule>
    </pattern>
   <pattern>
      <rule context="title-group/article-title/styled-content" role="error">
         <assert id="arttitle3c" test="@style-type='hide'">The "styled-content" element in "article-title" should have attribute "style-type='hide'". If the correct element has been used here, add the required attribute.</assert>
      </rule>
  </pattern>
   <pattern><!--Rules around expected attribute values of pub-date, and only one of each type-->
    <rule context="pub-date" role="error">
         <assert id="pubdate0a" test="@pub-type">"pub-date" element should have attribute "pub-type" declared. Allowed values are: issue-date, aop, collection, epub, epreprint and embargo. Please check with NPG Editorial Production.</assert>
      </rule>
    </pattern>
   <pattern>
      <rule context="pub-date[@pub-type]" role="error">
         <let name="pubType" value="@pub-type"/>
         <assert id="pubdate0b" test="$allowed-values/pub-types/pub-type[.=$pubType]">Unexpected value for "pub-type" attribute on "pub-date" element (<value-of select="$pubType"/>). Allowed values are: issue-date, aop, collection, epub, epreprint and embargo. Please check with NPG Editorial Production.</assert>
      </rule>
  </pattern>
   <pattern>
      <rule context="pub-date" role="error">
         <report id="pubdate0c" test="@pub-type=./preceding-sibling::pub-date/@pub-type">There should only be one instance of the "pub-date" element with "pub-type" attribute value of "<value-of select="@pub-type"/>". Please check with NPG Editorial Production.</report>
      </rule>
  </pattern>
   <pattern><!--Valid values for year, month and day-->
    <rule context="pub-date" role="error">
         <assert id="pubdate1a" test="not(year) or matches(year, '^(19|20)[0-9]{2}$')">Invalid year value: <value-of select="year"/>. It should be a 4-digit number starting with 19 or 20.</assert>
      </rule>
    </pattern>
   <pattern>
      <rule context="pub-date" role="error">
         <assert id="pubdate1b" test="not(month) or matches(month, '^((0[1-9])|(1[0-2]))$')">Invalid month value: <value-of select="month"/>. It should be a 2-digit number between 01 and 12.</assert>
      </rule>
    </pattern>
   <pattern>
      <rule context="pub-date" role="error">
         <assert id="pubdate1c" test="not(day) or matches(day, '^(0[1-9]|[12][0-9]|3[01])$')">Invalid day value: <value-of select="day"/>. It should be a 2-digit number between 01 and 31.</assert>
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
    <rule context="pub-date" role="error">
         <report id="pubdate3" test="year and day and not(month)">Missing month in pub-date. Currently only contains year and day.</report>
      </rule>
  </pattern>
   <pattern>
      <rule context="day[parent::pub-date] | month[parent::pub-date] | year[parent::pub-date]"
            role="error"><!--No content-type attribute on day, month or year-->
      <report id="pubdate4" test="@content-type">Do not use "content-type" attribute on "<name/>" within "pub-date" element.</report>
      </rule>
  </pattern>
   <pattern>
      <rule context="volume[parent::article-meta] | issue[parent::article-meta] | fpage[parent::article-meta] | lpage[parent::article-meta] | page-count[@count='0'][parent::article-meta]"
            role="error">
         <assert id="artinfo1a" test="normalize-space(.) or *">Empty "<name/>" element should not be used - please delete.</assert>
      </rule>
    </pattern>
   <pattern>
      <rule context="volume[parent::article-meta] | issue[parent::article-meta] | fpage[parent::article-meta] | lpage[parent::article-meta] | page-count[@count='0'][parent::article-meta]"
            role="error">
         <assert id="artinfo1b" test="not(@content-type)">Do not use "content-type" attribute on "<name/>" within article metadata.</assert>
      </rule>
  </pattern>
   <pattern><!--fpage[parent::article-meta] |-->
    <rule context="volume[parent::article-meta] | issue[parent::article-meta] | lpage[parent::article-meta] | page-count/@count"
            role="error">
         <assert id="artinfo2" test="not(normalize-space(.) or *) or matches(.,'^S?[0-9]+$')">Invalid value for "<name/>" (<value-of select="."/>) - this may start with a capital S, but otherwise should only contain numerals.</assert>
      </rule>
  </pattern>
   <pattern>
      <rule context="counts[page-count]" role="error">
         <assert id="artinfo3b" test="preceding-sibling::fpage">As "page-count" is used, we also expect "fpage" and "lpage" elements to be used in article metadata. Please check if "page-count" should have been used.</assert>
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
         <report id="artinfo5" test="parent::counts">Unexpected use of "<name/>" element - please delete.</report>
      </rule>
  </pattern>
   <pattern><!--Rules around expected attribute values of date-->
    <rule context="history/date" role="error">
         <assert id="histdate0a" test="@date-type">"date" element should have attribute "date-type" declared. Allowed values are: created, received, rev-recd (revision received), first-decision, accepted and misc. Please check with NPG Editorial Production.</assert>
      </rule>
  </pattern>
   <pattern>
      <rule context="history/date[@date-type]" role="error">
         <let name="dateType" value="@date-type"/>
         <assert id="histdate0b" test="$allowed-values/date-types/date-type[.=$dateType]">Unexpected value for "date-type" attribute on "date" element (<value-of select="$dateType"/>). Allowed values are: created, received, rev-recd (revision received), first-decision, accepted and misc. Please check with NPG Editorial Production.</assert>
      </rule>
  </pattern>
   <pattern><!--... and only one of each type-->
    <rule context="history/date" role="error">
         <report id="histdate0c"
                 test="@date-type[not(.='rev-recd')]=./preceding-sibling::date/@date-type">There should only be one instance of the "date" element with "date-type" attribute value of "<value-of select="@date-type"/>". Please check with NPG Editorial Production.</report>
      </rule>
  </pattern>
   <pattern><!--Valid values for year, month and day-->
    <rule context="history/date" role="error">
         <assert id="histdate1a" test="not(year) or matches(year, '^(19|20)[0-9]{2}$')">Invalid year value: <value-of select="year"/>. It should be a 4-digit number starting with 19 or 20.</assert>
      </rule>
  </pattern>
   <pattern>
      <rule context="history/date" role="error">
         <assert id="histdate1b" test="not(month) or matches(month, '^((0[1-9])|(1[0-2]))$')">Invalid month value: <value-of select="month"/>. It should be a 2-digit number between 01 and 12.</assert>
      </rule>
  </pattern>
   <pattern>
      <rule context="history/date" role="error">
         <assert id="histdate1c" test="not(day) or matches(day, '^(0[1-9]|[12][0-9]|3[01])$')">Invalid day value: <value-of select="day"/>. It should be a 2-digit number between 01 and 31.</assert>
      </rule>
  </pattern>
   <pattern>
      <rule context="history/date/season" role="error">
         <report id="histdate1d" test=".">Do not use "season" (<value-of select="."/>). "Day" and "month" are the only other elements which should be used.</report>
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
    <rule context="history/date" role="error">
         <report id="histdate3" test="year and day and not(month)">Missing month in "date" element. Currently only contains year and day.</report>
      </rule>
  </pattern>
   <pattern><!--No content-type attribute on day, month or year-->
    <rule context="day[ancestor::history] | month[ancestor::history] | year[ancestor::history]"
            role="error">
         <report id="histdate4" test="@content-type">Do not use "content-type" attribute on <name/> within "date" element.</report>
      </rule>
  </pattern>
   <pattern>
      <rule context="article-meta"><!--permissions and expected children exist-->
      <assert id="copy1a" test="permissions">Article metadata should include a "permissions" element.</assert>
      </rule>
  </pattern>
   <pattern>
      <rule context="permissions"><!--permissions and expected children exist-->
      <assert id="copy1b" test="copyright-year">Permissions should include the copyright year.</assert>
      </rule>
  </pattern>
   <pattern>
      <rule context="permissions">
         <assert id="copy1c" test="copyright-holder">Permissions should include the copyright holder: <value-of select="$allowed-values/journal[@title=$journal-title]/copyright-holder"/>.</assert>
      </rule>
  </pattern>
   <pattern><!--Is the copyright year valid?-->
    <rule context="copyright-year" role="error">
         <assert id="copy2" test="matches(.,'^(19|20)[0-9]{2}$')">Invalid year value for copyright: <value-of select="."/>. It should be a 4-digit number starting with 19 or 20.</assert>
      </rule>
  </pattern>
   <pattern><!--No other elements in copyright-statement-->
    <rule context="copyright-statement/*" role="error">
         <report id="copy4" test=".">Do not use "<name/>" element in "copyright-statement" - it should only contain text.</report>
      </rule>  
  </pattern>
   <pattern><!--valid @abstract-type-->
    <rule context="abstract[@abstract-type]" role="error">
         <let name="abstractType" value="@abstract-type"/>
         <assert id="abs1" test="$allowed-values/abstract-types/abstract-type[.=$abstractType]">Unexpected value for "abstract-type" attribute (<value-of select="$abstractType"/>). Allowed values are: editor, editor-standfirst, editorial-notes, executive-summary, first-paragraph, key-points, research-summary, standfirst, synopsis, toc, toc-note, web-summary.</assert>
      </rule>
  </pattern>
   <pattern><!--only one of each abstract type used-->
    <rule context="abstract[not(@abstract-type='editor' or @abstract-type='editor-standfirst' or @abstract-type='research-summary' or @abstract-type='editorial-notes')]"
            role="error">
         <report id="abs2a" test="@abstract-type=./preceding-sibling::abstract/@abstract-type">Only one abstract of type "<value-of select="@abstract-type"/>" should appear in an article.</report>
      </rule>
  </pattern>
   <pattern><!--dateline para in correct place-->
    <rule context="abstract[p[@content-type='dateline']]" role="error">
         <assert id="abs3a" test="@abstract-type='web-summary' or @abstract-type='toc'">Dateline paragraphs should only be used in 'web-summary' or 'toc' abstracts.</assert>
      </rule>
  </pattern>
   <pattern>
      <rule context="abstract[@abstract-type='web-summary' or @abstract-type='toc']/p[@content-type='dateline']"
            role="error">
         <assert id="abs3b" test="not(preceding-sibling::p)">Dateline paragraphs should only appear as the first element in an abstract.</assert>
      </rule>
  </pattern>
   <pattern><!--editor summaries specific-use attribute equal to 'aop' or 'issue'-->
    <rule context="abstract[@abstract-type='editor' or @abstract-type='editor-standfirst' or @abstract-type='research-summary' or @abstract-type='editorial-notes'][@specific-use]"
            role="error">
         <assert id="abs4a" test="@specific-use='aop' or @specific-use='issue'">Unexpected value (<value-of select="@specific-use"/>) for "specific-use" attribute on editor abstracts. Allowed values are "aop" or "issue".</assert>
      </rule>
  </pattern>
   <pattern><!--only one of each specific-use type used in editor summaries-->
    <rule context="abstract[@abstract-type='editor'][@specific-use]" role="error">
         <report id="abs4b"
                 test="@specific-use=./preceding-sibling::abstract[@abstract-type='editor']/@specific-use">Only one abstract of type "<value-of select="@specific-use"/>" should appear on editor abstract in each article.</report>
      </rule>
  </pattern>
   <pattern>
      <rule context="abstract[@abstract-type='editor-standfirst'][@specific-use]"
            role="error">
         <report id="abs4c"
                 test="@specific-use=./preceding-sibling::abstract[@abstract-type='editor-standfirst']/@specific-use">Only one abstract of type "<value-of select="@specific-use"/>" should appear on editor-standfirst in each article.</report>
      </rule>
  </pattern>
   <pattern>
      <rule context="abstract[@abstract-type='research-summary'][@specific-use]"
            role="error">
         <report id="abs4d"
                 test="@specific-use=./preceding-sibling::abstract[@abstract-type='research-summary']/@specific-use">Only one abstract of type "<value-of select="@specific-use"/>" should appear on research-summary in each article.</report>
      </rule>
  </pattern>
   <pattern>
      <rule context="abstract[@abstract-type='editorial-notes'][@specific-use]"
            role="error">
         <report id="abs4e"
                 test="@specific-use=./preceding-sibling::abstract[@abstract-type='editorial-notes']/@specific-use">Only one abstract of type "<value-of select="@specific-use"/>" should appear on research-summary in each article.</report>
      </rule>
  </pattern>
   <pattern>
      <rule context="article-meta" role="error">
         <let name="derived-status"
              value="if ($pcode='am' or $pcode='bcj' or $pcode='cddis' or $pcode='ctg' or $pcode='cti' or $pcode='emi' or $pcode='emm' or $pcode='las' or $pcode='mtna' or $pcode='nutd' or $pcode='oncsis' or $pcode='psp' or $pcode='tp' or $pcode='ncomms' or $pcode='srep') then 'online'       else if (ancestor::article-meta/pub-date[@pub-type='epub']) then 'issue'       else if (ancestor::article-meta/pub-date[@pub-type='aop'] and not(ancestor::article/body)) then 'author-ms'       else if (ancestor::article-meta/pub-date[@pub-type='aop']) then 'aop'       else 'issue'"/>
         <assert id="custom1" test="custom-meta-group/custom-meta[meta-name='publish-type']">All articles should contain publication status information at the end of "article-metadata". Insert "custom-meta-group/custom-meta" with "meta-name". For this journal and publication status, "meta-value" should be "<value-of select="$derived-status"/>".</assert>
      </rule>
  </pattern>
   <pattern>
      <rule context="article-meta/custom-meta-group/custom-meta[meta-name='publish-type']"
            role="error">
         <let name="status" value="meta-value"/>
         <let name="derived-status"
              value="if ($pcode='am' or $pcode='bcj' or $pcode='cddis' or $pcode='ctg' or $pcode='cti' or $pcode='emi' or $pcode='emm' or $pcode='las' or $pcode='mtna' or $pcode='nutd' or $pcode='oncsis' or $pcode='psp' or $pcode='tp' or $pcode='ncomms' or $pcode='srep' or $pcode='msb' or $pcode='scibx') then 'online'         else if (ancestor::article-meta/pub-date[@pub-type='epub']) then 'issue'         else if (ancestor::article-meta/pub-date[@pub-type='aop'] and not(ancestor::article/body)) then 'author-ms'         else if (ancestor::article-meta/pub-date[@pub-type='aop']) then 'aop'         else 'issue'"/>
         <assert id="custom2" test="$status = $derived-status">Unexpected value for "publish-type" (<value-of select="$status"/>). Expected value for this journal and publication status is "<value-of select="$derived-status"/>".</assert>
      </rule>
  </pattern>
   <pattern><!--sec - sec-type or specific-use attribute used-->
    <rule context="sec" role="error">
         <assert id="sec1a" test="@sec-type or @specific-use">"sec" should have "sec-type" or "specific-use" attribute.</assert>
      </rule>
  </pattern>
   <pattern><!--sec - sec-type or specific-use attribute used-->
    <rule context="sec" role="error">
         <report id="sec1b" test="@sec-type and @specific-use">"sec" should only use one "sec-type" or "specific-use" attribute, not both.</report>
      </rule>
  </pattern>
   <pattern><!--sec - id and xml:lang attributes not used-->
    <rule context="sec" role="error">
         <report id="sec1c" test="@id">Do not use "id" attribute on "sec".</report>
      </rule>
  </pattern>
   <pattern>
      <rule context="sec" role="error">
         <report id="sec1d" test="@xml:lang">Do not use "xml:lang" attribute on "sec".</report>
      </rule>
  </pattern>
   <pattern><!--sec - sec-type is valid-->
    <rule context="sec[@sec-type]" role="error">
         <let name="secType" value="@sec-type"/>
         <assert id="sec2a" test="$allowed-values/sec-types/sec-type[.=$secType]">Unexpected value for "sec-type" attribute (<value-of select="$secType"/>). Allowed values are: materials, online-methods, procedure. </assert>
      </rule>
  </pattern>
   <pattern><!--sec/@specific-use - follows expected syntax-->
    <rule context="sec[@specific-use]" role="error">
         <assert id="sec2b" test="matches(@specific-use,'^heading-level-[0-9]+$')">The "specific-use" attribute on "sec" (<value-of select="@specific-use"/>) should be used to show the section heading level. It should be "heading-level-" followed by a number.</assert>
      </rule>
  </pattern>
   <pattern><!--sec/@specific-use="heading-level-1" is a child of body-->
    <rule context="sec[@specific-use='heading-level-1']" role="error">
         <assert id="sec3a" test="parent::body|parent::abstract|parent::app">Section heading level 1 should only be used in body, abstract or app - check nesting and "specific-use" attribute values.</assert>
      </rule>
  </pattern>
   <pattern><!--sec/@specific-use="heading-level-2" is a child of sec heading level 1-->
    <rule context="sec[@specific-use='heading-level-2']" role="error">
         <assert id="sec3b"
                 test="parent::sec[@specific-use='heading-level-1'] or parent::sec[@sec-type='online-methods'][parent::sec/@specific-use='heading-level-1']">Section heading level 2 should be a child of section heading level 1 - check nesting and "specific-use" attribute values.</assert>
      </rule>
  </pattern>
   <pattern><!--sec/@specific-use="heading-level-3" is a child of sec heading level 2-->
    <rule context="sec[@specific-use='heading-level-3']" role="error">
         <assert id="sec3c"
                 test="parent::sec[@specific-use='heading-level-2'] or parent::sec[@sec-type='online-methods'][parent::sec/@specific-use='heading-level-2']">Section heading level 3 should be a child of section heading level 2 - check nesting and "specific-use" attribute values.</assert>
      </rule>
  </pattern>
   <pattern><!--sec/@specific-use="heading-level-4" is a child of sec heading level 3-->
    <rule context="sec[@specific-use='heading-level-4']" role="error">
         <assert id="sec3d" test="parent::sec/@specific-use='heading-level-3'">Section heading level 4 should be a child of section heading level 3 - check nesting and "specific-use" attribute values.</assert>
      </rule>
  </pattern>
   <pattern><!--sec/@specific-use="heading-level-5" is a child of sec heading level 4-->
    <rule context="sec[@specific-use='heading-level-5']" role="error">
         <assert id="sec3e" test="parent::sec/@specific-use='heading-level-4'">Section heading level 5 should be a child of section heading level 4 - check nesting and "specific-use" attribute values.</assert>
      </rule>
  </pattern>
   <pattern><!--sec/@specific-use="heading-level-6" is a child of sec heading level 5-->
    <rule context="sec[@specific-use='heading-level-6']" role="error">
         <assert id="sec3f" test="parent::sec/@specific-use='heading-level-5'">Section heading level 6 should be a child of section heading level 5 - check nesting and "specific-use" attribute values.</assert>
      </rule>
  </pattern>
   <pattern><!--sec/@specific-use="heading-level-7" is a child of sec heading level 6-->
    <rule context="sec[@specific-use='heading-level-7']" role="error">
         <assert id="sec3g" test="parent::sec/@specific-use='heading-level-6'">Section heading level 7 should be a child of section heading level 6 - check nesting and "specific-use" attribute values.</assert>
      </rule>
  </pattern>
   <pattern><!--sec/@specific-use="heading-level-8" is a child of sec heading level 7-->
    <rule context="sec[@specific-use='heading-level-8']" role="error">
         <assert id="sec3h" test="parent::sec/@specific-use='heading-level-7'">Section heading level 8 should be a child of section heading level 7 - check nesting and "specific-use" attribute values.</assert>
      </rule>
  </pattern>
   <pattern><!--sec - sec-type or specific-use attribute used-->
    <rule context="sec/sec-meta | sec/label | sec/address | sec/alternatives | sec/array | sec/boxed-text | sec/chem-struct-wrap | sec/fig | sec/fig-group | sec/graphic | sec/media |  sec/supplementary-material | sec/table-wrap | sec/table-wrap-group | sec/disp-formula-group | sec/def-list | sec/text-math | sec/mml:math | sec/related-article | sec/related-object | sec/disp-quote | sec/speech | sec/statement | sec/verse-group | sec/fn-group | sec/glossary | sec/ref-list"
            role="error">
         <report id="sec4" test=".">Children of "sec" should only be "title", "p", "sec", "disp-formula" or "preformat" - do not use "<name/>".</report>
      </rule>
  </pattern>
   <pattern><!--title - no attributes used-->
    <rule context="title">
         <report id="title1a" test="@id">Unnecessary use of "id" attribute on "title" element.</report>
      </rule>
  </pattern>
   <pattern>
      <rule context="title">
         <report id="title1b" test="@content-type">Unnecessary use of "content-type" attribute on "title" element.</report>
      </rule>
  </pattern>
   <pattern><!--List is not block-level, i.e. is a child of p or list-item [unless used for interview/quiz, materials/procedures]-->
    <rule context="list[not(@list-content or @list-type='materials' or @list-type='procedure-group')]"
            role="error">
         <assert id="list2a" test="parent::p or parent::list-item">Regular lists should be enclosed in paragraphs or other lists.</assert>
      </rule>
  </pattern>
   <pattern><!--List - no unnecessary attributes-->
    <rule context="list" role="error">
         <report id="list2b" test="@continued-from">Do not use "continued-from" attribute on "list" element.</report>
      </rule>
  </pattern>
   <pattern>
      <rule context="list" role="error">
         <report id="list2c" test="@prefix-word">Do not use "prefix-word" attribute on "list" element.</report>
      </rule>
  </pattern>
   <pattern>
      <rule context="list" role="error">
         <report id="list2d" test="@specific-use">Do not use "specific-use" attribute on "list" element.</report>
      </rule>
  </pattern>
   <pattern><!--List-item - no id attribute-->
    <rule context="list-item" role="error">
         <report id="list2e" test="@id">Do not use "id" attribute on "list-item" element.</report>
      </rule>
  </pattern>
   <pattern><!--List - list-type attribute stated (apart from interview/quizzes)-->
    <rule context="list[not(@list-content)]" role="error">
         <assert id="list3a" test="@list-type">Use "list-type" attribute to show type of list used. Allowed values are: none, bullet, number, lcletter, ucletter, lcroman and ucroman.</assert>
      </rule>
  </pattern>
   <pattern><!--list-type attribute is valid--><!--needs work - excludes lists in body when no sec exists; does it work in abstracts?-->
    <rule context="list[not(ancestor::sec/@sec-type) and ancestor::sec/@specific-use][@list-type]"
            role="error">
         <let name="listType" value="@list-type"/>
         <assert id="list3b" test="$allowed-values/list-types/list-type[.=$listType]">Unexpected value for "list-type" attribute (<value-of select="$listType"/>). Allowed values are: none, bullet, number, lcletter, ucletter, lcroman and ucroman. </assert>
      </rule>
  </pattern>
   <pattern><!--List-item - no labels needed-->
    <rule context="list-item" role="error">
         <report id="list4" test="label">Do not use "label" element in "list-item".</report>
      </rule>
  </pattern>
   <pattern><!--Interview is block-level, i.e. not a child of p or list-item-->
    <rule context="list[@list-content='interview']" role="error">
         <assert id="int1a" test="not(parent::p or parent::list-item)">Interviews should be modelled as block-level lists and should not be enclosed in paragraphs or other lists.</assert>
      </rule>
  </pattern>
   <pattern><!--Interview does not have an id-->
    <rule context="list[@list-content='interview']" role="error">
         <assert id="int1b" test="not(@id)">The "id" attribute is not necessary on interviews.</assert>
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
   <pattern><!--Interview does not have an id-->
    <rule context="list[@list-content='quiz']" role="error">
         <assert id="quiz1b" test="not(@id)">The "id" attribute is not necessary on quizzes.</assert>
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
    <rule context="p[not(ancestor::sec/@sec-type)][not(ancestor::ack or ancestor::app or ancestor::app-group or ancestor::boxed-text)][@content-type]"
            role="error">
         <let name="contentType" value="@content-type"/>
         <assert id="para1a" test="$allowed-values/content-types/content-type[.=$contentType]">Unexpected value for "content-type" attribute (<value-of select="$contentType"/>). Allowed values are: cross-head, dateline and greeting. </assert>
      </rule>
  </pattern>
   <pattern><!--p - no unnecessary attributes-->
    <rule context="p" role="error">
         <report id="para1b" test="@id">Do not use "id" attribute on "p" element.</report>
      </rule>
  </pattern>
   <pattern>
      <rule context="p" role="error">
         <report id="para1c" test="@specific-use">Do not use "specific-use" attribute on "p" element.</report>
      </rule>
  </pattern>
   <pattern>
      <rule context="p" role="error">
         <report id="para1d" test="@xml:lang">Do not use "xml:lang" attribute on "p" element.</report>
      </rule>
  </pattern>
   <pattern><!--dateline para in correct place-->
    <rule context="body//p[@content-type='dateline']" role="error">
         <assert id="para2" test="not(preceding-sibling::p)">Dateline paragraphs should only appear as the first element in "body", or directly following a section "title".</assert>
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
    <rule context="app/p">
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
         <report id="bio3"
                 test="@content-type or @id or @rid or @specific-use or @xlink:actuate or @xlink:href or @xlink:role or @xlink:show or @xlink:title">Do not use attributes on "bio" element.</report>
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
    <rule context="back/fn-group" role="error">
         <assert id="back-fn2b"
                 test="not(@content-type) or @content-type='endnotes' or @content-type='footnotes' or @content-type='closenotes' or @content-type='article-notes'">Allowed values for 'content-type' attribute on "fn-group" are "article-notes", "closenotes", "endnotes" or "footnotes".</assert>
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
         <assert id="back5a" test="@id">"fn" within footnotes section should have attribute 'id' declared. Expected syntax is "fn" followed by a number.</assert>
      </rule>
  </pattern>
   <pattern><!--footnotes - @id has required syntax-->
    <rule context="back/fn-group[@content-type='footnotes']/fn" role="error">
         <assert id="back5b" test="not(@id) or matches(@id,'^fn[0-9]+$')">Unexpected 'id' syntax found (<value-of select="@id"/>). Footnote ids should be "fn" followed by a number.</assert>
      </rule>
  </pattern>
   <pattern><!--footnotes - fn-type attribute not necessary-->
    <rule context="back/fn-group[@content-type='footnotes']/fn" role="error">
         <report id="back-fn5c" test="@fn-type">'fn-type' attribute is not necessary on footnotes.</report>
      </rule>
  </pattern>
   <pattern><!--footnotes - symbol attribute not necessary-->
    <rule context="back/fn-group[@content-type='footnotes']/fn" role="error">
         <report id="back-fn5d" test="@symbol">'symbol' attribute is not necessary on footnotes.</report>
      </rule>
  </pattern>
   <pattern><!--notes - zero or one-->
    <rule context="back/notes" role="error">
         <report id="notes1" test="preceding-sibling::notes">There should only be one "notes" (accession group) in "back".</report>
      </rule>
  </pattern>
   <pattern><!--notes - @notes-type="database-links"-->
    <rule context="back/notes" role="error">
         <assert id="notes2a" test="@notes-type='database-links' or @notes-type='note-in-proof'">Unexpected value for "notes" attribute 'notes-type' ("<value-of select="@notes-type"/>"). It should be either "database-links" or "note-in-proof".</assert>
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
    <rule context="back/notes/p/ext-link" role="error">
         <assert id="notes4b"
                 test="not(@ext-link-type) or @ext-link-type='genbank' or @ext-link-type='pdb'">Allowed values for 'ext-link-type' attribute on "ext-link" in notes section are "genbank" or "pdb".</assert>
      </rule>
  </pattern>
   <pattern><!--notes ext-link - @ext-link-type allowed-->
    <rule context="back/notes/p/ext-link" role="error">
         <assert id="notes4c" test="@xlink:href">External database links should have attribute 'xlink:href' declared.</assert>
      </rule>
  </pattern>
   <pattern><!--notes ext-link - @ext-link-type allowed-->
    <rule context="back/notes/p/ext-link" role="error">
         <assert id="notes4d" test="not(@xlink:href) or @xlink:href=.">'xlink:href' should be equal to the link text (<value-of select="."/>).</assert>
      </rule>
  </pattern>
   <pattern>
      <rule context="table-wrap-foot/fn" role="error">
        <let name="id" value="@id"/>
        <assert id="tab10a" test="ancestor::article//xref[@ref-type='table-fn'][@rid=$id]">Table footnote is not linked to. Either insert a correctly numbered link, or just mark up as a table footer paragraph.</assert>
      </rule>
   </pattern>
   <pattern>
        <rule context="table-wrap-foot/fn" role="error">
            <let name="id" value="@id"/>
            <assert id="tab10b"
                 test="not(ancestor::article//xref[@ref-type='table-fn'][@rid=$id]) or label">Table footnote should contain "label" element - check if it is a footnote or should just be a table footer paragraph.</assert>
        </rule>
    </pattern>
   <pattern>
        <rule context="xref[@ref-type='table-fn']" role="error"><!--Does symbol in link match symbol on footnote?-->
            <let name="id" value="@rid"/>
            <let name="sup-link" value="descendant::text()"/>
            <let name="sup-fn"
              value="ancestor::article//table-wrap-foot/fn[@id=$id]/label//text()"/>
            <assert id="tab10c" test="not($sup-fn) or not($sup-link) or $sup-link=$sup-fn">Mismatch on linking text: "<value-of select="$sup-link"/>" in table, but "<value-of select="$sup-fn"/>" in footnote. Please check that correct footnote has been linked to.</assert>
        </rule>
    </pattern>
   <pattern><!--supplementary-material - only caption allowed as a child-->
    <rule context="floats-group/supplementary-material[not(@content-type='external-media')]"
            role="error">
         <report id="supp1a" test="*[not(self::caption)]">Only "caption" should be used as a child of "supplementary-material" - do not use "<value-of select="local-name(*)"/>".</report>
      </rule>
  </pattern>
   <pattern><!--supplementary-material - caption must contain title-->
    <rule context="floats-group/supplementary-material/caption" role="error">
         <assert id="supp1b" test="title">Supplementary-material "caption" must contain "title".</assert>
      </rule>
  </pattern>
   <pattern><!--supplementary-material - must have an @id-->
    <rule context="floats-group/supplementary-material[not(@content-type='external-media')]"
            role="error">
         <assert id="supp2a" test="@id">Missing 'id' attribute - "supplementary-material" should have an 'id' of the form "s"+number.</assert>
      </rule>
  </pattern>
   <pattern><!--supplementary-material - @id must be correct format-->
    <rule context="floats-group/supplementary-material[not(@content-type='external-media')][@id]"
            role="error">
         <assert id="supp2b" test="matches(@id,'^s[0-9]*$')">Invalid 'id' value ("<value-of select="@id"/>"). "supplementary-material" 'id' attribute should be of the form "s"+number.</assert>
      </rule>
  </pattern>
   <pattern><!--supplementary-material - must have an @content-type-->
    <rule context="floats-group/supplementary-material[not(@xlink:href or contains(@xlink:href,'.'))]"
            role="error">
         <assert id="supp3a" test="@content-type">Missing 'content-type' attribute on "supplementary-material". Refer to Tagging Instructions for correct value.</assert>
      </rule>
  </pattern>
   <pattern><!--supplementary-material - must have a @content-type; when @xlink:href is invalid, point to Tagging instructions-->
    <rule context="floats-group/supplementary-material[not(@content-type='external-media')][contains(@xlink:href,'.')]"
            role="error">
         <let name="extension" value="functx:substring-after-last(@xlink:href,'.')"/>
         <report id="supp3b"
                 test="not($extension='eps' or $extension='gif' or $extension='jpg' or $extension='jpeg' or $extension='bmp' or $extension='png' or $extension='pict' or $extension='ps' or $extension='tiff' or $extension='wmf' or $extension='doc' or $extension='docx' or $extension='pdf' or $extension='pps' or $extension='ppt' or $extension='pptx' or $extension='xls' or $extension='xlsx' or $extension='tar' or $extension='tgz' or $extension='zip' or $extension='c' or $extension='csv' or $extension='htm' or $extension='html' or $extension='rtf' or $extension='txt' or $extension='xml' or $extension='aiff' or $extension='au' or $extension='avi' or $extension='midi' or $extension='mov' or $extension='mp2' or $extension='mp3' or $extension='mp4' or $extension='mpa' or $extension='mpg' or $extension='noa' or $extension='qt' or $extension='ra' or $extension='ram' or $extension='rv' or $extension='swf' or $extension='wav' or $extension='wmv' or $extension='cif' or $extension='exe' or $extension='pdb' or $extension='sdf' or $extension='sif') and not(@content-type)">Missing 'content-type' attribute on "supplementary-material". Refer to Tagging Instructions for correct value.</report>
      </rule>
  </pattern>
   <pattern><!--supplementary-material - must have a @content-type; when @xlink:href exists (and is valid) gives value that should be used-->
    <rule context="floats-group/supplementary-material[not(@content-type='external-media')][contains(@xlink:href,'.')]"
            role="error">
         <let name="extension" value="functx:substring-after-last(@xlink:href,'.')"/>
         <let name="content-type"
              value="if ($extension='doc' or $extension='docx' or $extension='pdf' or $extension='pps' or $extension='ppt' or $extension='pptx' or $extension='xls' or $extension='xlsx') then 'document'         else if ($extension='eps' or $extension='gif' or $extension='jpg' or $extension='jpeg' or $extension='bmp' or $extension='png' or $extension='pict' or $extension='ps' or $extension='tiff' or $extension='wmf') then 'image'         else if ($extension='tar' or $extension='tgz' or $extension='zip') then 'archive'         else if ($extension='c' or $extension='csv' or $extension='htm' or $extension='html' or $extension='rtf' or $extension='txt' or $extension='xml') then 'text'         else if ($extension='aiff' or $extension='au' or $extension='avi' or $extension='midi' or $extension='mov' or $extension='mp2' or $extension='mp3' or $extension='mp4' or $extension='mpa' or $extension='mpg' or $extension='noa' or $extension='qt' or $extension='ra' or $extension='ram' or $extension='rv' or $extension='swf' or $extension='wav' or $extension='wmv') then 'movie'         else if ($extension='cif' or $extension='exe' or $extension='pdb' or $extension='sdf' or $extension='sif') then 'other'         else ()"/>
         <assert id="supp3c"
                 test="@mimetype or not($extension='eps' or $extension='gif' or $extension='jpg' or $extension='jpeg' or $extension='bmp' or $extension='png' or $extension='pict' or $extension='ps' or $extension='tiff' or $extension='wmf' or $extension='doc' or $extension='docx' or $extension='pdf' or $extension='pps' or $extension='ppt' or $extension='pptx' or $extension='xls' or $extension='xlsx' or $extension='tar' or $extension='tgz' or $extension='zip' or $extension='c' or $extension='csv' or $extension='htm' or $extension='html' or $extension='rtf' or $extension='txt' or $extension='xml' or $extension='aiff' or $extension='au' or $extension='avi' or $extension='midi' or $extension='mov' or $extension='mp2' or $extension='mp3' or $extension='mp4' or $extension='mpa' or $extension='mpg' or $extension='noa' or $extension='qt' or $extension='ra' or $extension='ram' or $extension='rv' or $extension='swf' or $extension='wav' or $extension='wmv' or $extension='cif' or $extension='exe' or $extension='pdb' or $extension='sdf' or $extension='sif')">Missing 'content-type' attribute on "supplementary-material". For files with extension "<value-of select="$extension"/>", this should have the value "<value-of select="$content-type"/>".</assert>
      </rule>
  </pattern>
   <pattern><!--value used for @content-type is correct based on file extension (includes test for valid extension)-->
    <rule context="floats-group/supplementary-material[not(@content-type='external-media')][@content-type][contains(@xlink:href,'.')]"
            role="error">
         <let name="extension" value="functx:substring-after-last(@xlink:href,'.')"/>
         <let name="content-type"
              value="if ($extension='doc' or $extension='docx' or $extension='pdf' or $extension='pps' or $extension='ppt' or $extension='pptx' or $extension='xls' or $extension='xlsx') then 'document'         else if ($extension='eps' or $extension='gif' or $extension='jpg' or $extension='jpeg' or $extension='bmp' or $extension='png' or $extension='pict' or $extension='ps' or $extension='tiff' or $extension='wmf') then 'image'         else if ($extension='tar' or $extension='tgz' or $extension='zip') then 'archive'         else if ($extension='c' or $extension='csv' or $extension='htm' or $extension='html' or $extension='rtf' or $extension='txt' or $extension='xml') then 'text'         else if ($extension='aiff' or $extension='au' or $extension='avi' or $extension='midi' or $extension='mov' or $extension='mp2' or $extension='mp3' or $extension='mp4' or $extension='mpa' or $extension='mpg' or $extension='noa' or $extension='qt' or $extension='ra' or $extension='ram' or $extension='rv' or $extension='swf' or $extension='wav' or $extension='wmv') then 'movie'         else if ($extension='cif' or $extension='exe' or $extension='pdb' or $extension='sdf' or $extension='sif') then 'other'         else ()"/>
         <assert id="supp3d"
                 test="@content-type=$content-type or not($extension='eps' or $extension='gif' or $extension='jpg' or $extension='jpeg' or $extension='bmp' or $extension='png' or $extension='pict' or $extension='ps' or $extension='tiff' or $extension='wmf' or $extension='doc' or $extension='docx' or $extension='pdf' or $extension='pps' or $extension='ppt' or $extension='pptx' or $extension='xls' or $extension='xlsx' or $extension='tar' or $extension='tgz' or $extension='zip' or $extension='c' or $extension='csv' or $extension='htm' or $extension='html' or $extension='rtf' or $extension='txt' or $extension='xml' or $extension='aiff' or $extension='au' or $extension='avi' or $extension='midi' or $extension='mov' or $extension='mp2' or $extension='mp3' or $extension='mp4' or $extension='mpa' or $extension='mpg' or $extension='noa' or $extension='qt' or $extension='ra' or $extension='ram' or $extension='rv' or $extension='swf' or $extension='wav' or $extension='wmv' or $extension='cif' or $extension='exe' or $extension='pdb' or $extension='sdf' or $extension='sif')">For supplementary material files with extension "<value-of select="$extension"/>", the content-type attribute should have the value "<value-of select="$content-type"/>" (not "<value-of select="@content-type"/>").</assert>
      </rule>
  </pattern>
   <pattern><!--supplementary-material - must have an @id-->
    <rule context="floats-group/supplementary-material[not(@content-type='external-media')]"
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
                 test="$extension='eps' or $extension='gif' or $extension='jpg' or $extension='jpeg' or $extension='bmp' or $extension='png' or $extension='pict' or $extension='ps' or $extension='tiff' or $extension='wmf' or $extension='doc' or $extension='docx' or $extension='pdf' or $extension='pps' or $extension='ppt' or $extension='pptx' or $extension='xls' or $extension='xlsx' or $extension='tar' or $extension='tgz' or $extension='zip' or $extension='c' or $extension='csv' or $extension='htm' or $extension='html' or $extension='rtf' or $extension='txt' or $extension='xml' or $extension='aiff' or $extension='au' or $extension='avi' or $extension='midi' or $extension='mov' or $extension='mp2' or $extension='mp3' or $extension='mp4' or $extension='mpa' or $extension='mpg' or $extension='noa' or $extension='qt' or $extension='ra' or $extension='ram' or $extension='rv' or $extension='swf' or $extension='wav' or $extension='wmv' or $extension='cif' or $extension='exe' or $extension='pdb' or $extension='sdf' or $extension='sif'">Unexpected file extension value ("<value-of select="$extension"/>") in supplementary material '@xlink:href' attribute - please check.</assert>
      </rule>
  </pattern>
   <pattern><!--supplementary-material - must have a @mimetype; when @xlink:href does not exist, point to Tagging instructions-->
    <rule context="floats-group/supplementary-material[not(@content-type='external-media')][not(@xlink:href or contains(@xlink:href,'.'))]"
            role="error">
         <assert id="supp5a" test="@mimetype">Missing 'mimetype' attribute on "supplementary-material". Refer to Tagging Instructions for correct value.</assert>
      </rule>
  </pattern>
   <pattern><!--supplementary-material - must have a @mimetype; when @xlink:href is invalid, point to Tagging instructions-->
    <rule context="floats-group/supplementary-material[not(@content-type='external-media')][contains(@xlink:href,'.')]"
            role="error">
         <let name="extension" value="functx:substring-after-last(@xlink:href,'.')"/>
         <report id="supp5b"
                 test="not($extension='eps' or $extension='gif' or $extension='jpg' or $extension='jpeg' or $extension='bmp' or $extension='png' or $extension='pict' or $extension='ps' or $extension='tiff' or $extension='wmf' or $extension='doc' or $extension='docx' or $extension='pdf' or $extension='pps' or $extension='ppt' or $extension='pptx' or $extension='xls' or $extension='xlsx' or $extension='tar' or $extension='tgz' or $extension='zip' or $extension='c' or $extension='csv' or $extension='htm' or $extension='html' or $extension='rtf' or $extension='txt' or $extension='xml' or $extension='aiff' or $extension='au' or $extension='avi' or $extension='midi' or $extension='mov' or $extension='mp2' or $extension='mp3' or $extension='mp4' or $extension='mpa' or $extension='mpg' or $extension='noa' or $extension='qt' or $extension='ra' or $extension='ram' or $extension='rv' or $extension='swf' or $extension='wav' or $extension='wmv' or $extension='cif' or $extension='exe' or $extension='pdb' or $extension='sdf' or $extension='sif') and not(@mimetype)">Missing 'mimetype' attribute on "supplementary-material". Refer to Tagging Instructions for correct value.</report>
      </rule>
  </pattern>
   <pattern><!--supplementary-material - must have a @mimetype; when @xlink:href exists (and is valid) gives value that should be used-->
    <rule context="floats-group/supplementary-material[not(@content-type='external-media')][contains(@xlink:href,'.')]"
            role="error">
         <let name="extension" value="functx:substring-after-last(@xlink:href,'.')"/>
         <let name="mimetype"
              value="if ($extension='doc' or $extension='docx' or $extension='eps' or $extension='exe' or $extension='noa' or $extension='pdf' or $extension='pps' or $extension='ppt' or $extension='pptx' or $extension='ps' or $extension='rtf' or $extension='swf' or $extension='tar' or $extension='tgz' or $extension='wmf' or $extension='xls' or $extension='xlsx' or $extension='xml' or $extension='zip') then 'application'         else if ($extension='mp2' or $extension='mp3' or $extension='ra' or $extension='wav') then 'audio'         else if ($extension='cif' or $extension='pdb' or $extension='sdf') then 'chemical'         else if ($extension='bmp' or $extension='gif' or $extension='jpeg' or $extension='jpg' or $extension='pict' or $extension='png' or $extension='tiff') then 'image'         else if ($extension='c' or  $extension='csv' or $extension='htm' or $extension='html' or $extension='sif' or $extension='txt') then 'text'         else if ($extension='avi' or $extension='mov' or $extension='mp4' or $extension='mpg' or $extension='qt' or $extension='rv' or $extension='wmv') then 'video'         else ()"/>
         <assert id="supp5c"
                 test="@mimetype or not($extension='eps' or $extension='gif' or $extension='jpg' or $extension='jpeg' or $extension='bmp' or $extension='png' or $extension='pict' or $extension='ps' or $extension='tiff' or $extension='wmf' or $extension='doc' or $extension='docx' or $extension='pdf' or $extension='pps' or $extension='ppt' or $extension='pptx' or $extension='xls' or $extension='xlsx' or $extension='tar' or $extension='tgz' or $extension='zip' or $extension='c' or $extension='csv' or $extension='htm' or $extension='html' or $extension='rtf' or $extension='txt' or $extension='xml' or $extension='aiff' or $extension='au' or $extension='avi' or $extension='midi' or $extension='mov' or $extension='mp2' or $extension='mp3' or $extension='mp4' or $extension='mpa' or $extension='mpg' or $extension='noa' or $extension='qt' or $extension='ra' or $extension='ram' or $extension='rv' or $extension='swf' or $extension='wav' or $extension='wmv' or $extension='cif' or $extension='exe' or $extension='pdb' or $extension='sdf' or $extension='sif')">Missing 'mimetype' attribute on "supplementary-material". For files with extension "<value-of select="$extension"/>", this should have the value "<value-of select="$mimetype"/>".</assert>
      </rule>
  </pattern>
   <pattern><!--value used for @mimetype is correct based on file extension (includes test for valid extension)-->
    <rule context="floats-group/supplementary-material[not(@content-type='external-media')][@mimetype][contains(@xlink:href,'.')]"
            role="error">
         <let name="extension" value="functx:substring-after-last(@xlink:href,'.')"/>
         <let name="mimetype"
              value="if ($extension='doc' or $extension='docx' or $extension='eps' or $extension='exe' or $extension='noa' or $extension='pdf' or $extension='pps' or $extension='ppt' or $extension='pptx' or $extension='ps' or $extension='rtf' or $extension='swf' or $extension='tar' or $extension='tgz' or $extension='wmf' or $extension='xls' or $extension='xlsx' or $extension='xml' or $extension='zip') then 'application'         else if ($extension='mp2' or $extension='mp3' or $extension='ra' or $extension='wav') then 'audio'         else if ($extension='cif' or $extension='pdb' or $extension='sdf') then 'chemical'         else if ($extension='bmp' or $extension='gif' or $extension='jpeg' or $extension='jpg' or $extension='pict' or $extension='png' or $extension='tiff') then 'image'         else if ($extension='c' or  $extension='csv' or $extension='htm' or $extension='html' or $extension='sif' or $extension='txt') then 'text'         else if ($extension='avi' or $extension='mov' or $extension='mp4' or $extension='mpg' or $extension='qt' or $extension='rv' or $extension='wmv') then 'video'         else ()"/>
         <assert id="supp5d"
                 test="@mimetype=$mimetype or not($extension='eps' or $extension='gif' or $extension='jpg' or $extension='jpeg' or $extension='bmp' or $extension='png' or $extension='pict' or $extension='ps' or $extension='tiff' or $extension='wmf' or $extension='doc' or $extension='docx' or $extension='pdf' or $extension='pps' or $extension='ppt' or $extension='pptx' or $extension='xls' or $extension='xlsx' or $extension='tar' or $extension='tgz' or $extension='zip' or $extension='c' or $extension='csv' or $extension='htm' or $extension='html' or $extension='rtf' or $extension='txt' or $extension='xml' or $extension='aiff' or $extension='au' or $extension='avi' or $extension='midi' or $extension='mov' or $extension='mp2' or $extension='mp3' or $extension='mp4' or $extension='mpa' or $extension='mpg' or $extension='noa' or $extension='qt' or $extension='ra' or $extension='ram' or $extension='rv' or $extension='swf' or $extension='wav' or $extension='wmv' or $extension='cif' or $extension='exe' or $extension='pdb' or $extension='sdf' or $extension='sif')">For supplementary material files with extension "<value-of select="$extension"/>", the mimetype attribute should have the value "<value-of select="$mimetype"/>" (not "<value-of select="@mimetype"/>").</assert>
      </rule>
  </pattern>
   <pattern><!--supplementary-material - must have a @mime-subtype; when @xlink:href does not exist or is invalid, point to Tagging instructions-->
    <rule context="floats-group/supplementary-material[not(@content-type='external-media')][not(@xlink:href or contains(@xlink:href,'.'))]"
            role="error">
         <assert id="supp6a" test="@mime-subtype">Missing 'mime-subtype' attribute on "supplementary-material". Refer to Tagging Instructions for correct value.</assert>
      </rule>
  </pattern>
   <pattern><!--supplementary-material - must have a @mime-subtype; when @xlink:href exists (and is invalid) points to Tagging instructions-->
    <rule context="floats-group/supplementary-material[not(@content-type='external-media')][contains(@xlink:href,'.')]"
            role="error">
         <let name="extension" value="functx:substring-after-last(@xlink:href,'.')"/>
         <report id="supp6b"
                 test="not($extension='eps' or $extension='gif' or $extension='jpg' or $extension='jpeg' or $extension='bmp' or $extension='png' or $extension='pict' or $extension='ps' or $extension='tiff' or $extension='wmf' or $extension='doc' or $extension='docx' or $extension='pdf' or $extension='pps' or $extension='ppt' or $extension='pptx' or $extension='xls' or $extension='xlsx' or $extension='tar' or $extension='tgz' or $extension='zip' or $extension='c' or $extension='csv' or $extension='htm' or $extension='html' or $extension='rtf' or $extension='txt' or $extension='xml' or $extension='aiff' or $extension='au' or $extension='avi' or $extension='midi' or $extension='mov' or $extension='mp2' or $extension='mp3' or $extension='mp4' or $extension='mpa' or $extension='mpg' or $extension='noa' or $extension='qt' or $extension='ra' or $extension='ram' or $extension='rv' or $extension='swf' or $extension='wav' or $extension='wmv' or $extension='cif' or $extension='exe' or $extension='pdb' or $extension='sdf' or $extension='sif') and not(@mime-subtype)">Missing 'mime-subtype' attribute on "supplementary-material". Refer to Tagging Instructions for correct value based.</report>
      </rule>
  </pattern>
   <pattern><!--supplementary-material - must have a @mime-subtype; when @xlink:href exists (and is valid) gives value that should be used-->
    <rule context="floats-group/supplementary-material[not(@content-type='external-media')][contains(@xlink:href,'.')]"
            role="error">
         <let name="extension" value="functx:substring-after-last(@xlink:href,'.')"/>
         <let name="mime-subtype"
              value="if ($extension='tgz') then 'application/gzip'         else if ($extension='bmp') then 'bmp'         else if ($extension='csv') then 'csv'         else if ($extension='gif') then 'gif'         else if ($extension='htm' or $extension='html') then 'html'         else if ($extension='jpeg' or $extension='jpg') then 'jpeg'         else if ($extension='mp4' or $extension='mp2' or $extension='mp3' or $extension='mpg') then 'mpeg'         else if ($extension='doc' or $extension='dot') then 'msword'         else if ($extension='exe' or $extension='noa' or $extension='ole' or $extension='wp') then 'octet-stream'         else if ($extension='pdf') then 'pdf'         else if ($extension='c' or $extension='sif' or $extension='txt') then 'plain'         else if ($extension='png') then 'png'         else if ($extension='eps' or $extension='ps') then 'postscript'         else if ($extension='mov' or $extension='qt') then 'quicktime'         else if ($extension='rtf') then 'rtf'         else if ($extension='sbml') then 'sbml+xml'         else if ($extension='tiff') then 'tiff'         else if ($extension='xls') then 'vnd.ms-excel'         else if ($extension='xlsm') then 'vnd.ms-excel.sheet.macroEnabled.12'         else if ($extension='pps' or $extension='ppt') then 'vnd.ms-powerpoint'         else if ($extension='pptm') then 'vnd.ms-powerpoint.presentation.macroEnabled.12'         else if ($extension='docm') then 'vnd.ms-word.document.macroEnabled.12'         else if ($extension='pptx') then 'vnd.openxmlformats-officedocument.presentationml.presentation'         else if ($extension='xlsx') then 'vnd.openxmlformats-officedocument.spreadsheetml.sheet'         else if ($extension='docx') then 'vnd.openxmlformats-officedocument.wordprocessingml.document'         else if ($extension='ra') then 'vnd.rn-realaudio'         else if ($extension='rv') then 'vnd.rn-realvideo'         else if ($extension='cdx') then 'x-cdx'         else if ($extension='cif') then 'x-cif'         else if ($extension='jdx') then 'x-jcamp-dx'         else if ($extension='tex') then 'x-latex'         else if ($extension='mol') then 'x-mdl-molfile'         else if ($extension='sdf') then 'x-mdl-sdfile'         else if ($extension='xml') then 'xml'         else if ($extension='wmf') then 'x-msmetafile'         else if ($extension='avi') then 'x-msvideo'         else if ($extension='wmv') then 'x-ms-wmv'         else if ($extension='pdb') then 'x-pdb'         else if ($extension='pict') then 'x-pict'         else if ($extension='swf') then 'x-shockwave-flash'         else if ($extension='tar') then 'x-tar'         else if ($extension='wav') then 'x-wav'         else if ($extension='zip') then 'x-zip-compressed'         else ()"/>
         <assert id="supp6c"
                 test="@mime-subtype or not($extension='eps' or $extension='gif' or $extension='jpg' or $extension='jpeg' or $extension='bmp' or $extension='png' or $extension='pict' or $extension='ps' or $extension='tiff' or $extension='wmf' or $extension='doc' or $extension='docx' or $extension='pdf' or $extension='pps' or $extension='ppt' or $extension='pptx' or $extension='xls' or $extension='xlsx' or $extension='tar' or $extension='tgz' or $extension='zip' or $extension='c' or $extension='csv' or $extension='htm' or $extension='html' or $extension='rtf' or $extension='txt' or $extension='xml' or $extension='aiff' or $extension='au' or $extension='avi' or $extension='midi' or $extension='mov' or $extension='mp2' or $extension='mp3' or $extension='mp4' or $extension='mpa' or $extension='mpg' or $extension='noa' or $extension='qt' or $extension='ra' or $extension='ram' or $extension='rv' or $extension='swf' or $extension='wav' or $extension='wmv' or $extension='cif' or $extension='exe' or $extension='pdb' or $extension='sdf' or $extension='sif')">Missing 'mime-subtype' attribute on "supplementary-material". For files with extension "<value-of select="$extension"/>", this should have the value "<value-of select="$mime-subtype"/>".</assert>
      </rule>
  </pattern>
   <pattern><!--value used for @mimetype is correct based on file extension (includes test for valid extension)-->
    <rule context="floats-group/supplementary-material[not(@content-type='external-media')][@mime-subtype][contains(@xlink:href,'.')]"
            role="error">
         <let name="extension" value="functx:substring-after-last(@xlink:href,'.')"/>
         <let name="mime-subtype"
              value="if ($extension='tgz') then 'application/gzip'         else if ($extension='bmp') then 'bmp'         else if ($extension='csv') then 'csv'         else if ($extension='gif') then 'gif'         else if ($extension='htm' or $extension='html') then 'html'         else if ($extension='jpeg' or $extension='jpg') then 'jpeg'         else if ($extension='mp4' or $extension='mp2' or $extension='mp3' or $extension='mpg') then 'mpeg'         else if ($extension='doc' or $extension='dot') then 'msword'         else if ($extension='exe' or $extension='noa' or $extension='ole' or $extension='wp') then 'octet-stream'         else if ($extension='pdf') then 'pdf'         else if ($extension='c' or $extension='sif' or $extension='txt') then 'plain'         else if ($extension='png') then 'png'         else if ($extension='eps' or $extension='ps') then 'postscript'         else if ($extension='mov' or $extension='qt') then 'quicktime'         else if ($extension='rtf') then 'rtf'         else if ($extension='sbml') then 'sbml+xml'         else if ($extension='tiff') then 'tiff'         else if ($extension='xls') then 'vnd.ms-excel'         else if ($extension='xlsm') then 'vnd.ms-excel.sheet.macroEnabled.12'         else if ($extension='pps' or $extension='ppt') then 'vnd.ms-powerpoint'         else if ($extension='pptm') then 'vnd.ms-powerpoint.presentation.macroEnabled.12'         else if ($extension='docm') then 'vnd.ms-word.document.macroEnabled.12'         else if ($extension='pptx') then 'vnd.openxmlformats-officedocument.presentationml.presentation'         else if ($extension='xlsx') then 'vnd.openxmlformats-officedocument.spreadsheetml.sheet'         else if ($extension='docx') then 'vnd.openxmlformats-officedocument.wordprocessingml.document'         else if ($extension='ra') then 'vnd.rn-realaudio'         else if ($extension='rv') then 'vnd.rn-realvideo'         else if ($extension='cdx') then 'x-cdx'         else if ($extension='cif') then 'x-cif'         else if ($extension='jdx') then 'x-jcamp-dx'         else if ($extension='tex') then 'x-latex'         else if ($extension='mol') then 'x-mdl-molfile'         else if ($extension='sdf') then 'x-mdl-sdfile'         else if ($extension='xml') then 'xml'         else if ($extension='wmf') then 'x-msmetafile'         else if ($extension='avi') then 'x-msvideo'         else if ($extension='wmv') then 'x-ms-wmv'         else if ($extension='pdb') then 'x-pdb'         else if ($extension='pict') then 'x-pict'         else if ($extension='swf') then 'x-shockwave-flash'         else if ($extension='tar') then 'x-tar'         else if ($extension='wav') then 'x-wav'         else if ($extension='zip') then 'x-zip-compressed'         else ()"/>
         <assert id="supp6d"
                 test="@mime-subtype=$mime-subtype or not($extension='eps' or $extension='gif' or $extension='jpg' or $extension='jpeg' or $extension='bmp' or $extension='png' or $extension='pict' or $extension='ps' or $extension='tiff' or $extension='wmf' or $extension='doc' or $extension='docx' or $extension='pdf' or $extension='pps' or $extension='ppt' or $extension='pptx' or $extension='xls' or $extension='xlsx' or $extension='tar' or $extension='tgz' or $extension='zip' or $extension='c' or $extension='csv' or $extension='htm' or $extension='html' or $extension='rtf' or $extension='txt' or $extension='xml' or $extension='aiff' or $extension='au' or $extension='avi' or $extension='midi' or $extension='mov' or $extension='mp2' or $extension='mp3' or $extension='mp4' or $extension='mpa' or $extension='mpg' or $extension='noa' or $extension='qt' or $extension='ra' or $extension='ram' or $extension='rv' or $extension='swf' or $extension='wav' or $extension='wmv' or $extension='cif' or $extension='exe' or $extension='pdb' or $extension='sdf' or $extension='sif')">For supplementary material files with extension "<value-of select="$extension"/>", the mime-subtype attribute should have the value "<value-of select="$mime-subtype"/>" (not "<value-of select="@mime-subtype"/>").</assert>
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
</schema>