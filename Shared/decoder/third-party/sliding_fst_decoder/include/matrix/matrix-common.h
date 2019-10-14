// matrix/matrix-common.h

// Copyright 2009-2011  Microsoft Corporation

// See ../../COPYING for clarification regarding multiple authors
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at

//  http://www.apache.org/licenses/LICENSE-2.0

// THIS CODE IS PROVIDED *AS IS* BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY
// KIND, EITHER EXPRESS OR IMPLIED, INCLUDING WITHOUT LIMITATION ANY IMPLIED
// WARRANTIES OR CONDITIONS OF TITLE, FITNESS FOR A PARTICULAR PURPOSE,
// MERCHANTABLITY OR NON-INFRINGEMENT.
// See the Apache 2 License for the specific language governing permissions and
// limitations under the License.
#ifndef KALDI_MATRIX_MATRIX_COMMON_H_
#define KALDI_MATRIX_MATRIX_COMMON_H_

// This file contains some #includes, forward declarations
// and typedefs that are needed by all the main header
// files in this directory.

#include "base/kaldi-common.h"
#include "matrix/kaldi-blas.h"

namespace kaldi {

typedef enum {
  kTrans    = 1,//CblasTrans
  kNoTrans = 0//CblasNoTrans
} MatrixTransposeType;

typedef enum {
  kSetZero,
  kUndefined,
  kCopyData
} MatrixResizeType;


typedef enum {
  kDefaultStride,
  kStrideEqualNumCols,
} MatrixStrideType;

typedef enum {
  kTakeLower,
  kTakeUpper,
  kTakeMean,
  kTakeMeanAndCheck
} SpCopyType;

template<typename Real> class VectorBase;
template<typename Real> class Vector;
template<typename Real> class SubVector;
template<typename Real> class MatrixBase;
template<typename Real> class SubMatrix;
template<typename Real> class Matrix;
template<typename Real> class SpMatrix;
template<typename Real> class TpMatrix;
template<typename Real> class PackedMatrix;
template<typename Real> class SparseMatrix;

// these are classes that won't be defined in this
// directory; they're mostly needed for friend declarations.
template<typename Real> class CuMatrixBase;
template<typename Real> class CuSubMatrix;
template<typename Real> class CuMatrix;
template<typename Real> class CuVectorBase;
template<typename Real> class CuSubVector;
template<typename Real> class CuVector;
template<typename Real> class CuPackedMatrix;
template<typename Real> class CuSpMatrix;
template<typename Real> class CuTpMatrix;
template<typename Real> class CuSparseMatrix;

class CompressedMatrix;
class GeneralMatrix;

/// This class provides a way for switching between double and float types.
template<typename T> class OtherReal { };  // useful in reading+writing routines
                                           // to switch double and float.
/// A specialized class for switching from float to double.
template<> class OtherReal<float> {
 public:
  typedef double Real;
};
/// A specialized class for switching from double to float.
template<> class OtherReal<double> {
 public:
  typedef float Real;
};


typedef int32 MatrixIndexT;
typedef int32 SignedMatrixIndexT;
typedef uint32 UnsignedMatrixIndexT;

// If you want to use size_t for the index type, do as follows instead:
//typedef size_t MatrixIndexT;
//typedef ssize_t SignedMatrixIndexT;
//typedef size_t UnsignedMatrixIndexT;



/// This is not really a wrapper for CBLAS as CBLAS does not have this; in future we could
/// extend this somehow.
inline void mul_elements(
    const MatrixIndexT dim,
    const double *a,
    double *b) { // does b *= a, elementwise.
  double c1, c2, c3, c4;
  MatrixIndexT i;
  for (i = 0; i + 4 <= dim; i += 4) {
    c1 = a[i] * b[i];
    c2 = a[i+1] * b[i+1];
    c3 = a[i+2] * b[i+2];
    c4 = a[i+3] * b[i+3];
    b[i] = c1;
    b[i+1] = c2;
    b[i+2] = c3;
    b[i+3] = c4;
  }
  for (; i < dim; i++)
    b[i] *= a[i];
}

inline void mul_elements(
    const MatrixIndexT dim,
    const float *a,
    float *b) { // does b *= a, elementwise.
  float c1, c2, c3, c4;
  MatrixIndexT i;
  for (i = 0; i + 4 <= dim; i += 4) {
    c1 = a[i] * b[i];
    c2 = a[i+1] * b[i+1];
    c3 = a[i+2] * b[i+2];
    c4 = a[i+3] * b[i+3];
    b[i] = c1;
    b[i+1] = c2;
    b[i+2] = c3;
    b[i+3] = c4;
  }
  for (; i < dim; i++)
    b[i] *= a[i];
}
}
#endif  // KALDI_MATRIX_MATRIX_COMMON_H_
