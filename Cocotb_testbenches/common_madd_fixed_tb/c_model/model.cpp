#include "FixedPoint.hh"
#include <iostream>


extern "C"
void get_madd(float arr_in[], int arr_out[]){
    #ifdef A_SIGNED
        model::SignedFixedPoint<DAI, DAF> a{0};
        std::cout << "A_SIGNED" << std::endl;
    #else
        model::UnsignedFixedPoint<DAI, DAF> a{0};
        std::cout << "A_UNSIGNED" << std::endl;
    #endif
    #ifdef B_SIGNED
        model::SignedFixedPoint<DBI, DBF> b{0};
        std::cout << "B_SIGNED" << std::endl;
    #else
        model::UnsignedFixedPoint<DBI, DBF> b{0};
        std::cout << "B_UNSIGNED" << std::endl;
    #endif
    #ifdef C_SIGNED
        model::SignedFixedPoint<DCI, DCF> c{0};
        std::cout << "C_SIGNED" << std::endl;
    #else
        model::UnsignedFixedPoint<DCI, DCF> c{0};
        std::cout << "C_UNSIGNED" << std::endl;
    #endif
    #ifdef OUT_SIGNED
        model::SignedFixedPoint<DOUTI, DOUTF> madd{0};
        std::cout << "OUT_SIGNED" << std::endl;
    #else
        model::UnsignedFixedPoint<DOUTI, DOUTF> madd{0};
        std::cout << "OUT_UNSIGNED" << std::endl;
    #endif
    a = arr_in[0];
    b = arr_in[1];
    c = arr_in[2];
    madd = a*b+c;
    arr_out[0] = a.V;
    arr_out[1] = b.V;
    arr_out[2] = c.V;
    arr_out[3] = madd.V;
    std::cout << "A float: " << arr_in[0] << std::endl;
    std::cout << "B float: " << arr_in[1] << std::endl;
    std::cout << "C float: " << arr_in[2] << std::endl;
    std::cout << "A float in Xilinx format: " << a << std::endl;
    std::cout << "B float in Xilinx format: " << b << std::endl;
    std::cout << "C float in Xilinx format: " << c << std::endl;
    std::cout << "OUT float in Xilinx format: " << madd << std::endl;
    std::cout << "A int in Xilinx format: " << arr_out[0] << std::endl;
    std::cout << "B int in Xilinx format: " << arr_out[1] << std::endl;
    std::cout << "C int in Xilinx format: " << arr_out[2] << std::endl;
    std::cout << "OUT int in Xilinx format: " << arr_out[3] << std::endl;
}