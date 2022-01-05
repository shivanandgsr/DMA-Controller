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
//                                                     //                                                     
/////////////////////////////////////////////////////////

module TimingControlAssertions (interface 	Extr,Intr,
								input 		doRead,
								input 		doWrite,
								input 		EOPTrigger,
								input 		en_rw,
								input 		ldActChn,
								input [1:0]	ActCH,
								input 		State,NextState
								);
	
//
// Check for unknowns in read/write signals throughout transfer
//

property ValidReadWrite;
	@(posedge Extr.CLOCK)
	((Extr.CS_N) && (Extr.HLDA) && (Extr.EOP_N)) |-> !$isunknown(Extr.IOR_N, Extr.IOW_N) throughout Extr.HLDA(1:$);
endproperty

aValidReadWrite: assert property (ValidReadWrite);

//
// Check for Address bus valid throughout transfer
//

property ValidAddressBus;
	@(posedge Extr.CLOCK)
	((Extr.CS_N) && (Extr.HLDA) && (Extr.EOP_N)) |=> (Extr.ADDRESS) throughout Extr.HLDA (1:$);
endproperty

ValidAddressBus: assert property (ValidAddressBus);

//
//Check for EOP on transfer complete
//

property EOPUponTC;
	@(posedge Extr.CLOCK)
	((Extr.CS_N) && (Intr.TC)) |=> (~Extr.EOP_N);
endproperty

EOPUponTC: assert property (EOPUponTC);

//
// Checking Whether Address Strobe is high for only one cycle
//

property AddressStrobeEnable;
	@(posedge Extr.CLOCK)
	(Extr.CS_N) |-> (Extr.ADSTB) ##1 (~Extr.ADSTB);
endproperty

AddressStrobeEnable: assert property (AddressStrobeEnable);

//
// Checking Whether Read and Write enable at the same time
//

property ReadAndWrite;
	@(posedge Extr.CLOCK)
	(Extr.CS_N) |-> !((Extr.IOR_N == 0) && (Extr.IOW_N == 0));
endproperty

ReadAndWrite: assert property (ReadAndWrite);

//
// Checking whether Address Enable is high in Block Transfer mode till the end of transfer
//

property AddressEnableCheck;
	@(posedge Extr.CLOCK)
	((Extr.CS_N) && (Extr.HLDA) && (Extr.EOP_N)) |=> (Extr.AEN) throughout Extr.HLDA (1:$);
endproperty

AddressEnableCheck: assert property (AddressEnableCheck);
	
					
//
// Checking NextState For SI
//
					
property NextStateForSI;
	@(posedge Extr.CLOCK)
	((Extr.CS_N) && (|Intr.DMA_Req) && (State == SI)) |=> (NextState == S0);
endproperty

NextStateForSI: assert property (NextStateForSI);

//
// Checking NextState For S0
//

property NextStateForS0;
	@(posedge Extr.CLOCK)
	((Extr.CS_N) && (State == S0) && (Extr.EOP_N) && (Extr.HLDA) && (~Intr.MemToMem)) |=> (NextState == S1);
endproperty

NextStateForS0: assert property (NextStateForS0);

//
// Checking NextState For S1
//

property NextStateForS1;
	@(posedge Extr.CLOCK)
	((Extr.CS_N) && (State == S1) && (Extr.EOP_N)) |=> (NextState == S2);
endproperty

NextStateForS1: assert property (NextStateForS1);
	
//
// Checking NextState For S2 With Late Write
//	
	
property NextStateForS2_a;
	@(posedge Extr.CLOCK)
	((Extr.CS_N) && (State == S2) && (Extr.EOP_N) && (~Intr.ExtendedWrite)) |=> (NextState == S4);
endproperty

NextStateForS2_a: assert property (NextStateForS2_a);
//
// Checking NextState For S2 With Extended Write
//	
	
property NextStateForS2;
	@(posedge Extr.CLOCK)
	((Extr.CS_N) && (State == S2) && (Extr.EOP_N) && (Intr.ExtendedWrite)) |=> (NextState == S3);
endproperty

NextStateForS2: assert property (NextStateForS2);

//
// Checking NextState For S3
//
	
property NextStateForS3;
	@(posedge Extr.CLOCK)
	((Extr.CS_N) && (State == S3) && (Extr.EOP_N) && (~Extr.READY)) |=> (NextState == S4);
endproperty

NextStateForS3: assert property (NextStateForS3);
	
//
// Checking NextState For S4 In Block Transfer Mode With Carry
//	
	
property NextStateForS4;
	@(posedge Extr.CLOCK)
	((Extr.CS_N) && (State == S4) && (Extr.EOP_N) && (Intr.TransferMode) && (Intr.Carry)) |=> (NextState == S1);
endproperty

NextStateForS4: assert property (NextStateForS4);

//
// Checking NextState For S4 In Block Transfer Mode Without Carry
//	
	
property NextStateForS4_B;
	@(posedge Extr.CLOCK)
	((Extr.CS_N) && (State == S4) && (Extr.EOP_N) && (Intr.TransferMode) && (~Intr.Carry)) |=> (NextState == S2);
endproperty

NextStateForS4_B: assert property (NextStateForS4_B);

//
// Checking NextState For S4 In Single Transfer Mode
//	
	
property NextStateForS4_S;
	@(posedge Extr.CLOCK)
	((Extr.CS_N) && (State == S4) && (~Extr.EOP_N) && (!Intr.TransferMode)) |=> (NextState == SI);
endproperty

NextStateForS4_S: assert property (NextStateForS4_S);

//
// Checking NextState For SI when EOP occurs
//	

property NextStateForSI_EOP;
	@(posedge Extr.CLOCK)
	((Extr.CS_N) && (~Extr.EOP_N) && (State == SI)) |=> (NextState == SI);
endproperty

NextStateForSI_EOP: assert property (NextStateForSI_EOP);

//
// Checking NextState For S0 when EOP occurs
//	

property NextStateForS0_EOP;
	@(posedge Extr.CLOCK)
	((Extr.CS_N) && (~Extr.EOP_N) && (State == S0)) |=> (NextState == SI);
endproperty

NextStateForS0_EOP: assert property (NextStateForS0_EOP);

//
// Checking NextState For S1 when EOP occurs
//	

property NextStateForS1_EOP;
	@(posedge Extr.CLOCK)
	((Extr.CS_N) && (~Extr.EOP_N) && (State == S1)) |=> (NextState == SI);
endproperty

NextStateForS1_EOP: assert property (NextStateForS1_EOP);

//
// Checking NextState For S2 when EOP occurs
//	

property NextStateForS2_EOP;
	@(posedge Extr.CLOCK)
	((Extr.CS_N) && (~Extr.EOP_N) && (State == S2)) |=> (NextState == SI);
endproperty

NextStateForS2_EOP: assert property (NextStateForS2_EOP);

//
// Checking NextState For S3 when EOP occurs
//	

property NextStateForS3_EOP;
	@(posedge Extr.CLOCK)
	((Extr.CS_N) && (~Extr.EOP_N) && (State == S3)) |=> (NextState == SI);
endproperty

NextStateForS3_EOP: assert property (NextStateForS3_EOP);

//
// Checking NextState For S4 when EOP occurs
//	

property NextStateForS4_EOP;
	@(posedge Extr.CLOCK)
	((Extr.CS_N) && (~Extr.EOP_N) && (State == S4)) |=> (NextState == SI);
endproperty

NextStateForS4_EOP: assert property (NextStateForS4_EOP);

endmodule
/*
//------------------------------------------End of TimingControl Assertions------------------------