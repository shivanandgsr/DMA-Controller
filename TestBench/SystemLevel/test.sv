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

`include "environment.sv"
program test #(parameter NumRuns = 1)(interface Extr);

environment env;

initial
begin
	env = new(Extr,NumRuns);
	$display("test:: test:: Start Time : %0t",$time);
	env.run();
	$display("test:: test:: End Time : %0t",$time);
	$finish;
end
endprogram