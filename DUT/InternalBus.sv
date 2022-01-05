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

interface InternalBus ();

	wire  [1:0] ActiveChannel;					
	logic [3:0]	RequestReg;
	logic	   	MemToMem;
	logic		ReadMode;
	logic [3:0]	MaskedReg;
	logic [7:0] StatusReg;
	logic		TransferMode;
	logic		ExtendedWrite;
	logic		RotatingPriority;
	logic		DREQ_Sense;
	logic		DACK_Sense;
	logic 		TC;							
	logic 		ldAck;						
	logic 		Carry;						
	logic [3:0] DMA_Req;					
	logic 		AddrGen;					
	logic 		enAddrUp;					
	logic	    enAddrLo;					
	logic 		ldTempReg;					
	logic 		ldTempAddr;
	logic 		PriorityGen;
	


//---------------------------------------------------port declarations for Timing and Control Module------------------------------------------
	
	modport	TimingControl_Internal( input 	
										TC,
										Carry,					
										DMA_Req,									
										MemToMem,
										ReadMode,
										TransferMode,
										ExtendedWrite,	
									output
										ldAck,			
										AddrGen,		
										enAddrUp,		
										enAddrLo,		
										ldTempReg,
										ldTempAddr,
										ActiveChannel,
										PriorityGen
									);

//--------------------------------------------------port declarations for priority(default and rotating) Module----------------------------------
  									
	modport Priority_Internal	(	
									input 	
										ldAck,
										RotatingPriority,
										DREQ_Sense,
										DACK_Sense,
										RequestReg,
										MaskedReg,
										StatusReg,
									 	MemToMem,
										PriorityGen,
									output 
										DMA_Req,
										ActiveChannel
								);
								
	modport Datapath_Internal	(
									input 	
										enAddrLo,
							 			enAddrUp,
										AddrGen,
										ActiveChannel,
										ldTempReg,
										ldTempAddr,
										DMA_Req,
									output 		
										Carry,			
										TC,
										MemToMem,
										ExtendedWrite,
										ReadMode,
										TransferMode,			
										RotatingPriority,
										DREQ_Sense,				
										DACK_Sense,				
										RequestReg,
										StatusReg,
										MaskedReg									
								);
endinterface



//===================================================End of InternalBus Module=================================================================						
						