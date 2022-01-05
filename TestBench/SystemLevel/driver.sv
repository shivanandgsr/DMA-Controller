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

`include "generator.sv"
//
/*------------------------------------------driver class-------------------------------------------*/
//
class driver;
		
	virtual ExternalBus Extr;	// External interface 
	int NumPkts;	
	bit ActChUpdated;
	bit LastTransfer;
	logic [1:0] ActiveChannel; 
	
	const bit [1:0] Single = 2'b01;
	const bit [1:0] Block  = 2'b10;
	
	packet pkt;
	mailbox gen2drv;
	
	function new (virtual ExternalBus Extr,mailbox gen2drv,int NumRuns);
		this.Extr = Extr;
		this.NumPkts = NumRuns;
		this.gen2drv = gen2drv;
	endfunction
	
	extern task run();	// Initiate DMA write or read
	extern task ProgramMode	 (ref packet pkt); // ProgramMode the DMA before the transfer
	extern task drive		 (const ref packet pkt); // drive the address and data bus with respective values 
	extern task Stimulus	 (ref packet pkt,const ref logic[1:0]ActiveChannel);  // Stimulus (DREQ , data etc) during transfer
	extern task CheckDACK	 (const ref packet pkt,ref logic[1:0]ActiveChannel,ref bit ActChUpdated); // If DACK is received for highest priority packet
	extern task CheckResult	 (ref packet pkt,ref logic[1:0]ActiveChannel); // Check if it is single or block transfer and call CheckAddress task 
	extern task CheckAddress (ref packet pkt,ref logic[1:0]ActiveChannel); // Check if the address generated is valid and correct

endclass
/*------------------------------------------End of driver class------------------------------------*/
//
/*------------------------------------------TASK run-----------------------------------------------*/
task driver::run();
	
	$display("driver::run:: Start Time : %0t",$time);
	wait(Extr.RESET === '0);
	repeat(NumPkts)
	begin
		gen2drv.get(pkt);
		ProgramMode(pkt);
		fork
			Stimulus(pkt,ActiveChannel);
			CheckResult(pkt,ActiveChannel);
		join
	end
	
	$display("driver::run:: End Time : %0t",$time);
endtask
//
/*------------------------------------------TASK ProgramMode-----------------------------------------*/
//
task driver::ProgramMode(ref packet pkt);
	
	// Command register
	pkt.address = 4'h8 ; 
	pkt.data = pkt.Command;
	drive(pkt);
	
	//Mask register 
	pkt.address = 4'hF;
	pkt.data = pkt.Mask;
	drive(pkt);
	
	// Request register
	pkt.address = 4'h9;
	pkt.data = pkt.Request;
	drive(pkt);
	
	// Mode register ,Base and current address registers , Base and Current word count  
	for(bit [2:0]i='0;i <= 2'b11;i++)
	begin
		pkt.address =	4'hB;pkt.data = {pkt.Mode[i],i[1:0]};drive(pkt);
		pkt.address =	4'hC;drive(pkt);
		pkt.address =	{1'b0,i[1:0],1'b0};pkt.data = pkt.BaseAddress[i][15:8];drive(pkt);
		pkt.address =	{1'b0,i[1:0],1'b0};pkt.data = pkt.BaseAddress[i][ 7:0];drive(pkt);
		pkt.address =	4'hC;drive(pkt);
		pkt.address =	{1'b0,i[1:0],1'b1};pkt.data = pkt.BaseWordCount[i][15:8];drive(pkt);
		pkt.address =	{1'b0,i[1:0],1'b1};pkt.data = pkt.BaseWordCount[i][ 7:0];drive(pkt);
	end
	@(negedge Extr.CLOCK);pkt.address <= 'z;pkt.data <= 'z;Extr.iow <= '1;Extr.ior <= '1;
	repeat(5)@(posedge Extr.CLOCK);
endtask
//
/*------------------------------------------TASK drive---------------------------------------------*/
//
task driver::drive( const ref packet pkt/*,const ref logic write*/);
 
	@(negedge Extr.CLOCK);
	Extr.CS_N 	<= '0;
	Extr.ior 	<= '1;
	Extr.iow 	<= '0;
	Extr.addr	<= pkt.address;
	Extr.data 	<= pkt.data;
	
endtask
//
/*------------------------------------------TASK Stimulus------------------------------------------*/
//
task driver::Stimulus(ref packet pkt,const ref logic[1:0]ActiveChannel);
	
	automatic logic [AddrWordCountWidth-1:0] count;

	Extr.CS_N 	= '1;
	Extr.HLDA 	= '0;
	Extr.DREQ 	= pkt.DREQ;

	while( (pkt.Command.DREQsense ? |(~pkt.DREQ & ~pkt.Mask)  : |(pkt.DREQ & ~pkt.Mask)) || pkt.Request.set )
	begin 
		wait(Extr.HRQ);
			repeat($urandom_range(4,2))@(negedge Extr.CLOCK);Extr.HLDA = '1;	
		
		wait( Extr.EOP_N && (pkt.Command.DACKsense ? |Extr.DACK : |(~Extr.DACK)) ); 
		wait(ActiveChannel inside{[0:3]} && ActChUpdated);
		
		count = pkt.BaseWordCount[ActiveChannel];
		ActChUpdated = '0;
		
		if(pkt.Mode[ActiveChannel].Tmode == Block)
		begin
			pkt.DREQ [ActiveChannel] = ~pkt.DREQ[ActiveChannel] ; 
			Extr.DREQ[ActiveChannel] =  pkt.DREQ[ActiveChannel] ;
			pkt.Request.set = pkt.Request.ChNum == ActiveChannel? 1'b0 : pkt.Request.set;  
			wait(!Extr.EOP_N);
		end
		else if(pkt.Mode[ActiveChannel].Tmode == Single)
		begin
			wait(pkt.CurrentWordCount[ActiveChannel] == count-1'b1) 
			count = pkt.CurrentWordCount[ActiveChannel];
			if(pkt.CurrentWordCount[ActiveChannel] == '0)
			begin
				pkt.DREQ [ActiveChannel] = ~pkt.DREQ[ActiveChannel] ; 
				Extr.DREQ[ActiveChannel] =  pkt.DREQ[ActiveChannel] ;
				pkt.Request.set = pkt.Request.ChNum == ActiveChannel? 1'b0 : pkt.Request.set;
				wait(!Extr.EOP_N);
			end
		end
	end
	wait(!Extr.HRQ) ;Extr.HLDA = '0;
	assert( !( (pkt.Command.DREQsense ? |(~pkt.DREQ & ~pkt.Mask) : |(pkt.DREQ & ~pkt.Mask)) || pkt.Request.set ) && !Extr.HRQ)
	else
		$error("****ERROR::driver::Stimulus ::*****ERROR HRQ RECEIVED WHEN THERE IS NO REQUEST \n ");
	assert( !( (pkt.Command.DREQsense ? |(~pkt.DREQ & ~pkt.Mask) : |(pkt.DREQ & ~pkt.Mask)) || pkt.Request.set ) && (pkt.Command.DACKsense ? Extr.DACK ==='0 : Extr.DACK === '1) )
	else 
		$error("****ERROR::driver::Stimulus ::*****ERROR DACK RECEIVED WHEN THERE IS NO REQUEST \n ");
endtask
//
/*------------------------------------------TASK CheckResult-----------------------------------------*/
//
task driver::CheckResult(ref packet pkt,ref logic[1:0]ActiveChannel); 
	automatic bit Flag;
	
	while((pkt.Command.DREQsense ? |(~pkt.DREQ & ~pkt.Mask) : |( pkt.DREQ & ~pkt.Mask) ) || pkt.Request.set)
	begin
		wait( Extr.EOP_N && (pkt.Command.DACKsense ? |Extr.DACK : |(~Extr.DACK)) ); 
		if(!Flag) 
		begin
			CheckDACK(pkt,ActiveChannel,ActChUpdated);
			Flag = '1;
		end
		if(pkt.Mode[ActiveChannel].Tmode == Block)
		begin
			do
			begin
				wait(Extr.AEN);
				CheckAddress(pkt,ActiveChannel);
				wait(Extr.IOR_N && Extr.IOW_N);
				if (LastTransfer)
					@(posedge Extr.CLOCK);
			end
			while(pkt.CurrentWordCount[ActiveChannel] !== '1);
			Flag = '0;
		end
		else if(pkt.Mode[ActiveChannel].Tmode == Single)
		begin
			CheckAddress(pkt,ActiveChannel);
			Flag = '0;
		end
	end	
endtask
//
/*------------------------------------------TASK CheckDACK-------------------------------------*/
//
task driver::CheckDACK(const ref packet pkt,ref logic[1:0]ActiveChannel,ref bit ActChUpdated);
	
	static logic [3:0][1:0]priority_array = 8'b11_10_01_00;
	logic high_dreq,low_dreq,swreq;

	assert( pkt.Command.DACKsense ? $onehot(Extr.DACK) : $onehot(~Extr.DACK))
	else 
		$error("****ERROR::driver::CheckDACK::*****ERROR DACK IS NOT onehot \n ");
	for(int n =0; n <= NumChannels;n++)
	begin
		high_dreq = ~pkt.Command.DREQsense && ( Extr.DREQ[priority_array[n]]  && (~pkt.Mask[priority_array[n]]) ) ;
		low_dreq  =  pkt.Command.DREQsense && ( ~Extr.DREQ[priority_array[n]] && (~pkt.Mask[priority_array[n]]) ) ;
		swreq	  =  pkt.Request.set && (pkt.Request.ChNum == priority_array[n]) ;
				
		if(high_dreq | low_dreq | swreq)
		begin
			assert( pkt.Command.DACKsense ? Extr.DACK == 4'd1 << priority_array[n] : Extr.DACK == ~(4'd1 << priority_array[n])) 	
			begin
				ActiveChannel= priority_array[n];
				ActChUpdated = '1;
				if(pkt.Command.FRpriority)
					repeat(n+1) priority_array = {priority_array[0],priority_array[3:1]};
				return;
			end
			else 
				$error("****ERROR::driver::CheckDACK::*****ERROR Priority order : {%d,%d,%d,%d}  MASK : 4'b%b  REQUEST : 4'b%b  DREQ : 4'b%b  DACK : 4'b%b  Expected DACK : 4'b%b\n",priority_array[0],priority_array[1],priority_array[2],priority_array[3],pkt.Mask,pkt.Request,(pkt.Command.DREQsense ? ~Extr.DREQ : Extr.DREQ),(pkt.Command.DACKsense ? Extr.DACK : ~Extr.DACK),(pkt.Command.DACKsense ? 4'd1 << priority_array[n] : ~(4'd1 << priority_array[n])) );	
		end
	end		
endtask
//
/*------------------------------------------TASK CheckAddress--------------------------------------*/
//
task driver::CheckAddress(ref packet pkt,ref logic[1:0]ActiveChannel);
	static logic [AddrWordCountWidth-1:0] addr;
	
	addr[15:8] = Extr.ADSTB ? Extr.DATABUS : addr[15:8];
	wait(!(Extr.IOR_N && Extr.IOW_N));
	addr[ 7:0]  = Extr.ADDRESS;
	assert(addr === pkt.CurrentAddress[ActiveChannel])
	else
		$display("****ERROR::driver::CheckAddress::%s Transfer Mode:: addrhigh:%d,addrlow = %d,CurrentAddrHigh:%d,CurrentAddrLow:%d",pkt.Mode[ActiveChannel].Tmode,addr[15:8],addr[7:0],pkt.CurrentAddress[ActiveChannel][15:8],pkt.CurrentAddress[ActiveChannel][7:0]);
	
	pkt.CurrentAddress[ActiveChannel] =  pkt.Mode[ActiveChannel].AddrIncDec ? pkt.CurrentAddress[ActiveChannel]-1'b1 : pkt.CurrentAddress[ActiveChannel] + 1'b1;
	pkt.CurrentWordCount[ActiveChannel]--;
	if(pkt.CurrentWordCount[ActiveChannel]==='1)
		LastTransfer = '1;
endtask
/*
// -----------------------------------------END OF driver Class-----------------------------------
*/