<?xml version="1.0" encoding="UTF-8"?>
<sch:schema xmlns:sch="http://purl.oclc.org/dsdl/schematron" xmlns:mml="http://www.w3.org/1998/Math/MathML" queryBinding="xslt2">
  <sch:title>Schematron rules for NPG content in NLM v3.0 - metadata</sch:title>
  <sch:let name="allowed-values" value="document( 'allowed-values-nlm.xml' )/allowed-values"/><!--Points at document containing information on journal titles, ids and DOIs-->

  <sch:let name="subject-codes" value="document('subject-codes.xml')/s:subjects"/><!--Points at Ontologies document for checking subject codes are correct for each journal. Will need to update rules if format of this document changes-->
  <sch:ns uri="http://ns.nature.com/subjects/" prefix="s"/><!--Namespace for Ontologies document-->
  <sch:ns uri="http://ns.nature.com/products/" prefix="p"/><!--Namespace for Ontologies document-->

  <!--Regularly used values throughout rules-->
  <sch:let name="journal-title" value="//journal-meta/journal-title-group/journal-title"/>
  <sch:let name="journal-id" value="//journal-meta/journal-id"/>
  <sch:let name="filename" value="base-uri()"/><!--May not be necessary to declare this - delete if filename not used-->
  
  <!--Rules only cover metadata sections at the moment; more rules to be added for body-->
  
  <!--
    ******************************************************************************************************************************
    Root
    ******************************************************************************************************************************
  -->
  
  <!--article/@article-type matches expected values for journal-->
  <sch:pattern>
    <sch:rule context="article/@article-type" role="error"><!--Is the article-type valid?-->
      <sch:assert  id="article1" test="contains($allowed-values/journal[@title=$journal-title]/article-types,.) or not($allowed-values/journal[@title=$journal-title])">Unexpected root article type (<sch:value-of select="."/>) for <sch:value-of select="$journal-title"/>.</sch:assert>
    </sch:rule>
  </sch:pattern>
  
  <!--no processing instructions in the file-->
  
  <!--
    ******************************************************************************************************************************
    Front 
    ******************************************************************************************************************************
  -->
  
  <!-- ======================================================== Journal metadata =============================================== -->
  
  <sch:pattern>
    <sch:rule context="journal-id" role="error"><!--Correct attribute value included-->
      <sch:assert id="jmeta1" test="@journal-id-type='publisher'">The "journal-id" element should have attribute: journal-id-type="publisher".</sch:assert>
    </sch:rule>
  </sch:pattern>
  
  <sch:pattern>
    <sch:rule context="journal-meta" role="error"><!--Journal title exists-->
      <sch:assert id="jmeta2" test="descendant::journal-title-group">Journal title is missing from the journal metadata section. Other rules are based on having a correct journal title and therefore will not be run. Please resubmit this file when the title has been added.</sch:assert>
    </sch:rule>
  </sch:pattern>
  
  <sch:pattern>
    <sch:rule context="journal-title-group" role="error"><!--Are the journal title and id valid and match each other?-->
      <sch:assert id="jmeta3a" test="not(descendant::journal-title) or $allowed-values/journal[@title=$journal-title]">Journal titles must be from the prescribed list of journal names. "<sch:value-of select="$journal-title"/>" is not on this list - check spelling, spacing of words or use of the ampersand. Other rules are based on having a correct journal title and therefore will not be run. Please resubmit this file when the title has been corrected.</sch:assert>
      
      <sch:assert id="jmeta3b" test="$allowed-values/journal[id=$journal-id]">Journal id is incorrect. For <sch:value-of select="$journal-title"/>, it should be: <sch:value-of select="$allowed-values/journal[@title=$journal-title]/id"/>. Other rules are based on having a correct journal id and therefore will not be run. Please resubmit this file when the journal id has been corrected.</sch:assert>
      
      <sch:assert id="jmeta3c" test="$journal-id=$allowed-values/journal[@title=$journal-title]/id or not($allowed-values/journal[@title=$journal-title]) or not($allowed-values/journal[id=$journal-id])">Journal id (<sch:value-of select="$journal-id"/>) does not match journal title: <sch:value-of select="$journal-title"/>. Check which is the correct value.</sch:assert>
    </sch:rule>
  </sch:pattern>
  
  <sch:pattern>
    <sch:rule context="journal-title-group" role="error"><!--No other children of journal-title-group used-->
      <sch:report id="jmeta4a" test="abbrev-journal-title">Unexpected use of "abbrev-journal-title" in journal title group.</sch:report>
      <sch:report id="jmeta4b" test="journal-subtitle">Unexpected use of "journal-subtitle" in journal title group.</sch:report>
      <sch:report id="jmeta4c" test="trans-title-group">Unexpected use of "trans-title-group" in journal title group.</sch:report>
    </sch:rule>
  </sch:pattern>
  
  <sch:pattern>
    <sch:rule context="journal-meta/issn" role="error"><!--Correct attribute value inserted; ISSN matches expected syntax-->
      <sch:assert id="jmeta5" test="@pub-type='ppub' or @pub-type='epub'">ISSN should have attribute pub-type="ppub" for print or pub-type="epub" for electronic publication.</sch:assert>
      <sch:assert id="jmeta6" test="matches(.,'^[0-9]{4}\-[0-9]{3}([0-9]{1}|X)$')">ISSN does not conform to the expected syntax of two groups of four digits separated by a hyphen (-). The final character can be an 'X' rather than a number.</sch:assert>
    </sch:rule>
  </sch:pattern>
  
  <sch:pattern>
    <sch:rule context="journal-meta" role="error"><!--Other expected and unexpected elements-->
      <sch:report id="jmeta7a" test="isbn">Do not use the ISBN element in journal metadata.</sch:report>
      <sch:assert id="jmeta7b" test="publisher">Journal metadata should include a "publisher" element.</sch:assert>
    </sch:rule>
  </sch:pattern>
    
  <sch:pattern><!--Is the publisher name correct for the journal?-->
    <sch:rule context="journal-meta//publisher-name" role="error">
      <sch:assert id="jmeta8" test=". = $allowed-values/journal[@title=$journal-title]/publisher or not($journal-id=$allowed-values/journal[@title=$journal-title]/id) or not($allowed-values/journal[@title=$journal-title]) or not($allowed-values/journal[id=$journal-id])">The publisher text for <sch:value-of select="$journal-title"/> should be: <sch:value-of select="$allowed-values/journal[@title=$journal-title]/publisher"/></sch:assert>
    </sch:rule>
  </sch:pattern>

  <!-- ====================================================== Article metadata ================================================== -->

  <sch:pattern>
    <sch:rule context="article-meta" role="error"><!--Two article ids, one doi and one publisher-id-->
      <sch:assert id="ameta1a" test="article-id[@pub-id-type='doi'] and article-id[@pub-id-type='publisher-id']">Article metadata should contain two "article-id" elements, one with attribute pub-id-type="doi" and one with attribute pub-id-type="publisher-id".</sch:assert>
    </sch:rule>
  </sch:pattern>

  <!--test doi is as expected in same test-->
  
  <!--Article categories-->
  
  <sch:pattern>
    <sch:rule context="article-meta"><!--article-categories exists-->
      <sch:assert id="ameta1b" test="article-categories">Article metadata should include an "article-categories" element.</sch:assert>
    </sch:rule>
  </sch:pattern>
  
  
  <sch:pattern><!--Is the article heading type valid and does it match the main article type?-->
    <sch:rule context="subject[@content-type='article-type']" role="error">
      <sch:assert id="ameta2a" test="contains($allowed-values/journal[@title=$journal-title]/article-types,.) or not($allowed-values/journal[@title=$journal-title])">Unexpected subject article type (<sch:value-of select="."/>) for <sch:value-of select="$journal-title"/>.</sch:assert>
      <sch:assert id="ameta2b" test="matches(.,ancestor::article/@article-type) or not($allowed-values/journal[@title=$journal-title]) or not(contains($allowed-values/journal[@title=$journal-title]/article-types,.))">Subject article type (<sch:value-of select="."/>) does not match root article type (<sch:value-of select="ancestor::article/@article-type"/>)</sch:assert>
    </sch:rule>
  </sch:pattern>
  
  <sch:pattern><!--Has at least one subject code been included?-->
    <sch:rule  context="article-categories" role="error">
      <sch:assert id="ameta3" test="descendant::subj-group[@subj-group-type='subjects']">Subject code(s) should be contained in article metadata section.</sch:assert>
    </sch:rule>
  </sch:pattern>
  
  <sch:pattern><!--Is the NPG subject code allowed in this journal?-->
    <sch:rule context="subject[@content-type='npg.subject']/named-content[@content-type='id']" role="error">
      <sch:let name="code" value="."/>
      <sch:assert id="subject1" test="$subject-codes/s:subject[@code=$code]/p:references/p:reference[@type='product'][@pcode=$journal-id] or not($journal-id=$allowed-values/journal[@title=$journal-title]/id) or not($allowed-values/journal[@title=$journal-title]) or not($allowed-values/journal[id=$journal-id])">Unexpected subject code (<sch:value-of select="$code"/> - <sch:value-of select="$subject-codes/s:subject[@code=$code]/@name"/>) for <sch:value-of select="$journal-title"/></sch:assert>
    </sch:rule>
  </sch:pattern>
  
  <sch:pattern><!--Is the old-style subject code allowed in this journal?-->
    <sch:rule context="subject[@content-type='subject']" role="error">
      <sch:assert id="subject2" test="contains(.,$journal-id) or not($journal-id=$allowed-values/journal[@title=$journal-title]/id) or not($allowed-values/journal[@title=$journal-title]) or not($allowed-values/journal[id=$journal-id])">Unexpected subject code (<sch:value-of select="."/> for <sch:value-of select="$journal-title"/></sch:assert>
    </sch:rule>
  </sch:pattern>
  
  <!--@content-type='indications' rules-->
  
  <!--Article title (title-group)-->
  
  <!--Contrib group-->
  
  <!-- **** Publication date **** -->
  
  <!--Rules around expected attribute values of pub-date - dependent on each journal perhaps?-->
  
  <sch:pattern><!--Valid values for year, month and day-->
    <sch:rule context="pub-date" role="error">
      <sch:assert id="date1a" test="not(year) or matches(year, '^(19|20)[0-9]{2}$')">Invalid year value: <sch:value-of select="year"/>. It should be a 4-digit number starting with 19 or 20.</sch:assert>
      <sch:assert id="date1b" test="not(month) or matches(month, '^((0[1-9])|(1[0-2]))$')">Invalid month value: <sch:value-of select="month"/>. It should be a 2-digit number between 01 and 12.</sch:assert>
      <sch:assert id="date1c" test="not(day) or matches(day, '^(0[1-9]|[12][0-9]|3[01])$')">Invalid day value: <sch:value-of select="day"/>. It should be a 2-digit number between 01 and 31.</sch:assert>
    </sch:rule>
  </sch:pattern> 
  
  <sch:pattern><!--Concatenate year/month/day and check valid if those elements have already passed basic validation checks. This rule adapted from http://regexlib.com, author Michel Chouinard -->
    <sch:rule context="pub-date[matches(year, '^(19|20)[0-9]{2}$') and matches(month, '^((0[1-9])|(1[0-2]))$') and matches(day, '^(0[1-9]|[12][0-9]|3[01])$')]" role="error">
      <sch:assert id="date2" test="matches(concat(year,month,day), '^(((19|20)(([0][48])|([2468][048])|([13579][26]))|2000)(([0][13578]|[1][02])([012][0-9]|[3][01])|([0][469]|11)([012][0-9]|30)|02([012][0-9]))|((19|20)(([02468][1235679])|([13579][01345789]))|1900)(([0][13578]|[1][02])([012][0-9]|[3][01])|([0][469]|11)([012][0-9]|30)|02([012][0-8])))$')">Invalid publication date - the day value (<sch:value-of select="day"/>) does not exist for the month (<sch:value-of select="month"/>) in the year (<sch:value-of select="year"/>).</sch:assert>
    </sch:rule>
  </sch:pattern>
  
  <sch:pattern><!--Year/Day - invalid combination in pub-date-->
    <sch:rule context="pub-date" role="error">
      <sch:report id="date3" test="year and day and not(month)">Missing month in pub-date. Currently only contains year and day.</sch:report>
    </sch:rule>
  </sch:pattern>
  
  <!--Volume-->
  
  <!--Issue-->
  
  <!--Page spans correct, not present for online only or aop-->

  <!--Permissions, including copyright info-->
  
  <sch:pattern>
    <sch:rule context="article-meta"><!--permissions and expected children exist-->
      <sch:assert id="copy1a" test="permissions">Article metadata should include a "permissions" element.</sch:assert>
      <sch:assert id="copy1b" test="permissions/copyright-year">Permissions should include the copyright year.</sch:assert>
      <sch:assert id="copy1c" test="permissions/copyright-holder">Permissions should include the copyright holder: <sch:value-of select="$allowed-values/journal[@title=$journal-title]/copyright-holder"/>.</sch:assert>
    </sch:rule>
  </sch:pattern>
  
  <sch:pattern><!--Is the copyright year valid?-->
    <sch:rule context="copyright-year" role="error">
      <sch:assert id="copy2" test="matches(.,'^(19|20)[0-9]{2}$')">Invalid year value for copyright: <sch:value-of select="."/>. It should be a 4-digit number starting with 19 or 20.</sch:assert>
    </sch:rule>
  </sch:pattern>

  <sch:pattern><!--Is the copyright holder correct for the journal?-->
    <sch:rule context="copyright-holder" role="error">
      <sch:assert id="copy3" test=". = $allowed-values/journal[@title=$journal-title]/copyright-holder or not($journal-id=$allowed-values/journal[@title=$journal-title]/id) or not($allowed-values/journal[@title=$journal-title]) or not($allowed-values/journal[id=$journal-id])">The copyright-holder text for <sch:value-of select="$journal-title"/> should be: <sch:value-of select="$allowed-values/journal[@title=$journal-title]/copyright-holder"/></sch:assert>
    </sch:rule>
  </sch:pattern>

  <!--Related article - type and link as expected?-->
  
  <!--Abstract-->
  
  <!--Keywords-->
  
</sch:schema>
