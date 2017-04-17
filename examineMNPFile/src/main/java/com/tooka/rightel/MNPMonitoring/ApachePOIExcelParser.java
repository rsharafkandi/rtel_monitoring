package com.tooka.rightel.MNPMonitoring;

import org.apache.poi.ss.usermodel.*;
import org.apache.poi.xssf.usermodel.XSSFWorkbook;

import java.io.FileInputStream;
import java.io.FileNotFoundException;
import java.io.IOException;
import java.util.Iterator;

public class ApachePOIExcelParser {

    private String xlsxFileName = "";
    private Workbook workbook = null;
    
    public ApachePOIExcelParser (String xlsxFilename){
    	this.xlsxFileName = xlsxFilename;
    	
        try {

            FileInputStream excelFile = new FileInputStream( xlsxFileName );
            workbook = new XSSFWorkbook(excelFile);

            
        } catch (FileNotFoundException e) {
            e.printStackTrace();
            return;
        } catch (IOException e) {
            e.printStackTrace();
            return;
        }    	
    }
    
    public void finalize() throws IOException{
        workbook.close();
    }
    
    /*
     * Return Excel Sheet's number of rows
     */
    public int getRowCount( String sheetName){
    	Sheet datatypeSheet = workbook.getSheet(sheetName);
    	int firstRow = datatypeSheet.getFirstRowNum();
    	int lastRow = datatypeSheet.getLastRowNum();
    	return lastRow - firstRow;
    }
    
    public int getRowCount( int sheetIndex ){
    	String sheetName = getSheetName( sheetIndex );
    	return getRowCount( sheetName );
    }
    
    public int getRowCount( ){
    	String sheetName = getSheetName( 0 );
    	return getRowCount( sheetName );
    }
    
    /*
     * Return Excel Sheetname
     */
    public String getSheetName( int sheetindex ){
    	Sheet datatypeSheet = workbook.getSheetAt(sheetindex);
    	return datatypeSheet.getSheetName();
    }
    
    /*
     * Dump all Sheet content on the screen
     */
    public void rowDump( String sheetName){
    	Sheet datatypeSheet = workbook.getSheet(sheetName);
        Iterator<Row> iterator = datatypeSheet.iterator();
        
        while (iterator.hasNext()) {
            Row nextRow = iterator.next();
            Iterator<Cell> cellIterator = nextRow.cellIterator();
             
            while (cellIterator.hasNext()) {
                Cell cell = cellIterator.next();
                 
                switch (cell.getCellType()) {
                    case Cell.CELL_TYPE_STRING:
                        System.out.print(cell.getStringCellValue());
                        break;
                    case Cell.CELL_TYPE_BOOLEAN:
                        System.out.print(cell.getBooleanCellValue());
                        break;
                    case Cell.CELL_TYPE_NUMERIC:
                        System.out.print(cell.getNumericCellValue());
                        break;
                }
                System.out.print(", ");
            }
            System.out.println();
        }
    }
    
    public void rowDump( int sheetIndex ){
    	String sheetName = getSheetName( sheetIndex );
    	rowDump( sheetName );  	
    }
    
    public void rowDump(){
    	String sheetName = getSheetName( 0 );
    	rowDump( sheetName );
    }
    
    /*
     * Return Excel Document's number of sheets
     */
    public int getSheetCount(){
    	return workbook.getNumberOfSheets();
    }
    
    /*
     * Show a line by line list of Document's sheets
     */
    public void showSheetList(){
    	for ( int i=0; i < workbook.getNumberOfSheets(); i++ )
    		System.out.println(workbook.getSheetName(i));  	
    }
    
}