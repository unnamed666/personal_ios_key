// matrix/kaldi-vector.cc

// Copyright 2009-2011  Microsoft Corporation;  Lukas Burget;
//                      Saarland University;   Go Vivace Inc.;  Ariya Rastrow;
//                      Petr Schwarz;  Yanmin Qian;  Jan Silovsky;
//                      Haihua Xu; Wei Shi
//                2015  Guoguo Chen


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

#include <algorithm>
#include <string>
//#include "matrix/cblas-wrappers.h"
#include "matrix/kaldi-vector.h"
#include "matrix/kaldi-matrix.h"


namespace kaldi {
#ifdef CBLAS
template<typename Real>
Real VecVec(const VectorBase<Real> &a,
            const VectorBase<Real> &b) {
  MatrixIndexT adim = a.Dim();
  KALDI_ASSERT(adim == b.Dim());
  return cblas_Xdot(adim, a.Data(), 1, b.Data(), 1);
}
#endif



template<typename Real, typename OtherReal>
Real VecVec(const VectorBase<Real> &ra,
            const VectorBase<OtherReal> &rb) {
  MatrixIndexT adim = ra.Dim();
  KALDI_ASSERT(adim == rb.Dim());
  const Real *a_data = ra.Data();
  const OtherReal *b_data = rb.Data();
  Real sum = 0.0;
  for (MatrixIndexT i = 0; i < adim; i++)
    sum += a_data[i]*b_data[i];
  return sum;
}

// instantiate the template above.
template
float VecVec<>(const VectorBase<float> &ra,
               const VectorBase<double> &rb);
template
double VecVec<>(const VectorBase<double> &ra,
                const VectorBase<float> &rb);


/*
 template<>
template<>
void VectorBase<float>::AddVec(const float alpha,
                               const VectorBase<float> &v) {
  KALDI_ASSERT(dim_ == v.dim_);
  KALDI_ASSERT(&v != this);
  cblas_Xaxpy(dim_, alpha, v.Data(), 1, data_, 1);
}

template<>
template<>
void VectorBase<double>::AddVec(const double alpha,
                                const VectorBase<double> &v) {
  KALDI_ASSERT(dim_ == v.dim_);
  KALDI_ASSERT(&v != this);
  cblas_Xaxpy(dim_, alpha, v.Data(), 1, data_, 1);
}
 */


template<typename Real>
inline void Vector<Real>::Init(const MatrixIndexT dim) {
  KALDI_ASSERT(dim >= 0);
  if (dim == 0) {
    this->dim_ = 0;
    this->data_ = NULL;
    return;
  }
  MatrixIndexT size;
  void *data;
  void *free_data;

  size = dim * sizeof(Real);

  if ((data = KALDI_MEMALIGN(16, size, &free_data)) != NULL) {
    this->data_ = static_cast<Real*> (data);
    this->dim_ = dim;
  } else {
    throw std::bad_alloc();
  }
}


template<typename Real>
void Vector<Real>::Resize(const MatrixIndexT dim, MatrixResizeType resize_type) {

  // the next block uses recursion to handle what we have to do if
  // resize_type == kCopyData.
  if (resize_type == kCopyData) {
    if (this->data_ == NULL || dim == 0) resize_type = kSetZero;  // nothing to copy.
    else if (this->dim_ == dim) { return; } // nothing to do.
    else {
      // set tmp to a vector of the desired size.
      Vector<Real> tmp(dim, kUndefined);
      if (dim > this->dim_) {
        memcpy(tmp.data_, this->data_, sizeof(Real)*this->dim_);
        memset(tmp.data_+this->dim_, 0, sizeof(Real)*(dim-this->dim_));
      } else {
        memcpy(tmp.data_, this->data_, sizeof(Real)*dim);
      }
      tmp.Swap(this);
      // and now let tmp go out of scope, deleting what was in *this.
      return;
    }
  }
  // At this point, resize_type == kSetZero or kUndefined.

  if (this->data_ != NULL) {
    if (this->dim_ == dim) {
      if (resize_type == kSetZero) this->SetZero();
      return;
    } else {
      Destroy();
    }
  }
  Init(dim);
  if (resize_type == kSetZero) this->SetZero();
}


/// Copy data from another vector
template<typename Real>
void VectorBase<Real>::CopyFromVec(const VectorBase<Real> &v) {
  KALDI_ASSERT(Dim() == v.Dim());
  if (data_ != v.data_) {
    std::memcpy(this->data_, v.data_, dim_ * sizeof(Real));
  }
}
/// Load data into the vector
template<typename Real>
void VectorBase<Real>::CopyFromPtr(const Real *data, MatrixIndexT sz) {
  KALDI_ASSERT(dim_ == sz);
  std::memcpy(this->data_, data, Dim() * sizeof(Real));
}

template<typename Real>
template<typename OtherReal>
void VectorBase<Real>::CopyFromVec(const VectorBase<OtherReal> &other) {
  KALDI_ASSERT(dim_ == other.Dim());
  Real * __restrict__  ptr = data_;
  const OtherReal * __restrict__ other_ptr = other.Data();
  for (MatrixIndexT i = 0; i < dim_; i++)
    ptr[i] = other_ptr[i];
}

template void VectorBase<float>::CopyFromVec(const VectorBase<double> &other);
template void VectorBase<double>::CopyFromVec(const VectorBase<float> &other);

// Remove element from the vector. The vector is non reallocated
template<typename Real>
void Vector<Real>::RemoveElement(MatrixIndexT i) {
  KALDI_ASSERT(i <  this->dim_ && "Access out of vector");
  for (MatrixIndexT j = i + 1; j <  this->dim_; j++)
    this->data_[j-1] =  this->data_[j];
  this->dim_--;
}


/// Deallocates memory and sets object to empty vector.
template<typename Real>
void Vector<Real>::Destroy() {
  /// we need to free the data block if it was defined
  if (this->data_ != NULL)
    KALDI_MEMALIGN_FREE(this->data_);
  this->data_ = NULL;
  this->dim_ = 0;
}

template<typename Real>
void VectorBase<Real>::SetZero() {
  std::memset(data_, 0, dim_ * sizeof(Real));
}

template<typename Real>
bool VectorBase<Real>::IsZero(Real cutoff) const {
  Real abs_max = 0.0;
  for (MatrixIndexT i = 0; i < Dim(); i++)
    abs_max = std::max(std::abs(data_[i]), abs_max);
  return (abs_max <= cutoff);
}

template<typename Real>
void VectorBase<Real>::SetRandn() {
  kaldi::RandomState rstate;
  MatrixIndexT last = (Dim() % 2 == 1) ? Dim() - 1 : Dim();
  for (MatrixIndexT i = 0; i < last; i += 2) {
    kaldi::RandGauss2(data_ + i, data_ + i +1, &rstate);
  }
  if (Dim() != last) data_[last] = static_cast<Real>(kaldi::RandGauss(&rstate));
}

template<typename Real>
void VectorBase<Real>::SetRandUniform() {
  kaldi::RandomState rstate;
  for (MatrixIndexT i = 0; i < Dim(); i++) {
    *(data_+i) = RandUniform(&rstate);
  }
}

template<typename Real>
MatrixIndexT VectorBase<Real>::RandCategorical() const {
  kaldi::RandomState rstate;
  Real sum = this->Sum();
  KALDI_ASSERT(this->Min() >= 0.0 && sum > 0.0);
  Real r = RandUniform(&rstate) * sum;
  Real *data = this->data_;
  MatrixIndexT dim = this->dim_;
  Real running_sum = 0.0;
  for (MatrixIndexT i = 0; i < dim; i++) {
    running_sum += data[i];
    if (r < running_sum) return i;
  }
  return dim_ - 1; // Should only happen if RandUniform()
                   // returns exactly 1, or due to roundoff.
}

template<typename Real>
void VectorBase<Real>::Set(Real f) {
  // Why not use memset here?
  for (MatrixIndexT i = 0; i < dim_; i++) { data_[i] = f; }
}

template<typename Real>
void VectorBase<Real>::CopyRowsFromMat(const MatrixBase<Real> &mat) {
  KALDI_ASSERT(dim_ == mat.NumCols() * mat.NumRows());

  Real *inc_data = data_;
  const MatrixIndexT cols = mat.NumCols(), rows = mat.NumRows();

  if (mat.Stride() == mat.NumCols()) {
    memcpy(inc_data, mat.Data(), cols*rows*sizeof(Real));
  } else {
    for (MatrixIndexT i = 0; i < rows; i++) {
      // copy the data to the propper position
      memcpy(inc_data, mat.RowData(i), cols * sizeof(Real));
      // set new copy position
      inc_data += cols;
    }
  }
}

template<typename Real>
template<typename OtherReal>
void VectorBase<Real>::CopyRowsFromMat(const MatrixBase<OtherReal> &mat) {
  KALDI_ASSERT(dim_ == mat.NumCols() * mat.NumRows());
  Real *vec_data = data_;
  const MatrixIndexT cols = mat.NumCols(),
      rows = mat.NumRows();

  for (MatrixIndexT i = 0; i < rows; i++) {
    const OtherReal *mat_row = mat.RowData(i);
    for (MatrixIndexT j = 0; j < cols; j++) {
      vec_data[j] = static_cast<Real>(mat_row[j]);
    }
    vec_data += cols;
  }
}

template
void VectorBase<float>::CopyRowsFromMat(const MatrixBase<double> &mat);
template
void VectorBase<double>::CopyRowsFromMat(const MatrixBase<float> &mat);


template<typename Real>
void VectorBase<Real>::CopyColsFromMat(const MatrixBase<Real> &mat) {
  KALDI_ASSERT(dim_ == mat.NumCols() * mat.NumRows());

  Real*       inc_data = data_;
  const MatrixIndexT  cols     = mat.NumCols(), rows = mat.NumRows(), stride = mat.Stride();
  const Real *mat_inc_data = mat.Data();

  for (MatrixIndexT i = 0; i < cols; i++) {
    for (MatrixIndexT j = 0; j < rows; j++) {
      inc_data[j] = mat_inc_data[j*stride];
    }
    mat_inc_data++;
    inc_data += rows;
  }
}

template<typename Real>
void VectorBase<Real>::CopyRowFromMat(const MatrixBase<Real> &mat, MatrixIndexT row) {
  KALDI_ASSERT(row < mat.NumRows());
  KALDI_ASSERT(dim_ == mat.NumCols());
  const Real *mat_row = mat.RowData(row);
  memcpy(data_, mat_row, sizeof(Real)*dim_);
}

template<typename Real>
template<typename OtherReal>
void VectorBase<Real>::CopyRowFromMat(const MatrixBase<OtherReal> &mat, MatrixIndexT row) {
  KALDI_ASSERT(row < mat.NumRows());
  KALDI_ASSERT(dim_ == mat.NumCols());
  const OtherReal *mat_row = mat.RowData(row);
  for (MatrixIndexT i = 0; i < dim_; i++)
    data_[i] = static_cast<Real>(mat_row[i]);
}

template
void VectorBase<float>::CopyRowFromMat(const MatrixBase<double> &mat, MatrixIndexT row);
template
void VectorBase<double>::CopyRowFromMat(const MatrixBase<float> &mat, MatrixIndexT row);


#ifdef HAVE_MKL
template<>
void VectorBase<float>::ApplyPow(float power) { vsPowx(dim_, data_, power, data_); }
template<>
void VectorBase<double>::ApplyPow(double power) { vdPowx(dim_, data_, power, data_); }
#else
// takes elements to a power.  Throws exception if could not (but only for power != 1 and power != 2).
template<typename Real>
void VectorBase<Real>::ApplyPow(Real power) {
  if (power == 1.0) return;
  if (power == 2.0) {
    for (MatrixIndexT i = 0; i < dim_; i++)
      data_[i] = data_[i] * data_[i];
  } else if (power == 0.5) {
    for (MatrixIndexT i = 0; i < dim_; i++) {
      if (!(data_[i] >= 0.0))
        KALDI_ERR << "Cannot take square root of negative value "
                  << data_[i];
      data_[i] = std::sqrt(data_[i]);
    }
  } else {
    for (MatrixIndexT i = 0; i < dim_; i++) {
      data_[i] = pow(data_[i], power);
      if (data_[i] == HUGE_VAL) {  // HUGE_VAL is what errno returns on error.
        KALDI_ERR << "Could not raise element "  << i << " to power "
                  << power << ": returned value = " << data_[i];
      }
    }
  }
}
#endif

// takes absolute value of the elements to a power.
// Throws exception if could not (but only for power != 1 and power != 2).
template<typename Real>
void VectorBase<Real>::ApplyPowAbs(Real power, bool include_sign) {
  if (power == 1.0)
    for (MatrixIndexT i = 0; i < dim_; i++)
      data_[i] = (include_sign && data_[i] < 0 ? -1 : 1) * std::abs(data_[i]);
  if (power == 2.0) {
    for (MatrixIndexT i = 0; i < dim_; i++)
      data_[i] = (include_sign && data_[i] < 0 ? -1 : 1) * data_[i] * data_[i];
  } else if (power == 0.5) {
    for (MatrixIndexT i = 0; i < dim_; i++) {
      data_[i] = (include_sign && data_[i] < 0 ? -1 : 1) * std::sqrt(std::abs(data_[i]));
    }
  } else if (power < 0.0) {
    for (MatrixIndexT i = 0; i < dim_; i++) {
      data_[i] = (data_[i] == 0.0 ? 0.0 : pow(std::abs(data_[i]), power));
      data_[i] *= (include_sign && data_[i] < 0 ? -1 : 1);
      if (data_[i] == HUGE_VAL) {  // HUGE_VAL is what errno returns on error.
        KALDI_ERR << "Could not raise element "  << i << "to power "
                  << power << ": returned value = " << data_[i];
      }
    }
  } else {
    for (MatrixIndexT i = 0; i < dim_; i++) {
      data_[i] = (include_sign && data_[i] < 0 ? -1 : 1) * pow(std::abs(data_[i]), power);
      if (data_[i] == HUGE_VAL) {  // HUGE_VAL is what errno returns on error.
        KALDI_ERR << "Could not raise element "  << i << "to power "
                  << power << ": returned value = " << data_[i];
      }
    }
  }
}



template<typename Real>
Real VectorBase<Real>::Max() const {
  Real ans = - std::numeric_limits<Real>::infinity();
  const Real *data = data_;
  MatrixIndexT i, dim = dim_;
  for (i = 0; i + 4 <= dim; i += 4) {
    Real a1 = data[i], a2 = data[i+1], a3 = data[i+2], a4 = data[i+3];
    if (a1 > ans || a2 > ans || a3 > ans || a4 > ans) {
      Real b1 = (a1 > a2 ? a1 : a2), b2 = (a3 > a4 ? a3 : a4);
      if (b1 > ans) ans = b1;
      if (b2 > ans) ans = b2;
    }
  }
  for (; i < dim; i++)
    if (data[i] > ans) ans = data[i];
  return ans;
}

template<typename Real>
Real VectorBase<Real>::Max(MatrixIndexT *index_out) const {
  if (dim_ == 0) KALDI_ERR << "Empty vector";
  Real ans = - std::numeric_limits<Real>::infinity();
  MatrixIndexT index = 0;
  const Real *data = data_;
  MatrixIndexT i, dim = dim_;
  for (i = 0; i + 4 <= dim; i += 4) {
    Real a1 = data[i], a2 = data[i+1], a3 = data[i+2], a4 = data[i+3];
    if (a1 > ans || a2 > ans || a3 > ans || a4 > ans) {
      if (a1 > ans) { ans = a1; index = i; }
      if (a2 > ans) { ans = a2; index = i + 1; }
      if (a3 > ans) { ans = a3; index = i + 2; }
      if (a4 > ans) { ans = a4; index = i + 3; }
    }
  }
  for (; i < dim; i++)
    if (data[i] > ans) { ans = data[i]; index = i; }
  *index_out = index;
  return ans;
}

template<typename Real>
Real VectorBase<Real>::Min() const {
  Real ans = std::numeric_limits<Real>::infinity();
  const Real *data = data_;
  MatrixIndexT i, dim = dim_;
  for (i = 0; i + 4 <= dim; i += 4) {
    Real a1 = data[i], a2 = data[i+1], a3 = data[i+2], a4 = data[i+3];
    if (a1 < ans || a2 < ans || a3 < ans || a4 < ans) {
      Real b1 = (a1 < a2 ? a1 : a2), b2 = (a3 < a4 ? a3 : a4);
      if (b1 < ans) ans = b1;
      if (b2 < ans) ans = b2;
    }
  }
  for (; i < dim; i++)
    if (data[i] < ans) ans = data[i];
  return ans;
}

template<typename Real>
Real VectorBase<Real>::Min(MatrixIndexT *index_out) const {
  if (dim_ == 0) KALDI_ERR << "Empty vector";
  Real ans = std::numeric_limits<Real>::infinity();
  MatrixIndexT index = 0;
  const Real *data = data_;
  MatrixIndexT i, dim = dim_;
  for (i = 0; i + 4 <= dim; i += 4) {
    Real a1 = data[i], a2 = data[i+1], a3 = data[i+2], a4 = data[i+3];
    if (a1 < ans || a2 < ans || a3 < ans || a4 < ans) {
      if (a1 < ans) { ans = a1; index = i; }
      if (a2 < ans) { ans = a2; index = i + 1; }
      if (a3 < ans) { ans = a3; index = i + 2; }
      if (a4 < ans) { ans = a4; index = i + 3; }
    }
  }
  for (; i < dim; i++)
    if (data[i] < ans) { ans = data[i]; index = i; }
  *index_out = index;
  return ans;
}


template<typename Real>
template<typename OtherReal>
void VectorBase<Real>::CopyColFromMat(const MatrixBase<OtherReal> &mat, MatrixIndexT col) {
  KALDI_ASSERT(col < mat.NumCols());
  KALDI_ASSERT(dim_ == mat.NumRows());
  for (MatrixIndexT i = 0; i < dim_; i++)
    data_[i] = mat(i, col);
  // can't do this very efficiently so don't really bother. could improve this though.
}
// instantiate the template above.
template
void VectorBase<float>::CopyColFromMat(const MatrixBase<float> &mat, MatrixIndexT col);
template
void VectorBase<float>::CopyColFromMat(const MatrixBase<double> &mat, MatrixIndexT col);
template
void VectorBase<double>::CopyColFromMat(const MatrixBase<float> &mat, MatrixIndexT col);
template
void VectorBase<double>::CopyColFromMat(const MatrixBase<double> &mat, MatrixIndexT col);


template<typename Real>
Real VectorBase<Real>::Sum() const {
  double sum = 0.0;
  for (MatrixIndexT i = 0; i < dim_; i++) { sum += data_[i]; }
  return sum;
}

template<typename Real>
Real VectorBase<Real>::SumLog() const {
  double sum_log = 0.0;
  double prod = 1.0;
  for (MatrixIndexT i = 0; i < dim_; i++) {
    prod *= data_[i];
    // Possible future work (arnab): change these magic values to pre-defined
    // constants
    if (prod < 1.0e-10 || prod > 1.0e+10) {
      sum_log += Log(prod);
      prod = 1.0;
    }
  }
  if (prod != 1.0) sum_log += Log(prod);
  return sum_log;
}


template<typename Real>
Real VectorBase<Real>::LogSumExp(Real prune) const {
  Real sum;
  if (sizeof(sum) == 8) sum = kLogZeroDouble;
  else sum = kLogZeroFloat;
  Real max_elem = Max(), cutoff;
  if (sizeof(Real) == 4) cutoff = max_elem + kMinLogDiffFloat;
  else cutoff = max_elem + kMinLogDiffDouble;
  if (prune > 0.0 && max_elem - prune > cutoff) // explicit pruning...
    cutoff = max_elem - prune;

  double sum_relto_max_elem = 0.0;

  for (MatrixIndexT i = 0; i < dim_; i++) {
    BaseFloat f = data_[i];
    if (f >= cutoff)
      sum_relto_max_elem += Exp(f - max_elem);
  }
  return max_elem + Log(sum_relto_max_elem);
}

template<typename Real>
void VectorBase<Real>::InvertElements() {
  for (MatrixIndexT i = 0; i < dim_; i++) {
    data_[i] = static_cast<Real>(1 / data_[i]);
  }
}

template<typename Real>
void VectorBase<Real>::ApplyLog() {
  for (MatrixIndexT i = 0; i < dim_; i++) {
    if (data_[i] < 0.0)
      KALDI_ERR << "Trying to take log of a negative number.";
    data_[i] = Log(data_[i]);
  }
}

template<typename Real>
void VectorBase<Real>::Dump() {
  for (MatrixIndexT i = 0; i < dim_; i++) {
    std::cout<<data_[i]<<"\t";
  }
}

template<typename Real>
void VectorBase<Real>::ApplyLogAndCopy(const VectorBase<Real> &v) {
  KALDI_ASSERT(dim_ == v.Dim());
  for (MatrixIndexT i = 0; i < dim_; i++) {
    data_[i] = Log(v(i));
  }
}

template<typename Real>
void VectorBase<Real>::ApplyExp() {
  for (MatrixIndexT i = 0; i < dim_; i++) {
    data_[i] = Exp(data_[i]);
  }
}

template<typename Real>
void VectorBase<Real>::ApplyAbs() {
  for (MatrixIndexT i = 0; i < dim_; i++) { data_[i] = std::abs(data_[i]); }
}

template<typename Real>
MatrixIndexT VectorBase<Real>::ApplyFloor(Real floor_val) {
  MatrixIndexT num_floored = 0;
  for (MatrixIndexT i = 0; i < dim_; i++) {
    if (data_[i] < floor_val) {
      data_[i] = floor_val;
      num_floored++;
    }
  }
  return num_floored;
}

template<typename Real>
MatrixIndexT VectorBase<Real>::ApplyCeiling(Real ceil_val) {
  MatrixIndexT num_changed = 0;
  for (MatrixIndexT i = 0; i < dim_; i++) {
    if (data_[i] > ceil_val) {
      data_[i] = ceil_val;
      num_changed++;
    }
  }
  return num_changed;
}


template<typename Real>
MatrixIndexT VectorBase<Real>::ApplyFloor(const VectorBase<Real> &floor_vec) {
  KALDI_ASSERT(floor_vec.Dim() == dim_);
  MatrixIndexT num_floored = 0;
  for (MatrixIndexT i = 0; i < dim_; i++) {
    if (data_[i] < floor_vec(i)) {
      data_[i] = floor_vec(i);
      num_floored++;
    }
  }
  return num_floored;
}

template<typename Real>
Real VectorBase<Real>::ApplySoftMax() {
  Real max = this->Max(), sum = 0.0;
  for (MatrixIndexT i = 0; i < dim_; i++) {
    sum += (data_[i] = Exp(data_[i] - max));
  }
  std::cout<<"notice........................................"<<std::endl;
  //this->Scale(1.0 / sum);
  return max + Log(sum);
}

template<typename Real>
Real VectorBase<Real>::ApplyLogSoftMax() {
  Real max = this->Max(), sum = 0.0;
  for (MatrixIndexT i = 0; i < dim_; i++) {
    sum += Exp((data_[i] -= max));
  }
  sum = Log(sum);
  this->Add(-1.0 * sum);
  return max + sum;
}

#ifdef HAVE_MKL
template<>
void VectorBase<float>::Tanh(const VectorBase<float> &src) {
  KALDI_ASSERT(dim_ == src.dim_);
  vsTanh(dim_, src.data_, data_);
}
template<>
void VectorBase<double>::Tanh(const VectorBase<double> &src) {
  KALDI_ASSERT(dim_ == src.dim_);
  vdTanh(dim_, src.data_, data_);
}
#else
template<typename Real>
void VectorBase<Real>::Tanh(const VectorBase<Real> &src) {
  KALDI_ASSERT(dim_ == src.dim_);
  for (MatrixIndexT i = 0; i < dim_; i++) {
    Real x = src.data_[i];
    if (x > 0.0) {
      Real inv_expx = Exp(-x);
      x = -1.0 + 2.0 / (1.0 + inv_expx * inv_expx);
    } else {
      Real expx = Exp(x);
      x = 1.0 - 2.0 / (1.0 + expx * expx);
    }
    data_[i] = x;
  }
}
#endif

#ifdef HAVE_MKL
// Implementing sigmoid based on tanh.
template<>
void VectorBase<float>::Sigmoid(const VectorBase<float> &src) {
  KALDI_ASSERT(dim_ == src.dim_);
  this->CopyFromVec(src);
  this->Scale(0.5);
  vsTanh(dim_, data_, data_);
  this->Add(1.0);
  this->Scale(0.5);
}
template<>
void VectorBase<double>::Sigmoid(const VectorBase<double> &src) {
  KALDI_ASSERT(dim_ == src.dim_);
  this->CopyFromVec(src);
  this->Scale(0.5);
  vdTanh(dim_, data_, data_);
  this->Add(1.0);
  this->Scale(0.5);
}
#else
template<typename Real>
void VectorBase<Real>::Sigmoid(const VectorBase<Real> &src) {
  KALDI_ASSERT(dim_ == src.dim_);
  for (MatrixIndexT i = 0; i < dim_; i++) {
    Real x = src.data_[i];
    // We aim to avoid floating-point overflow here.
    if (x > 0.0) {
      x = 1.0 / (1.0 + Exp(-x));
    } else {
      Real ex = Exp(x);
      x = ex / (ex + 1.0);
    }
    data_[i] = x;
  }
}
#endif


template<typename Real>
void VectorBase<Real>::Add(Real c) {
  for (MatrixIndexT i = 0; i < dim_; i++) {
    data_[i] += c;
  }
}

template<typename Real>
void VectorBase<Real>::MulElements(const VectorBase<Real> &v) {
  KALDI_ASSERT(dim_ == v.dim_);
  for (MatrixIndexT i = 0; i < dim_; i++) {
    data_[i] *= v.data_[i];
  }
}

template<typename Real>  // Set each element to y = (x == orig ? changed : x).
void VectorBase<Real>::ReplaceValue(Real orig, Real changed) {
  Real *data = data_;
  for (MatrixIndexT i = 0; i < dim_; i++)
    if (data[i] == orig) data[i] = changed;
}


template<typename Real>
template<typename OtherReal>
void VectorBase<Real>::MulElements(const VectorBase<OtherReal> &v) {
  KALDI_ASSERT(dim_ == v.Dim());
  const OtherReal *other_ptr = v.Data();
  for (MatrixIndexT i = 0; i < dim_; i++) {
    data_[i] *= other_ptr[i];
  }
}
// instantiate template.
template
void VectorBase<float>::MulElements(const VectorBase<double> &v);
template
void VectorBase<double>::MulElements(const VectorBase<float> &v);




template<typename Real>
void VectorBase<Real>::DivElements(const VectorBase<Real> &v) {
  KALDI_ASSERT(dim_ == v.dim_);
  for (MatrixIndexT i = 0; i < dim_; i++) {
    data_[i] /= v.data_[i];
  }
}

template<typename Real>
template<typename OtherReal>
void VectorBase<Real>::DivElements(const VectorBase<OtherReal> &v) {
  KALDI_ASSERT(dim_ == v.Dim());
  const OtherReal *other_ptr = v.Data();
  for (MatrixIndexT i = 0; i < dim_; i++) {
    data_[i] /= other_ptr[i];
  }
}
// instantiate template.
template
void VectorBase<float>::DivElements(const VectorBase<double> &v);
template
void VectorBase<double>::DivElements(const VectorBase<float> &v);

template<typename Real>
void VectorBase<Real>::AddVecDivVec(Real alpha, const VectorBase<Real> &v,
                                    const VectorBase<Real> &rr, Real beta) {
  KALDI_ASSERT((dim_ == v.dim_ && dim_ == rr.dim_));
  for (MatrixIndexT i = 0; i < dim_; i++) {
    data_[i] = alpha * v.data_[i]/rr.data_[i] + beta * data_[i] ;
  }
}

template<typename Real>
template<typename OtherReal>
void VectorBase<Real>::AddVec(const Real alpha, const VectorBase<OtherReal> &v) {
  KALDI_ASSERT(dim_ == v.dim_);
  // remove __restrict__ if it causes compilation problems.
  Real *__restrict__ data = data_;
  OtherReal *__restrict__ other_data = v.data_;
  MatrixIndexT dim = dim_;
  if (alpha != 1.0)
    for (MatrixIndexT i = 0; i < dim; i++)
      data[i] += alpha * other_data[i];
  else
    for (MatrixIndexT i = 0; i < dim; i++)
      data[i] += other_data[i];
}

template
void VectorBase<float>::AddVec(const float alpha, const VectorBase<double> &v);
template
void VectorBase<double>::AddVec(const double alpha, const VectorBase<float> &v);

template<typename Real>
template<typename OtherReal>
void VectorBase<Real>::AddVec2(const Real alpha, const VectorBase<OtherReal> &v) {
  KALDI_ASSERT(dim_ == v.dim_);
  // remove __restrict__ if it causes compilation problems.
  Real *__restrict__ data = data_;
  OtherReal *__restrict__ other_data = v.data_;
  MatrixIndexT dim = dim_;
  if (alpha != 1.0)
    for (MatrixIndexT i = 0; i < dim; i++)
      data[i] += alpha * other_data[i] * other_data[i];
  else
    for (MatrixIndexT i = 0; i < dim; i++)
      data[i] += other_data[i] * other_data[i];
}

template
void VectorBase<float>::AddVec2(const float alpha, const VectorBase<double> &v);
template
void VectorBase<double>::AddVec2(const double alpha, const VectorBase<float> &v);

template<typename Real>
void VectorBase<Real>::AddVec2(const Real alpha, const VectorBase<Real> &v) {
  KALDI_ASSERT(dim_ == v.dim_);
  for (MatrixIndexT i = 0; i < dim_; i++)
    data_[i] += alpha * v.data_[i] * v.data_[i];
}




template<typename Real>
void Vector<Real>::Swap(Vector<Real> *other) {
  std::swap(this->data_, other->data_);
  std::swap(this->dim_, other->dim_);
}

#ifdef CBLAS
template<typename Real>
void VectorBase<Real>::AddDiagMat2(
    Real alpha, const MatrixBase<Real> &M,
    MatrixTransposeType trans, Real beta) {
  if (trans == kNoTrans) {
    KALDI_ASSERT(this->dim_ == M.NumRows());
    MatrixIndexT rows = this->dim_, cols = M.NumCols(),
           mat_stride = M.Stride();
    Real *data = this->data_;
    const Real *mat_data = M.Data();
    for (MatrixIndexT i = 0; i < rows; i++, mat_data += mat_stride, data++)
      *data = beta * *data + alpha * cblas_Xdot(cols,mat_data,1,mat_data,1);
  } else {
    KALDI_ASSERT(this->dim_ == M.NumCols());
    MatrixIndexT rows = M.NumRows(), cols = this->dim_,
           mat_stride = M.Stride();
    Real *data = this->data_;
    const Real *mat_data = M.Data();
    for (MatrixIndexT i = 0; i < cols; i++, mat_data++, data++)
      *data = beta * *data + alpha * cblas_Xdot(rows, mat_data, mat_stride,
                                                 mat_data, mat_stride);
  }
}
#endif




template class Vector<float>;
template class Vector<double>;
template class VectorBase<float>;
template class VectorBase<double>;

}  // namespace kaldi
