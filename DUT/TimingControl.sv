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

module TimingControl (interface Extr,Intr);
	
	bit			    	doRead;							// initiate DMA read transfer (write to memory )
	logic 				doWrite;						// initiate DMA write transfer (read from memory)
	logic 				EOPTrigger;						// trigger EOP 
	logic 				en_rw;							// enable read or write
	logic 				ldActChn;
	logic [1:0]			ActCH;
	int					FirstTransfer;
	
	enum bit [3:0] {
					 SI,S0,								// SI - inactive state (IDLE cycle) ,S0 - 1st state in Active cycle
					 S1,S2,S3,S4,						// (Memory - I/O) States
					 S11,S12,S13,S14,					// (Memory to Memory) READ states
					 S21,S22,S23,S24					// (Memory to Memory) WRITE states
					} State, NextState ;  

 
	assign Extr.EOP_N   		= EOPTrigger ? 1'b0 : 1'b1;
	assign Intr.ActiveChannel 	= Intr.MemToMem ? ActCH : 'z ;
	assign Extr.IOW_N   		= Extr.CS_N ? (~Intr.MemToMem ? ~doRead  : 1'b1) : 'bz;
	assign Extr.MEMR_N  		= Extr.CS_N ? ( Intr.MemToMem ? ~doRead  : 1'b1) : 'bz;
	assign Extr.IOR_N   		= Extr.CS_N ? (~Intr.MemToMem ? ~doWrite : 1'b1) : 'bz;
	assign Extr.MEMW_N  		= Extr.CS_N ? ( Intr.MemToMem ? ~doWrite : 1'b1) : 'bz;
//----------------------------------------------------------------------NEXT STATE LOGIC--------------------------------------------------------------------------
	
	
	always_ff @(posedge Extr.CLOCK)
	begin
		if(Extr.RESET)
			State <= SI;
		else
			State <= NextState;
	end
	
	always_comb
	begin
		EOPTrigger 		 = 1'b0;
		Intr.ldTempAddr  = 1'b0;
		doRead  		 = 1'b0;
		doWrite 		 = 1'b0;
		Intr.AddrGen     = 1'b0;
		Extr.ADSTB  	 = 1'b0;
		Intr.enAddrUp  	 = 1'b0;
		Intr.enAddrLo    = 1'b0;
		Intr.PriorityGen = 1'b0;
		case(State)
			SI:	begin
					NextState 			= (Extr.CS_N ===1)? S0 : SI ;
					en_rw 				= 1'b0;
					Extr.AEN    		= 1'b0;
					Extr.ADSTB  		= 1'b0;
					FirstTransfer 		= 0;
				end
				
			S0:	begin
					NextState 		= (!Extr.CS_N) ? SI : (!Extr.EOP_N ? S0 : (Extr.HLDA ? (Intr.MemToMem ? S11 : S1) : S0)) ;
					Intr.ldTempAddr = (!Extr.EOP_N | !Extr.CS_N) ? 1'b0 : (Extr.HLDA ? ((FirstTransfer == 0) ? 1'b1 : 1'b0) : 1'b0) ;
					Intr.PriorityGen= ((|Intr.DMA_Req) & (FirstTransfer==0)) ? 1'b1 : 1'b0;
					Extr.HRQ		= |Intr.DMA_Req ;
					en_rw		    =  1'b1;
				end
					
			S1: begin
					NextState 	  	= (!Extr.CS_N) ? SI : (!Extr.EOP_N ? S0 : S2);
					Extr.ADSTB 	  	=  1'b1;
					Extr.AEN	  	=  1'b1;
					Intr.enAddrUp 	=  1'b1;
					Intr.ldAck    	=  1'b1;
					
				end
				
			S2:	begin
					NextState	   	= (!Extr.CS_N) ? SI : (!Extr.EOP_N ? S0 : (Intr.ExtendedWrite ? S3 : S4)) ;
					Intr.enAddrLo   = 1'b1;
					FirstTransfer++;
				end
				
			S3: begin
					NextState 		= !Extr.CS_N ? SI : (!Extr.EOP_N ? S0 : (Extr.READY ?  S3 : S4));
				end
					
			S4:	begin
					NextState			= !Extr.CS_N ? SI : ((!Extr.EOP_N | Intr.TC |!Intr.TransferMode) ? S0 : (Intr.TransferMode ? (Intr.Carry ? S1 : S2) : S0));
					Intr.AddrGen		= !Intr.TransferMode ? 1'b1 : (Intr.Carry ? 1'b1 : 1'b1) ;
					Intr.ldAck			= Intr.TC ? 1'b0 : 1'b1 ;
					en_rw 				= Intr.TC ? 1'b0 : 1'b1 ;
					Extr.AEN    		= Intr.TC ? 1'b0 : 1'b1 ;
					FirstTransfer   	= Intr.TC ? 0  : FirstTransfer;
					doRead				= Intr.ReadMode ? 1'b1 : 1'b0 ; 
					doWrite				= Intr.ReadMode ? 1'b0 : 1'b1 ;
					EOPTrigger 			= Intr.TC ? 1'b1 : 1'b0 ;
					Extr.HRQ			= Intr.TC ? (|Intr.DMA_Req ? 1'b1 : 1'b0) : 1'b1 ;
				end
				
//--------------------------------------------------States for Memory to Memory transfer---------------------------------------------------------------------------------
			S11:begin
					NextState 	  = ~Extr.EOP_N ? SI	  : S12 ;
					Extr.ADSTB 	  = ~Extr.EOP_N ? 1'b0 : 1'b1;
					Intr.enAddrUp = ~Extr.EOP_N ? 1'b0 : 1'b1;
					en_rw	  	  = ~Extr.EOP_N ? 1'b0 : 1'b1;
				end
				
			S12:begin
					NextState 	   	= ~Extr.EOP_N ? SI	  : S13 ;	
					Extr.ADSTB  	= 1'b0;
					Intr.enAddrUp  	= 1'b0;
					ActCH	  		= 2'b00;	
				end
					
			S13:begin
					NextState		=  ~Extr.EOP_N  ? SI : S14 ;
					Intr.ldTempReg	=  ~Extr.EOP_N  ? 'z : 1'b1;
					doRead			=   1'b1 ;
				end
				
			S14:begin
					NextState	    =  ~Extr.EOP_N  ? SI :(Intr.Carry ? S21 : S22);
					Intr.AddrGen	=   1'b1;
				end
					
			S21:begin
					NextState	   = ~Extr.EOP_N  ? SI  : S22 ;
					Extr.ADSTB     = ~Extr.EOP_N  ? 1'b0 : 1'b1;
					Intr.enAddrUp  = ~Extr.EOP_N  ? 1'b0 : 1'b1;
				end
				
			S22:begin
					NextState 	   = ~Extr.EOP_N ? SI  : (Intr.ExtendedWrite ? S23 : S24) ;	
					Extr.ADSTB  = 1'b0;
					Intr.enAddrUp  = 1'b0;
					ActCH	   = 2'b01;
				end
					
			S23:begin
					NextState 	   = ~Extr.EOP_N ? SI  :   (Extr.READY ?  S23 : S24) ;
				end

			S24:begin
					NextState	= 	( ~Extr.EOP_N | Intr.TC  ) ? SI   : (Intr.Carry ? S11 : S12);
					en_rw 		= 	( ~Extr.EOP_N | Intr.TC  ) ? 1'b0 : en_rw;
					doWrite		= 	1'b1;
					Intr.AddrGen=	( ~Extr.EOP_N | Intr.TC  ) ? 1'b0 : 1'b1;
					ldActChn	= 	( ~Extr.EOP_N | Intr.TC  ) ? 1'b0 : 1'b1;
					EOPTrigger 	=   Intr.TC ? 1'b1 : 1'b0;
				end		
		endcase
	end
endmodule	
/*
//------------------------------------------End of TimoingControl Module---------------------------
*/ 