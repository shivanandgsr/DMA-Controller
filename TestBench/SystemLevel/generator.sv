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

`include "packet.sv"

class generator ;
	
	packet pkt;
	mailbox gen2drv;
	
	int NumPkts;

	function new(mailbox gen2driv,int NumPkts); 
		this.gen2drv = gen2driv;
		this.NumPkts = NumPkts;
	endfunction
   
	task run();
		repeat(NumPkts)
		begin
			pkt = new();
			packet_a:assert( pkt.randomize() ) 
					 else $fatal("gen Randomization Failed");
			gen2drv.put(pkt);
		end
	endtask
endclass
/*
//------------------------------------------End of generator class---------------------------------
*/