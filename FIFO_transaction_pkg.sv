package FIFO_transaction_pkg ;

  class FIFO_transaction#(parameter FIFO_WIDTH = 16,
                          parameter FIFO_DEPTH = 8) ;
  
  rand bit rst_n, wr_en, rd_en; 
  rand logic [FIFO_WIDTH-1:0] data_in; 

  logic [FIFO_WIDTH-1:0] data_out;
  logic wr_ack, overflow;
  logic full, empty, almostfull, almostempty, underflow;

  int RD_EN_ON_DIST ;
  int WR_EN_ON_DIST ;

  function new(int rd_val = 30, int wr_val = 70);
    RD_EN_ON_DIST = rd_val;
    WR_EN_ON_DIST = wr_val;
  endfunction

  constraint rst_n_c { rst_n dist {0:/10 , 1:/90};}
  constraint wr_en_c { wr_en dist {0:/(100-WR_EN_ON_DIST) , 1:/WR_EN_ON_DIST};}
  constraint rd_en_c { rd_en dist {0:/(100-RD_EN_ON_DIST) , 1:/RD_EN_ON_DIST};}

  endclass //FIFO_transaction

  endpackage