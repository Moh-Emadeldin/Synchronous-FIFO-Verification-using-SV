package FIFO_scoreboard_pkg ;
import FIFO_transaction_pkg ::*;
import shared_pkg ::*;
parameter FIFO_WIDTH = 16;
parameter FIFO_DEPTH = 8;
  

  localparam max_fifo_addr = $clog2(FIFO_DEPTH);
	
	logic [FIFO_WIDTH-1:0] data_out_ref;
  logic [FIFO_WIDTH-1:0] Queue [$] ;
  logic full_ref , empty_ref ;
  logic [max_fifo_addr:0] count;

  
class FIFO_scoreboard ;

  task check_data (input FIFO_transaction F_chk_txn);
    Reference_model (F_chk_txn);
    if ((data_out_ref !== F_chk_txn.data_out)) begin
          error_count ++ ;
          $display("   [ERROR] Mismatch at time %0t:", $time);
          $display("  data_out     => Expected: %0h, Actual: %0h", data_out_ref,    F_chk_txn.data_out);
    end
    else begin 
      correct_count ++;
    end

  endtask

  function void Reference_model (input FIFO_transaction F_ref_txn);
			// Reset logic
			if (!F_ref_txn.rst_n) begin
				Queue <= {}; 
				count <= 0;
			end
			else begin
				// Write operation if not full
				if (F_ref_txn.wr_en && count <  FIFO_DEPTH) begin
					Queue.push_back(F_ref_txn.data_in);  
					count <= Queue.size();       
				end

				// Read operation if not empty
				if (F_ref_txn.rd_en && count != 0) begin
					data_out_ref <= Queue.pop_front();
					count <= Queue.size();          
				end
				
			end

			// Update reference flags
			full_ref = (count == FIFO_DEPTH);
			empty_ref = (count == 0);
		endfunction 

  endclass
endpackage