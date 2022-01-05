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

`include "driver.sv"

class environment;

	generator gen;
	driver drv;
	mailbox gen2drv;
	int NumRuns;
	virtual ExternalBus Extr;

	function new(virtual ExternalBus Extr,int NumRuns);
		this.Extr = Extr;
		this.NumRuns = NumRuns;
	endfunction

	extern task run();
endclass

task environment::run();
	$display("environment:: Start Time : %0t",$time);
	gen2drv = new();
	gen = new(gen2drv,NumRuns);
	drv = new (Extr,gen2drv,NumRuns);
	fork
		gen.run();
		@(posedge Extr.CLOCK);
		drv.run();
	join
	$display("environment:: End Time : %0t",$time);
endtask
/*
//------------------------------------------End of environment class-------------------------------