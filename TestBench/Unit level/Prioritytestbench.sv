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
//
//
//-------------------------------------UNIT TEST TOP MODULE FOR PRIORITY LOGIC-------------------------------
module top;

	logic clock;
	logic reset;
	logic [3:0][1:0]priority_array = 8'b11_10_01_00; 
	
	InternalBus Intr();
	ExternalBus Extr(clock,reset);
	
	PriorityLogic  PL(.Extr(Extr.Priority_External),.Intr(Intr.Priority_Internal));
	always
		#5 clock = ~clock;
			
			
	task automatic Fixed_priority_stimulus;
	
		$display("============Starting Fixed Priority Testing============\n");
		Intr.DREQ_Sense <= 1'b1;
		Intr.DACK_Sense <= 1'b1;
		Intr.RotatingPriority <= 1'b0;
		
		for (int i = 0; i <= 15 ; i++)
		begin
			Intr.MaskedReg		<= i;
			Intr.StatusReg[3:0] <= '0;
			for (int j = 0; j <= 15 ; j++)
			begin
				@(posedge clock);Intr.ldAck <= 1'b0;Extr.HLDA  <= 1'b0;
				Extr.DREQ <= j;
				Intr.RequestReg <= 4'b0000;
				@(negedge Extr.CLOCK) Intr.PriorityGen <= 1;
					repeat(2) @(negedge clock) ;Extr.HLDA <= 1'b1;Intr.ldAck <= 1'b1;
					Priority_verify();
					PriorityGen <= 0;
			end
		end
		Intr.RequestReg <= 3'b000;
		Intr.MaskedReg<= 4'b0000;
		@(posedge clock);Intr.ldAck <= 1'b0;Extr.HLDA  <= 1'b0;
		$display("============End of Fixed Priority Testing===============\n");
	endtask
	
	task automatic Rotating_priority_stimulus;
	
		$display("============Starting Rotating Priority Testing==========\n");
		Intr.DREQ_Sense <= 1'b1;
		Intr.DACK_Sense <= 1'b0;
		Intr.RequestReg <= 3'b000;
		Intr.MaskedReg <= 4'b0000;
		Intr.RotatingPriority <= 1'b1;
		drive();
		$display("============End of Rotating Priority Testing==========\n");
	
	endtask		
		
	task automatic drive();
		
		for(int i =0; i <=15 ; i++)
		begin
			@(posedge clock);Intr.ldAck <= 1'b0;Extr.HLDA  <= 1'b0;
			Extr.DREQ  <= i;
			@(negedge clock) Intr.PriorityGen <= '1;
			repeat(2) @(negedge clock) ;Extr.HLDA <= 1'b1;Intr.ldAck <= 1'b1;
			Priority_verify();
			Intr.PriorityGen <= '0;
		end
		@(posedge clock);Intr.ldAck <= 1'b0;Extr.HLDA  <= 1'b0;
	endtask
	
	task automatic Priority_verify();
		@(posedge clock) ;
		if(Extr.HLDA && Intr.ldAck)
		begin
			for(int k =0; k <= 3 ;k++)
			begin	
				if( (Intr.DREQ_Sense && Extr.DREQ[priority_array[k]]) || (!Intr.DREQ_Sense && !Extr.DREQ[priority_array[k]]) )
				begin
					$display("********ERROR :: Priority order : {%d,%d,%d,%d} DREQ : 4'b%b  DACK : 4'b%b  Expected DACK : 4'b%b\n",priority_array[0],priority_array[1],priority_array[2],priority_array[3],Extr.DREQ,Extr.DACK,(Intr.DACK_Sense ? 4'd1 << priority_array[k] : ~(4'd1 << priority_array[k])) );
					if(Intr.RotatingPriority)
						repeat(k+1) priority_array = {priority_array[0],priority_array[3:1]};
				end
			end
		end
	endtask
	
	initial
	begin
		clock <= 1'b1;
		Fixed_priority_stimulus();
		Rotating_priority_stimulus();
		$finish;
	end
	
endmodule
/*
//------------------------------------------End of Priority Testbench------------------------------
*/