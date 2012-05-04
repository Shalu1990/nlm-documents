<?xml version="1.0" encoding="UTF-8"?>
<schema xmlns="http://purl.oclc.org/dsdl/schematron" queryBinding="xslt2">
  <title>Schematron rules for NPG content in NLM v3.0</title>
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
  <let name="article-type" value="article/@article-type"/>
  <let name="filename" value="base-uri()"/><!--May not be necessary to declare this - delete if filename not used-->
  
  <!--Rules only cover metadata sections at the moment; more rules to be added for body-->
  
  <!--
    ******************************************************************************************************************************
    Root
    ******************************************************************************************************************************
  -->
  
  <!--article/@article-type exists and matches expected values for journal-->
  <pattern>
    <rule context="article" role="error"><!--Does the article have an article-type attribute-->
      <assert  id="article1" test="@article-type">All articles should have an article-type attribute on "article". The value should be the same as the information contained in the subject element with attribute content-type="article-type".</assert>
    </rule>
  </pattern>
  
  <pattern>
    <rule context="article[@article-type]" role="error"><!--Is the article-type valid?-->
      <assert  id="article2" test="$journal-title = $allowed-values/article-types/article-type[@type=$article-type]/journal or not($journal-title) or not($products[descendant::dc:title=$journal-title])">Unexpected root article type (<value-of select="$article-type"/>) for <value-of select="$journal-title"/>.</assert>
    </rule>
  </pattern>
  
  <pattern>
    <rule context="article[@xml:lang]" role="error"><!--If @xml:lang exists, does it have an allowed value-->
      <let name="lang" value="@xml:lang"></let>
      <assert  id="article3" test="$allowed-values/languages/language[.=$lang]">Unexpected language (<value-of select="$lang"/>) declared on root article element. Expected values are "en" (English), "de" (German) and "ja" (Japanese/Kanji).</assert>
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
      <assert id="jmeta2a" test="descendant::journal-title-group/journal-title">Journal title is missing from the journal metadata section. Other rules are based on having a correct journal title and therefore will not be run. Please resubmit this file when the title has been added.</assert>
    </rule>
  </pattern>
  <pattern>
    <rule context="journal-title-group[1]" role="error"><!--only one journal-title-group-->
      <report id="jmeta2b" test="following-sibling::journal-title-group">Only one journal-title-group should be used for NPG content.</report>
    </rule>
  </pattern>
  
  <pattern>
    <rule context="journal-title-group" role="error"><!--Is the journal title valid-->
      <assert id="jmeta3a" test="not(descendant::journal-title) or $products[descendant::dc:title=$journal-title]">Journal titles must be from the prescribed list of journal names. "<value-of select="$journal-title"/>" is not on this list - check spelling, spacing of words or use of the ampersand. Other rules are based on having a correct journal title and therefore will not be run. Please resubmit this file when the title has been corrected.</assert>
      </rule>
    </pattern>
  <pattern>
    <rule context="journal-title-group" role="error"><!--Is the journal id valid?-->
      <assert id="jmeta3b" test="$products[descendant::terms:pcode=$journal-id] or not($products[descendant::dc:title=$journal-title])">Journal id is incorrect. For <value-of select="$journal-title"/>, it should be: <value-of select="$products//*[child::dc:title=$journal-title]/terms:pcode"/>. Other rules are based on having a correct journal id and therefore will not be run. Please resubmit this file when the journal id has been corrected.</assert></rule>
    </pattern>
  <pattern>
    <rule context="journal-title-group" role="error"><!--Do the journal title and id match each other?-->
      <assert id="jmeta3c" test="$journal-id=$products//*[child::dc:title=$journal-title]/terms:pcode or not($products[descendant::dc:title=$journal-title]) or not($products[descendant::terms:pcode=$journal-id])">Journal id (<value-of select="$journal-id"/>) does not match journal title: <value-of select="$journal-title"/>. Check which is the correct value.</assert>
    </rule>
  </pattern>
  
  <pattern>
    <rule context="journal-subtitle | trans-title-group" role="error"><!--No other children of journal-title-group used-->
      <report id="jmeta4" test="parent::journal-title-group">Unexpected use of "<name/>" in "journal-title-group". "journal-title-group" should only contain "journal-title".</report>
    </rule>
  </pattern>
  
  <pattern>
    <rule context="journal-title-group/journal-title[1]" role="error"><!--Only one journal title present-->
      <report id="jmeta4b" test="following-sibling::journal-title">More than one journal title found. Only one journal title should be used in NPG articles.</report>
    </rule>
  </pattern>
  
  <pattern>
    <rule context="journal-title-group/abbrev-journal-title[1]" role="error"><!--Only one journal title present-->
      <report id="jmeta4c" test="following-sibling::abbrev-journal-title">More than one abbreviated journal title found. Only one abbreviated journal title should be used in NPG articles.</report>
    </rule>
  </pattern>
  
  <pattern>
    <rule context="journal-meta/issn" role="error"><!--Correct attribute value inserted; ISSN matches expected syntax-->
      <assert id="jmeta5a" test="@pub-type='ppub' or @pub-type='epub'">ISSN should have attribute pub-type="ppub" for print or pub-type="epub" for electronic publication.</assert>
      </rule>
    </pattern>
  <pattern>
    <rule context="journal-meta/issn" role="error">
      <let name="issn" value="concat('http://ns.nature.com/publications/',.)"/>
      <assert id="jmeta5b" test="not($journal-title) or not($products[descendant::dc:title=$journal-title]) or $products//*[child::dc:title=$journal-title][terms:hasPublication[@rdf:resource=$issn]]">Unexpected ISSN value for <value-of select="$journal-title"/> (<value-of select="."/>)</assert>
    </rule>
  </pattern>
  
  <pattern>
    <rule context="journal-meta/isbn" role="error"><!--Other expected and unexpected elements-->
      <report id="jmeta6" test=".">Do not use the ISBN element in journal metadata.</report>
    </rule>
  </pattern>
  
  <pattern>
    <rule context="journal-meta" role="error"><!--Other expected and unexpected elements-->
      <assert id="jmeta7a" test="publisher">Journal metadata should include a "publisher" element.</assert>
    </rule>
  </pattern>
  
  <pattern>
    <rule context="publisher" role="error">
      <report id="jmeta7b" test="publisher-loc">Do not use "publisher-loc" element in publisher information. This is not necessary for NPG articles.</report>
    </rule>
  </pattern>
  
  <pattern>
    <rule context="journal-title-group | journal-title | publisher">
      <report id="jmeta8a" test="@content-type">Unnecessary use of "content-type" attribute on "<name/>" element.</report>
    </rule>
  </pattern>
  
  <pattern><!--Does the publisher-name match the copyright-holder?-->
    <let name="holder" value="//permissions/copyright-holder"></let>
    <rule context="publisher/publisher-name" role="error">
      <assert id="jmeta9" test=". = $holder or not($holder) or not($holder=$allowed-values/journal[@title=$journal-title]/copyright-holder)">The publisher-name (<value-of select="."/>) should match the copyright-holder (<value-of select="$holder"/>).</assert>
    </rule>
  </pattern>

  <!-- ====================================================== Article metadata ================================================== -->

  <pattern>
    <rule context="article-meta" role="error"><!--Two article ids, one doi and one publisher-id-->
      <assert id="ameta1a" test="article-id[@pub-id-type='doi'] and article-id[@pub-id-type='publisher-id']">Article metadata should contain at least two "article-id" elements, one with attribute pub-id-type="doi" and one with attribute pub-id-type="publisher-id".</assert>
      </rule>
    </pattern>
  <pattern>
    <rule context="article-meta" role="error">
      <assert id="ameta1b" test="article-categories">Article metadata should include an "article-categories" element.</assert>
    </rule>
  </pattern>

  <!--Article categories-->
  
  <pattern><!--Does article categories contain "category" information and does it match article/@article-type?-->
    <rule context="article-categories" role="error">
      <assert id="ameta2a" test="subj-group[@subj-group-type='category']">Article categories should contain a "subj-group" element with attribute "subj-group-type='category'". The value of the child "subject" element should be the same as the main article-type attribute: <value-of select="$article-type"/>.</assert>
    </rule>
    </pattern>
  <pattern>
    <rule context="article-categories" role="error">
      <assert id="ameta2b" test="subj-group[@subj-group-type='category']/subject = $article-type or not($article-type) or not(subj-group[@subj-group-type='category']/subject)">Subject catgory (<value-of select="subj-group[@subj-group-type='category']/subject"/>) does not match root article type (<value-of select="$article-type"/>)</assert>
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
  
  <!--If @subj-group-type="career" or "discipline" or "sector" - article/@article-type="naturejobs"; only one of each type
  If @subj-group-type="region" - article/@article-type="naturejobs"; should contain subject/@content-type="continent"; may also contain subject/@content-type="country", "state" "area"
  allowed values - "continent" (africa, all, asia, aus, eur, na, sa); country, state (two letter state names) and area -->
  
  <!--Article title (title-group)-->
  <pattern>
    <rule context="fn-group | trans-title-group" role="error"><!--No unexpected children of article title-group used-->
      <report id="arttitle1" test="parent::title-group">Unexpected use of "<name/>" in article "title-group". "title-group" should only contain "article-title", "subtitle", "alt-title".</report>
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
  
  <!--Contrib group-->
  
  <!-- **** Publication date **** -->
  
  <pattern><!--Rules around expected attribute values of pub-date, and only one of each type-->
    <rule context="pub-date" role="error">
      <assert id="pubdate0a" test="@pub-type">"pub-date" element should have attribute "pub-type" declared. Allowed values are: issue-date, aop, collection, epub, epreprint and embargo. Please check with NPG Editorial Production.</assert></rule>
    </pattern>
  <pattern>
    <rule context="pub-date[@pub-type]" role="error">
      <let name="pubType" value="@pub-type"></let>
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
      <report id="pubdate1d" test=".">Do not use "season" (<value-of select="."/>) in dates of NPG articles. "Day" and "month" are the only other elements which should be used.</report>
    </rule>
  </pattern> 
 
  <pattern><!--Concatenate year/month/day and check valid if those elements have already passed basic validation checks. This rule adapted from http://regexlib.com, author Michel Chouinard -->
    <rule context="pub-date[matches(year, '^(19|20)[0-9]{2}$') and matches(month, '^((0[1-9])|(1[0-2]))$') and matches(day, '^(0[1-9]|[12][0-9]|3[01])$')]" role="error">
      <assert id="pubdate2" test="matches(concat(year,month,day), '^(((19|20)(([0][48])|([2468][048])|([13579][26]))|2000)(([0][13578]|[1][02])([012][0-9]|[3][01])|([0][469]|11)([012][0-9]|30)|02([012][0-9]))|((19|20)(([02468][1235679])|([13579][01345789]))|1900)(([0][13578]|[1][02])([012][0-9]|[3][01])|([0][469]|11)([012][0-9]|30)|02([012][0-8])))$')">Invalid publication date - the day value (<value-of select="day"/>) does not exist for the month (<value-of select="month"/>) in the year (<value-of select="year"/>).</assert>
    </rule>
  </pattern>
  
  <pattern><!--Year/Day - invalid combination in pub-date-->
    <rule context="pub-date" role="error">
      <report id="pubdate3" test="year and day and not(month)">Missing month in pub-date. Currently only contains year and day.</report>
    </rule>
  </pattern>
  
  <pattern>
    <rule context="day[parent::pub-date] | month[parent::pub-date] | year[parent::pub-date]" role="error"><!--No content-type attribute on day, month or year-->
      <report id="pubdate4" test="@content-type">Do not use "content-type" attribute on "<name/>" within "pub-date" element.</report>
    </rule>
  </pattern>
  
  <!--Volume, issue, fpage, lpage, counts/page-count. Add tests for when we don't expect to have volume/issue values dependent on pub-type (aop etc) -->
  
  <pattern>
    <rule context="volume[parent::article-meta] | issue[parent::article-meta] | fpage[parent::article-meta] | lpage[parent::article-meta] | page-count[@count='0'][parent::article-meta]" role="error">
      <assert id="artinfo1a" test="normalize-space(.) or *">Empty "<name/>" element should not be used - please delete.</assert>
    </rule>
    </pattern>
  <pattern>
    <rule context="volume[parent::article-meta] | issue[parent::article-meta] | fpage[parent::article-meta] | lpage[parent::article-meta] | page-count[@count='0'][parent::article-meta]" role="error">
      <assert id="artinfo1b" test="not(@content-type)">Do not use "content-type" attribute on "<name/>" within article metadata.</assert>
    </rule>
  </pattern>
  
  <pattern>
    <rule context="volume[parent::article-meta] | issue[parent::article-meta] | fpage[parent::article-meta] | lpage[parent::article-meta] | page-count/@count" role="error">
      <assert id="artinfo2" test="not(normalize-space(.) or *) or matches(.,'^[0-9]+$')">Invalid value for "<name/>" (<value-of select="."/>) - this should only contain numerals.</assert>
    </rule>
  </pattern>
  
  <pattern>
    <rule context="fpage[normalize-space(.) or *][parent::article-meta]" role="error">
      <assert id="artinfo3a" test="following-sibling::lpage and following-sibling::counts/page-count">As "fpage" is used, we also expect "lpage" and "counts"/"page-count" elements to be used in article metadata.</assert>
    </rule>
  </pattern>
  <pattern>
    <rule context="counts[page-count]" role="error">
      <assert id="artinfo3b" test="preceding-sibling::fpage">As "page-count" is used, we also expect "fpage" and "lpage" elements to be used in article metadata. Please check if "page-count" should have been used.</assert>
    </rule>
  </pattern>
  
  <pattern>
    <let name="span" value="//article-meta/lpage[normalize-space(.) or *][matches(.,'^[0-9]+$')] - //article-meta/fpage[normalize-space(.) or *][matches(.,'^[0-9]+$')] + 1"/>
    <rule context="counts/page-count[not(@count='0')][matches(@count,'^[0-9]+$')]">
      <assert id="artinfo4" test="@count = $span or not($span)">Incorrect value given for "page-count" attribute "count". Expected value is: <value-of select="$span"/>.</assert>
    </rule>
  </pattern>
  
  <pattern>
    <rule context="fig-count | table-count | equation-count | ref-count | word-count" role="error">
      <report id="artinfo5" test="parent::counts">Unexpected use of "<name/>" element. Please delete - not necessary in NPG articles.</report>
    </rule>
  </pattern>
  
  <!--History - same rules for dates as for pub-dates-->

  <pattern><!--Rules around expected attribute values of date-->
    <rule context="history/date" role="error">
      <assert id="histdate0a" test="@date-type">"date" element should have attribute "date-type" declared. Allowed values are: created, received, rev-recd (revision received), accepted and misc. Please check with NPG Editorial Production.</assert>
    </rule>
  </pattern>
  <pattern>
    <rule context="history/date[@date-type]" role="error">
      <let name="dateType" value="@date-type" />
      <assert id="histdate0b" test="$allowed-values/date-types/date-type[.=$dateType]">Unexpected value for "date-type" attribute on "date" element (<value-of select="$dateType"/>). Allowed values are: created, received, rev-recd (revision received), accepted and misc. Please check with NPG Editorial Production.</assert>
    </rule>
  </pattern>
  
  <pattern><!--... and only one of each type-->
    <rule context="history/date" role="error">
      <report id="histdate0c" test="@date-type=./preceding-sibling::date/@date-type">There should only be one instance of the "date" element with "date-type" attribute value of "<value-of select="@date-type"/>". Please check with NPG Editorial Production.</report>
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
      <report id="histdate1d" test=".">Do not use "season" (<value-of select="."/>) in dates of NPG articles. "Day" and "month" are the only other elements which should be used.</report>
    </rule>
  </pattern>
  
  <pattern><!--Concatenate year/month/day and check valid if those elements have already passed basic validation checks. This rule adapted from http://regexlib.com, author Michel Chouinard -->
    <rule context="history/date[matches(year, '^(19|20)[0-9]{2}$') and matches(month, '^((0[1-9])|(1[0-2]))$') and matches(day, '^(0[1-9]|[12][0-9]|3[01])$')]" role="error">
      <assert id="histdate2" test="matches(concat(year,month,day), '^(((19|20)(([0][48])|([2468][048])|([13579][26]))|2000)(([0][13578]|[1][02])([012][0-9]|[3][01])|([0][469]|11)([012][0-9]|30)|02([012][0-9]))|((19|20)(([02468][1235679])|([13579][01345789]))|1900)(([0][13578]|[1][02])([012][0-9]|[3][01])|([0][469]|11)([012][0-9]|30)|02([012][0-8])))$')">Invalid history date - the day value (<value-of select="day"/>) does not exist for the month (<value-of select="month"/>) in the year (<value-of select="year"/>).</assert>
    </rule>
  </pattern>
  
  <pattern><!--Year/Day - invalid combination in date-->
    <rule context="history/date" role="error">
      <report id="histdate3" test="year and day and not(month)">Missing month in "date" element. Currently only contains year and day.</report>
    </rule>
  </pattern>
  
  <pattern><!--No content-type attribute on day, month or year-->
    <rule context="day[ancestor::history] | month[ancestor::history] | year[ancestor::history]" role="error">
      <report id="histdate4" test="@content-type">Do not use "content-type" attribute on <name/> within "date" element.</report>
    </rule>
  </pattern>

  <!--Permissions, including copyright info-->
  
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

  
  <pattern><!--Is the copyright holder correct for the journal?-->
    <rule context="copyright-holder" role="error">
      <assert id="copy3" test=". = $allowed-values/journal[@title=$journal-title]/copyright-holder or  not($allowed-values/journal[@title=$journal-title])">The copyright-holder for <value-of select="$journal-title"/> should be: <value-of select="$allowed-values/journal[@title=$journal-title]/copyright-holder"/></assert>
    </rule>
  </pattern>

  <!--Related article - type and link as expected?-->
  
  <!--Abstract-->
  
  <!--Keywords-->
  
</schema>
