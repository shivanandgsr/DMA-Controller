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

module PriorityLogic(interface Extr,Intr);
	logic				enPriority;
	logic [3:0]			MaskedReq;							// Masked Channel Requests
	logic [3:0]			ChannelReq;							// Combined ( I/O Request or via software) channel Requests
	logic [3:0]			DREQ_temp;							// senses if DREQ is active high or active low
	logic [3:0]			ChannelAck;							// Channnel Ack in active high sense
	logic [1:0]         ActCH;														
	logic [3:0][1:0] 	PriorityArray = 8'b11_10_01_00;	
	
	
	
	assign Intr.DMA_Req	     = Extr.CS_N ? ChannelReq : '0 ;
	
	assign MaskedReq	     = DREQ_temp & (~Intr.MaskedReg[3:0]);
	
	assign DREQ_temp		 = Intr.DREQ_Sense ? Extr.DREQ : ~Extr.DREQ ;  
	
	assign ChannelReq		 = Intr.RequestReg[2] ? (( MaskedReq | (4'd1 << Intr.RequestReg[1:0]) ) & ~Intr.StatusReg[3:0]) : MaskedReq & ~Intr.StatusReg[3:0] ;

	assign Extr.DACK		 = Intr.ldAck ? (Intr.DACK_Sense ? ChannelAck : ~ChannelAck) : (Intr.DACK_Sense ? '0 : '1);
	
	assign Intr.ActiveChannel = Intr.MemToMem ? 'bz : ActCH;
	
//
//----------------------------------------------------------Intr.ActCH Logic---------------------------------------------------------------------------------------
	always_comb
	begin
		unique case(ChannelAck)
			4'b0001:	ActCH = 2'd0;
			4'b0010:	ActCH = 2'd1;
			4'b0100:	ActCH = 2'd2;
			4'b1000:	ActCH = 2'd3;
			default:	ActCH = 2'bz;
		endcase	
	end
//
//-------------------------------------------------------------Priority logic----------------------------------------------------------------------------------------
	always_ff @(posedge Intr.PriorityGen)
	begin
		if(!(|ChannelReq))
		begin
			ChannelAck <= '0;
			PriorityArray <= 8'b11_10_01_00;
		end
		else
		priority case(1'b1)
						ChannelReq[PriorityArray[0]]:begin
														ChannelAck <= 4'd1 << PriorityArray[0];
														PriorityArray <= Intr.RotatingPriority? {PriorityArray[0],PriorityArray[3:1]}   : 8'b11_10_01_00;
													end
						ChannelReq[PriorityArray[1]]:begin
														ChannelAck <= 4'd1 << PriorityArray[1];
														PriorityArray <= Intr.RotatingPriority? {PriorityArray[1:0],PriorityArray[3:2]} : 8'b11_10_01_00;
													end
						ChannelReq[PriorityArray[2]]:begin
														ChannelAck <= 4'd1 << PriorityArray[2];
														PriorityArray <= Intr.RotatingPriority? {PriorityArray[2:0],PriorityArray[3]}   : 8'b11_10_01_00;
													end
						ChannelReq[PriorityArray[3]]:begin
														ChannelAck = 4'd1 << PriorityArray[3];
														PriorityArray <= Intr.RotatingPriority? PriorityArray : 8'b11_10_01_00;
													end
		endcase
	end
endmodule
//
//-------------------------------------------------------------End of Priority module---------------------------------------------------------------------------------