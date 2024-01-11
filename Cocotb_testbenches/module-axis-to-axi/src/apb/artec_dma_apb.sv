`timescale 1ns/1ps

module artec_dma_apb #(parameter APB_ID = 32'hA3D_0000)(
	input                            clk       ,
	input                            rstn      ,
	artec_apb_if.slave               apb       ,
	output artec_dma_pkg::settings_t settings_o,
	input  artec_dma_pkg::status_t   status_i
);

import artec_dma_pkg::*;

assign apb.s.pready = 1'b1;

logic write;

reg [PKG_FB_NUM-1:0][31:0] frame_ptr_r          ;
reg [          31:0]       frame_status_ptr_r   ;
reg [PKG_CH_NUM-1:0][31:0] offset_r             ;
reg [PKG_CH_NUM-1:0][31:0] channel_size_r       ;
reg [PKG_CH_NUM-1:0]       mask_enable_r        ;
reg                        start_r              ;
reg                        fifo_overflow_reset_r;

reg_fifo_overflow_t fifo_overflow_r;
reg_control_t       control_r      ;

assign apb.s.prdata = (apb.m.psel) ? (
									 (apb.m.paddr[7:2] ==  0)  ? {APB_ID                           } :
									 (apb.m.paddr[7:2] ==  1)  ? {PKG_VERSION                      } :
									 (apb.m.paddr[7:2] ==  2)  ? {PKG_CH_NUM                       } :
									 (apb.m.paddr[7:2] ==  3)  ? {PKG_HEADER_SIZE                  } :
									 (apb.m.paddr[7:2] ==  5)  ? {channel_size_r[0]                } :
									 (apb.m.paddr[7:2] ==  6)  ? {offset_r[0]                      } :
									 (apb.m.paddr[7:2] ==  7)  ? {PKG_BPE_0                        } :
									 (apb.m.paddr[7:2] ==  8)  ? {PKG_TYPE_0                       } :
									 (apb.m.paddr[7:2] ==  9)  ? {channel_size_r[1]                } :
									 (apb.m.paddr[7:2] == 10)  ? {offset_r[1]                      } :
									 (apb.m.paddr[7:2] == 11)  ? {PKG_BPE_1                        } :
									 (apb.m.paddr[7:2] == 12)  ? {PKG_TYPE_1                       } :
									 (apb.m.paddr[7:2] == 13)  ? {channel_size_r[2]                } :
									 (apb.m.paddr[7:2] == 14)  ? {offset_r[2]                      } :
									 (apb.m.paddr[7:2] == 15)  ? {PKG_BPE_2                        } :
									 (apb.m.paddr[7:2] == 16)  ? {PKG_TYPE_2                       } :
									 (apb.m.paddr[7:2] == 17)  ? {channel_size_r[3]                } :
									 (apb.m.paddr[7:2] == 18)  ? {offset_r[3]                      } :
									 (apb.m.paddr[7:2] == 19)  ? {PKG_BPE_3                        } :
									 (apb.m.paddr[7:2] == 20)  ? {PKG_TYPE_3                       } :
									 (apb.m.paddr[7:2] == 21)  ? {channel_size_r[4]                } :
									 (apb.m.paddr[7:2] == 22)  ? {offset_r[4]                      } :
									 (apb.m.paddr[7:2] == 23)  ? {PKG_BPE_4                        } :
									 (apb.m.paddr[7:2] == 24)  ? {PKG_TYPE_4                       } :
									 (apb.m.paddr[7:2] == 25)  ? {channel_size_r[5]                } :
									 (apb.m.paddr[7:2] == 26)  ? {offset_r[5]                      } :
									 (apb.m.paddr[7:2] == 27)  ? {PKG_BPE_5                        } :
									 (apb.m.paddr[7:2] == 28)  ? {PKG_TYPE_5                       } :

									 (apb.m.paddr[7:2] == 48)  ? {frame_ptr_r[0]                   } :
									 (apb.m.paddr[7:2] == 49)  ? {frame_ptr_r[1]                   } :
									 (apb.m.paddr[7:2] == 50)  ? {frame_ptr_r[2]                   } :
									 (apb.m.paddr[7:2] == 51)  ? {frame_ptr_r[3]                   } :
									 (apb.m.paddr[7:2] == 52)  ? {frame_ptr_r[4]                   } :
									 (apb.m.paddr[7:2] == 53)  ? {frame_ptr_r[5]                   } :
									 (apb.m.paddr[7:2] == 54)  ? {frame_ptr_r[6]                   } :
									 (apb.m.paddr[7:2] == 55)  ? {frame_ptr_r[7]                   } :
									 (apb.m.paddr[7:2] == 56)  ? {frame_status_ptr_r               } :
									 (apb.m.paddr[7:2] == 57)  ? {32'b0 | mask_enable_r            } :
									 (apb.m.paddr[7:2] == 58)  ? {32'b0 | control_r                } :
									 (apb.m.paddr[7:2] == 59)  ? {32'b0 | status_i.frame_status    } :
									 (apb.m.paddr[7:2] == 60)  ? {32'b0 | fifo_overflow_r          } :
									 (apb.m.paddr[7:2] == 61)  ? {32'b0 | fifo_overflow_reset_r    } :
									 (apb.m.paddr[7:2] == 62)  ? {32'b0 | status_i.frame_number    } : 32'b0
									 ) : 32'b0;

// ******************************************************* //
// Write 
// ******************************************************* //

assign write = apb.m.psel & apb.m.penable & apb.m.pwrite;

// ******************************************************* //
// Register 
// ******************************************************* //

for (genvar i = 0; i < PKG_CH_NUM; i++) begin
	always_ff @(posedge clk `async_rstn(rstn)) begin : proc_offset_r
	    if(~rstn) begin
	        offset_r[i] <= PKG_CH_OFFSET[i];
	    end else if (settings_o.common.clear) begin
	    	offset_r[i] <= PKG_CH_OFFSET[i];
	    end else begin
	        offset_r[i] <= write && apb.m.paddr[7:2]==(6+i*4) ? apb.m.pwdata : offset_r[i];
	    end
	end
end

for (genvar i = 0; i < PKG_CH_NUM; i++) begin



	always_ff @(posedge clk `async_rstn(rstn)) begin : proc_channel_size_r
	    if(~rstn) begin
	        channel_size_r[i] <= PKG_CH_SIZE[i];
	    end else if (settings_o.common.clear) begin
	    	channel_size_r[i] <= PKG_CH_SIZE[i];
	    end else begin
	        channel_size_r[i] <= write && apb.m.paddr[7:2]==(5+i*4) ? apb.m.pwdata : channel_size_r[i];
	    end
	end
end

for (genvar i = 0; i < PKG_FB_NUM; i++) begin
	always_ff @(posedge clk `async_rstn(rstn)) begin : proc_frame_ptr_r
	    if(~rstn) begin
	        frame_ptr_r[i] <= 0;
	    end else if (settings_o.common.clear) begin
	    	frame_ptr_r[i] <= 0;
	    end else begin
	        frame_ptr_r[i] <= write && apb.m.paddr[7:2]==(48+i) ? apb.m.pwdata : frame_ptr_r[i];
	    end
	end
end

always_ff @(posedge clk `async_rstn(rstn)) begin : proc_frame_status_ptr_r
    if(~rstn) begin
        frame_status_ptr_r <= 0;
    end else if (settings_o.common.clear) begin
    	frame_status_ptr_r <= 0;
    end else begin
        frame_status_ptr_r <= write && apb.m.paddr[7:2]==56 ? apb.m.pwdata : frame_status_ptr_r;
    end
end

always_ff @(posedge clk `async_rstn(rstn)) begin : proc_mask_enable_r
    if(~rstn) begin
        mask_enable_r <= 0;
    end else if (settings_o.common.clear) begin
    	mask_enable_r <= 0;
    end else begin
        mask_enable_r <= write && apb.m.paddr[7:2]==57 ? apb.m.pwdata : mask_enable_r;
    end
end

always_ff @(posedge clk `async_rstn(rstn)) begin : proc_control_r
    if(~rstn) begin
        control_r <= 0;
    end else begin

   		control_r.enable  <= write && apb.m.paddr[7:2]==58       ? apb.m.pwdata[0] : control_r.enable;
       	control_r.clear   <= control_r.clear && control_r.finish ?               0 : 
       						 write && apb.m.paddr[7:2]==58       ? apb.m.pwdata[1] : control_r.clear;
       	control_r.stsclr  <= control_r.stsclr                    ?               0 : 
       					     write && apb.m.paddr[7:2]==58       ? apb.m.pwdata[2] : control_r.stsclr;
       	control_r.finish  <= status_i.stop;

    end
end

// ******************************************************* //
// Start/Stop 
// ******************************************************* //

logic enable_r;

always_ff @(posedge clk or negedge rstn) begin : proc_start_r
	if(~rstn) begin
		enable_r <= 0;
	end else if (settings_o.common.clear) begin
		enable_r <= 0;
	end else begin
		enable_r <= control_r.enable;
	end
end

assign start_w = control_r.enable && !enable_r;
assign stop_w  = !control_r.enable && enable_r;

// ******************************************************* //
// Fifo Overflow 
// ******************************************************* //

for (genvar i = 0; i < PKG_CH_NUM; i++) begin

	always_ff @(posedge clk `async_rstn(rstn)) begin : proc_fifo_overflow_r
	    if(~rstn) begin
	        fifo_overflow_r.fifo_flags[i] <= 0;
	    end else if (settings_o.common.clear) begin
	    	fifo_overflow_r.fifo_flags[i] <= 0;	
	    end else if (control_r.stsclr) begin
	    	fifo_overflow_r.fifo_flags[i] <= 0;
	    end else begin
	    	fifo_overflow_r.fifo_flags[i] <= fifo_overflow_r.fifo_flags[i] | status_i.fifo_flags[i];
	    end
	end
end

// ******************************************************* //
// Settings 
// ******************************************************* //

assign settings_o.common.start            = start_w;
assign settings_o.common.stop             = stop_w;
assign settings_o.common.framebuffer_addr = frame_ptr_r;
assign settings_o.common.status_addr      = frame_status_ptr_r;
assign settings_o.common.clear            = control_r.clear && control_r.finish;

for (genvar i = 0; i < PKG_CH_NUM; i++) begin

	assign settings_o.channel[i].channel_size = channel_size_r[i];
	assign settings_o.channel[i].enable = mask_enable_r[i];
	assign settings_o.channel[i].offset = offset_r[i];

end


endmodule
