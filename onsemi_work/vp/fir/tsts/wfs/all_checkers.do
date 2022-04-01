onerror resume
wave tags F0
wave update off
wave add @tb_sb@1.checker_fir_out -tag F0 -radix string -expand -subitemconfig { @tb_sb@1.checker_fir_out.data {-expand -radix string -select} @tb_sb@1.checker_fir_out.data.match {-radix hexadecimal -select} @tb_sb@1.checker_fir_out.data.expected_re {-radix hexadecimal -select} @tb_sb@1.checker_fir_out.data.expected_im {-radix hexadecimal -select} @tb_sb@1.checker_fir_out.data.observed_re {-radix hexadecimal -select} @tb_sb@1.checker_fir_out.data.observed_im {-radix hexadecimal -select} {@tb_sb@1.checker_fir_out.data.observed_im[11]} {-radix hexadecimal} {@tb_sb@1.checker_fir_out.data.observed_im[10]} {-radix hexadecimal} {@tb_sb@1.checker_fir_out.data.observed_im[9]} {-radix hexadecimal} {@tb_sb@1.checker_fir_out.data.observed_im[8]} {-radix hexadecimal} {@tb_sb@1.checker_fir_out.data.observed_im[7]} {-radix hexadecimal} {@tb_sb@1.checker_fir_out.data.observed_im[6]} {-radix hexadecimal} {@tb_sb@1.checker_fir_out.data.observed_im[5]} {-radix hexadecimal} {@tb_sb@1.checker_fir_out.data.observed_im[4]} {-radix hexadecimal} {@tb_sb@1.checker_fir_out.data.observed_im[3]} {-radix hexadecimal} {@tb_sb@1.checker_fir_out.data.observed_im[2]} {-radix hexadecimal} {@tb_sb@1.checker_fir_out.data.observed_im[1]} {-radix hexadecimal} {@tb_sb@1.checker_fir_out.data.observed_im[0]} {-radix hexadecimal} @tb_sb@1.checker_fir_out.error_count {-radix hexadecimal -select} } -select
wave update on
wave top 0
wave zoom range 0 2200000
wave filter settings -pattern * -leaf_name_only 1 -history {*} -signal_type 255 
