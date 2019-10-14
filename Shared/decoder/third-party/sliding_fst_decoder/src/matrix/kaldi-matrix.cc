// matrix/kaldi-matrix.cc

// Copyright 2009-2011   Lukas Burget;  Ondrej Glembek;  Go Vivace Inc.;
//                       Microsoft Corporation;  Saarland University;
//                       Yanmin Qian;  Petr Schwarz;  Jan Silovsky;
//                       Haihua Xu

// See ../../COPYING for clarification regarding multiple authors
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//  http://www.apache.org/licenses/LICENSE-2.0
//
// THIS CODE IS PROVIDED *AS IS* BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY
// KIND, EITHER EXPRESS OR IMPLIED, INCLUDING WITHOUT LIMITATION ANY IMPLIED
// WARRANTIES OR CONDITIONS OF TITLE, FITNESS FOR A PARTICULAR PURPOSE,
// MERCHANTABLITY OR NON-INFRINGEMENT.
// See the Apache 2 License for the specific language governing permissions and
// limitations under the License.

#include "matrix/kaldi-matrix.h"

namespace kaldi {
#ifdef CBLAS
template<>
template<>
void MatrixBase<float>::AddVecVec(const float alpha,
                                  const VectorBase<float> &a,
                                  const VectorBase<float> &rb) {
  KALDI_ASSERT(a.Dim() == num_rows_ && rb.Dim() == num_cols_);
  cblas_Xger(a.Dim(), rb.Dim(), alpha, a.Data(), 1, rb.Data(),
             1, data_, stride_);
}

template<typename Real>
template<typename OtherReal>
void MatrixBase<Real>::AddVecVec(const Real alpha,
                                 const VectorBase<OtherReal> &a,
                                 const VectorBase<OtherReal> &b) {
  KALDI_ASSERT(a.Dim() == num_rows_ && b.Dim() == num_cols_);
  if (num_rows_ * num_cols_ > 100) { // It's probably worth it to allocate
    // temporary vectors of the right type and use BLAS.
    Vector<Real> temp_a(a), temp_b(b);
    cblas_Xger(num_rows_, num_cols_, alpha, temp_a.Data(), 1,
               temp_b.Data(), 1, data_, stride_);
  } else {
    const OtherReal *a_data = a.Data(), *b_data = b.Data();
    Real *row_data = data_;
    for (MatrixIndexT i = 0; i < num_rows_; i++, row_data += stride_) {
      BaseFloat alpha_ai = alpha * a_data[i];
      for (MatrixIndexT j = 0; j < num_cols_; j++)
        row_data[j] += alpha_ai * b_data[j];
    }
  }
}
#endif

#ifdef CBLAS
template<>
template<>
void MatrixBase<double>::AddVecVec(const double alpha,
                                   const VectorBase<double> &a,
                                   const VectorBase<double> &rb) {
  KALDI_ASSERT(a.Dim() == num_rows_ && rb.Dim() == num_cols_);
  if (num_rows_ == 0) return;
  cblas_Xger(a.Dim(), rb.Dim(), alpha, a.Data(), 1, rb.Data(),
             1, data_, stride_);
}
#endif
#ifdef CBLAS
template<typename Real>
void MatrixBase<Real>::AddMatMat(const Real alpha,
                                  const MatrixBase<Real>& A,
                                  MatrixTransposeType transA,
                                  const MatrixBase<Real>& B,
                                  MatrixTransposeType transB,
                                  const Real beta) {
  KALDI_ASSERT((transA == kNoTrans && transB == kNoTrans && A.num_cols_ == B.num_rows_ && A.num_rows_ == num_rows_ && B.num_cols_ == num_cols_)
               || (transA == kTrans && transB == kNoTrans && A.num_rows_ == B.num_rows_ && A.num_cols_ == num_rows_ && B.num_cols_ == num_cols_)
               || (transA == kNoTrans && transB == kTrans && A.num_cols_ == B.num_cols_ && A.num_rows_ == num_rows_ && B.num_rows_ == num_cols_)
               || (transA == kTrans && transB == kTrans && A.num_rows_ == B.num_cols_ && A.num_cols_ == num_rows_ && B.num_rows_ == num_cols_));
  KALDI_ASSERT(&A !=  this && &B != this);
  if (num_rows_ == 0) return;
  cblas_Xgemm(alpha, transA, A.data_, A.num_rows_, A.num_cols_, A.stride_,
              transB, B.data_, B.stride_, beta, data_, num_rows_, num_cols_, stride_);

}
#endif
template<typename Real>
void MatrixBase<Real>::SetMatMatDivMat(const MatrixBase<Real>& A,
                                       const MatrixBase<Real>& B,
                                       const MatrixBase<Real>& C) {
  KALDI_ASSERT(A.NumRows() == B.NumRows() && A.NumCols() == B.NumCols());
  KALDI_ASSERT(A.NumRows() == C.NumRows() && A.NumCols() == C.NumCols());
  for (int32 r = 0; r < A.NumRows(); r++) { // each frame...
    for (int32 c = 0; c < A.NumCols(); c++) {
      BaseFloat i = C(r, c), o = B(r, c), od = A(r, c),
          id;
      if (i != 0.0) {
        id = od * (o / i); /// o / i is either zero or "scale".
      } else {
        id = od; /// Just imagine the scale was 1.0.  This is somehow true in
        /// expectation; anyway, this case should basically never happen so it doesn't
        /// really matter.
      }
      (*this)(r, c) = id;
    }
  }
}


template<typename Real>
void MatrixBase<Real>::CopyLowerToUpper() {
  KALDI_ASSERT(num_rows_ == num_cols_);
  Real *data = data_;
  MatrixIndexT num_rows = num_rows_, stride = stride_;
  for (int32 i = 0; i < num_rows; i++)
    for (int32 j = 0; j < i; j++)
      data[j * stride + i ] = data[i * stride + j];
}


template<typename Real>
void MatrixBase<Real>::CopyUpperToLower() {
  KALDI_ASSERT(num_rows_ == num_cols_);
  Real *data = data_;
  MatrixIndexT num_rows = num_rows_, stride = stride_;
  for (int32 i = 0; i < num_rows; i++)
    for (int32 j = 0; j < i; j++)
      data[i * stride + j] = data[j * stride + i];
}
#ifdef CBLAS
template<typename Real>
void MatrixBase<Real>::SymAddMat2(const Real alpha,
                                  const MatrixBase<Real> &A,
                                  MatrixTransposeType transA,
                                  Real beta) {
  KALDI_ASSERT(num_rows_ == num_cols_ &&
               ((transA == kNoTrans && A.num_rows_ == num_rows_) ||
                (transA == kTrans && A.num_cols_ == num_cols_)));
  KALDI_ASSERT(A.data_ != data_);
  if (num_rows_ == 0) return;

  /// When the matrix dimension(this->num_rows_) is not less than 56
  /// and the transpose type transA == kTrans, the cblas_Xsyrk(...)
  /// function will produce NaN in the output. This is a bug in the
  /// ATLAS library. To overcome this, the AddMatMat function, which calls
  /// cblas_Xgemm(...) rather than cblas_Xsyrk(...), is used in this special
  /// sitation.
  /// Wei Shi: Note this bug is observerd for single precision matrix
  /// on a 64-bit machine
#ifdef HAVE_ATLAS
  if (transA == kTrans && num_rows_ >= 56) {
    this->AddMatMat(alpha, A, kTrans, A, kNoTrans, beta);
    return;
  }
#endif // HAVE_ATLAS

  MatrixIndexT A_other_dim = (transA == kNoTrans ? A.num_cols_ : A.num_rows_);

  // This function call is hard-coded to update the lower triangle.
  cblas_Xsyrk(transA, num_rows_, A_other_dim, alpha, A.Data(),
              A.Stride(), beta, this->data_, this->stride_);
}


template<typename Real>
void MatrixBase<Real>::AddMat(const Real alpha, const MatrixBase<Real>& A,
                               MatrixTransposeType transA) {
  if (&A == this) {
    if (transA == kNoTrans) {
      Scale(alpha + 1.0);
    } else {
      KALDI_ASSERT(num_rows_ == num_cols_ && "AddMat: adding to self (transposed): not symmetric.");
      Real *data = data_;
      if (alpha == 1.0) {  // common case-- handle separately.
        for (MatrixIndexT row = 0; row < num_rows_; row++) {
          for (MatrixIndexT col = 0; col < row; col++) {
            Real *lower = data + (row * stride_) + col, *upper = data + (col
                                                                          * stride_) + row;
            Real sum = *lower + *upper;
            *lower = *upper = sum;
          }
          *(data + (row * stride_) + row) *= 2.0;  // diagonal.
        }
      } else {
        for (MatrixIndexT row = 0; row < num_rows_; row++) {
          for (MatrixIndexT col = 0; col < row; col++) {
            Real *lower = data + (row * stride_) + col, *upper = data + (col
                                                                          * stride_) + row;
            Real lower_tmp = *lower;
            *lower += alpha * *upper;
            *upper += alpha * lower_tmp;
          }
          *(data + (row * stride_) + row) *= (1.0 + alpha);  // diagonal.
        }
      }
    }
  } else {
    int aStride = (int) A.stride_, stride = stride_;
    Real *adata = A.data_, *data = data_;
    if (transA == kNoTrans) {
      KALDI_ASSERT(A.num_rows_ == num_rows_ && A.num_cols_ == num_cols_);
      if (num_rows_ == 0) return;
      for (MatrixIndexT row = 0; row < num_rows_; row++, adata += aStride,
               data += stride) {
        cblas_Xaxpy(num_cols_, alpha, adata, 1, data, 1);
      }
    } else {
      KALDI_ASSERT(A.num_cols_ == num_rows_ && A.num_rows_ == num_cols_);
      if (num_rows_ == 0) return;
      for (MatrixIndexT row = 0; row < num_rows_; row++, adata++, data += stride)
        cblas_Xaxpy(num_cols_, alpha, adata, aStride, data, 1);
    }
  }
}
#endif

#ifdef CBLAS
template<typename Real>
void MatrixBase<Real>::AddDiagVecMat(
    const Real alpha, const VectorBase<Real> &v,
    const MatrixBase<Real> &M,
    MatrixTransposeType transM,
    Real beta) {
  if (beta != 1.0) this->Scale(beta);

  if (transM == kNoTrans) {
    KALDI_ASSERT(SameDim(*this, M));
  } else {
    KALDI_ASSERT(M.NumRows() == NumCols() && M.NumCols() == NumRows());
  }
  KALDI_ASSERT(v.Dim() == this->NumRows());

  MatrixIndexT M_row_stride = M.Stride(), M_col_stride = 1, stride = stride_,
      num_rows = num_rows_, num_cols = num_cols_;
  if (transM == kTrans) std::swap(M_row_stride, M_col_stride);
  Real *data = data_;
  const Real *Mdata = M.Data(), *vdata = v.Data();
  if (num_rows_ == 0) return;
  for (MatrixIndexT i = 0; i < num_rows; i++, data += stride, Mdata += M_row_stride, vdata++)
    cblas_Xaxpy(num_cols, alpha * *vdata, Mdata, M_col_stride, data, 1);
}
#endif
template<typename Real>
void MatrixBase<Real>::AddMatDiagVec(
    const Real alpha,
    const MatrixBase<Real> &M, MatrixTransposeType transM,
    VectorBase<Real> &v,
    Real beta) {

  //if (beta != 1.0) this->Scale(beta);

  if (transM == kNoTrans) {
    KALDI_ASSERT(SameDim(*this, M));
  } else {
    KALDI_ASSERT(M.NumRows() == NumCols() && M.NumCols() == NumRows());
  }
  KALDI_ASSERT(v.Dim() == this->NumCols());

  MatrixIndexT M_row_stride = M.Stride(),
               M_col_stride = 1,
               stride = stride_,
               num_rows = num_rows_,
               num_cols = num_cols_;

  if (transM == kTrans)
    std::swap(M_row_stride, M_col_stride);

  Real *data = data_;
  const Real *Mdata = M.Data(), *vdata = v.Data();
  if (num_rows_ == 0) return;
  for (MatrixIndexT i = 0; i < num_rows; i++){
      for(MatrixIndexT j = 0; j < num_cols; j ++ ){
          data[i*stride + j] += alpha * vdata[j] * Mdata[i*M_row_stride + j*M_col_stride];
      }
  }
}

template<typename Real>
void MatrixBase<Real>::AddMatMatElements(const Real alpha,
                                         const MatrixBase<Real>& A,
                                         const MatrixBase<Real>& B,
                                         const Real beta) {
    KALDI_ASSERT(A.NumRows() == B.NumRows() && A.NumCols() == B.NumCols());
    KALDI_ASSERT(A.NumRows() == NumRows() && A.NumCols() == NumCols());
    Real *data = data_;
    const Real *dataA = A.Data();
    const Real *dataB = B.Data();

    for (MatrixIndexT i = 0; i < num_rows_; i++) {
        for (MatrixIndexT j = 0; j < num_cols_; j++) {
            data[j] = beta*data[j] + alpha*dataA[j]*dataB[j];
        }
        data += Stride();
        dataA += A.Stride();
        dataB += B.Stride();
    }
}


// Copy constructor.  Copies data to newly allocated memory.
template<typename Real>
Matrix<Real>::Matrix (const MatrixBase<Real> & M,
                      MatrixTransposeType trans/*=kNoTrans*/)
    : MatrixBase<Real>() {
  if (trans == kNoTrans) {
    Resize(M.num_rows_, M.num_cols_);
    this->CopyFromMat(M);
  } else {
    Resize(M.num_cols_, M.num_rows_);
    this->CopyFromMat(M, kTrans);
  }
}

// Copy constructor.  Copies data to newly allocated memory.
template<typename Real>
Matrix<Real>::Matrix (const Matrix<Real> & M):
    MatrixBase<Real>() {
  Resize(M.num_rows_, M.num_cols_);
  this->CopyFromMat(M);
}

/// Copy constructor from another type.
template<typename Real>
template<typename OtherReal>
Matrix<Real>::Matrix(const MatrixBase<OtherReal> & M,
                     MatrixTransposeType trans) : MatrixBase<Real>() {
  if (trans == kNoTrans) {
    Resize(M.NumRows(), M.NumCols());
    this->CopyFromMat(M);
  } else {
    Resize(M.NumCols(), M.NumRows());
    this->CopyFromMat(M, kTrans);
  }
}

// Instantiate this constructor for float->double and double->float.
template
Matrix<float>::Matrix(const MatrixBase<double> & M,
                      MatrixTransposeType trans);
template
Matrix<double>::Matrix(const MatrixBase<float> & M,
                       MatrixTransposeType trans);

template<typename Real>
inline void Matrix<Real>::Init(const MatrixIndexT rows,
                               const MatrixIndexT cols,
                               const MatrixStrideType stride_type) {
  if (rows * cols == 0) {
    KALDI_ASSERT(rows == 0 && cols == 0);
    this->num_rows_ = 0;
    this->num_cols_ = 0;
    this->stride_ = 0;
    this->data_ = NULL;
    return;
  }
  KALDI_ASSERT(rows > 0 && cols > 0);
  MatrixIndexT skip, stride;
  size_t size;
  void *data;  // aligned memory block
  void *temp;  // memory block to be really freed

  // compute the size of skip and real cols
  skip = ((16 / sizeof(Real)) - cols % (16 / sizeof(Real)))
      % (16 / sizeof(Real));
  stride = cols + skip;
  size = static_cast<size_t>(rows) * static_cast<size_t>(stride)
      * sizeof(Real);

  // allocate the memory and set the right dimensions and parameters
  if (NULL != (data = KALDI_MEMALIGN(16, size, &temp))) {
    MatrixBase<Real>::data_        = static_cast<Real *> (data);
    MatrixBase<Real>::num_rows_      = rows;
    MatrixBase<Real>::num_cols_      = cols;
    MatrixBase<Real>::stride_  = (stride_type == kDefaultStride ? stride : cols);
  } else {
    throw std::bad_alloc();
  }
}
/*
template<typename Real>
void MatrixBase<Real>::CopyFromNumpy(const np::ndarray &logit,MatrixTransposeType Trans) {//
	if (Trans == kNoTrans) {
		KALDI_ASSERT(num_rows_ == logit.shape(0) && num_cols_ == logit.shape(1));
		int32 this_stride = stride_;
		Real *this_data = data_;
	    for (MatrixIndexT i = 0; i < num_rows_; i++)
		   for (MatrixIndexT j = 0; j < num_cols_; j++){
		      this_data[i * this_stride + j] = p::extract<double>(logit[(int)i][(int)j]);
		   }
	    	//(*this).Row(i).CopyFromVec(M.Row(i));
	} else {
	    KALDI_ASSERT(num_cols_ == logit.shape(0) && num_rows_ == logit.shape(1));
	    int32 this_stride = stride_;//, other_stride = M.Stride();
	    Real *this_data = data_;

	    for (MatrixIndexT i = 0; i < num_rows_; i++)
	      for (MatrixIndexT j = 0; j < num_cols_; j++){
	    	  this_data[i * this_stride + j] = p::extract<double>(logit[(int)j][(int)i]);
	      }
	  }
}*/

template<typename Real>
void Matrix<Real>::Resize(const MatrixIndexT rows,
                          const MatrixIndexT cols,
                          MatrixResizeType resize_type,
                          MatrixStrideType stride_type) {
  // the next block uses recursion to handle what we have to do if
  // resize_type == kCopyData.
  if (resize_type == kCopyData) {
    if (this->data_ == NULL || rows == 0) resize_type = kSetZero;  // nothing to copy.
    else if (rows == this->num_rows_ && cols == this->num_cols_) { return; } // nothing to do.
    else {
      // set tmp to a matrix of the desired size; if new matrix
      // is bigger in some dimension, zero it.
      MatrixResizeType new_resize_type =
          (rows > this->num_rows_ || cols > this->num_cols_) ? kSetZero : kUndefined;
      Matrix<Real> tmp(rows, cols, new_resize_type);
      MatrixIndexT rows_min = std::min(rows, this->num_rows_),
          cols_min = std::min(cols, this->num_cols_);
      tmp.Range(0, rows_min, 0, cols_min).
          CopyFromMat(this->Range(0, rows_min, 0, cols_min));
      tmp.Swap(this);
      // and now let tmp go out of scope, deleting what was in *this.
      return;
    }
  }
  // At this point, resize_type == kSetZero or kUndefined.

  if (MatrixBase<Real>::data_ != NULL) {
    if (rows == MatrixBase<Real>::num_rows_
        && cols == MatrixBase<Real>::num_cols_) {
      if (resize_type == kSetZero)
        this->SetZero();
      return;
    }
    else
      Destroy();
  }
  Init(rows, cols, stride_type);
  if (resize_type == kSetZero) MatrixBase<Real>::SetZero();
}

template<typename Real>
template<typename OtherReal>
void MatrixBase<Real>::CopyFromMat(const MatrixBase<OtherReal> &M,
                                   MatrixTransposeType Trans) {
  if (sizeof(Real) == sizeof(OtherReal) &&
      static_cast<const void*>(M.Data()) ==
      static_cast<const void*>(this->Data())) {
    // CopyFromMat called on same data.  Nothing to do (except sanity checks).
    KALDI_ASSERT(Trans == kNoTrans && M.NumRows() == NumRows() &&
                 M.NumCols() == NumCols() && M.Stride() == Stride());
    return;
  }
  if (Trans == kNoTrans) {
    KALDI_ASSERT(num_rows_ == M.NumRows() && num_cols_ == M.NumCols());
    for (MatrixIndexT i = 0; i < num_rows_; i++)
      (*this).Row(i).CopyFromVec(M.Row(i));
  } else {
    KALDI_ASSERT(num_cols_ == M.NumRows() && num_rows_ == M.NumCols());
    int32 this_stride = stride_, other_stride = M.Stride();
    Real *this_data = data_;
    const OtherReal *other_data = M.Data();
    for (MatrixIndexT i = 0; i < num_rows_; i++)
      for (MatrixIndexT j = 0; j < num_cols_; j++)
        this_data[i * this_stride + j] = other_data[j * other_stride + i];
  }
}
#ifdef TENSOR
//template<typename Real>
//void MatrixBase<Real>::CopyFromTensor(const Eigen::TensorMap<Eigen::Tensor<float, 1, Eigen::RowMajor>,Eigen::Aligned> &logit
//		 ,int32 row
//		 ,int32 col){//
//	KALDI_ASSERT(num_rows_ == row && num_cols_ == col);
//	KALDI_ASSERT(num_rows_*num_cols_ == logit.size());
//	int32 this_stride = stride_;
//	Real *this_data = data_;
//	long index = 0 ;
//	for (MatrixIndexT i = 0; i < num_rows_; i++)
//	   for (MatrixIndexT j = 0; j < num_cols_; j++){
//			this_data[i * this_stride + j] = logit(index);
//			index++;
//	   }
//}
template<typename Real>
void MatrixBase<Real>::CopyFromTensor(const Eigen::TensorMap<Eigen::Tensor<float, 1, Eigen::RowMajor>,Eigen::Aligned> &logit
									   ,int32 row
									   ,int32 col){//
	KALDI_ASSERT(num_rows_ == row && num_cols_ == col);
	KALDI_ASSERT(num_rows_*num_cols_ == logit.size());
	int32 this_stride = stride_;
	Real *this_data = data_;
	long index = 0 ;

	for (MatrixIndexT i = 0; i < num_rows_; i++)//all frames
	{
		double expSum = 0.0;
		for (MatrixIndexT j = 0; j < num_cols_; j++){//all classes
			this_data[i * this_stride + j] = std::exp(logit(index));
			expSum += this_data[i * this_stride + j];
			index++;
		}
		for (MatrixIndexT j = 0; j < num_cols_; j++){
			if(fabs(expSum) <= 1e-6)//expSum!=0
				this_data[i * this_stride + j] = 1.0/28.0;
			else{
				this_data[i * this_stride + j] = this_data[i * this_stride + j]/expSum;
			}
		}
		//expSum
	}
}
#endif
// template instantiations.
template
void MatrixBase<float>::CopyFromMat(const MatrixBase<double> & M,
                                    MatrixTransposeType Trans);
template
void MatrixBase<double>::CopyFromMat(const MatrixBase<float> & M,
                                     MatrixTransposeType Trans);
template
void MatrixBase<float>::CopyFromMat(const MatrixBase<float> & M,
                                    MatrixTransposeType Trans);
template
void MatrixBase<double>::CopyFromMat(const MatrixBase<double> & M,
                                     MatrixTransposeType Trans);

template<typename Real>
void MatrixBase<Real>::CopyRowsFromVec(const VectorBase<Real> &rv) {
  if (rv.Dim() == num_rows_*num_cols_) {
    if (stride_ == num_cols_) {
      // one big copy operation.
      const Real *rv_data = rv.Data();
      std::memcpy(data_, rv_data, sizeof(Real)*num_rows_*num_cols_);
    } else {
      const Real *rv_data = rv.Data();
      for (MatrixIndexT r = 0; r < num_rows_; r++) {
        Real *row_data = RowData(r);
        for (MatrixIndexT c = 0; c < num_cols_; c++) {
          row_data[c] = rv_data[c];
        }
        rv_data += num_cols_;
      }
    }
  } else if (rv.Dim() == num_cols_) {
    const Real *rv_data = rv.Data();
    for (MatrixIndexT r = 0; r < num_rows_; r++)
      std::memcpy(RowData(r), rv_data, sizeof(Real)*num_cols_);
  } else {
    KALDI_ERR << "Wrong sized arguments";
  }
}

template<typename Real>
template<typename OtherReal>
void MatrixBase<Real>::CopyRowsFromVec(const VectorBase<OtherReal> &rv) {
  if (rv.Dim() == num_rows_*num_cols_) {
    const OtherReal *rv_data = rv.Data();
    for (MatrixIndexT r = 0; r < num_rows_; r++) {
      Real *row_data = RowData(r);
      for (MatrixIndexT c = 0; c < num_cols_; c++) {
        row_data[c] = static_cast<Real>(rv_data[c]);
      }
      rv_data += num_cols_;
    }
  } else if (rv.Dim() == num_cols_) {
    const OtherReal *rv_data = rv.Data();
    Real *first_row_data = RowData(0);
    for (MatrixIndexT c = 0; c < num_cols_; c++)
      first_row_data[c] = rv_data[c];
    for (MatrixIndexT r = 1; r < num_rows_; r++)
      std::memcpy(RowData(r), first_row_data, sizeof(Real)*num_cols_);
  } else {
    KALDI_ERR << "Wrong sized arguments.";
  }
}


template
void MatrixBase<float>::CopyRowsFromVec(const VectorBase<double> &rv);
template
void MatrixBase<double>::CopyRowsFromVec(const VectorBase<float> &rv);

template<typename Real>
void MatrixBase<Real>::CopyColsFromVec(const VectorBase<Real> &rv) {
  if (rv.Dim() == num_rows_*num_cols_) {
    const Real *v_inc_data = rv.Data();
    Real *m_inc_data = data_;

    for (MatrixIndexT c = 0; c < num_cols_; c++) {
      for (MatrixIndexT r = 0; r < num_rows_; r++) {
        m_inc_data[r * stride_] = v_inc_data[r];
      }
      v_inc_data += num_rows_;
      m_inc_data ++;
    }
  } else if (rv.Dim() == num_rows_) {
    const Real *v_inc_data = rv.Data();
    Real *m_inc_data = data_;
    for (MatrixIndexT r = 0; r < num_rows_; r++) {
      Real value = *(v_inc_data++);
      for (MatrixIndexT c = 0; c < num_cols_; c++)
        m_inc_data[c] = value;
      m_inc_data += stride_;
    }
  } else {
    KALDI_ERR << "Wrong size of arguments.";
  }
}


template<typename Real>
void MatrixBase<Real>::CopyRowFromVec(const VectorBase<Real> &rv, const MatrixIndexT row) {
  KALDI_ASSERT(rv.Dim() == num_cols_ &&
               static_cast<UnsignedMatrixIndexT>(row) <
               static_cast<UnsignedMatrixIndexT>(num_rows_));

  const Real *rv_data = rv.Data();
  Real *row_data = RowData(row);

  std::memcpy(row_data, rv_data, num_cols_ * sizeof(Real));
}

template<typename Real>
void MatrixBase<Real>::CopyDiagFromVec(const VectorBase<Real> &rv) {
  KALDI_ASSERT(rv.Dim() == std::min(num_cols_, num_rows_));
  const Real *rv_data = rv.Data(), *rv_end = rv_data + rv.Dim();
  Real *my_data = this->Data();
  for (; rv_data != rv_end; rv_data++, my_data += (this->stride_+1))
    *my_data = *rv_data;
}

template<typename Real>
void MatrixBase<Real>::CopyColFromVec(const VectorBase<Real> &rv,
                                      const MatrixIndexT col) {
  KALDI_ASSERT(rv.Dim() == num_rows_ &&
               static_cast<UnsignedMatrixIndexT>(col) <
               static_cast<UnsignedMatrixIndexT>(num_cols_));

  const Real *rv_data = rv.Data();
  Real *col_data = data_ + col;

  for (MatrixIndexT r = 0; r < num_rows_; r++)
    col_data[r * stride_] = rv_data[r];
}



template<typename Real>
void Matrix<Real>::RemoveRow(MatrixIndexT i) {
  KALDI_ASSERT(static_cast<UnsignedMatrixIndexT>(i) <
               static_cast<UnsignedMatrixIndexT>(MatrixBase<Real>::num_rows_)
               && "Access out of matrix");
  for (MatrixIndexT j = i + 1; j <  MatrixBase<Real>::num_rows_; j++)
    MatrixBase<Real>::Row(j-1).CopyFromVec( MatrixBase<Real>::Row(j));
  MatrixBase<Real>::num_rows_--;
}

template<typename Real>
void Matrix<Real>::Destroy() {
  // we need to free the data block if it was defined
  if (NULL != MatrixBase<Real>::data_)
    KALDI_MEMALIGN_FREE( MatrixBase<Real>::data_);
  MatrixBase<Real>::data_ = NULL;
  MatrixBase<Real>::num_rows_ = MatrixBase<Real>::num_cols_
      = MatrixBase<Real>::stride_ = 0;
}



template<typename Real>
void MatrixBase<Real>::MulElements(const MatrixBase<Real> &a) {
  KALDI_ASSERT(a.NumRows() == num_rows_ && a.NumCols() == num_cols_);

  if (num_cols_ == stride_ && num_cols_ == a.stride_) {
    mul_elements(num_rows_ * num_cols_, a.data_, data_);
  } else {
    MatrixIndexT a_stride = a.stride_, stride = stride_;
    Real *data = data_, *a_data = a.data_;
    for (MatrixIndexT i = 0; i < num_rows_; i++) {
      mul_elements(num_cols_, a_data, data);
      a_data += a_stride;
      data += stride;
    }
  }
}

template<typename Real>
void MatrixBase<Real>::DivElements(const MatrixBase<Real> &a) {
  KALDI_ASSERT(a.NumRows() == num_rows_ && a.NumCols() == num_cols_);
  MatrixIndexT i;
  MatrixIndexT j;

  for (i = 0; i < num_rows_; i++) {
    for (j = 0; j < num_cols_; j++) {
      (*this)(i, j) /= a(i, j);
    }
  }
}

template<typename Real>
Real MatrixBase<Real>::Sum() const {
  double sum = 0.0;

  for (MatrixIndexT i = 0; i < num_rows_; i++) {
    for (MatrixIndexT j = 0; j < num_cols_; j++) {
      sum += (*this)(i, j);
    }
  }

  return (Real)sum;
}

template<typename Real> void MatrixBase<Real>::Max(const MatrixBase<Real> &A) {
  KALDI_ASSERT(A.NumRows() == NumRows() && A.NumCols() == NumCols());
  for (MatrixIndexT row = 0; row < num_rows_; row++) {
    Real *row_data = RowData(row);
    const Real *other_row_data = A.RowData(row);
    MatrixIndexT num_cols = num_cols_;
    for (MatrixIndexT col = 0; col < num_cols; col++) {
      row_data[col] = std::max(row_data[col],
                               other_row_data[col]);
    }
  }
}

template<typename Real> void MatrixBase<Real>::Min(const MatrixBase<Real> &A) {
  KALDI_ASSERT(A.NumRows() == NumRows() && A.NumCols() == NumCols());
  for (MatrixIndexT row = 0; row < num_rows_; row++) {
    Real *row_data = RowData(row);
    const Real *other_row_data = A.RowData(row);
    MatrixIndexT num_cols = num_cols_;
    for (MatrixIndexT col = 0; col < num_cols; col++) {
      row_data[col] = std::min(row_data[col],
                               other_row_data[col]);
    }
  }
}

#ifdef CBLAS
template<typename Real> void MatrixBase<Real>::Scale(Real alpha) {
  if (alpha == 1.0) return;
  if (num_rows_ == 0) return;
  if (num_cols_ == stride_) {
    cblas_Xscal(static_cast<size_t>(num_rows_) * static_cast<size_t>(num_cols_),
                alpha, data_,1);
  } else {
    Real *data = data_;
    for (MatrixIndexT i = 0; i < num_rows_; ++i, data += stride_) {
      cblas_Xscal(num_cols_, alpha, data,1);
    }
  }
}
#endif

template<typename Real>  // scales each row by scale[i].
void MatrixBase<Real>::MulRowsVec(const VectorBase<Real> &scale) {
  KALDI_ASSERT(scale.Dim() == num_rows_);
  MatrixIndexT M = num_rows_, N = num_cols_;

  for (MatrixIndexT i = 0; i < M; i++) {
    Real this_scale = scale(i);
    for (MatrixIndexT j = 0; j < N; j++) {
      (*this)(i, j) *= this_scale;
    }
  }
}

#ifdef CBLAS
template<typename Real>
void MatrixBase<Real>::MulRowsGroupMat(const MatrixBase<Real> &src) {
  KALDI_ASSERT(src.NumRows() == this->NumRows() &&
               this->NumCols() % src.NumCols() == 0);
  int32 group_size = this->NumCols() / src.NumCols(),
      num_groups = this->NumCols() / group_size,
      num_rows = this->NumRows();

  for (MatrixIndexT i = 0; i < num_rows; i++) {
    Real *data = this->RowData(i);
    for (MatrixIndexT j = 0; j < num_groups; j++, data += group_size) {
      Real scale = src(i, j);
      cblas_Xscal(group_size, scale, data, 1);
    }
  }
}
#endif
template<typename Real>
void MatrixBase<Real>::GroupPnormDeriv(const MatrixBase<Real> &input,
                                       const MatrixBase<Real> &output,
                                       Real power) {
  KALDI_ASSERT(input.NumCols() == this->NumCols() && input.NumRows() == this->NumRows());
  KALDI_ASSERT(this->NumCols() % output.NumCols() == 0 &&
               this->NumRows() == output.NumRows());

  int group_size = this->NumCols() / output.NumCols(),
    num_rows = this->NumRows(), num_cols = this->NumCols();

  if (power == 1.0) {
    for (MatrixIndexT i = 0; i < num_rows; i++) {
      for (MatrixIndexT j = 0; j < num_cols; j++) {
        Real input_val = input(i, j);
        (*this)(i, j) = (input_val == 0 ? 0 : (input_val > 0 ? 1 : -1));
      }
    }
  } else if (power == std::numeric_limits<Real>::infinity()) {
    for (MatrixIndexT i = 0; i < num_rows; i++) {
      for (MatrixIndexT j = 0; j < num_cols; j++) {
        Real output_val = output(i, j / group_size), input_val = input(i, j);
        if (output_val == 0)
          (*this)(i, j) = 0;
        else
          (*this)(i, j) = (std::abs(input_val) == output_val ? 1.0 : 0.0)
              * (input_val >= 0 ? 1 : -1);
      }
    }
  } else {
    for (MatrixIndexT i = 0; i < num_rows; i++) {
      for (MatrixIndexT j = 0; j < num_cols; j++) {
        Real output_val = output(i, j / group_size),
          input_val = input(i, j);
        if (output_val == 0)
          (*this)(i, j) = 0;
         else
            (*this)(i, j) = pow(std::abs(input_val), power - 1) *
              pow(output_val, 1 - power) * (input_val >= 0 ? 1 : -1) ;
      }
    }
  }
}

template<typename Real>
void MatrixBase<Real>::GroupMaxDeriv(const MatrixBase<Real> &input,
                                     const MatrixBase<Real> &output) {
  KALDI_ASSERT(input.NumCols() == this->NumCols() &&
              input.NumRows() == this->NumRows());
  KALDI_ASSERT(this->NumCols() % output.NumCols() == 0 &&
               this->NumRows() == output.NumRows());

  int group_size = this->NumCols() / output.NumCols(),
      num_rows = this->NumRows(), num_cols = this->NumCols();

  for (MatrixIndexT i = 0; i < num_rows; i++) {
    for (MatrixIndexT j = 0; j < num_cols; j++) {
      Real input_val = input(i, j);
      Real output_val = output(i, j / group_size);
      (*this)(i, j) = (input_val == output_val ? 1 : 0);
    }
  }
}

template<typename Real>  // scales each column by scale[i].
void MatrixBase<Real>::MulColsVec(const VectorBase<Real> &scale) {
  KALDI_ASSERT(scale.Dim() == num_cols_);
  for (MatrixIndexT i = 0; i < num_rows_; i++) {
    for (MatrixIndexT j = 0; j < num_cols_; j++) {
      Real this_scale = scale(j);
      (*this)(i, j) *= this_scale;
    }
  }
}

template<typename Real>
void MatrixBase<Real>::SetZero() {
  if (num_cols_ == stride_)
    memset(data_, 0, sizeof(Real)*num_rows_*num_cols_);
  else
    for (MatrixIndexT row = 0; row < num_rows_; row++)
      memset(data_ + row*stride_, 0, sizeof(Real)*num_cols_);
}

template<typename Real>
void MatrixBase<Real>::Set(Real value) {
  for (MatrixIndexT row = 0; row < num_rows_; row++) {
    for (MatrixIndexT col = 0; col < num_cols_; col++) {
      (*this)(row, col) = value;
    }
  }
}

template<typename Real>
void MatrixBase<Real>::SetUnit() {
  SetZero();
  for (MatrixIndexT row = 0; row < std::min(num_rows_, num_cols_); row++)
    (*this)(row, row) = 1.0;
}

template<typename Real>
void MatrixBase<Real>::SetRandn() {
  kaldi::RandomState rstate;
  for (MatrixIndexT row = 0; row < num_rows_; row++) {
    Real *row_data = this->RowData(row);
    MatrixIndexT nc = (num_cols_ % 2 == 1) ? num_cols_ - 1 : num_cols_;
    for (MatrixIndexT col = 0; col < nc; col += 2) {
      kaldi::RandGauss2(row_data + col, row_data + col + 1, &rstate);
    }
    if (nc != num_cols_) row_data[nc] = static_cast<Real>(kaldi::RandGauss(&rstate));
  }
}

template<typename Real>
void MatrixBase<Real>::SetRandUniform() {
  kaldi::RandomState rstate;
  for (MatrixIndexT row = 0; row < num_rows_; row++) {
    Real *row_data = this->RowData(row);
    for (MatrixIndexT col = 0; col < num_cols_; col++, row_data++) {
      *row_data = static_cast<Real>(kaldi::RandUniform(&rstate));
    }
  }
}


// Constructor... note that this is not const-safe as it would
// be quite complicated to implement a "const SubMatrix" class that
// would not allow its contents to be changed.
template<typename Real>
SubMatrix<Real>::SubMatrix(const MatrixBase<Real> &M,
                           const MatrixIndexT ro,
                           const MatrixIndexT r,
                           const MatrixIndexT co,
                           const MatrixIndexT c) {
  if (r == 0 || c == 0) {
    // we support the empty sub-matrix as a special case.
    KALDI_ASSERT(c == 0 && r == 0);
    this->data_ = NULL;
    this->num_cols_ = 0;
    this->num_rows_ = 0;
    this->stride_ = 0;
    return;
  }
  KALDI_ASSERT(static_cast<UnsignedMatrixIndexT>(ro) <
               static_cast<UnsignedMatrixIndexT>(M.num_rows_) &&
               static_cast<UnsignedMatrixIndexT>(co) <
               static_cast<UnsignedMatrixIndexT>(M.num_cols_) &&
               static_cast<UnsignedMatrixIndexT>(r) <=
               static_cast<UnsignedMatrixIndexT>(M.num_rows_ - ro) &&
               static_cast<UnsignedMatrixIndexT>(c) <=
               static_cast<UnsignedMatrixIndexT>(M.num_cols_ - co));
  // point to the begining of window
  MatrixBase<Real>::num_rows_ = r;
  MatrixBase<Real>::num_cols_ = c;
  MatrixBase<Real>::stride_ = M.Stride();
  MatrixBase<Real>::data_ = M.Data_workaround() +
      static_cast<size_t>(co) +
      static_cast<size_t>(ro) * static_cast<size_t>(M.Stride());
}


template<typename Real>
SubMatrix<Real>::SubMatrix(Real *data,
                           MatrixIndexT num_rows,
                           MatrixIndexT num_cols,
                           MatrixIndexT stride):
    MatrixBase<Real>(data, num_cols, num_rows, stride) { // caution: reversed order!
  if (data == NULL) {
    KALDI_ASSERT(num_rows * num_cols == 0);
    this->num_rows_ = 0;
    this->num_cols_ = 0;
    this->stride_ = 0;
  } else {
    KALDI_ASSERT(this->stride_ >= this->num_cols_);
  }
}


template<typename Real>
void MatrixBase<Real>::Add(const Real alpha) {
  Real *data = data_;
  MatrixIndexT stride = stride_;
  for (MatrixIndexT r = 0; r < num_rows_; r++)
    for (MatrixIndexT c = 0; c < num_cols_; c++)
      data[c + stride*r] += alpha;
}

template<typename Real>
void MatrixBase<Real>::AddToDiag(const Real alpha) {
  Real *data = data_;
  MatrixIndexT this_stride = stride_ + 1,
      num_to_add = std::min(num_rows_, num_cols_);
  for (MatrixIndexT r = 0; r < num_to_add; r++)
    data[r * this_stride] += alpha;
}

template<typename Real>
Real MatrixBase<Real>::Trace(bool check_square) const  {
  KALDI_ASSERT(!check_square || num_rows_ == num_cols_);
  Real ans = 0.0;
  for (MatrixIndexT r = 0;r < std::min(num_rows_, num_cols_);r++) ans += data_ [r + stride_*r];
  return ans;
}

template<typename Real>
Real MatrixBase<Real>::Max() const {
  KALDI_ASSERT(num_rows_ > 0 && num_cols_ > 0);
  Real ans= *data_;
  for (MatrixIndexT r = 0; r < num_rows_; r++)
    for (MatrixIndexT c = 0; c < num_cols_; c++)
      if (data_[c + stride_*r] > ans)
        ans = data_[c + stride_*r];
  return ans;
}

template<typename Real>
Real MatrixBase<Real>::Min() const {
  KALDI_ASSERT(num_rows_ > 0 && num_cols_ > 0);
  Real ans= *data_;
  for (MatrixIndexT r = 0; r < num_rows_; r++)
    for (MatrixIndexT c = 0; c < num_cols_; c++)
      if (data_[c + stride_*r] < ans)
        ans = data_[c + stride_*r];
  return ans;
}


template<typename Real>
bool MatrixBase<Real>::IsSymmetric(Real cutoff) const {
  MatrixIndexT R = num_rows_, C = num_cols_;
  if (R != C) return false;
  Real bad_sum = 0.0, good_sum = 0.0;
  for (MatrixIndexT i = 0;i < R;i++) {
    for (MatrixIndexT j = 0;j < i;j++) {
      Real a = (*this)(i, j), b = (*this)(j, i), avg = 0.5*(a+b), diff = 0.5*(a-b);
      good_sum += std::abs(avg); bad_sum += std::abs(diff);
    }
    good_sum += std::abs((*this)(i, i));
  }
  if (bad_sum > cutoff*good_sum) return false;
  return true;
}

template<typename Real>
bool MatrixBase<Real>::IsDiagonal(Real cutoff) const{
  MatrixIndexT R = num_rows_, C = num_cols_;
  Real bad_sum = 0.0, good_sum = 0.0;
  for (MatrixIndexT i = 0;i < R;i++) {
    for (MatrixIndexT j = 0;j < C;j++) {
      if (i == j) good_sum += std::abs((*this)(i, j));
      else bad_sum += std::abs((*this)(i, j));
    }
  }
  return (!(bad_sum > good_sum * cutoff));
}

// This does nothing, it's designed to trigger Valgrind errors
// if any memory is uninitialized.
template<typename Real>
void MatrixBase<Real>::TestUninitialized() const {
  MatrixIndexT R = num_rows_, C = num_cols_, positive = 0;
  for (MatrixIndexT i = 0; i < R; i++)
    for (MatrixIndexT j = 0; j < C; j++)
      if ((*this)(i, j) > 0.0) positive++;
  if (positive > R * C)
    KALDI_ERR << "Error....";
}


template<typename Real>
bool MatrixBase<Real>::IsUnit(Real cutoff) const {
  MatrixIndexT R = num_rows_, C = num_cols_;
  Real bad_max = 0.0;
  for (MatrixIndexT i = 0; i < R;i++)
    for (MatrixIndexT j = 0; j < C;j++)
      bad_max = std::max(bad_max, static_cast<Real>(std::abs( (*this)(i, j) - (i == j?1.0:0.0))));
  return (bad_max <= cutoff);
}

template<typename Real>
bool MatrixBase<Real>::IsZero(Real cutoff)const {
  MatrixIndexT R = num_rows_, C = num_cols_;
  Real bad_max = 0.0;
  for (MatrixIndexT i = 0;i < R;i++)
    for (MatrixIndexT j = 0;j < C;j++)
      bad_max = std::max(bad_max, static_cast<Real>(std::abs( (*this)(i, j) )));
  return (bad_max <= cutoff);
}




template<typename Real>
bool MatrixBase<Real>::Equal(const MatrixBase<Real> &other) const {
  if (num_rows_ != other.num_rows_ || num_cols_ != other.num_cols_)
    KALDI_ERR << "Equal: size mismatch.";
  for (MatrixIndexT i = 0; i < num_rows_; i++)
    for (MatrixIndexT j = 0; j < num_cols_; j++)
      if ( (*this)(i, j) != other(i, j))
        return false;
  return true;
}


template<typename Real>
Real MatrixBase<Real>::LargestAbsElem() const{
  MatrixIndexT R = num_rows_, C = num_cols_;
  Real largest = 0.0;
  for (MatrixIndexT i = 0;i < R;i++)
    for (MatrixIndexT j = 0;j < C;j++)
      largest = std::max(largest, (Real)std::abs((*this)(i, j)));
  return largest;
}
#ifdef CBLAS
template<typename Real>
Real MatrixBase<Real>::LogDet(Real *det_sign) const {
  Real log_det;
  Matrix<Real> tmp(*this);
  tmp.Invert(&log_det, det_sign, false);  // false== output not needed (saves some computation).
  return log_det;
}
#endif




template<typename Real>
void MatrixBase<Real>::InvertElements() {
  for (MatrixIndexT r = 0; r < num_rows_; r++) {
    for (MatrixIndexT c = 0; c < num_cols_; c++) {
      (*this)(r, c) = static_cast<Real>(1.0 / (*this)(r, c));
    }
  }
}

template<typename Real>
void MatrixBase<Real>::Transpose() {
  KALDI_ASSERT(num_rows_ == num_cols_);
  MatrixIndexT M = num_rows_;
  for (MatrixIndexT i = 0;i < M;i++)
    for (MatrixIndexT j = 0;j < i;j++) {
      Real &a = (*this)(i, j), &b = (*this)(j, i);
      std::swap(a, b);
    }
}


template<typename Real>
void Matrix<Real>::Transpose() {
  if (this->num_rows_ != this->num_cols_) {
    Matrix<Real> tmp(*this, kTrans);
    Resize(this->num_cols_, this->num_rows_);
    this->CopyFromMat(tmp);
  } else {
    (static_cast<MatrixBase<Real>&>(*this)).Transpose();
  }
}

template<typename Real>
void MatrixBase<Real>::ApplyFloor(Real floor_val) {
  MatrixIndexT num_rows = num_rows_, num_cols = num_cols_;
  for (MatrixIndexT i = 0; i < num_rows; i++) {
    Real *data = this->RowData(i);
    for (MatrixIndexT j = 0; j < num_cols; j++)
      data[j] = (data[j] < floor_val ? floor_val : data[j]);
  }
}

template<typename Real>
void MatrixBase<Real>::ApplyCeiling(Real ceiling_val) {
  MatrixIndexT num_rows = num_rows_, num_cols = num_cols_;
  for (MatrixIndexT i = 0; i < num_rows; i++) {
    Real *data = this->RowData(i);
    for (MatrixIndexT j = 0; j < num_cols; j++)
      data[j] = (data[j] > ceiling_val ? ceiling_val : data[j]);
  }
}

template<typename Real>
void MatrixBase<Real>::ApplyLog() {
  for (MatrixIndexT i = 0; i < num_rows_; i++) {
    Row(i).ApplyLog();
  }
}

template<typename Real>
void MatrixBase<Real>::Dump() {
  for (MatrixIndexT i = 0; i < num_rows_; i++) {
    Row(i).Dump();
    std::cout<<std::endl;
  }
}

template<typename Real>
void MatrixBase<Real>::ApplyExp() {
  for (MatrixIndexT i = 0; i < num_rows_; i++) {
    Row(i).ApplyExp();
  }
}

template<typename Real>
void MatrixBase<Real>::ApplyPow(Real power) {
  for (MatrixIndexT i = 0; i < num_rows_; i++) {
    Row(i).ApplyPow(power);
  }
}

template<typename Real>
void MatrixBase<Real>::ApplyPowAbs(Real power, bool include_sign) {
  for (MatrixIndexT i = 0; i < num_rows_; i++) {
    Row(i).ApplyPowAbs(power, include_sign);
  }
}

template<typename Real>
void MatrixBase<Real>::ApplyHeaviside() {
  MatrixIndexT num_rows = num_rows_, num_cols = num_cols_;
  for (MatrixIndexT i = 0; i < num_rows; i++) {
    Real *data = this->RowData(i);
    for (MatrixIndexT j = 0; j < num_cols; j++)
      data[j] = (data[j] > 0 ? 1.0 : 0.0);
  }
}

template<typename Real>
void MatrixBase<Real>::Heaviside(const MatrixBase<Real> &src) {
  KALDI_ASSERT(SameDim(*this, src));
  MatrixIndexT num_rows = num_rows_, num_cols = num_cols_;
  Real *row_data = data_;
  const Real *src_row_data = src.Data();
  for (MatrixIndexT row = 0; row < num_rows;
       row++,row_data += stride_, src_row_data += src.stride_) {
    for (MatrixIndexT col = 0; col < num_cols; col++)
      row_data[col] = (src_row_data[col] > 0 ? 1.0 : 0.0);
  }
}




template<typename Real>
void Matrix<Real>::Swap(Matrix<Real> *other) {
  std::swap(this->data_, other->data_);
  std::swap(this->num_cols_, other->num_cols_);
  std::swap(this->num_rows_, other->num_rows_);
  std::swap(this->stride_, other->stride_);
}


// Begin non-member function definitions.

//  /**
//   * @brief Extension of the HTK header
//  */
// struct HtkHeaderExt
//  {
// INT_32 mHeaderSize;
// INT_32 mVersion;
// INT_32 mSampSize;
// };





template<typename Real>
bool AttemptComplexPower(Real *x_re, Real *x_im, Real power) {
  // Used in Matrix<Real>::Power().
  // Attempts to take the complex value x to the power "power",
  // assuming that power is fractional (i.e. we don't treat integers as a
  // special case).  Returns false if this is not possible, either
  // because x is negative and real (hence there is no obvious answer
  // that is "closest to 1", and anyway this case does not make sense
  // in the Matrix<Real>::Power() routine);
  // or because power is negative, and x is zero.

  // First solve for r and theta in
  // x_re = r*cos(theta), x_im = r*sin(theta)
  if (*x_re < 0.0 && *x_im == 0.0) return false;  // can't do
  // it for negative real values.
  Real r = std::sqrt((*x_re * *x_re) + (*x_im * *x_im));  // r == radius.
  if (power < 0.0 && r == 0.0) return false;
  Real theta = std::atan2(*x_im, *x_re);
  // Take the power.
  r = std::pow(r, power);
  theta *= power;
  *x_re = r * std::cos(theta);
  *x_im = r * std::sin(theta);
  return true;
}

template
bool AttemptComplexPower(float *x_re, float *x_im, float power);
template
bool AttemptComplexPower(double *x_re, double *x_im, double power);


#ifdef CBLAS
template <typename Real>
Real TraceMatMat(const MatrixBase<Real> &A,
                  const MatrixBase<Real> &B,
                  MatrixTransposeType trans) {  // tr(A B), equivalent to sum of each element of A times same element in B'
  MatrixIndexT aStride = A.stride_, bStride = B.stride_;
  if (trans == kNoTrans) {
    KALDI_ASSERT(A.NumRows() == B.NumCols() && A.NumCols() == B.NumRows());
    Real ans = 0.0;
    Real *adata = A.data_, *bdata = B.data_;
    MatrixIndexT arows = A.NumRows(), acols = A.NumCols();
    for (MatrixIndexT row = 0;row < arows;row++, adata+=aStride, bdata++)
      ans += cblas_Xdot(acols, adata, 1, bdata, bStride);
    return ans;
  } else {
    KALDI_ASSERT(A.NumRows() == B.NumRows() && A.NumCols() == B.NumCols());
    Real ans = 0.0;
    Real *adata = A.data_, *bdata = B.data_;
    MatrixIndexT arows = A.NumRows(), acols = A.NumCols();
    for (MatrixIndexT row = 0;row < arows;row++, adata+=aStride, bdata+=bStride)
      ans += cblas_Xdot(acols, adata, 1, bdata, 1);
    return ans;
  }
}
#endif




template<typename Real>
Real MatrixBase<Real>::LogSumExp(Real prune) const {
  Real sum;
  if (sizeof(sum) == 8) sum = kLogZeroDouble;
  else sum = kLogZeroFloat;
  Real max_elem = Max(), cutoff;
  if (sizeof(Real) == 4) cutoff = max_elem + kMinLogDiffFloat;
  else cutoff = max_elem + kMinLogDiffDouble;
  if (prune > 0.0 && max_elem - prune > cutoff) // explicit pruning...
    cutoff = max_elem - prune;

  double sum_relto_max_elem = 0.0;

  for (MatrixIndexT i = 0; i < num_rows_; i++) {
    for (MatrixIndexT j = 0; j < num_cols_; j++) {
      BaseFloat f = (*this)(i, j);
      if (f >= cutoff)
        sum_relto_max_elem += Exp(f - max_elem);
    }
  }
  return max_elem + Log(sum_relto_max_elem);
}

template<typename Real>
Real MatrixBase<Real>::ApplySoftMax() {
  Real max = this->Max(), sum = 0.0;
  // the 'max' helps to get in good numeric range.
  for (MatrixIndexT i = 0; i < num_rows_; i++)
    for (MatrixIndexT j = 0; j < num_cols_; j++)
      sum += ((*this)(i, j) = Exp((*this)(i, j) - max));
  //this->Scale(1.0 / sum);
  return max + Log(sum);
}

template<typename Real>
void MatrixBase<Real>::Tanh(const MatrixBase<Real> &src) {
  KALDI_ASSERT(SameDim(*this, src));

  if (num_cols_ == stride_ && src.num_cols_ == src.stride_) {
    SubVector<Real> src_vec(src.data_, num_rows_ * num_cols_),
        dst_vec(this->data_, num_rows_ * num_cols_);
    dst_vec.Tanh(src_vec);
  } else {
    for (MatrixIndexT r = 0; r < num_rows_; r++) {
      SubVector<Real> src_vec(src, r), dest_vec(*this, r);
      dest_vec.Tanh(src_vec);
    }
  }
}

template<typename Real>
void MatrixBase<Real>::SoftHinge(const MatrixBase<Real> &src) {
  KALDI_ASSERT(SameDim(*this, src));
  int32 num_rows = num_rows_, num_cols = num_cols_;
  for (MatrixIndexT r = 0; r < num_rows; r++) {
    Real *row_data = this->RowData(r);
    const Real *src_row_data = src.RowData(r);
    for (MatrixIndexT c = 0; c < num_cols; c++) {
      Real x = src_row_data[c], y;
      if (x > 10.0) y = x; // avoid exponentiating large numbers; function
      // approaches y=x.
      else y = Log1p(Exp(x)); // these defined in kaldi-math.h
      row_data[c] = y;
    }
  }
}


template<typename Real>
void MatrixBase<Real>::GroupMax(const MatrixBase<Real> &src) {
  KALDI_ASSERT(src.NumCols() % this->NumCols() == 0 &&
               src.NumRows() == this->NumRows());
  int group_size = src.NumCols() / this->NumCols(),
      num_rows = this->NumRows(), num_cols = this->NumCols();
  for (MatrixIndexT i = 0; i < num_rows; i++) {
    const Real *src_row_data = src.RowData(i);
    for (MatrixIndexT j = 0; j < num_cols; j++) {
      Real max_val = -1e20;
      for (MatrixIndexT k = 0; k < group_size; k++) {
        Real src_data = src_row_data[j * group_size + k];
        if (src_data > max_val)
          max_val = src_data;
      }
      (*this)(i, j) = max_val;
    }
  }
}

template<typename Real>
void MatrixBase<Real>::CopyCols(const MatrixBase<Real> &src,
                                const MatrixIndexT *indices) {
  KALDI_ASSERT(NumRows() == src.NumRows());
  MatrixIndexT num_rows = num_rows_, num_cols = num_cols_,
      this_stride = stride_, src_stride = src.stride_;
  Real *this_data = this->data_;
  const Real *src_data = src.data_;
#ifdef KALDI_PARANOID
  MatrixIndexT src_cols = src.NumCols();
  for (MatrixIndexT i = 0; i < num_cols; i++)
    KALDI_ASSERT(indices[i] >= -1 && indices[i] < src_cols);
#endif

  // For the sake of memory locality we do this row by row, rather
  // than doing it column-wise using cublas_Xcopy
  for (MatrixIndexT r = 0; r < num_rows; r++, this_data += this_stride, src_data += src_stride) {
    const MatrixIndexT *index_ptr = &(indices[0]);
    for (MatrixIndexT c = 0; c < num_cols; c++, index_ptr++) {
      if (*index_ptr < 0) this_data[c] = 0;
      else this_data[c] = src_data[*index_ptr];
    }
  }
}


template<typename Real>
void MatrixBase<Real>::AddCols(const MatrixBase<Real> &src,
                               const MatrixIndexT *indices) {
  KALDI_ASSERT(NumRows() == src.NumRows());
  MatrixIndexT num_rows = num_rows_, num_cols = num_cols_,
      this_stride = stride_, src_stride = src.stride_;
  Real *this_data = this->data_;
  const Real *src_data = src.data_;
#ifdef KALDI_PARANOID
  MatrixIndexT src_cols = src.NumCols();
  for (MatrixIndexT i = 0; i < num_cols; i++)
    KALDI_ASSERT(indices[i] >= -1 && indices[i] < src_cols);
#endif

  // For the sake of memory locality we do this row by row, rather
  // than doing it column-wise using cublas_Xcopy
  for (MatrixIndexT r = 0; r < num_rows; r++, this_data += this_stride, src_data += src_stride) {
    const MatrixIndexT *index_ptr = &(indices[0]);
    for (MatrixIndexT c = 0; c < num_cols; c++, index_ptr++) {
      if (*index_ptr >= 0)
        this_data[c] += src_data[*index_ptr];
    }
  }
}
#ifdef CBLAS
template<typename Real>
void MatrixBase<Real>::CopyRows(const MatrixBase<Real> &src,
                                const MatrixIndexT *indices) {
  KALDI_ASSERT(NumCols() == src.NumCols());
  MatrixIndexT num_rows = num_rows_, num_cols = num_cols_,
      this_stride = stride_;
  Real *this_data = this->data_;

  for (MatrixIndexT r = 0; r < num_rows; r++, this_data += this_stride) {
    MatrixIndexT index = indices[r];
    if (index < 0) memset(this_data, 0, sizeof(Real) * num_cols_);
    else cblas_Xcopy(num_cols, src.RowData(index), 1, this_data, 1);
  }
}

template<typename Real>
void MatrixBase<Real>::CopyRows(const Real *const *src) {
  MatrixIndexT num_rows = num_rows_,
      num_cols = num_cols_, this_stride = stride_;
  Real *this_data = this->data_;

  for (MatrixIndexT r = 0; r < num_rows; r++, this_data += this_stride) {
    const Real *const src_data = src[r];
    if (src_data == NULL) memset(this_data, 0, sizeof(Real) * num_cols);
    else cblas_Xcopy(num_cols, src_data, 1, this_data, 1);
  }
}

template<typename Real>
void MatrixBase<Real>::CopyToRows(Real *const *dst) const {
  MatrixIndexT num_rows = num_rows_,
      num_cols = num_cols_, this_stride = stride_;
  const Real *this_data = this->data_;

  for (MatrixIndexT r = 0; r < num_rows; r++, this_data += this_stride) {
    Real *const dst_data = dst[r];
    if (dst_data != NULL)
      cblas_Xcopy(num_cols, this_data, 1, dst_data, 1);
  }
}


template<typename Real>
void MatrixBase<Real>::AddRows(Real alpha,
                               const MatrixBase<Real> &src,
                               const MatrixIndexT *indexes) {
  KALDI_ASSERT(NumCols() == src.NumCols());
  MatrixIndexT num_rows = num_rows_,
      num_cols = num_cols_, this_stride = stride_;
  Real *this_data = this->data_;

  for (MatrixIndexT r = 0; r < num_rows; r++, this_data += this_stride) {
    MatrixIndexT index = indexes[r];
    KALDI_ASSERT(index >= -1 && index < src.NumRows());
    if (index != -1)
      cblas_Xaxpy(num_cols, alpha, src.RowData(index), 1, this_data, 1);
  }
}
#endif
#ifdef CLBAS
template<typename Real>
void MatrixBase<Real>::AddRows(Real alpha, const Real *const *src) {
  MatrixIndexT num_rows = num_rows_,
      num_cols = num_cols_, this_stride = stride_;
  Real *this_data = this->data_;

  for (MatrixIndexT r = 0; r < num_rows; r++, this_data += this_stride) {
    const Real *const src_data = src[r];
    if (src_data != NULL)
      cblas_Xaxpy(num_cols, alpha, src_data, 1, this_data, 1);
  }
}

template<typename Real>
void MatrixBase<Real>::AddToRows(Real alpha, Real *const *dst) const {
  MatrixIndexT num_rows = num_rows_,
      num_cols = num_cols_, this_stride = stride_;
  const Real *this_data = this->data_;

  for (MatrixIndexT r = 0; r < num_rows; r++, this_data += this_stride) {
    Real *const dst_data = dst[r];
    if (dst_data != NULL)
      cblas_Xaxpy(num_cols, alpha, this_data, 1, dst_data, 1);
  }
}
#endif

template<typename Real>
void MatrixBase<Real>::Sigmoid(const MatrixBase<Real> &src) {
  KALDI_ASSERT(SameDim(*this, src));

  if (num_cols_ == stride_ && src.num_cols_ == src.stride_) {
    SubVector<Real> src_vec(src.data_, num_rows_ * num_cols_),
        dst_vec(this->data_, num_rows_ * num_cols_);
    dst_vec.Sigmoid(src_vec);
  } else {
    for (MatrixIndexT r = 0; r < num_rows_; r++) {
      SubVector<Real> src_vec(src, r), dest_vec(*this, r);
      dest_vec.Sigmoid(src_vec);
    }
  }
}

template<typename Real>
void MatrixBase<Real>::DiffSigmoid(const MatrixBase<Real> &value,
                                   const MatrixBase<Real> &diff) {
  KALDI_ASSERT(SameDim(*this, value) && SameDim(*this, diff));
  MatrixIndexT num_rows = num_rows_, num_cols = num_cols_,
      stride = stride_, value_stride = value.stride_, diff_stride = diff.stride_;
  Real *data = data_;
  const Real *value_data = value.data_, *diff_data = diff.data_;
  for (MatrixIndexT r = 0; r < num_rows; r++) {
    for (MatrixIndexT c = 0; c < num_cols; c++)
      data[c] = diff_data[c] * value_data[c] * (1.0 - value_data[c]);
    data += stride;
    value_data += value_stride;
    diff_data += diff_stride;
  }
}

template<typename Real>
void MatrixBase<Real>::DiffTanh(const MatrixBase<Real> &value,
                                   const MatrixBase<Real> &diff) {
  KALDI_ASSERT(SameDim(*this, value) && SameDim(*this, diff));
  MatrixIndexT num_rows = num_rows_, num_cols = num_cols_,
      stride = stride_, value_stride = value.stride_, diff_stride = diff.stride_;
  Real *data = data_;
  const Real *value_data = value.data_, *diff_data = diff.data_;
  for (MatrixIndexT r = 0; r < num_rows; r++) {
    for (MatrixIndexT c = 0; c < num_cols; c++)
      data[c] = diff_data[c] * (1.0 - (value_data[c] * value_data[c]));
    data += stride;
    value_data += value_stride;
    diff_data += diff_stride;
  }
}




//Explicit instantiation of the classes
//Apparently, it seems to be necessary that the instantiation
//happens at the end of the file. Otherwise, not all the member
//functions will get instantiated.

template class Matrix<float>;
template class Matrix<double>;
template class MatrixBase<float>;
template class MatrixBase<double>;
template class SubMatrix<float>;
template class SubMatrix<double>;

} // namespace kaldi
