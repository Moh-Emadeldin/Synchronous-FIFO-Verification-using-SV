interface fifo_if (clk);

  parameter FIFO_WIDTH = 16;
  parameter FIFO_DEPTH = 8;

  input bit clk ;
  bit   rst_n, wr_en, rd_en;
  logic [FIFO_WIDTH-1:0] data_in;
  logic [FIFO_WIDTH-1:0] data_out;
  logic wr_ack, overflow;
  logic full, empty, almostfull, almostempty, underflow;

  modport DUT (input clk, rst_n, data_in, wr_en, rd_en,
               output data_out, wr_ack, full, empty, almostempty, almostfull, overflow, underflow  );
  modport TEST (input clk, data_out, wr_ack, full, empty, almostempty, almostfull, overflow, underflow,
                output rst_n, data_in, wr_en, rd_en);
  modport MONITOR (input clk, rst_n, data_in, wr_en, rd_en, data_out, wr_ack, full, empty, almostempty, almostfull, overflow, underflow );


endinterface
