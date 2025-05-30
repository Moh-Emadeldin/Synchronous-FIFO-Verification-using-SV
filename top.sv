module top ;
  bit clk ;

  initial begin
    clk = 0 ;
    forever begin
      #1 clk = ~clk ;
    end
  end

  fifo_if fifoif (clk) ;
  FIFO DUT (fifoif);
  fifo_tb TEST (fifoif);
  fifo_monitor MON (fifoif);
  
endmodule