////////////////////////////////////////////////////////////////////////////////
// Author: Kareem Waseem
// Course: Digital Verification using SV & UVM
//
// Description: FIFO Design 
// 
////////////////////////////////////////////////////////////////////////////////
module FIFO(fifo_if.DUT fifoif);
 
localparam max_fifo_addr = $clog2(fifoif.FIFO_DEPTH);

reg [fifoif.FIFO_WIDTH-1:0] mem [fifoif.FIFO_DEPTH-1:0];

reg [max_fifo_addr-1:0] wr_ptr, rd_ptr;
reg [max_fifo_addr:0] count;

always @(posedge fifoif.clk or negedge fifoif.rst_n) begin
	if (!fifoif.rst_n) begin
		wr_ptr <= 0;
		// BUG DETECTED : wr_ack should be Low when reset is asserted .
		fifoif.wr_ack <= 0 ;
		// BUG DETECTED : overflow should be Low when reset is asserted .
		fifoif.overflow <= 0 ;

	end
	// Writing Block 
	else if (fifoif.wr_en && count < fifoif.FIFO_DEPTH ) begin
		mem[wr_ptr] <= fifoif.data_in;
		fifoif.wr_ack <= 1;
		wr_ptr <= wr_ptr + 1;
	end
	else begin 
		fifoif.wr_ack <= 0; 
		if (fifoif.full & fifoif.wr_en)
			fifoif.overflow <= 1;
		else
			fifoif.overflow <= 0;
	end
end


// Reading Block 
always @(posedge fifoif.clk or negedge fifoif.rst_n) begin
	if (!fifoif.rst_n) begin
		rd_ptr <= 0;
		// BUG DETECTED : Underflow should be Low when reset is asserted .
		fifoif.underflow <= 0 ;
	end
	else if (fifoif.rd_en && count != 0 ) begin
		fifoif.data_out <= mem[rd_ptr];
		rd_ptr <= rd_ptr + 1;
	end
	// BUG DETECTED : Underflow output should be Sequential .
	else begin 
		if (fifoif.empty & fifoif.rd_en)
			fifoif.underflow <= 1;
		else
			fifoif.underflow <= 0;
end
end

always @(posedge fifoif.clk or negedge fifoif.rst_n) begin
	if (!fifoif.rst_n) begin
		count <= 0;
	end
	else begin
		if	( ({fifoif.wr_en, fifoif.rd_en} == 2'b10) && !fifoif.full) 
			count <= count + 1;
		else if ( ({fifoif.wr_en, fifoif.rd_en} == 2'b01) && !fifoif.empty)
			count <= count - 1;
			// BUG DETECTED : Uncovered case when both wr_en and rd_en are high and FIFO if full , Reading process happens .
			else if ( ({fifoif.wr_en, fifoif.rd_en} == 2'b11) && fifoif.full)
			count <= count - 1;
			//BUG DETECTED : Uncovered case when both wr_en and rd_en are high and FIFO if empty , Writing process happens .
			else if ( ({fifoif.wr_en, fifoif.rd_en} == 2'b11) && fifoif.empty)
			count <= count + 1;

	end
end

assign fifoif.full = (count == fifoif.FIFO_DEPTH)? 1 : 0;
assign fifoif.empty = (count == 0)? 1 : 0;
//BUG DETECTED : almostfull is high when there is two spots empty , while it should be only one .
assign fifoif.almostfull = (count == fifoif.FIFO_DEPTH-1)? 1 : 0; 
assign fifoif.almostempty = (count == 1)? 1 : 0;
`ifdef SIM
//Assertions 

always_comb begin : RST_check
	if(!fifoif.rst_n) 
	rst_assetion : assert final ((!count)&&(!wr_ptr)&&(!rd_ptr)&&(!fifoif.wr_ack)&&(!fifoif.underflow)&&(!fifoif.overflow));
	rst_cover : cover final ((!count)&&(!wr_ptr)&&(!rd_ptr)&&(!fifoif.wr_ack)&&(!fifoif.underflow)&&(!fifoif.overflow));
end

always_comb begin : Full_check
	if((fifoif.rst_n)&&(count == fifoif.FIFO_DEPTH))
	full_assertion : assert final (fifoif.full);
	full_cover : cover final (fifoif.full);
end

always_comb begin : Almostfull_check
	if((fifoif.rst_n)&&(count == (fifoif.FIFO_DEPTH-1)))
	almostfull_assertion : assert final (fifoif.almostfull);
	almostfull_cover : cover final (fifoif.almostfull);	
end

always_comb begin : Empty_check
	if((fifoif.rst_n)&&(count == 0))
	empty_assertion : assert final (fifoif.empty);
	empty_cover : cover final (fifoif.empty);
end

always_comb begin :Almostempty_check
	if((fifoif.rst_n)&&(count == 1))
	almostempty_assertion : assert final (fifoif.almostempty);
	almostempty_cover : cover final (fifoif.almostempty);
end


property wr_ack_p ;
	@(posedge fifoif.clk) 
	disable iff (!fifoif.rst_n)
	(fifoif.wr_en && !fifoif.full) |=> (fifoif.wr_ack) ;
endproperty

property overflow_p ;
	@(posedge fifoif.clk) 
	disable iff (!fifoif.rst_n)
	(fifoif.wr_en && fifoif.full) |=> (fifoif.overflow) ;
endproperty

property underflow_p ;
	@(posedge fifoif.clk) 
	disable iff (!fifoif.rst_n)
	(fifoif.rd_en && fifoif.empty) |=> (fifoif.underflow) ;
endproperty

property wr_ptr_wraparound;
	@(posedge fifoif.clk) 
	disable iff (!fifoif.rst_n)
	(fifoif.wr_en && !fifoif.full) |=> ((wr_ptr == ($past(wr_ptr) + 1))|| ((wr_ptr==0)&&($past(wr_ptr)+1 == 8)));
endproperty

property rd_ptr_wraparound;
	@(posedge fifoif.clk) 
	disable iff (!fifoif.rst_n)
	(fifoif.rd_en && !fifoif.empty ) |=> ((rd_ptr == ( $past(rd_ptr)+1 ))|| ((rd_ptr==0)&&($past(rd_ptr)+1 == 8)));
endproperty

property counter_wraparound_incr;
	@(posedge fifoif.clk) 
	disable iff (!fifoif.rst_n)
	( ({fifoif.wr_en, fifoif.rd_en} == 2'b10) && !fifoif.full) || ( ({fifoif.wr_en, fifoif.rd_en} == 2'b11) && fifoif.empty)
	 |=> (count == $past(count)+1);
endproperty

property counter_wraparound_decr;
	@(posedge fifoif.clk) 
	disable iff (!fifoif.rst_n)
	( ({fifoif.wr_en, fifoif.rd_en} == 2'b01) && !fifoif.empty) || ( ({fifoif.wr_en, fifoif.rd_en} == 2'b11) && fifoif.full)
	 |=> (count == $past(count)-1);
endproperty

property wr_ptr_thershold ;
	@(posedge fifoif.clk) 
	disable iff (!fifoif.rst_n)
	(wr_ptr < fifoif.FIFO_DEPTH) ;
endproperty

property rd_ptr_thershold ;
	@(posedge fifoif.clk) 
	disable iff (!fifoif.rst_n)
	(rd_ptr < fifoif.FIFO_DEPTH) ;
endproperty

property count_thershold ;
	@(posedge fifoif.clk) 
	disable iff (!fifoif.rst_n)
	(count <= fifoif.FIFO_DEPTH) ;
endproperty



wr_ack_assertion : assert property (wr_ack_p) ;
wr_ack_cover : cover property (wr_ack_p) ;

overflow_assertion : assert property (overflow_p) ;
overflow_cover : cover property (overflow_p) ;

underflow_assertion : assert property (underflow_p) ;
underflow_cover : cover property (underflow_p) ;

wr_ptr_wraparound_assertion : assert property (wr_ptr_wraparound);
wr_ptr_wraparound_cover : cover property (wr_ptr_wraparound);

rd_ptr_wraparound_assertion : assert property (rd_ptr_wraparound);
rd_ptr_wraparound_cover : cover property (rd_ptr_wraparound);

counter_wraparound_incr_assertion : assert property (counter_wraparound_incr);
counter_wraparound_incr_cover : cover property (counter_wraparound_incr);

counter_wraparound_decr_assertion : assert property (counter_wraparound_decr);
counter_wraparound_decr_cover : cover property (counter_wraparound_decr);

wr_ptr_thershold_assertion : assert property (wr_ptr_thershold);
wr_ptr_thershold_cover : cover property (wr_ptr_thershold);

rd_ptr_thershold_assertion : assert property (rd_ptr_thershold);
rd_ptr_thershold_cover : cover property (rd_ptr_thershold);

count_thershold_assertion : assert property (count_thershold);
count_thershold_cover : cover property (count_thershold);

`endif 

endmodule