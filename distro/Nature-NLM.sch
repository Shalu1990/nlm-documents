<?xml version="1.0" encoding="UTF-8"?>
<schema xmlns="http://purl.oclc.org/dsdl/schematron" queryBinding="xslt2">
  <title>Schematron rules for NPG content in NLM v3.0 - metadata</title>
  <ns uri="http://www.w3.org/1998/Math/MathML" prefix="mml"/>
  <ns uri="http://docs.oasis-open.org/ns/oasis-exchange/table" prefix="oasis"/>
  <ns uri="http://www.w3.org/1999/xlink" prefix="xlink"/>
  <let name="allowed-values" value="document( 'allowed-values-nlm.xml' )/allowed-values"/><!--Points at document containing information on journal titles, ids and DOIs-->

  <let name="products" value="document('products.owl')"/>
  <!--<let name="subjects" value="document('subjects.owl')/skos:concept"/>
  <ns uri="http://ns.nature.com/subjects/" prefix="skos"/>Namespace for Ontologies document-->
  <ns uri="http://ns.nature.com/terms/" prefix="terms"/><!--Namespace for Ontologies document-->
  <ns uri="http://purl.org/dc/elements/1.1/" prefix="dc"/><!--Namespace for Ontologies document-->
  <ns uri="http://www.w3.org/1999/02/22-rdf-syntax-ns#" prefix="rdf"/><!--Namespace for Ontologies document-->
  
  <!--Regularly used values throughout rules-->
  <let name="journal-title" value="//journal-meta/journal-title-group/journal-title"/>
  <let name="journal-id" value="//journal-meta/journal-id"/>
  <let name="filename" value="base-uri()"/><!--May not be necessary to declare this - delete if filename not used-->
  
  <!--Rules only cover metadata sections at the moment; more rules to be added for body-->
  
  <!--
    ******************************************************************************************************************************
    Root
    ******************************************************************************************************************************
  -->
  
  <!--article/@article-type matches expected values for journal-->
  <pattern>
    <rule context="article" role="error"><!--Does the article have an article-type attribute-->
      <assert  id="article1" test="@article-type">All articles should have an article-type attribute on "article". The value should be the same as the information contained in the subject element with attribute content-type="article-type".</assert>
    </rule>
  </pattern>
  
  <pattern>
    <rule context="article/@article-type" role="error"><!--Is the article-type valid?-->
      <assert  id="article2" test="contains($allowed-values/journal[@title=$journal-title]/article-types,.) or not($allowed-values/journal[@title=$journal-title])">Unexpected root article type (<value-of select="."/>) for <value-of select="$journal-title"/>.</assert>
    </rule>
  </pattern>
  
  <pattern>
    <rule context="article[@xml:lang]" role="error"><!--If @xml:lang exists, does it have an allowed value-->
      <assert  id="article3" test="contains($allowed-values/languages,@xml:lang)">Unexpected language "<value-of select="@xml:lang"/>" declared on root article element. Expected values are "en" (English), "de" (German) and "ja" (Japanese/Kanji).</assert>
    </rule>
  </pattern>
  
  <!--no processing instructions in the file-->
  
  <!--
    ******************************************************************************************************************************
    Front 
    ******************************************************************************************************************************
  -->
  
  <!-- ======================================================== Journal metadata =============================================== -->
  
  <pattern>
    <rule context="journal-id" role="error"><!--Correct attribute value included-->
      <assert id="jmeta1" test="@journal-id-type='publisher'">The "journal-id" element should have attribute: journal-id-type="publisher".</assert>
    </rule>
  </pattern>
  
  <pattern>
    <rule context="journal-meta" role="error"><!--Journal title exists-->
      <assert id="jmeta2" test="descendant::journal-title-group">Journal title is missing from the journal metadata section. Other rules are based on having a correct journal title and therefore will not be run. Please resubmit this file when the title has been added.</assert>
    </rule>
  </pattern>
  
  <pattern>
    <rule context="journal-title-group" role="error"><!--Are the journal title and id valid and do they match each other?-->
      <assert id="jmeta3a" test="not(descendant::journal-title) or $products[descendant::dc:title=$journal-title]">Journal titles must be from the prescribed list of journal names. "<value-of select="$journal-title"/>" is not on this list - check spelling, spacing of words or use of the ampersand. Other rules are based on having a correct journal title and therefore will not be run. Please resubmit this file when the title has been corrected.</assert>
      <assert id="jmeta3b" test="$products[descendant::terms:pcode=$journal-id]">Journal id is incorrect. For <value-of select="$journal-title"/>, it should be: <value-of select="$products//*[child::dc:title=$journal-title]/terms:pcode"/>. Other rules are based on having a correct journal id and therefore will not be run. Please resubmit this file when the journal id has been corrected.</assert>
      <assert id="jmeta3c" test="$journal-id=$products//*[child::dc:title=$journal-title]/terms:pcode or not($products[descendant::dc:title=$journal-title]) or not($products[descendant::terms:pcode=$journal-id])">Journal id (<value-of select="$journal-id"/>) does not match journal title: <value-of select="$journal-title"/>. Check which is the correct value.</assert>
    </rule>
  </pattern>
  
  <pattern>
    <rule context="journal-subtitle | abbrev-journal-title | trans-title-group" role="error"><!--No other children of journal-title-group used-->
      <report id="jmeta4" test="parent::journal-title-group">Unexpected use of "<name/>" in "journal-title-group". "journal-title-group" should only contain "journal-title".</report>
    </rule>
  </pattern>
  
  <pattern>
    <rule context="journal-meta/issn" role="error"><!--Correct attribute value inserted; ISSN matches expected syntax-->
      <assert id="jmeta5a" test="@pub-type='ppub' or @pub-type='epub'">ISSN should have attribute pub-type="ppub" for print or pub-type="epub" for electronic publication.</assert>
      <let name="issn" value="concat('http://ns.nature.com/publications/',.)"/>
      <assert id="jmeta5b" test="$products//*[child::dc:title=$journal-title][terms:hasPublication[@rdf:resource=$issn]]">Unexpected ISSN value for <value-of select="$journal-title"/> (<value-of select="."/>)</assert>
    </rule>
  </pattern>
  
  <pattern>
    <rule context="journal-meta/isbn" role="error"><!--Other expected and unexpected elements-->
      <report id="jmeta6" test=".">Do not use the ISBN element in journal metadata.</report>
    </rule>
  </pattern>
  
  <pattern>
    <rule context="journal-meta" role="error"><!--Other expected and unexpected elements-->
      <assert id="jmeta7" test="publisher">Journal metadata should include a "publisher" element.</assert>
    </rule>
  </pattern>
  
  <pattern><!--Does the publisher-name match the copyright-holder?-->
    <let name="holder" value="//permissions/copyright-holder"></let>
    <rule context="publisher/publisher-name" role="error">
      <assert id="jmeta8" test=". = $holder or not($holder) or not($holder=$allowed-values/journal[@title=$journal-title]/copyright-holder)">The publisher-name (<value-of select="."/>) should match the copyright-holder (<value-of select="$holder"/>).</assert>
    </rule>
  </pattern>

  <!-- ====================================================== Article metadata ================================================== -->

  <pattern>
    <rule context="article-meta" role="error"><!--Two article ids, one doi and one publisher-id-->
      <assert id="ameta1a" test="article-id[@pub-id-type='doi'] and article-id[@pub-id-type='publisher-id']">Article metadata should contain two "article-id" elements, one with attribute pub-id-type="doi" and one with attribute pub-id-type="publisher-id".</assert>
    </rule>
  </pattern>

  <!--test doi is as expected in same test-->
  
  <!--Article categories-->
  
  <pattern>
    <rule context="article-meta"><!--article-categories exists-->
      <assert id="ameta1b" test="article-categories">Article metadata should include an "article-categories" element.</assert>
    </rule>
  </pattern>
  
  
  <pattern><!--Is the article heading type valid and does it match the main article type?-->
    <rule context="subject[@content-type='article-type']" role="error">
      <assert id="ameta2a" test="contains($allowed-values/journal[@title=$journal-title]/article-types,.) or not($allowed-values/journal[@title=$journal-title])">Unexpected subject article type (<value-of select="."/>) for <value-of select="$journal-title"/>.</assert>
      <!--This rule falls over if article/@article-type does not exist. Also fires if there is an error in the article/@article-type. Attributes changed. Rewrite.--><assert id="ameta2b" test="article/@article-type and matches(.,ancestor::article/@article-type) or not($allowed-values/journal[@title=$journal-title]) or not(contains($allowed-values/journal[@title=$journal-title]/article-types,.))">Subject article type (<value-of select="."/>) does not match root article type (<value-of select="ancestor::article/@article-type"/>)</assert>
    </rule>
  </pattern>
  
<!--
  <pattern>Has at least one subject code been included? Is this applicable to all journals?
    <rule context="article-categories" role="error">
      <assert id="ameta3a" test="descendant::subj-group[@subj-group-type='subjects']">Subject code(s) should be contained in article metadata section. Contact NPG Editorial Production for values that should be used.</assert>
    </rule>
  </pattern>
  
  <pattern>Is the NPG subject code allowed in this journal? Will need updating for current ontology filenames. Applicable to which journals?
    <rule context="subject[@content-type='npg.subject']/named-content[@content-type='id']" role="error">
      <let name="code" value="."/>
      <assert id="ameta3b" test="$subject-codes/s:subject[@code=$code]/p:references/p:reference[@type='product'][@pcode=$journal-id] or not($journal-id=$allowed-values/journal[@title=$journal-title]/id) or not($allowed-values/journal[@title=$journal-title]) or not($allowed-values/journal[id=$journal-id])">Unexpected subject code (<value-of select="$code"/> - <value-of select="$subject-codes/s:subject[@code=$code]/@name"/>) for <value-of select="$journal-title"/>. Contact NPG Editorial Production for values that should be used.</assert>
    </rule>
  </pattern>
  
  <pattern>Is the old-style subject code allowed in this journal?
    <rule context="subject[@content-type='subject']" role="error">
      <assert id="ameta3c" test="contains(.,$journal-id) or not($journal-id=$allowed-values/journal[@title=$journal-title]/id) or not($allowed-values/journal[@title=$journal-title]) or not($allowed-values/journal[id=$journal-id])">Unexpected subject code (<value-of select="."/> for <value-of select="$journal-title"/>. Contact NPG Editorial Production for values that should be used.</assert>
    </rule>
  </pattern>
-->
  
  <!--@content-type='indications' rules-->
  
  <!--Article title (title-group)-->
  
  <!--Contrib group-->
  
  <!-- **** Publication date **** -->
  
  <!--Rules around expected attribute values of pub-date-->
  
  <pattern><!--Valid values for year, month and day-->
    <rule context="pub-date" role="error">
      <assert id="date1a" test="not(year) or matches(year, '^(19|20)[0-9]{2}$')">Invalid year value: <value-of select="year"/>. It should be a 4-digit number starting with 19 or 20.</assert>
      <assert id="date1b" test="not(month) or matches(month, '^((0[1-9])|(1[0-2]))$')">Invalid month value: <value-of select="month"/>. It should be a 2-digit number between 01 and 12.</assert>
      <assert id="date1c" test="not(day) or matches(day, '^(0[1-9]|[12][0-9]|3[01])$')">Invalid day value: <value-of select="day"/>. It should be a 2-digit number between 01 and 31.</assert>
    </rule>
  </pattern> 
  
  <pattern><!--Concatenate year/month/day and check valid if those elements have already passed basic validation checks. This rule adapted from http://regexlib.com, author Michel Chouinard -->
    <rule context="pub-date[matches(year, '^(19|20)[0-9]{2}$') and matches(month, '^((0[1-9])|(1[0-2]))$') and matches(day, '^(0[1-9]|[12][0-9]|3[01])$')]" role="error">
      <assert id="date2" test="matches(concat(year,month,day), '^(((19|20)(([0][48])|([2468][048])|([13579][26]))|2000)(([0][13578]|[1][02])([012][0-9]|[3][01])|([0][469]|11)([012][0-9]|30)|02([012][0-9]))|((19|20)(([02468][1235679])|([13579][01345789]))|1900)(([0][13578]|[1][02])([012][0-9]|[3][01])|([0][469]|11)([012][0-9]|30)|02([012][0-8])))$')">Invalid publication date - the day value (<value-of select="day"/>) does not exist for the month (<value-of select="month"/>) in the year (<value-of select="year"/>).</assert>
    </rule>
  </pattern>
  
  <pattern><!--Year/Day - invalid combination in pub-date-->
    <rule context="pub-date" role="error">
      <report id="date3" test="year and day and not(month)">Missing month in pub-date. Currently only contains year and day.</report>
    </rule>
  </pattern>
  
  <!--Volume-->
  
  <!--Issue-->
  
  <!--Page spans correct, not present for online only or aop-->

  <!--Permissions, including copyright info-->
  
  <pattern>
    <rule context="article-meta"><!--permissions and expected children exist-->
      <assert id="copy1a" test="permissions">Article metadata should include a "permissions" element.</assert>
      <assert id="copy1b" test="permissions/copyright-year">Permissions should include the copyright year.</assert>
      <assert id="copy1c" test="permissions/copyright-holder">Permissions should include the copyright holder: <value-of select="$allowed-values/journal[@title=$journal-title]/copyright-holder"/>.</assert>
    </rule>
  </pattern>
  
  <pattern><!--Is the copyright year valid?-->
    <rule context="copyright-year" role="error">
      <assert id="copy2" test="matches(.,'^(19|20)[0-9]{2}$')">Invalid year value for copyright: <value-of select="."/>. It should be a 4-digit number starting with 19 or 20.</assert>
    </rule>
  </pattern>

  
  <pattern><!--Is the copyright holder correct for the journal?-->
    <rule context="copyright-holder" role="error">
      <assert id="copy3" test=". = $allowed-values/journal[@title=$journal-title]/copyright-holder or  not($allowed-values/journal[@title=$journal-title])">The copyright-holder for <value-of select="$journal-title"/> should be: <value-of select="$allowed-values/journal[@title=$journal-title]/copyright-holder"/></assert>
    </rule>
  </pattern>

  <!--Related article - type and link as expected?-->
  
  <!--Abstract-->
  
  <!--Keywords-->
  
</schema>
