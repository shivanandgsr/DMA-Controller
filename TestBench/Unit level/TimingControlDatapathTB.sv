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

module top;

	logic clock;
	logic reset;
	
	logic 		 read,write;
	logic [ 7:0] data;
	logic [15:0] addr;
	logic 		 ProgramMode;
	logic [1:0]  ActCH;
	logic eop_n;
	
	InternalBus Intr();
	ExternalBus Extr(clock,reset);
	
	TimingControl TC (.Extr(Extr.TimingControl_External),.Intr(Intr.TimingControl_Internal));
	Datapath 	  DP (.Extr(Extr.Datapath_External),.Intr(Intr.Datapath_Internal));
	bind Datapath DatapathAssertions DA (Extr,Intr,CURRENT_ADDRESS,CURRENT_WORDCOUNT,BASE_ADDRESS,BASE_WORDCOUNT,TEMPORARY_ADDRESS,TEMPORARY_WORDCOUNT,TEMPORARY,COMMAND,REQUEST,MODE,STATUS,MASK,MasterClear,Bytelow,ClearBytePointer,ChannelNo,enAddrReg,enWordCountReg,enStatusReg,enTempReg,ldAddrReg,ldWordCountReg,ldCmdReg,ldMaskReg,ldModeReg);
	

	always #5 clock = ~clock;

	assign Extr.IOR_N     = !Extr.CS_N ? ~read : 'bz;
	assign Extr.IOW_N 	  = !Extr.CS_N ? ~write : 'bz;
	assign Extr.DATABUS	  = !Extr.CS_N ? (read ? 'bz : (write ? data : 'bz)): 'bz ;
	assign Extr.ADDRESS	  = !Extr.CS_N ? addr : 'bz;
	assign Intr.ActiveChannel = Intr.MemToMem ? 'bz : ActCH;
	assign Extr.EOP_N	= eop_n;
	initial
	begin
		clock = 1'b0; reset = 1'b1; Intr.DMA_Req <= '1;
		@(negedge clock) reset <= 1'b0; write <= 1'b1; read <= 1'b0;
		//Writing to Base and Current Address registers in program mode
		Extr.CS_N <= 1'b0;//read <= 1'b0;
			for(int i=0;i<=6;i=i+2)
			begin
				addr <= 8'hc;data <= i*1;
				@(negedge clock) addr <= i;
				@(negedge clock) data <= i*2;
				repeat(2)@(negedge clock);
			end
			//Read all Base and Current Address registers in program mode
			for(int i =0;i<=6;i=i+2)
			begin
				addr<=8'hc; write<= '1;read <= '0;
				@(negedge clock)addr <= i;read <= '1; write<= '0;
				repeat(2)@(negedge clock);
			end
			//Configuring mode registers
			
				@(negedge clock)data[1:0] <= 0; data[7:2] <= 6'h16; addr <= 4'hb;read <='0;write<=1;
				@(negedge clock);
				@(negedge clock)data[1:0] <= 1; data[7:2] <= 6'h26; addr <= 4'hb;read <='0;write<=1;
				@(negedge clock);
				@(negedge clock)data[1:0] <= 2; data[7:2] <= 6'h16; addr <= 4'hb;read <='0;write<=1;
				@(negedge clock);
				@(negedge clock)data[1:0] <= 3; data[7:2] <= 6'h26; addr <= 4'hb;read <='0;write<=1;
				@(negedge clock);
				
			//write Command	 Register
			@(negedge clock) data <= 8'h80; addr <= 4'h8;
			@(negedge clock);
			//write Request Register
			@(negedge clock) data <= 4'hc; addr <= 4'h9;
			@(negedge clock);
			//write Mask Register
			@(negedge clock) data <= '0; addr<= '1;
			@(negedge clock);
			//Write WordCount Registers
			for(int i =1;i<=7;i=i+2)
			begin
				addr<=8'hc;read <= '0;write <='1;data <= i*2;
				@(negedge clock) addr <= i;
				@(negedge clock) data <= i*1;
				repeat(2)@(negedge clock);
			end
			//Read to all wordcount registers
			for(int i =1;i<=7;i=i+2)
			begin
				addr<=8'hc;read <= '0;write<='1;
				@(negedge clock) addr <= i;read <= '1; write <= '0;
				
				repeat(2)@(negedge clock);
			end
			
			//Read Status Register
			addr <=4'h8;
			
			//Read Temporary registers
			//@(negedge clock) addr <= 4'hd;
			
			//Clear Mask Register
			@(negedge clock) read <= '0; write<='1;addr<= 4'he;
			
			//Master clear
			@(negedge clock) addr <= 4'hd;read<='0;write<='1;
			
			
			
			//Transfer mode
			@(negedge clock) Extr.CS_N <= '1; data <='z; ActCH <='0; Intr.DMA_Req <= '1; eop_n <= 'z; Extr.HLDA <= '0;
			wait(Extr.HRQ)
			repeat($urandom_range(0,10)) @(negedge Extr.CLOCK);
			Extr.HLDA <='1;
			
			wait(!Extr.EOP_N) ActCH <= 2'b01; Intr.DMA_Req <= 4'b0110;
			
			wait(!Extr.EOP_N) ActCH <= 2'b10; 
			
			wait(!Extr.EOP_N) ActCH <= 2'b11; Intr.DMA_Req <= 4'b1111;
			
			wait (!Extr.EOP_N) Extr.HLDA <= '0;
				
		repeat(20)
		@(negedge clock);
		
		$finish();
	end
endmodule
/*
//------------------------------------------End of TimingControl and Datapath Testbench------------
*/
	
	