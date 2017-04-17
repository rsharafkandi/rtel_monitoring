package com.tooka.rightel.MNPMonitoring;


import org.apache.commons.cli.CommandLineParser;
import org.apache.commons.cli.DefaultParser;
import org.apache.commons.cli.Option;
import org.apache.commons.cli.Options;
import org.apache.commons.cli.CommandLine;
import org.apache.commons.cli.ParseException;

public class ApachePOIExcelParserRunnable {

    public static void main(String[] args) {
    	
        String xlsxFileName = "";
        String xlsxSheetName = "";
        String xlsxCommandName = "rowcount";
           
    	// create the command line parser
    	CommandLineParser parser = new DefaultParser();

    	// create the Options
    	Options options = new Options();
    	Option optionFilename = Option.builder("f")
    			.longOpt( "filename" )
    			.desc( "xlsx filename" )
    			.hasArg()
    			.argName( "FILENAME" )
    			.build();
    	Option optionSheetName = Option.builder("s")
    			.longOpt( "sheetname" )
    			.desc( "xls sheetname" )
    			.hasArg()
    			.argName( "SHEETNAME" )
    			.build();
    	Option optionCommand = Option.builder("c")
    			.longOpt( "command" )
    			.desc( "Command" )
    			.hasArg()
    			.argName( "COMMAND")
    			.build();
    	
    	options.addOption("h", "--help", false, "display program usage.");
    	options.addOption( optionFilename );
    	options.addOption( optionSheetName );
    	options.addOption( optionCommand );
    	
    	try {
    	    // parse the command line arguments
    	    CommandLine line = parser.parse( options, args );

    	    if( line.hasOption( "h" ) ){
    	    	System.out.println("This piece of program is developed using org.apache POI Api to do basic parsing of Microsoft XLSX documents");
    	    	System.out.println();
    	    	System.out.println("Usage: java -cp JAR_FILE com.tooka.rightel.MNPMonitoring.ApachePOIExcelParser -h -f filename -s sheetname -c command");;
    	    	System.out.println("\t-h\t\tShow this usage message");
    	    	System.out.println("\t-f filename\tXLSX filename to process");
    	    	System.out.println("\t-s sheetname\tExcel sheetname. If omited first sheet is processed by default");
    	    	System.out.println("\t-c command\tWhat to do:");
    	    	System.out.println("\t\t\t\trowcount");
    	    	System.out.println("\t\t\t\trowdump");
    	    	System.out.println("\t\t\t\tsheetcount");
    	    	System.out.println("\t\t\t\tsheetlist");
    	    	return;
    	    }
    	    if( line.hasOption( "filename" ) ) {
    	        xlsxFileName = line.getOptionValue( "filename" );
    	    }
    	    if ( line.hasOption( "sheetname" )) {
    	    	xlsxSheetName = line.getOptionValue( "sheetname" );
    	    }
    	    if ( line.hasOption( "command" )) {
    	    	xlsxCommandName = line.getOptionValue( "command" );
    	    }
    	}
    	catch( ParseException exp ) {
    	    System.out.println( "Unexpected exception:" + exp.getMessage() );
    	}
    	
        ApachePOIExcelParser excelParser = new ApachePOIExcelParser( xlsxFileName );
        
        if( xlsxSheetName == "" )
        	xlsxSheetName = excelParser.getSheetName(0);
        
        switch(xlsxCommandName.toLowerCase() ){
        case "rowcount":
        	System.out.println( excelParser.getRowCount(xlsxSheetName) );
        	break;
        case "rowdump":
        	excelParser.rowDump(xlsxSheetName);
            break;
        case "sheetcount":
        	System.out.println(excelParser.getSheetCount());
        	break;
        case "sheetlist":
        	excelParser.showSheetList();
        	break;
        default:
        	System.out.println("ERROR! Invalid command: " + xlsxCommandName);
        	break;
        }

    }
}