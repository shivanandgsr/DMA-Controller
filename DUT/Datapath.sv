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

module Datapath(interface Intr,Extr);

	logic  	[3:0][15:0] CURRENT_ADDRESS;
	logic	[3:0][15:0] CURRENT_WORDCOUNT;
	logic   [3:0][15:0] BASE_ADDRESS;
	logic	[3:0][15:0] BASE_WORDCOUNT;
	logic		 [15:0]	TEMPORARY_ADDRESS;
	logic 		 [15:0] TEMPORARY_WORDCOUNT;
	logic 	     [ 7:0]	TEMPORARY;
	logic        [ 7:0] COMMAND;
	logic	[3:0]		REQUEST;
	logic 	[3:0][ 5:0]	MODE;
	logic		 [ 7:0] STATUS;
	logic 		 [ 3:0] MASK;
	
	logic				ldAddrReg;
	logic				ldWordCountReg;
	logic				ldCmdReg;
	logic				ldModeReg;
	logic				ldReqReg;
	logic				ldMaskReg;
	logic				enAddrReg;
	logic				enWordCountReg;
	logic				enTempReg;
	logic				enStatusReg;
	logic		 [ 1:0]	ChannelNo;
	logic				ClearBytePointer;
	logic				ClearMaskReg;
	logic				MasterClear;
	logic 				Bytelow;	
	
					
					
	
	assign Extr.DATABUS				=  Extr.CS_N ? (Intr.enAddrUp ? TEMPORARY_ADDRESS[15:8] : 'bz) : (!Extr.IOR_N ? (enAddrReg ? (Bytelow ? CURRENT_ADDRESS[ChannelNo][7:0] : CURRENT_ADDRESS[ChannelNo][15:8]) : (enWordCountReg ? (Bytelow ? CURRENT_WORDCOUNT[ChannelNo][7:0] : CURRENT_WORDCOUNT[ChannelNo][15:8]) : (enStatusReg ? STATUS :(enTempReg ? TEMPORARY :'bz))) ) : 'bz);
	assign Extr.ADDRESS 			=  Extr.CS_N ? ((Intr.enAddrLo |Intr.enAddrUp) ? TEMPORARY_ADDRESS[ 7:0] : Extr.ADDRESS) : 'bz;
	assign Intr.TC	   				= (CURRENT_WORDCOUNT[Intr.ActiveChannel] == '1) ? 1'b1 : 1'b0;;
	assign Intr.Carry 				= MODE[Intr.ActiveChannel][5] ?  (((TEMPORARY_ADDRESS[7:0] == '0)  && ( TEMPORARY_WORDCOUNT != '1) ) ? 1'b1 : 1'b0 ) : (( ( TEMPORARY_ADDRESS[7:0] =='1) && (TEMPORARY_WORDCOUNT!='1) ) ? 1'b1 : 1'b0);
	assign Intr.MemToMem			=  COMMAND[0];
	assign Intr.ExtendedWrite		=  COMMAND[5];
	assign Intr.ReadMode			= (MODE[Intr.ActiveChannel][1:0]==2'b10) ? 1'b1 : ((MODE[Intr.ActiveChannel][1:0] == 2'b01) ? 1'b0 : 1'bz);
	assign Intr.TransferMode		= (MODE[Intr.ActiveChannel][5:4]==2'b10) ? 1'b1 : ((MODE[Intr.ActiveChannel][5:4] == 2'b01) ? 1'b0 : 1'bz);
	assign Intr.RotatingPriority	=  COMMAND[4];
	assign Intr.DREQ_Sense 			= !COMMAND[6];
	assign Intr.DACK_Sense			=  COMMAND[7];
	assign Intr.RequestReg			=  REQUEST;
	assign Intr.StatusReg			=  STATUS;
	assign Intr.MaskedReg 			=  MASK;
	assign ChannelNo				= (!Extr.CS_N) ? ((enAddrReg | enWordCountReg | ldAddrReg | ldWordCountReg) ? Extr.ADDRESS[2:1] : 'bz) : 'bz;
	
	always_comb
	begin
	
		ldAddrReg 		= !Extr.CS_N & !Extr.IOW_N & (Extr.ADDRESS[3:0] inside {4'd0,4'd2,4'd4,4'd6});
		ldWordCountReg	= !Extr.CS_N & !Extr.IOW_N & (Extr.ADDRESS[3:0] inside {4'd1,4'd3,4'd5,4'd7});
		enAddrReg		= !Extr.CS_N & !Extr.IOR_N & (Extr.ADDRESS[3:0] inside {4'd0,4'd2,4'd4,4'd6});
		enWordCountReg	= !Extr.CS_N & !Extr.IOR_N & (Extr.ADDRESS[3:0] inside {4'd1,4'd3,4'd5,4'd7});
		ldCmdReg		= !Extr.CS_N & !Extr.IOW_N & (Extr.ADDRESS[3:0] == 4'b1000);
		ldReqReg		= !Extr.CS_N & !Extr.IOW_N & (Extr.ADDRESS[3:0] == 4'b1001);
		ldModeReg		= !Extr.CS_N & !Extr.IOW_N & (Extr.ADDRESS[3:0] == 4'b1011);
		ldMaskReg		= !Extr.CS_N & !Extr.IOW_N & (Extr.ADDRESS[3:0] == 4'b1111);
		enTempReg		= !Extr.CS_N & !Extr.IOR_N & (Extr.ADDRESS[3:0] == 4'b1101);
		enStatusReg		= !Extr.CS_N & !Extr.IOR_N & (Extr.ADDRESS[3:0] == 4'b1000);
		ClearBytePointer= !Extr.CS_N & !Extr.IOW_N & (Extr.ADDRESS[3:0] == 4'b1100);
		ClearMaskReg	= !Extr.CS_N & !Extr.IOW_N & (Extr.ADDRESS[3:0] == 4'b1110);
		MasterClear		= !Extr.CS_N & !Extr.IOW_N & (Extr.ADDRESS[3:0] == 4'b1101);
		
			MoreThanOneOperation: assert ($countones({ldAddrReg,ldWordCountReg,enAddrReg,enWordCountReg,ldCmdReg,ldReqReg,ldModeReg,ldMaskReg,enTempReg,enStatusReg,ClearBytePointer,ClearMaskReg,MasterClear}) inside {0,1})
						          else $fatal("More than one read or write operation");
	end
	
						  
	always_ff @(posedge Extr.CLOCK)
	begin 
		if(MasterClear | Extr.RESET)
		begin
			REQUEST			  	<= 4'd0;
			STATUS 			 	<= 8'd0;
			MASK			 	<= 4'hF;
			TEMPORARY 		 	<= 8'd0;
			TEMPORARY_ADDRESS	<= 16'd0;
			TEMPORARY_WORDCOUNT	<= 16'd0;
			CURRENT_ADDRESS  	<= BASE_ADDRESS;
			CURRENT_WORDCOUNT	<= BASE_WORDCOUNT;
		end
		else
		begin
			REQUEST				 			<= ldReqReg ? Extr.DATABUS[3:0] : REQUEST;
			STATUS[7:4]			 			<= Intr.DMA_Req;
			STATUS[Intr.ActiveChannel]		<= (CURRENT_WORDCOUNT[Intr.ActiveChannel] == '1) ? 1'b1 : STATUS[Intr.ActiveChannel];
			MASK 				 			<= ClearMaskReg ? '0 : (ldMaskReg ? Extr.DATABUS : MASK);
			TEMPORARY						<= Intr.ldTempReg ?  Extr.DATABUS : TEMPORARY;
			TEMPORARY_ADDRESS 				<= Extr.CS_N ? (Intr.AddrGen ? (MODE[Intr.ActiveChannel][3] ? TEMPORARY_ADDRESS - 16'd1 : TEMPORARY_ADDRESS + 16'd1) : (Intr.ldTempAddr ? CURRENT_ADDRESS[Intr.ActiveChannel] : TEMPORARY_ADDRESS)) : TEMPORARY_ADDRESS;
			TEMPORARY_WORDCOUNT				<= Extr.CS_N ? (Intr.AddrGen ? (TEMPORARY_WORDCOUNT != '1 ? TEMPORARY_WORDCOUNT - 16'b1 : TEMPORARY_WORDCOUNT) : (Intr.ldTempAddr ? CURRENT_WORDCOUNT[Intr.ActiveChannel] : TEMPORARY_WORDCOUNT)) : TEMPORARY_WORDCOUNT;
			BASE_ADDRESS[ChannelNo][7:0] 	<= ldAddrReg ? (Bytelow ? Extr.DATABUS : BASE_ADDRESS[ChannelNo][7:0]) : BASE_ADDRESS[ChannelNo][7:0];
			BASE_ADDRESS[ChannelNo][15:8] 	<= ldAddrReg ? (!Bytelow ? Extr.DATABUS : BASE_ADDRESS[ChannelNo][15:8]) : BASE_ADDRESS[ChannelNo][15:8];
			BASE_WORDCOUNT[ChannelNo][7:0] 	<= ldWordCountReg ? (Bytelow ? Extr.DATABUS : BASE_WORDCOUNT[ChannelNo][7:0]) : BASE_WORDCOUNT[ChannelNo][7:0];
			BASE_WORDCOUNT[ChannelNo][15:8] <= ldWordCountReg ? (!Bytelow ? Extr.DATABUS : BASE_WORDCOUNT[ChannelNo][15:8]) : BASE_WORDCOUNT[ChannelNo][15:8];	
			COMMAND							<= ldCmdReg ? Extr.DATABUS : COMMAND;
			MODE [Extr.DATABUS[1:0]]		<= ldModeReg ? Extr.DATABUS[7:2] : MODE[Extr.DATABUS[1:0]];
			
			if(Extr.CS_N)
			begin
				CURRENT_ADDRESS[Intr.ActiveChannel]  <= Intr.enAddrLo ? TEMPORARY_ADDRESS : ((TEMPORARY_WORDCOUNT == '1) ? ((MODE[Intr.ActiveChannel][2] ? BASE_ADDRESS[Intr.ActiveChannel] : TEMPORARY_ADDRESS[Intr.ActiveChannel])) : CURRENT_ADDRESS[Intr.ActiveChannel]) ;
				CURRENT_WORDCOUNT[Intr.ActiveChannel]  <= Intr.enAddrLo ? TEMPORARY_WORDCOUNT : ((TEMPORARY_WORDCOUNT == '1) ? ((MODE[Intr.ActiveChannel][2] ? BASE_WORDCOUNT[Intr.ActiveChannel] : TEMPORARY_WORDCOUNT[Intr.ActiveChannel])) : CURRENT_WORDCOUNT[Intr.ActiveChannel]) ;
			end
			else
			begin
				CURRENT_ADDRESS[ChannelNo][7:0] 	<= ldAddrReg ? (Bytelow ? Extr.DATABUS : CURRENT_ADDRESS[ChannelNo][7:0]) : CURRENT_ADDRESS[ChannelNo][7:0];
				CURRENT_ADDRESS[ChannelNo][15:8] 	<= ldAddrReg ? (!Bytelow ? Extr.DATABUS : CURRENT_ADDRESS[ChannelNo][15:8]) : CURRENT_ADDRESS[ChannelNo][15:8];
				CURRENT_WORDCOUNT[ChannelNo][7:0] 	<= ldWordCountReg ? (Bytelow ? Extr.DATABUS :CURRENT_WORDCOUNT[ChannelNo][7:0]) : CURRENT_WORDCOUNT[ChannelNo][7:0];
				CURRENT_WORDCOUNT[ChannelNo][15:8] 	<= ldWordCountReg ? (!Bytelow ? Extr.DATABUS :CURRENT_WORDCOUNT[ChannelNo][15:8]) : CURRENT_WORDCOUNT[ChannelNo][15:8];
			end 
		end
	end
								
	always_ff@(posedge Extr.CLOCK)
	begin
		if(MasterClear | Extr.RESET | ClearBytePointer)
			Bytelow <= '0;
		else if (!Bytelow)
			Bytelow <= ~Bytelow;
	end
endmodule
/*
// -----------------------------------------End of Datapath Module---------------------------------				
*/										
								
								
	