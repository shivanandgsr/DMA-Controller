
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

interface ExternalBus (input logic CLOCK , RESET );
		
	logic 		CS_N;					// CHIP SELECT Active LOW signal
	logic 		READY;					// READY
	logic 		HLDA;					// HOLD ACKNOWLEDGE
	logic 		HRQ;					// HOLD REQUEST
	logic 		AEN;					// ADDRESS ENABLE
	logic 		ADSTB;					// ADDRESS STROBE
	logic 		MEMR_N;					// MEMORY READ Active LOW signal
	logic 		MEMW_N;					// MEMORY WRITE Active LOW signal
	logic [3:0] DREQ;					// DMA Request
	logic [3:0]	DACK;					// DMA ACKNOWLEDGE
	tri   [7:0]	DATABUS;				// DATA BUS
	tri   [7:0] ADDRESS;				// ADDRESS
	tri 		IOR_N;					// I/O READ Active LOW signal
	tri			IOW_N;					// I/O WRITE Active LOW signal
	tri 		EOP_N;					// END OF PROCESS Active Low signal
	
	logic [7:0]	data;
	logic [7:0]	addr;
	logic		ior;
	logic 		iow;
	
	assign IOR_N = CS_N ? 'z : ior ;
	assign IOW_N = CS_N ? 'z : iow ;
	assign ADDRESS = CS_N ? 'z : addr ;
	assign DATABUS = CS_N ? 'z : ~iow ? data :'z ;
	
	
// ----------------------------------------------------port declarations for Timing and Control Module------------------------------------------------------
	modport TimingControl_External(input 
										CLOCK,
										RESET,
									  	CS_N,
									  	READY,
									 	HLDA,
									
									output 
										AEN,
										ADSTB,
										MEMR_N,
									 	MEMW_N,
										HRQ,
									
									inout 	
										EOP_N,
										IOR_N,
										IOW_N
								  );
		
// ---------------------------------------------------port declarations for priority(default and rotating) Module-----------------------------------------------
	modport Priority_External	(input 
									DREQ,
									HLDA,
									CS_N,
									
								output	
									DACK
								);

	modport Datapath_External	(input 	
									CLOCK,
									RESET,
								 	CS_N,
								inout 	
									IOR_N,
								  	IOW_N,
								 	EOP_N,
								 	ADDRESS,
								 	DATABUS
								);
								
	modport DMATop				(input 
									CS_N,
									READY,
									HLDA,
									DREQ,
								inout 
									DATABUS,
									IOR_N,
									IOW_N,
									EOP_N,
									ADDRESS,
								output 
									HRQ,
									DACK,
									AEN,
									ADSTB,
									MEMR_N,
									MEMW_N
								);								
									
endinterface
//
//=====================================================End of ExternalBus Module=================================================================================	
