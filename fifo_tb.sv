import FIFO_transaction_pkg ::*;
import shared_pkg::*;
module fifo_tb (fifo_if.TEST fifoif);
  FIFO_transaction test_txn = new();
  initial begin
    $assertoff;
    fifoif.rst_n = 0 ;
    #2;
    $asserton;
    repeat(2) @(negedge fifoif.clk);
    repeat(2000) begin
    assert(test_txn.randomize());
    fifoif.rst_n = test_txn.rst_n ;
    fifoif.wr_en = test_txn.wr_en ;
    fifoif.rd_en = test_txn.rd_en ;
    fifoif.data_in = test_txn.data_in ;
    repeat(2) @(negedge fifoif.clk);
    end
    test_finished = 1 ;
  end
endmodule