package artec_dma_pkg;

// ******************************************************* //
// Memory Organization
// ******************************************************* //

//Overall size = 0x47E000 + 0x47E000 + 0x23F000 + 0x80000 + 0x200000 + 0x1000 = 0xDBC000
//Overall size = 0xD77000 + 0xD77000 + 0xD77000 + 0xD77000 + 0xD77000 + 0x1000 = 0x4354000
//Overall size = 0xDB0000 + 0xDB0000 + 0xDB0000 + 0xDB0000 + 0xDB0000 + 0x1000 = 0x4471000

parameter PKG_APB_ID        = 32'hA314_0001                        ;
parameter PKG_VERSION       = 32'h0000_0002                        ;
parameter PKG_FB_NUM        = 32'h0000_0008                        ;
parameter PKG_CH_NUM        = 32'h0000_0006                        ;
parameter PKG_CH_NUM_L      = $clog2(PKG_CH_NUM)                   ;
parameter PKG_HEADER_SIZE   = 32'h0000_1000                        ;
parameter PKG_MEMORY_SIZE_0 = 32'h00DB_0000                        ;
parameter PKG_MEMORY_SIZE_1 = 32'h00DB_0000                        ;
parameter PKG_MEMORY_SIZE_2 = 32'h00DB_0000                        ;
parameter PKG_MEMORY_SIZE_3 = 32'h00DB_0000                        ;
parameter PKG_MEMORY_SIZE_4 = 32'h00DB_0000                        ;
parameter PKG_MEMORY_SIZE_5 = 32'h00DB_0000                        ;
parameter PKG_BPE_0  		= 32'h0000_0002                        ;
parameter PKG_BPE_1  		= 32'h0000_0002                        ;
parameter PKG_BPE_2  		= 32'h0000_0002                        ;
parameter PKG_BPE_3  		= 32'h0000_0002                        ;
parameter PKG_BPE_4  		= 32'h0000_0002                        ;
parameter PKG_BPE_5  		= 32'h0000_0002                        ;
parameter PKG_TYPE_0        = 32'h20_30_52_4C                      ;
parameter PKG_TYPE_1        = 32'h20_30_52_54                      ;
parameter PKG_TYPE_2        = 32'h20_31_52_4C                      ;
parameter PKG_TYPE_3        = 32'h20_31_52_54                      ;
parameter PKG_TYPE_4        = 32'h20_32_52_4C                      ;
parameter PKG_TYPE_5        = 32'h20_32_52_54                      ;
parameter PKG_OFFSET_ZERO   = 32'h0000_0000                        ;
parameter PKG_OFFSET_ONE    = PKG_MEMORY_SIZE_0 + PKG_OFFSET_ZERO  ;
parameter PKG_OFFSET_TWO    = PKG_MEMORY_SIZE_1 + PKG_OFFSET_ONE   ;
parameter PKG_OFFSET_THREE  = PKG_MEMORY_SIZE_2 + PKG_OFFSET_TWO   ;
parameter PKG_OFFSET_FOUR   = PKG_MEMORY_SIZE_3 + PKG_OFFSET_THREE ;
parameter PKG_OFFSET_FIVE   = PKG_MEMORY_SIZE_4 + PKG_OFFSET_FOUR  ;
parameter PKG_OFFSET_HEADER = PKG_MEMORY_SIZE_5 + PKG_OFFSET_FIVE  ;

parameter PKG_AXI_DATA_WIDTH = 128;
parameter PKG_ADDRESS_SHIFT = $clog2((PKG_AXI_DATA_WIDTH/8)-1);

parameter logic [PKG_CH_NUM-1:0][31:0] PKG_CH_OFFSET         = {PKG_OFFSET_FIVE,PKG_OFFSET_FOUR,PKG_OFFSET_THREE,PKG_OFFSET_TWO,PKG_OFFSET_ONE,PKG_OFFSET_ZERO};
parameter logic [PKG_CH_NUM-1:0][31:0] PKG_CH_SIZE           = {PKG_MEMORY_SIZE_5,PKG_MEMORY_SIZE_4,PKG_MEMORY_SIZE_3,PKG_MEMORY_SIZE_2,PKG_MEMORY_SIZE_1,PKG_MEMORY_SIZE_0};
parameter logic [PKG_CH_NUM-1:0][31:0] PKG_CH_INPUT_WIDTH    = {32'd64,32'd64,32'd64,32'd64,32'd64,32'd64}                                            ;
parameter logic [PKG_CH_NUM-1:0][31:0] PKG_CH_BUFFER_DEPTH   = {32'd4096,32'd4096,32'd4096,32'd4096,32'd4096,32'd4096}                                ;
parameter logic [PKG_CH_NUM-1:0][31:0] PKG_ARB_PRIORITY_TRIG = {32'd16,32'd16,32'd16,32'd16,32'd16,32'd16}                                            ;
parameter logic [PKG_CH_NUM-1:0][31:0] PKG_CH_PACKET_SIZE    = {32'd64,32'd64,32'd64,32'd64,32'd64,32'd64}                                            ;

parameter PKG_REQ_WIDTH = $clog2(PKG_CH_BUFFER_DEPTH[0]);

parameter PKG_ARB_BUFFER_DEPTH  = 512;
parameter PKG_ARB_LAST_CNT_TRIG = 16 ;

parameter PKG_HEADER_ACTUAL_SIZE = 32;

// ******************************************************* //
// Class Counter
// ******************************************************* //

class cnt_cl #(parameter logic [63:0] MAX_VALUE = 255);
	
	typedef struct packed {
		logic                         incr;
		logic                         last;
		logic                         clr ;
		logic [  $clog2(MAX_VALUE):0] next;
		logic [$clog2(MAX_VALUE)-1:0] cur ;
	} cnt_t;
	
endclass

`define cnt_typedef(MAX_VALUE) \
	typedef struct packed { \
		logic                         incr; \
		logic                         last; \
		logic                         clr ; \
		logic [  $clog2(MAX_VALUE):0] next; \
		logic [$clog2(MAX_VALUE)-1:0] cur ; \
	} cnt_t;

// ******************************************************* //
// Control types
// ******************************************************* //

typedef struct packed {
	logic [31:0] channel_size;
	logic [31:0] offset;
	logic        enable;
} settings_channel_t;

typedef struct packed {
	logic [PKG_FB_NUM-1:0][31:0] framebuffer_addr;
	logic [          31:0]       status_addr     ;
	logic                        clear           ;
	logic                        stop            ;
	logic                        start           ;
} settings_common_t;

typedef struct packed {
	settings_channel_t [PKG_CH_NUM-1:0] channel;
	settings_common_t                   common ;
} settings_t;

typedef struct packed {
	logic dfifo_full;
	logic cfifo_full;
} fifo_flags_t;

typedef struct packed {
	logic                                                 stop;
	logic        [PKG_FB_NUM-1:0]                         frame_status;
	fifo_flags_t [PKG_CH_NUM-1:0]                         fifo_flags  ;
	logic        [PKG_CH_NUM-1:0][$clog2(PKG_FB_NUM)-1:0] frame_number;
} status_t;

// ******************************************************* //
// Registers 
// ******************************************************* //

typedef struct packed {
	fifo_flags_t [PKG_CH_NUM-1:0] fifo_flags;
} reg_fifo_overflow_t;

typedef struct packed {
	logic finish;
	logic stsclr;
	logic clear;
	logic enable;
} reg_control_t;

// ******************************************************* //
// Common types
// ******************************************************* //

// AXIS Types

typedef struct packed {
	logic [ 3:0] f_cache; // Should be 0
	logic [ 3:0] f_xuser; // Should be 0
	logic [ 3:0] f_rsrv ; // Should be 0
	logic [ 3:0] f_tag  ; // Should be 0
	logic [31:0] f_saddr; // Start Address
	logic        f_drr  ; // Should be 0
	logic        f_eof  ; // Should be 0
	logic [ 5:0] f_dsa  ; // Should be 0
	logic        f_type ; // INCR or FIXED (Should be 0)
	logic [22:0] f_btt  ; // Bytes to Transfer
} axis_cmd_t;

typedef logic [PKG_AXI_DATA_WIDTH-1:0] axis_data_t;

// Info type

typedef struct packed {
	logic       eof ;
	logic [2:0] fnum;
	logic       sof ;
} info_t;

// Converter output

typedef struct packed {
	logic [PKG_AXI_DATA_WIDTH-1:0] data;
	info_t                         info;
} cnv_o_t;

// Channel output

typedef struct packed {
	logic [31:0] address ;
	logic [ 7:0] data_num;
	info_t       info    ;
} ch_task_o_t;

typedef axis_data_t ch_data_o_t;

// Arbiter output

typedef struct packed {
	logic [PKG_CH_NUM_L-1:0] idx  ;
	ch_task_o_t              taskf;
} arb_task_o_t;

typedef ch_data_o_t arb_data_o_t;

// Sync output

typedef struct packed {
	logic                    sync ;
	logic [PKG_CH_NUM_L-1:0] idx  ;
	ch_task_o_t              taskf;
} sync_task_o_t;

typedef arb_data_o_t sync_data_o_t;

// ******************************************************* //
// Statistics types
// ******************************************************* //

typedef struct packed {
	logic [143:0] agm_data        ;
	logic [ 47:0] time_sample     ;
	logic [223:0] integral        ;
	logic         proximity_sensor;
	logic [  1:0] compression_type;
	logic [127:0] flash_info      ;
} stats_outside_t;

endpackage
