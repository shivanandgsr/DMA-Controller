module DMATop(interface Extr);

	InternalBus Intr();
	
	PriorityLogic  PL(.Extr(Extr.Priority_External),.Intr(Intr.Priority_Internal));
	TimingControl  TC(.Extr(Extr.TimingControl_External),.Intr(Intr.TimingControl_Internal));
	Datapath 	   DP(.Extr(Extr.Datapath_External),.Intr(Intr.Datapath_Internal));
	
endmodule
