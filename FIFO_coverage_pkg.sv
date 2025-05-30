package FIFO_coverage_pkg ;
import FIFO_transaction_pkg ::*;

  class FIFO_coverage ;
    FIFO_transaction  F_cvg_txn ;

  covergroup fifo_cvr_gp ;

    wr_en_cp: coverpoint F_cvg_txn.wr_en ;
    rd_en_cp: coverpoint F_cvg_txn.rd_en ;
    full_cp: coverpoint F_cvg_txn.full ;
    almostfull_cp: coverpoint F_cvg_txn.almostfull ; 
    empty_cp: coverpoint F_cvg_txn.empty ;
    almostempty_cp: coverpoint F_cvg_txn.almostempty ; 
    overflow_cp: coverpoint F_cvg_txn.overflow ;
    underflow_cp: coverpoint F_cvg_txn.underflow ; 
    wr_ack_cp: coverpoint F_cvg_txn.wr_ack  ;

    cross_wr_rd_full:         cross wr_en_cp, rd_en_cp, full_cp;
    cross_wr_rd_almostfull:   cross wr_en_cp, rd_en_cp, almostfull_cp;
    cross_wr_rd_empty:        cross wr_en_cp, rd_en_cp, empty_cp;
    cross_wr_rd_almostempty:  cross wr_en_cp, rd_en_cp, almostempty_cp;
    cross_wr_rd_overflow:     cross wr_en_cp, rd_en_cp, overflow_cp{
      ignore_bins wr0_rd0_overflow1 = binsof(wr_en_cp)intersect{0} && binsof(rd_en_cp)intersect{0} && binsof(overflow_cp)intersect{1};
      ignore_bins wr0_rd1_overflow1 = binsof(wr_en_cp)intersect{0} && binsof(rd_en_cp)intersect{1} && binsof(overflow_cp)intersect{1};
    }
    cross_wr_rd_underflow:    cross wr_en_cp, rd_en_cp, underflow_cp{
      ignore_bins wr0_rd0_underflow1 = binsof(wr_en_cp)intersect{0} && binsof(rd_en_cp)intersect{0} && binsof(underflow_cp)intersect{1};
      ignore_bins wr1_rd0_underflow1 = binsof(wr_en_cp)intersect{1} && binsof(rd_en_cp)intersect{0} && binsof(underflow_cp)intersect{1};
    }

    cross_wr_rd_wr_ack:       cross wr_en_cp, rd_en_cp, wr_ack_cp{
      ignore_bins wr0_rd1_ack_1 = binsof(wr_en_cp)intersect{0} && binsof(rd_en_cp)intersect{1} && binsof(wr_ack_cp)intersect{1};
      ignore_bins wr0_rd0_ack_1 = binsof(wr_en_cp)intersect{0} && binsof(rd_en_cp)intersect{0} && binsof(wr_ack_cp)intersect{1};
    }
        
  endgroup

  function new();
    fifo_cvr_gp = new();
  endfunction

  function void sample_data (input FIFO_transaction F_txn);
    F_cvg_txn = F_txn ;
    fifo_cvr_gp.sample();
  endfunction

  endclass
endpackage