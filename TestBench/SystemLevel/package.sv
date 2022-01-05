//Project : Design and Verification of                 //
//			8237A-5 DMA Controll                       //																				    
//													   //															
// Subject:	ECE 571									   //										                        																															    
// Guide  : Mark Faust   							   //													            
// Date   : March 12, 2021							   //																		
// Team	  :	Shivanand Reddy Gujjula,                   //
//			Sri Harsha Doppalapudi,                    //
//			Jayashree Bodavula,	                       //
//			Sameer Shaik							   //																										
// Portland State University                           //  
//                                                     //                                                     //
/////////////////////////////////////////////////////////

package DMApackage;

	localparam AddressBusWidth = 8;
	localparam DataBusWidth    = 8;
	localparam AddrWordCountWidth = 16;
	localparam NumChannels  = 4;
	
	typedef struct packed {
							bit [1:0]	Tmode;
							bit 		AddrIncDec;
							bit 		AutoInit;
							bit [1:0]	rwv;
						  }ModeRegister;
				  
	typedef struct packed {
							bit DACKsense;
							bit DREQsense;
							bit LateExtWrite;
							bit FRpriority;
							bit CmprdTime;
							bit ContrDis;
							bit CH0AddHoldEn;
							bit MemToMem;
						  } CommandRegister;
				  
	typedef struct packed {
							bit set;
							bit [1:0] ChNum;
						  } RequestRegister;
endpackage
/*
//------------------------------------------End of package Module----------------------------------
*/