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

//
// DMA 8237A Assertions module 
//
module AssertionsDMA(interface Extr);
	//
	/*-----------------------------------------------Master Mode Assertions-------------------------------------------------*/
	//
	property AssertMasterMode(property Master);
		@(posedge Extr.CLOCK) disable iff(Extr.RESET | (Extr.CS_N !== '1) ) Master;
	endproperty
	/*
	// AEN assertions
	*/
	property AEN_Property1;
		$rose(Extr.HLDA) |=> !$fell(Extr.HLDA) |-> Extr.AEN ;
	endproperty
	
	property AEN_Property2;
		Extr.EOP_N =='0 |-> Extr.AEN == '0;
	endproperty
	
	ERROR_AEN_Property1:assert property(AssertMasterMode(AEN_Property1));
	ERROR_AEN_Property2:assert property(AssertMasterMode(AEN_Property2));
	/*
	// ADSTB assertions
	*/
	property ADSTB_Property1;
		$rose(Extr.HLDA) |=> Extr.ADSTB ;
	endproperty
	
	property ADSTB_Property2;
		Extr.ADSTB |=> !Extr.ADSTB;
	endproperty
	
	property ADSTB_Property3;
		!Extr.EOP_N |-> !Extr.ADSTB;
	endproperty
	
	property ADSTB_Property4;
		ADSTB_Property1 and ADSTB_Property2;
	endproperty
	ERROR_ADSTB_Property1:assert property(AssertMasterMode(ADSTB_Property1));
	ERROR_ADSTB_Property2:assert property(AssertMasterMode(ADSTB_Property2));
	ERROR_ADSTB_Property3:assert property(AssertMasterMode(ADSTB_Property3));
	ERROR_ADSTB_Property4:assert property(AssertMasterMode(ADSTB_Property4));
	/*
	// IOR assertions
	*/
	property IOR_Property1_Master;
		!Extr.IOR_N |=> Extr.IOR_N;
	endproperty
	
	property IOR_Property2_Master;
		!Extr.EOP_N |-> Extr.IOR_N;
	endproperty
	
	ERROR_IOR_Property1_Master:assert property(AssertMasterMode(IOR_Property1_Master));
	ERROR_IOR_Property2_Master:assert property(AssertMasterMode(IOR_Property2_Master));
	/*
	// IOW assertions
	*/
	property IOW_Property1_Master;
		!Extr.IOW_N |=> Extr.IOW_N;
	endproperty
	
	property IOW_Property2_Master;
		!Extr.EOP_N |-> Extr.IOW_N;
	endproperty
	
	ERROR_IOW_Property1_Master:assert property(AssertMasterMode(IOW_Property1_Master));
	ERROR_IOW_Property2_Master:assert property(AssertMasterMode(IOW_Property2_Master));
	/*
	// IOR and IOW combined assertions 
	*/
	property IORW_Property1_Master;
		!Extr.EOP_N |-> !(~Extr.IOW_N && ~Extr.IOR_N);
	endproperty
	
	property IORW_Property2_Master;
		$rose(Extr.HLDA) |-> ##[3:$] !Extr.READY && (~Extr.IOR_N || ~Extr.IOW_N);
	endproperty
	
	property IORW_Property3_Master;
		Extr.HLDA |-> !$isunknown( {Extr.IOW_N,Extr.IOR_N});
	endproperty
	
	property IORW_Property4_Master;
		$fell(Extr.HRQ) |-> Extr.IOW_N === 'z && Extr.IOR_N === 'z;
	endproperty
	
	ERROR_IORW_Property1_Master:assert property(AssertMasterMode(IORW_Property1_Master));
	ERROR_IORW_Property2_Master:assert property(AssertMasterMode(IORW_Property2_Master));
	ERROR_IORW_Property3_Master:assert property(AssertMasterMode(IORW_Property3_Master));
	ERROR_IORW_Property4_Master:assert property(AssertMasterMode(IORW_Property4_Master));
	/*
	// Master Mode-Address bus should be Valid during transfer
	*/
	property AddressBusValid_Property_Master;
		Extr.AEN |-> !$isunknown(Extr.ADDRESS)
	endproperty	
	ERROR_AddressBusValid_Property_Master:assert property(AssertMasterMode(AddressBusValid_Property_Master));
	/*
	// Master Mode- Data bus should be Valid during transfer
	*/
	property DataBusValid_Property_Master;
		Extr.AEN && Extr.ADSTB |-> !$isunknown(Extr.DATABUS)
	endproperty	
	ERROR_DataBusValid_Property_Master:assert property(AssertMasterMode(DataBusValid_Property_Master));	
	//
	/*-----------------------------------------------Slave Mode Assertions--------------------------------------------------*/
	//
	property AssertSlaveMode(property Slave);
		@(posedge Extr.CLOCK) disable iff( Extr.RESET | Extr.CS_N !== '0) Slave ;
	endproperty
	/*
	// Slave Mode IOR and IOW should not be low at same time
	*/
	property IORW_Property_Slave;
		!(~Extr.IOW_N && ~Extr.IOR_N);
	endproperty
	ERROR_IORW_Property_Slave:assert property(AssertSlaveMode(IORW_Property_Slave));
	/*
	// Slave Mode - Address  should be Valid during Program condition until IOR or IOW are high
	*/
	property AddressBusValid_Property_Slave;
		(~Extr.IOW_N && Extr.IOR_N) || (Extr.IOW_N && ~Extr.IOR_N) |-> !$isunknown(Extr.ADDRESS);
	endproperty
	ERROR_AddressBusValid_Property_Slave:assert property(AssertSlaveMode(AddressBusValid_Property_Slave));
	/*
	// Slave Mode - Data should be Valid  during Program condition (IOW is low) or (one clock later IOR is low)
	*/
	property DataValid_Property_Slave;
		( ~Extr.IOW_N |-> !$isunknown(Extr.DATABUS) ) or ( ~Extr.IOR_N |=> !$isunknown(Extr.DATABUS) );
	endproperty
	ERROR_DataValid_Property_Slave:assert property(AssertSlaveMode(DataValid_Property_Slave));
	
endmodule
/*
//------------------------------------------End of Assertion Module--------------------------------
*/