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

module DatapathAssertions (	interface 				Extr,Intr,
							input  	[3:0][15:0] 	CURRENT_ADDRESS,
							input	[3:0][15:0] 	CURRENT_WORDCOUNT,
							input   [3:0][15:0] 	BASE_ADDRESS,
							input	[3:0][15:0] 	BASE_WORDCOUNT,
							input		 [15:0]		TEMPORARY_ADDRESS,
							input 		 [15:0] 	TEMPORARY_WORDCOUNT,
							input	     [ 7:0]		TEMPORARY,
							input        [ 7:0] 	COMMAND,
							input		 [ 3:0]		REQUEST,
							input 	[3:0][ 5:0]		MODE,
							input		 [ 7:0] 	STATUS,
							input 		 [ 3:0] 	MASK,
							input					MasterClear,
							input					Bytelow,
							input					ClearBytePointer,
							input 		 [ 1:0]		ChannelNo,
							input					enAddrReg,
							input 					enWordCountReg,
							input					enStatusReg,
							input					enTempReg,
							input 					ldAddrReg,
							input 					ldWordCountReg,
							input 					ldCmdReg,
							input					ldMaskReg,
							input 					ldModeReg
						  );
						  
//-----------------------------------------------------------------------------------------------------------------------------------------------------------------
//													Assertions for Idle Cycle (Program Mode) DMA Acting as slave
//-----------------------------------------------------------------------------------------------------------------------------------------------------------------

	//
	//Check for Temporary Register on Reset and Master Clear
	//
	
	property TempRegOnReset;
		@(posedge Extr.CLOCK)
		(Extr.RESET | MasterClear) |=> (TEMPORARY == '0);
	endproperty
	
	TempRegOnResetA: assert property (TempRegOnReset);
	
	//
	//Check for Mask Register on Reset and Master Clear
	//
	
	property MaskRegOnReset;
		@(posedge Extr.CLOCK)
		(Extr.RESET | MasterClear) |=> (MASK == '1);
	endproperty
	
	MaskRegOnResetA: assert property (MaskRegOnReset);
	
	//
	//Check for Request Register on Reset and Master Clear
	//
	
	property RequestReqOnReset;
		@(posedge Extr.CLOCK)
		(Extr.RESET | MasterClear) |=> (REQUEST == '0);
	endproperty
	
	RequestRegOnResetA: assert property (RequestReqOnReset);
	
	//
	//Check for Status Register on Reset and Master Clear
	//
	
	property StatusRegOnReset;
		@(posedge Extr.CLOCK)
		(Extr.RESET | MasterClear) |=> (STATUS == '0);
	endproperty
	
	StatusRegOnResetA: assert property (StatusRegOnReset);
	
	//
	//Check for Temporary Address Register on Reset and Master Clear
	//
	
	property TempAddressRegOnReset;
		@(posedge Extr.CLOCK)
		(Extr.RESET | MasterClear) |=> (TEMPORARY_ADDRESS == '0);
	endproperty
	
	TempAddressRegOnResetA: assert property (TempAddressRegOnReset);
	
	//
	//Check for Temporary Wordcount Register on Reset and Master Clear
	//
	
	property TempWordCountRegOnReset;
		@(posedge Extr.CLOCK)
		(Extr.RESET | MasterClear) |=> (TEMPORARY_WORDCOUNT == '0);
	endproperty
	
	TempWordCountRegOnResetA: assert property (TempWordCountRegOnReset);
	
	//
	//Check for Current Address Register on Reset and Master Clear
	//
	property CurrentAddressRegOnReset;
		@(posedge Extr.CLOCK)
		(Extr.RESET | MasterClear) |=> (CURRENT_ADDRESS === BASE_ADDRESS);
	endproperty
	
	CurrentAddressRegOnResetA: assert property (CurrentAddressRegOnReset);
	
	//
	//Check for Current Wordcount Register on Reset and Master Clear
	//
	
	property CurrentWordCountRegOnReset;
		@(posedge Extr.CLOCK)
		(Extr.RESET | MasterClear) |=> (CURRENT_WORDCOUNT === BASE_WORDCOUNT);
	endproperty
	
	CurrentWordCountRegOnResetA: assert property (CurrentWordCountRegOnReset);
	
	//
	//Check for Read and write signals low at same time
	//

	property ReadWriteCheck;
		@(posedge Extr.CLOCK)
		disable iff (Extr.RESET | MasterClear)
		!Extr.CS_N |-> !(!Extr.IOR_N & !Extr.IOW_N);
	endproperty
	
	ReadWriteCheckA: assert property (ReadWriteCheck);
	
	//
	//Address Valid on read and write operations in program mode
	//
	
	property AddresValidOnReadWriteInProgramMode;
		@(posedge Extr.CLOCK)
		disable iff (Extr.RESET | MasterClear)
		!Extr.CS_N |-> (!Extr.IOW_N | !Extr.IOR_N) |-> !$isunknown(Extr.ADDRESS[3:0]);
	endproperty
	
	AddresValidOnReadWriteInProgramModeA: assert property (AddresValidOnReadWriteInProgramMode);
	
	//
	//Data Valid on write operations in program mode
	//
	
	property DataValidOnWriteInProgramMode;
		@(posedge Extr.CLOCK)
		disable iff (Extr.RESET | MasterClear)
		!Extr.CS_N |-> !Extr.IOW_N |-> !$isunknown(Extr.DATABUS);
	endproperty
	
	DataValidOnWriteInProgramModeA: assert property (DataValidOnWriteInProgramMode);
	
	//
	//DataValid on Read operation in program mode
	//
	
	property DataValidOnReadInProgramMode;
		@(posedge Extr.CLOCK)
		disable iff (Extr.RESET | MasterClear)
		!Extr.CS_N |-> !Extr.IOR_N |=> !$isunknown(Extr.DATABUS);
	endproperty
	
	DataValidOnReadInProgramModeA: assert property (DataValidOnReadInProgramMode);
	
	//
	//Set Bytelow to zero on clearbyte pointer
	//
	
	property BytelowSet;
		@(posedge Extr.CLOCK)
		!Extr.CS_N |-> (ClearBytePointer | MasterClear | Extr.RESET) |=> !Bytelow;
	endproperty
	
	BytelowSetA: assert property (BytelowSet);
	
	//
	//Check for byte pointer toggle for read and write of address and wordcount register
	//
	
	property BytelowCheck;
		@(posedge Extr.CLOCK)
		disable iff (ClearBytePointer | MasterClear | Extr.RESET)
		!Extr.CS_N |-> !Bytelow |=> Bytelow;
	endproperty
	
	BytelowCheckA: assert property (BytelowCheck);
	
	//
	//read check for Address registers (bytelow)
	//
	
	property ReadToCurrentAddressRegByteLow;
		@(posedge Extr.CLOCK)
		disable iff ( MasterClear | Extr.RESET)
		!Extr.CS_N & enAddrReg & Bytelow |-> (Extr.DATABUS == CURRENT_ADDRESS[ChannelNo][7:0]);
	endproperty 
	
	ReadToCurrentAddressRegByteLowA: assert property (ReadToCurrentAddressRegByteLow);
	
	//
	//read check for address registers (bytehigh)
	//
	
	property ReadToCurrentAddressRegByteHigh;
		@(posedge Extr.CLOCK)
		disable iff (MasterClear | Extr.RESET)
		!Extr.CS_N & enAddrReg & !Bytelow |-> (Extr.DATABUS == CURRENT_ADDRESS[ChannelNo][15:8]);
	endproperty
	
	ReadToCurrentAddressRegByteHighA: assert property (ReadToCurrentAddressRegByteHigh);
	
	//
	//Read check for wordcount registers (byte low)
	//
	
	property ReadToCurrentWordCountRegByteLow;
		@(posedge Extr.CLOCK)
		disable iff (MasterClear |Extr.RESET)
		!Extr.CS_N & enWordCountReg & Bytelow |-> (Extr.DATABUS == CURRENT_WORDCOUNT[ChannelNo][7:0]);
	endproperty
	
	ReadToCurrentWordCountRegByteLowA: assert property (ReadToCurrentWordCountRegByteLow);
	
	// 
	//Read check for wordcount registers(byte high)
	//
	
	property ReadToCurrentWordCountRegByteHigh;
		@(posedge Extr.CLOCK)
		disable iff (MasterClear | Extr.RESET)
		!Extr.CS_N & enWordCountReg & !Bytelow |-> (Extr.DATABUS == CURRENT_WORDCOUNT[ChannelNo][15:8]);
	endproperty
	
	ReadToCurrentWordCountRegByteHighA: assert property (ReadToCurrentWordCountRegByteHigh);
	
	//
	//Read to status register
	//
	
	property ReadToStatusReg;
		@(posedge Extr.CLOCK)
		disable iff (MasterClear | Extr.RESET)
		!Extr.CS_N & enStatusReg |-> (Extr.DATABUS == STATUS);
	endproperty
	
	ReadToStatusRegA: assert property (ReadToStatusReg);
	
	//
	//Read Temporary Register
	//
	
	property ReadToTempReg;
		@(posedge Extr.CLOCK)
		disable iff (MasterClear | Extr.RESET)
		!Extr.CS_N & enTempReg |-> (Extr.DATABUS === TEMPORARY);
	endproperty
	
	ReadToTempRegA: assert property (ReadToTempReg);
	
	//
	//Write to Current Address register 
	//
	
	property WriteToCurrentAddrReg;
		@(posedge Extr.CLOCK)
		disable iff (MasterClear | Extr.RESET | Extr.CS_N)
		ClearBytePointer ##1 ldAddrReg |=> ((CURRENT_ADDRESS[ChannelNo][15:8] == $past(Extr.DATABUS)) |=> (CURRENT_ADDRESS[$past(ChannelNo)][7:0] == $past(Extr.DATABUS)) );
	endproperty
	
	WriteToCurrentAddrRegA: assert property (WriteToCurrentAddrReg);
	
	//
	//write to Base Address register
	//
	
	property WriteToBaseAddrReg;
		@(posedge Extr.CLOCK)
		disable iff (MasterClear | Extr.RESET | Extr.CS_N)
		ClearBytePointer ##1 ldAddrReg |=> ((BASE_ADDRESS[ChannelNo][15:8] == $past(Extr.DATABUS)) |=> (BASE_ADDRESS[$past(ChannelNo)][7:0] == $past(Extr.DATABUS)) );
	endproperty
	
	WriteToBaseAddrRegA: assert property (WriteToBaseAddrReg);
	
	//
	//Write to Current wordcount registers
	//
	
	property WriteToCurrentWordCountReg;
		@(posedge Extr.CLOCK)
		disable iff (MasterClear | Extr.RESET | Extr.CS_N)
		ClearBytePointer ##1 ldWordCountReg |=> ((CURRENT_WORDCOUNT[ChannelNo][15:8] == $past(Extr.DATABUS)) |=> (CURRENT_WORDCOUNT[$past(ChannelNo)][7:0] == $past(Extr.DATABUS)) );
	endproperty
	
	WriteToCurrentWordCountRegA: assert property (WriteToCurrentWordCountReg);
	
	//
	//Write to Base wordcount registers
	//
		
	property WriteToBaseWordCountReg;
		@(posedge Extr.CLOCK)
		disable iff (MasterClear | Extr.RESET | Extr.CS_N)
		ClearBytePointer ##1 ldWordCountReg |=> ((BASE_WORDCOUNT[ChannelNo][15:8] == $past(Extr.DATABUS)) |=> (BASE_WORDCOUNT[$past(ChannelNo)][7:0] == $past(Extr.DATABUS)) );
	endproperty
	
	WriteToBaseWordCountRegA: assert property (WriteToBaseWordCountReg);
	
	//
	//Write to command regiater
	//
		
	property WriteToCmdReg;
		@(posedge Extr.CLOCK)
		disable iff (MasterClear | Extr.RESET | Extr.CS_N)
		ldCmdReg |=> (COMMAND == $past(Extr.DATABUS));
	endproperty
	
	WriteToCmdRegA: assert property (WriteToCmdReg);
	
	//
	//Write to mask registers
	//
	
	property WriteToMaskReg;
		@(posedge Extr.CLOCK)
		disable iff (MasterClear | Extr.RESET | Extr.CS_N)
		ldMaskReg |=> (MASK == $past(Extr.DATABUS[3:0]));
	endproperty
	
	WriteToMaskRegA: assert property (WriteToMaskReg);
	
	//
	//Write to mode registers
	//
	
	property WriteToModeReg;
		@(posedge Extr.CLOCK)
		disable iff (MasterClear | Extr.RESET | Extr.CS_N)
		ldModeReg |=> (MODE[$past(Extr.DATABUS[1:0])] == $past(Extr.DATABUS[7:2]));
	endproperty
	
	WriteToModeRegA: assert property (WriteToModeReg);

//--------------------------------------------------------------------------------------------------------------------------------------------------------------------------
//													Assertions for Active cycle (Transfer Mode) DMA acting as Master
//--------------------------------------------------------------------------------------------------------------------------------------------------------------------------

//
//Address bus has valid address during transfer mode
//
	property AddrValidInTransferMode;
		@(posedge Extr.CLOCK)
		disable iff (!Extr.CS_N)
		Extr.AEN |-> !$isunknown(Extr.ADDRESS);
	endproperty
	
	AddrValidInTransferModeA: assert property (AddrValidInTransferMode);
	
//
//Data bus has valid address during transfer mode when ADSTB is high
//
	property DataValidInTransferMode;
		@(posedge Extr.CLOCK)
		disable iff (!Extr.CS_N)
		Extr.ADSTB |-> !$isunknown(Extr.DATABUS)
	endproperty
	
	DataValidInTransferModeA: assert property (DataValidInTransferMode);
	
//
//Base address register does not change during transfer mode
//
	property BaseAddrCheckInTransferMode;
		@(posedge Extr.CLOCK)
		disable iff (!Extr.CS_N)
		!$changed(BASE_ADDRESS);
	endproperty
	
	BaseAddrCheckInTransferModeA: assert property (BaseAddrCheckInTransferMode);
	
//
//Base wordcount does not change during transfer mode
//
	property BaseWordCountRegCheckInTransferMode;
		@(posedge Extr.CLOCK)
		disable iff (!Extr.CS_N)
		!$changed(BASE_WORDCOUNT);
	endproperty
	
	BaseWordCountRegCheckInTransferModeA: assert property (BaseWordCountRegCheckInTransferMode);
	
//
//Current Address Reg contains address on data bus 
//
	property StatusRegOnTransferComplete;
		@(posedge Extr.CLOCK)
		Extr.CS_N |-> Intr.TC |=> STATUS[$past(Intr.ActiveChannel)];
	endproperty
	
	StatusRegOnTransferCompleteA: assert property (StatusRegOnTransferComplete);
	
	property StatusRegOnDMARequest;
		@(posedge Extr.CLOCK)
		disable iff (!Extr.CS_N)
		$changed(Intr.DMA_Req) |=> (STATUS[7:4] == Intr.DMA_Req);
	endproperty
	
	StatusRegOnDMARequestA: assert property (StatusRegOnDMARequest);
	
	property CurrentAddrRegCheckInTransferMode;
		@(posedge Extr.CLOCK)
		disable iff (!Extr.CS_N)
		Extr.CS_N |-> Extr.HLDA |-> (CURRENT_ADDRESS[Intr.ActiveChannel][7:0] === $past(Extr.ADDRESS));
	endproperty
	
	CurrentAddrRegCheckInTransferModeA: assert property (CurrentAddrRegCheckInTransferMode);
	
	property CurrentWordCountRegCheckInTransferMode;
		@(posedge Extr.CLOCK)
		disable iff (!Extr.CS_N | (CURRENT_WORDCOUNT[Intr.ActiveChannel] == '1) | Intr.Carry)
		CURRENT_WORDCOUNT[Intr.ActiveChannel] == $past(CURRENT_WORDCOUNT[Intr.ActiveChannel]) - 16'd1;
	endproperty
	
	CurrentWordCountRegCheckInTransferModeA: assert property (CurrentWordCountRegCheckInTransferMode);
	
		
endmodule
/*
//------------------------------------------End of Datapath Assertions-----------------------------
*/