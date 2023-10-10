#pragma once

#ifdef _MSC_VER
#pragma warning(push)
#pragma warning(disable : 4267)
#else
#pragma GCC diagnostic ignored "-Wunused-parameter"
#pragma GCC diagnostic ignored "-Wmaybe-uninitialized"
#pragma GCC diagnostic ignored "-Wbool-compare"
#pragma GCC diagnostic ignored "-Wint-in-bool-context"
#pragma GCC diagnostic ignored "-Wshadow"
#pragma GCC diagnostic ignored "-Wtype-limits"
#endif

#include "ap_fixed/ap_fixed.h"

#ifdef _MSC_VER
#pragma warning(pop)
#else
#pragma GCC diagnostic warning "-Wtype-limits"
#pragma GCC diagnostic warning "-Wshadow"
#pragma GCC diagnostic warning "-Wint-in-bool-context"
#pragma GCC diagnostic warning "-Wbool-compare"
#pragma GCC diagnostic warning "-Wmaybe-uninitialized"
#pragma GCC diagnostic warning "-Wunused-parameter"
#endif

namespace model {

template <int IntegerDigits, int FractionalDigits = 0>
using FixedPoint = ap_ufixed<IntegerDigits + FractionalDigits, IntegerDigits,
        AP_RND_CONV, AP_SAT>;

template <int IntegerDigits, int FractionalDigits = 0>
using UnsignedFixedPoint = FixedPoint<IntegerDigits, FractionalDigits>;


template <int IntegerDigits, int FractionalDigits = 0>
using SignedFixedPoint = ap_fixed<IntegerDigits + FractionalDigits,
        IntegerDigits, AP_RND_CONV, AP_SAT>;

template <typename T, typename = void>
struct IsFixedPoint : std::false_type
{};

template <typename T>
struct IsFixedPoint<T,
        std::void_t<decltype(std::declval<T>().V), decltype(T::width),
                decltype(T::iwidth), decltype(T::qmode), decltype(T::omode)>>
    : std::true_type
{};

}  // namespace model
