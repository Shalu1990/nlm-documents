import java.io.InputStream;
import java.util.HashMap;
import java.util.Stack;

import org.xml.sax.Attributes;
import org.xml.sax.ContentHandler;
import org.xml.sax.InputSource;
import org.xml.sax.Locator;
import org.xml.sax.SAXException;
import org.xml.sax.XMLReader;
import org.xml.sax.ext.LexicalHandler;
import org.xml.sax.helpers.XMLReaderFactory;

public class Documap implements ContentHandler, LexicalHandler
{
    TreeContext tc = new TreeContext();
    Locator loc;


    @SuppressWarnings("serial")
    class TreeContext extends Stack< HashMap< String, Integer >>
    {
        boolean justClosed;
        Stack< String > parents = new Stack< String >();

        public void onStartElement( String uri, String localName )
        {
            String pseudo = localName;

            if( justClosed == false || size() == 0 )
            {
                // going deeper ...
                HashMap< String, Integer > newContext = new HashMap< String, Integer >();
                newContext.put( pseudo, 1 );
                push( newContext );
            }
            else
            {
                // there are preceding sibling elements ...
                HashMap< String, Integer > currContext = peek();
                Integer preceding = currContext.get( pseudo );
                if( preceding != null )
                {
                    int newCount = preceding.intValue() + 1;
                    currContext.remove( pseudo );
                    preceding = newCount;
                    currContext.put( pseudo, newCount );
                }
                else
                {
                    currContext.put( pseudo, 1 );
                }
            }

            parents.push( pseudo );
            this.justClosed = false;
        }


        @Override
        public synchronized boolean equals( Object o )
        {
            return super.equals( o ); // for clarity
        }


        @Override
        public synchronized int hashCode()
        {
            return super.hashCode(); // for clarity
        }


        public void onEndElement()
        {
            if( justClosed == true )
            {
                pop();
            }
            this.justClosed = true;
            parents.pop();
        }


        public String currentContext()
        {
            StringBuffer sb = new StringBuffer();
            for( int i = 0; i < size(); i++ )
            {
                if( i == 0 )
                {
                    sb.append( "/" + parents.get( 0 ) + "[1]" );
                }
                else
                {
                    String pseudo = parents.get( i );
                    sb.append( pseudo );
                    HashMap< String, Integer > context = get( i );
                    Integer n = context.get( pseudo );
                    sb.append( "[" + ( n == null ? "1" : n ) + "]" );
                }
                if( i < size() - 1 )
                {
                    sb.append( "/" );
                }

            }
            return sb.toString();

        }

    } // class


    public void comment( char[] arg0, int arg1, int arg2 ) throws SAXException
    {
    // TODO Auto-generated method stub

    }


    public void endCDATA() throws SAXException
    {
    // TODO Auto-generated method stub

    }


    public void endDTD() throws SAXException
    {
    // TODO Auto-generated method stub

    }


    public void endEntity( String arg0 ) throws SAXException
    {
    // TODO Auto-generated method stub

    }


    public void startCDATA() throws SAXException
    {
    // TODO Auto-generated method stub

    }


    public void startDTD( String arg0, String arg1, String arg2 ) throws SAXException
    {
    // TODO Auto-generated method stub

    }


    public void startEntity( String arg0 ) throws SAXException
    {
    // TODO Auto-generated method stub

    }


    public void characters( char[] arg0, int arg1, int arg2 ) throws SAXException
    {
    // TODO Auto-generated method stub

    }


    public void endDocument() throws SAXException
    {
    // TODO Auto-generated method stub

    }


    public void endElement( String arg0, String arg1, String arg2 ) throws SAXException
    {
        tc.onEndElement();

    }


    public void endPrefixMapping( String arg0 ) throws SAXException
    {
    // TODO Auto-generated method stub

    }


    public void ignorableWhitespace( char[] arg0, int arg1, int arg2 ) throws SAXException
    {
    // TODO Auto-generated method stub

    }


    public void processingInstruction( String arg0, String arg1 ) throws SAXException
    {
    // TODO Auto-generated method stub

    }


    public void setDocumentLocator( Locator arg0 )
    {
        this.loc = arg0;
    }


    public void skippedEntity( String arg0 ) throws SAXException
    {
    // TODO Auto-generated method stub

    }


    public void startDocument() throws SAXException
    {
    // TODO Auto-generated method stub

    }


    public void startElement( String uri, String localName, String qName, Attributes atts )
            throws SAXException
    {
        tc.onStartElement( uri, localName );
        System.out.println( "<place xpath='" + this.tc.currentContext() + "' line='"
                + loc.getLineNumber() + "' column='" + loc.getColumnNumber() + "'/>" );

    }


    public void startPrefixMapping( String arg0, String arg1 ) throws SAXException
    {
    // TODO Auto-generated method stub

    }


    /**
     * @param args
     */
    public static void main( String[] args )
    {
        String sysid = args[ 0 ];
        Documap h = new Documap();

        try
        {

            XMLReader parser = XMLReaderFactory.createXMLReader();
            parser.setContentHandler( h );
            System.out.println( "<?xml version='1.0'?><documap>" );
            parser.parse( sysid );
            System.out.println( "</documap>" );
        }
        catch( Exception e )
        {
            // TODO Auto-generated catch block
            System.err.println( "error" );
            e.printStackTrace();
        }

    }

}
