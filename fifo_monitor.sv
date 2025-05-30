import FIFO_transaction_pkg ::*;
import FIFO_scoreboard_pkg ::*;
import FIFO_coverage_pkg ::*;
import shared_pkg ::*;

module fifo_monitor (fifo_if.MONITOR fifoif);
FIFO_transaction FIFO_mon_txn  =new();
FIFO_scoreboard FIFO_mon_sb =new();
FIFO_coverage FIFO_mon_cov = new();

  initial begin

    forever begin
      @(negedge fifoif.clk);
      assert(FIFO_mon_txn.randomize());
      FIFO_mon_txn.rst_n       = fifoif.rst_n;
      FIFO_mon_txn.wr_en       = fifoif.wr_en;
      FIFO_mon_txn.rd_en       = fifoif.rd_en;
      FIFO_mon_txn.data_in     = fifoif.data_in;
      FIFO_mon_txn.data_out    = fifoif.data_out;
      FIFO_mon_txn.wr_ack      = fifoif.wr_ack;
      FIFO_mon_txn.overflow    = fifoif.overflow;
      FIFO_mon_txn.full        = fifoif.full;
      FIFO_mon_txn.empty       = fifoif.empty;
      FIFO_mon_txn.almostfull  = fifoif.almostfull;
      FIFO_mon_txn.almostempty = fifoif.almostempty;
      FIFO_mon_txn.underflow   = fifoif.underflow;

      fork
        begin
          FIFO_mon_cov.sample_data(FIFO_mon_txn);
        end

        begin
          FIFO_mon_sb.check_data(FIFO_mon_txn);
        end
      join
      if(test_finished) begin
        $display("Simulation Stopped : Error count = %0d , Correct count = %0d",error_count,correct_count);
        $stop ;      
      end
      
    end
  end
  


endmodule